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

import com.hpl.erk.chain.Chain;
import com.hpl.erk.coroutines.ChainedCoroutine;
import com.hpl.erk.func.Pair;


public abstract class ForkLink<Head, In, OutK, OutV> extends
		KeyValChain<Head, OutK, OutV> {
  
	public ForkLink(Chain<Head, ? extends In> pred) {
		super(pred.complete);
		this.pred = pred;
	}

	protected Chain<Head, ? extends In> pred;

  /**
   * Called after a link is constructed.  Here is where an eager link does its 
   * magic if it's complete.  We can't do it in the constructor, since we aren't
   * fully constructed at EagerLink's constructor.
   * @return
   */
  public void activate() {
  }
  
  public abstract class LinkCoroutine extends ChainedCoroutine<In, Pair<? extends OutK, ? extends OutV>> {
    public LinkCoroutine() {
      super(pred.iterator());
    }
  }



  public abstract class Context extends KeyValChain<Head,OutK,OutV>.Context {
    protected final Chain<Head,? extends In>.Context source;
    public Context(Chain<Head, ? extends In>.Context source) {
		super();
		this.source = source;
	}
	protected Context() {
      this(pred.createContext());
    }
    
  }
  
  public abstract Context createContext();

  @Override
  public <H, T extends Head> KeyValChain<H, OutK,OutV> prepend(Chain<H, T> chain) {
    @SuppressWarnings("unchecked")
    ForkLink<H, In, OutK, OutV> clone = (ForkLink<H, In, OutK,OutV>)clone();
    clone.complete = chain.complete;
    clone.pred = pred.prepend(chain);
    clone.activate();
    return clone;
  }
  
  @Override
  protected ForkLink<Head,In,OutK,OutV> clone() {
    try {
      @SuppressWarnings("unchecked")
      final ForkLink<Head, In, OutK, OutV> clone = (ForkLink<Head, In, OutK, OutV>)super.clone();
      return clone;
    } catch (CloneNotSupportedException e) {
      return null;
    }
  }

}
