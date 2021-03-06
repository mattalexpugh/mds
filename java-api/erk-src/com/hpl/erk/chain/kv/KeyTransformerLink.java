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

package com.hpl.erk.chain.kv;

import com.hpl.erk.chain.Flow;
import com.hpl.erk.func.NullaryFunc;
import com.hpl.erk.func.Pair;
import com.hpl.erk.func.SourceExhausted;
import com.hpl.erk.func.UnaryFunc;

public class KeyTransformerLink<Head, InK, OutK, V> extends KeyValLink<Head, InK, V, OutK, V> {
  protected final NullaryFunc<? extends UnaryFunc<? super InK, ? extends OutK>> creator; 

  protected KeyTransformerLink(KeyValChain<Head, ? extends InK, ? extends V> pred,
                               NullaryFunc<? extends UnaryFunc<? super InK, ? extends OutK>> creator) 
  {
    super(pred);
    this.creator = creator;
  }

  @Override
  public int expectedSize() {
    return pred.expectedSize();
  }
  
  @Override
  public Flow pipeInto(final Receiver<? super OutK, ? super V> sink) {
    return pred.pipeInto(new ChainedReceiver<InK, V, OutK, V>(sink) {
      protected final UnaryFunc<? super InK, ? extends OutK> transformer = creator.call();

      @Override
      public boolean receive(InK key, V value) {
        return sink.receive(transformer.call(key), value);
      }});
  }



  @Override
  public Context createContext() {
    return new Context() {
      protected final UnaryFunc<? super InK, ? extends OutK> transformer = creator.call();

      @Override
      public Pair<OutK,V> produce() throws SourceExhausted {
        Pair<? extends InK, ? extends V> elt = source.produce();
        return new Pair<OutK,V>(transformer.call(elt.key), elt.value);
      }
    };
  }
 }
