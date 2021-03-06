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

package com.hpl.erk.impl_helper;

import java.util.Collection;
import java.util.Random;

public final class HashCode {
  private enum UpdateMethod {
    MASH {
      @Override
      long update(long accum, long n, int nBytes) {
        for (int i=0; i<nBytes; i++, n>>>=8) {
          int lob = (int)(n & 0xFF);
          long mapped = MAP[lob];
          final long alob = accum & 1;
          accum = ((accum >>> 1) ^ (alob<<63)) + mapped;
        }
        return accum;
      }
    },
    LinearCongruent {
      final static long multiplier = 0x5DEECE66DL;
      final static long addend = 0xBL;
      final static long mask = (1L<<48)-1;

      @Override
      long update(long accum, long n, int nBytes) {
        long state = accum;
        state = (state * multiplier + addend) & mask;
        long high = state >>> 16;
        state = (state * multiplier + addend) & mask;
        long low = state >>> 16;
        accum = ((high << 32) | low) + n;
        return accum;
      }
    };
    abstract long update(long accum, long n, int nBytes);
  }
  
  protected static long NULL_VALUE;
  protected static long EMPTY_VALUE;
  protected static long TRUE_VALUE;
  protected static long FALSE_VALUE;
  protected static long[] MAP = null;
  static {
    setUp("erk.HashCode");
  }
  
  protected long accum = 0;
  protected final UpdateMethod updateMethod;
  
  private HashCode(UpdateMethod updateMethod) {
    this.updateMethod = updateMethod;
  }
  
  public static HashCode simple() {
    return new HashCode(UpdateMethod.LinearCongruent);
  }
  public static HashCode uniform() {
    return new HashCode(UpdateMethod.MASH);
  }
  
  public static HashCode simple(Class<?> clss) {
    return simple().include(clss);
  }
  public static HashCode uniform(Class<?> clss) {
    return uniform().include(clss);
  }
  
  public long asLong() {
    return accum;
  }
  public final int asInt() {
    return (int)(accum ^ (accum >>> 32));
  }
  
  public final int value() {
    return asInt();
  }
  
  
  public HashCode include(long n) {
    return update(n, 8);
  }
  public HashCode include(int n) {
    return update(n & 0xFFFF_FFFF, 4);
  }
  public HashCode include(short n) {
    return update(n & 0xFFFF, 2);
  }
  public HashCode include(char n) {
    return update(n & 0xFFFF, 2);
  }
  public HashCode include(byte n) {
    return update(n & 0xFF, 1);
  }
  public HashCode include(boolean b) {
    return include(b ? TRUE_VALUE : FALSE_VALUE);
  }
  public HashCode include(double n) {
    return include(Double.doubleToRawLongBits(n));
  }
  public HashCode include(float n) {
    return include(Float.floatToIntBits(n));
  }
  public HashCode include(HashCodeAware obj) {
    obj.addTo(this);
    return this;
  }
  
  public HashCode include(Object obj) {
    if (obj == null) {
      return include(NULL_VALUE);
    } else if (obj instanceof HashCodeAware) {
      return include((HashCodeAware)obj);
    } else {
      return include(obj.hashCode());
    }
  }
  
  public HashCode includeIdentity(Object obj) {
    return include(System.identityHashCode(obj));
  }
  
  public HashCode includeTimestamp() {
    return include(System.nanoTime());
  }

  public HashCode includeNonNull(HashCodeAware obj) {
    if (obj != null) {
      return include(obj);
    }
    return this;
  }
  public HashCode includeNonNull(Object obj) {
    if (obj != null) {
        return include(obj);
    }
    return this;
  }
  
  public HashCode includeContents(CharSequence s) {
    if (s == null) {
      return include(NULL_VALUE);
    }
    int n = s.length();
    if (n == 0) {
      return include(EMPTY_VALUE);
    }
    for (int i=0; i<n; i++) {
      include(s.charAt(i));
    }
    return this;
  }
  public <T> HashCode includeContents(Collection<T> collection) {
    if (collection == null) {
      return include(NULL_VALUE);
    }
    if (collection.size() == 0) {
      return include(EMPTY_VALUE);
    }
    for (T elt : collection) {
      include(elt);
    }
    return this;
  }
  public <T> HashCode includeContents(T[] array) {
    if (array == null) {
      return include(NULL_VALUE);
    }
    if (array.length == 0) {
      return include(EMPTY_VALUE);
    }
    for (T elt : array) {
      include(elt);
    }
    return this;
  }
  public HashCode includeContents(long[] array) {
    if (array == null) {
      return include(NULL_VALUE);
    }
    if (array.length == 0) {
      return include(EMPTY_VALUE);
    }
    for (long elt : array) {
      include(elt);
    }
    return this;
  }
  public HashCode includeContents(int[] array) {
    if (array == null) {
      return include(NULL_VALUE);
    }
    if (array.length == 0) {
      return include(EMPTY_VALUE);
    }
    for (int elt : array) {
      include(elt);
    }
    return this;
  }
  public HashCode includeContents(short[] array) {
    if (array == null) {
      return include(NULL_VALUE);
    }
    if (array.length == 0) {
      return include(EMPTY_VALUE);
    }
    for (short elt : array) {
      include(elt);
    }
    return this;
  }
  public HashCode includeContents(char[] array) {
    if (array == null) {
      return include(NULL_VALUE);
    }
    if (array.length == 0) {
      return include(EMPTY_VALUE);
    }
    for (char elt : array) {
      include(elt);
    }
    return this;
  }
  public HashCode includeContents(byte[] array) {
    if (array == null) {
      return include(NULL_VALUE);
    }
    if (array.length == 0) {
      return include(EMPTY_VALUE);
    }
    for (byte elt : array) {
      include(elt);
    }
    return this;
  }
  public HashCode includeContents(boolean[] array) {
    if (array == null) {
      return include(NULL_VALUE);
    }
    if (array.length == 0) {
      return include(EMPTY_VALUE);
    }
    for (boolean elt : array) {
      include(elt);
    }
    return this;
  }
  
  
  
  
  private HashCode update(long n, int nBytes) {
    accum = updateMethod.update(accum, n, nBytes);
    return this;
  }
  
  

  private static void setUp(String key) {
    Random rnd = new Random(key.hashCode());
    NULL_VALUE = rnd.nextLong();
    EMPTY_VALUE = rnd.nextLong();
    TRUE_VALUE = rnd.nextLong();
    FALSE_VALUE = rnd.nextLong();
    final int n = 1<<Byte.SIZE;
    MAP = new long[n];
    for (int i=0; i<n; i++) {
      MAP[i] = rnd.nextLong();
    }
  }
}
