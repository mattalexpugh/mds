/*
 *
 *  Managed Data Structures
 *  Copyright © 2016 Hewlett Packard Enterprise Development Company LP.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  As an exception, the copyright holders of this Library grant you permission
 *  to (i) compile an Application with the Library, and (ii) distribute the 
 *  Application containing code generated by the Library and added to the 
 *  Application during this compilation process under terms of your choice, 
 *  provided you also meet the terms and conditions of the Application license.
 *
 */

package com.hpl.erk.types;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.lang.reflect.TypeVariable;
import java.util.Arrays;
import java.util.HashMap;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;

import com.hpl.erk.formatters.SeqFormatter;
import com.hpl.erk.func.Functions;
import com.hpl.erk.func.Pair;
import com.hpl.erk.types.templates.PTypeTempl;
import com.hpl.erk.types.templates.TemplateVar;
import com.hpl.erk.types.templates.Templates;
import com.hpl.erk.types.templates.TypeTemplate;

public class GenericTypeToken implements TypeDeclToken {
  private static final Map<Class<?>, GenericTypeToken> known = new HashMap<>();
  private static final Map<Pair<GenericTypeToken,TypeToken>, ParameterizedTypeToken> subtypes = new HashMap<>();

  private final Class<?> rawClass;
  private final TypeVariable<?>[] vars;
  private Map<ParameterizedTypeToken, ParameterizedTypeToken> instances;
  private ParameterizedTypeToken rawToken = null;
  private Map<Class<?>, TypeTemplate> ancestors = null;

  protected GenericTypeToken(Class<?> rawClass) {
    this.rawClass = rawClass;
    this.vars = rawClass.getTypeParameters();
    if (vars.length == 0) {
      throw new IllegalArgumentException(String.format("Not a generic class: %s", rawClass));
    }
  }
  
  static final Object inFind = new Object();
  protected static GenericTypeToken find(Class<?> raw) {
    synchronized (inFind) {
      GenericTypeToken g = known.get(raw);
      if (g == null) {
        g = new GenericTypeToken(raw);
        known.put(raw, g);
      }
      return g;
    }
  }

  public int arity() {
    return vars.length;
  }
  
  public Class<?> rawClass() {
    return rawClass;
  }
  
  public ParameterizedTypeToken bind(TypeBound ...bounds) {
    return bind(true, bounds);
  }
  
  public ParameterizedTypeToken bindUnchecked(TypeBound ...bounds) {
    return bind(false, bounds);
  }
  
  synchronized public ParameterizedTypeToken bind(boolean check, TypeBound ...bounds) {
    if (bounds.length != vars.length) {
      throw new IllegalArgumentException(String.format("Wrong number of arguments (%,d) to %s", bounds.length, this));
    }
    if (instances == null) {
      instances = new HashMap<>();
    }
    ParameterizedTypeToken token = new ParameterizedTypeToken(this, bounds);
    ParameterizedTypeToken old = instances.get(token);
    if (old != null) {
      return old;
    }
    
    if (check) {
      if (!checkBounds(token, bounds)) {
        throw new IllegalArgumentException(String.format("%s not acceptable parameterization for %s", token, this));
      }
    }
    instances.put(token, token);
    return token;
  }
  
  public boolean checkBounds(TypeBound...bounds) {
    ParameterizedTypeToken token = new ParameterizedTypeToken(this, bounds);
    return checkBounds(token, bounds);
  }

  private static final TypeBound isEnum = TypeToken.below(TypeToken.generic(Enum.class).raw());
  public boolean checkBounds(ParameterizedTypeToken token, TypeBound... bounds) {
    if (bounds.length != vars.length) {
      return false;
    }
    /*
     * The problem here is that the declaration is Enum<E extends Enum<E>>, so we go
     * into an infinite loop.  
     * TODO: This probably occurs elsewhere.  Generalize it.
     */
    if (rawClass == Enum.class) {
      return isEnum.satisfiedBy(bounds[0]);
    }
    for (int i = 0; i<vars.length; i++) {
      TypeVariable<?> v = vars[i];
      TypeBound actual = bounds[i];
      TypeBound[] uppers = token.toBounds(v.getBounds());
      TypeBound range = TypeRange.between(TypeRange.NO_BOUND, uppers);
      if (!range.satisfiedBy(actual)) {
        return false;
      }
    }
    return true;
  }
  
  synchronized public ParameterizedTypeToken raw() {
    if (rawToken == null) {
      int n = arity();
      TypeBound[] bounds = new TypeBound[n];
      Arrays.fill(bounds, TypeRange.WILDCARD);
      rawToken = new ParameterizedTypeToken(this, bounds);
    }
    return rawToken;
  }
  
  public ParameterizedTypeToken asSubtypeOf(TypeToken token) {
    final Class<?> c = token.rawClass();
    if (!c.isAssignableFrom(rawClass)) {
      return null;
    }
    if (token instanceof ParameterizedTypeToken) {
      ParameterizedTypeToken pt = (ParameterizedTypeToken)token;
      if (pt.generic == this) {
        return pt;
      }
      
    } else if (token instanceof SimpleTypeToken) {
      // if a non-generic parent is descended from it, any parameterization will work
      return raw();
    }
    final Pair<GenericTypeToken, TypeToken> key = Functions.pair(this, token);
    ParameterizedTypeToken subtype = subtypes.get(key);
    if (subtype == null) {
      TypeTemplate ancestor = ancestors.get(c);
      if (ancestor == null) {
        return null;
      }
      TypeBound[] bounds = new TypeBound[vars.length];
      Arrays.fill(bounds, TypeRange.WILDCARD);
      ancestor.inferBounds(token, bounds);
      subtype = bind(bounds);
      subtypes.put(key, subtype);
    }
    return subtype;
  }
  
  @Override
  public String toString() {
    SeqFormatter<String> sf = SeqFormatter.angleBracketList();
    for (TypeVariable<?> v : vars) {
      Type[] bounds = v.getBounds();
      SeqFormatter<Type> bf = SeqFormatter.<Type>withSep(" & ").open(" extends ").empty("");
      for (Type bound : bounds) {
        if (bound != Object.class) {
          bf.add(bound);
        }
      }
      sf.addFormatted("%s%s", v.getName(), bf);
    }
    return String.format("%s%s", rawClass.getSimpleName(), sf);
  }

  public TypeBound varVal(TypeVariable<?> var, TypeBound[] actuals) {
    for (int i=0; i<vars.length; i++) {
      if (vars[i] == var) {
        return actuals[i];
      }
    }
    throw new IllegalArgumentException(String.format("%s doesn't have variable %s", this, var));
  }
  
  protected void addParent(Type parentType, List<TypeToken> nonGenerics, Map<GenericTypeToken, Type[]> generics) {
    if (parentType == null) {
      return;
    }
    if (parentType instanceof Class) {
      Class<?> cp = (Class<?>)parentType;
      TypeToken token = TypeToken.find(cp);
      nonGenerics.add(token);
    } else if (parentType instanceof ParameterizedType) {
      ParameterizedType ptype = (ParameterizedType)parentType;
      Class<?> tRaw = (Class<?>)ptype.getRawType();
      GenericTypeToken gp = GenericTypeToken.find(tRaw);
      Type[] params = ptype.getActualTypeArguments();
      generics.put(gp, params);
    }
{
      // todo
    }
  }

  public void fillAncestors(Map<Class<?>, TypeTemplate> map, TypeTemplate[] params) {
    fillAncestors(rawClass.getGenericSuperclass(), map, params);
    for (Type iface : rawClass.getGenericInterfaces()) {
      fillAncestors(iface, map, params);
    }
  }

  private void fillAncestors(Type parent, Map<Class<?>, TypeTemplate> map, TypeTemplate[] params) {
    if (parent != null) {
      TypeTemplate template = Templates.from(parent, vars, params);
      template.fillAncestors(map);
    } else {
      TypeToken.OBJECT.fillAncestors(map);
    }
  }
  
  public Map<Class<?>, TypeTemplate> ancestors() {
    if (ancestors == null) {
      ancestors = new IdentityHashMap<>();
      TypeTemplate self = new PTypeTempl(this, TemplateVar.array(arity()));
      self.fillAncestors(ancestors);
    }
    return ancestors;
  }
  

}
