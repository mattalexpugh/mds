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

import java.util.Map;

import com.hpl.erk.chain.Flow;
import com.hpl.erk.func.SourceExhausted;

public class MapSink<Head, K, V, M extends Map<? super K, ? super V>>
		extends JoinLink<Head, K, V, M>
{
  protected final M map;
  
  protected MapSink(KeyValChain<Head, ? extends K, ? extends V> pred, M map) {
    super(pred);
    this.map = map;
  }

  public M val() {
    return map;
  }
  
  @Override
  public Flow pipeInto(final Receiver<? super M> sink) {
    return new Flow() {
      @Override
      public void perform() {
        if (sink.receive(map)) {
          sink.close();
        }
      }
    };
  }
  

  @Override
  public Context createContext() {
    return new Context() {
      boolean handedOut = false;
      @Override
      public M produce() throws SourceExhausted {
        exhaustedIf(handedOut);
        handedOut = true;
        return map;
      }
    };
  }
  
  @Override
  public void activate() {
    if (complete) {
      pred.fill(new KeyValChain.FinalReceiver<K, V>() {
        @Override
        public boolean receive(K key, V value) {
          map.put(key, value);
          return true;
        }});
//      super.activate();
//      KeyValChain<?,? extends K, ? extends V>.Context source = pred.createContext();
//      for (Pair<? extends K, ? extends V> elt : source) {
//        map.put(elt.key, elt.value);
//      }
    }
  }

}
