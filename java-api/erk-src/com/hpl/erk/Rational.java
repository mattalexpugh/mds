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

package com.hpl.erk;

import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

import com.hpl.erk.impl_helper.HashCode;

public class Rational extends Number implements Comparable<Rational> {
  private static final long serialVersionUID = 7052294903867119700L;
  private static final AtomicLong defaultMaxDenom = new AtomicLong(1000);
  @SuppressWarnings("unused")
  private static final AtomicInteger defaultMaxBinPower = new AtomicInteger(10);
  private final long num;
  private final long denom;

  public Rational(long num, long denom) {
    long gcd = denom == 1 ? 1 : gcd(num, denom);
    this.num = num/gcd;
    this.denom = denom/gcd;
  }
  
  public Rational(long n) {
    this(n, 1);    
  }
  
  public static Rational fromDouble(double d, long maxDenom) {
    boolean neg = d < 0;
    if (neg) {
      d = -d;
    }
    double whole = Math.floor(d);
    d -= whole;
    if (d == 0) {
      final long num = (long)(neg ? -whole : whole);
      return new Rational(num, 1);
    }
    boolean overHalf = d > 0.5;
    if (overHalf) {
      d = 1-d;
    }
    Rational r = farey(d, maxDenom);
    if (!neg && !overHalf && whole==0) {
      return r;
    }
    long num = r.num;
    long denom = r.denom;
    if (overHalf) {
      num = denom-num;
    }
    if (whole > 0) {
      num += whole*denom;
    }
    if (neg) {
      num = -num;
    }
    if (num == r.num) {
      return r;
    }
    return new Rational(num, denom);
  }
  
  private static Rational farey(double d, long maxDenom) {
    double upperNum = 1;
    double lowerNum = 1;
    double upperDenom = (long)(1/d);
    double lowerDenom = upperDenom+1;
    double upper = upperNum/upperDenom;
    double lower = lowerNum/lowerDenom;
    if (lower == d) {
      return new Rational((long)lowerNum,(long)upperDenom);
    }
    
    double probeDenom;
    while ((probeDenom = upperDenom+lowerDenom) <= maxDenom) {
      double probeNum = upperNum+lowerNum;
      double probe = probeNum/probeDenom;
      if (d == probe) {
        return new Rational((long)probeNum, (long)probeDenom);
      }
      if (d > probe) {
        lowerNum = probeNum;
        lowerDenom = probeDenom;
        lower = probe;
      } else {
        upperNum = probeNum;
        upperDenom = probeDenom;
        upper = probe;
      }
    }
    double upperDelta = d-upper;
    double lowerDelta = d-lower;
    if (upperDelta > lowerDelta) {
      return new Rational((long)lowerNum,(long)upperDenom);
    } else {
      return new Rational((long)upperNum, (long)upperDenom);
    }
  }

  public static Rational fromDouble(double d) {
    return fromDouble(d, defaultMaxDenom.get());
  }

  public static long defaultMaxDenominator() {
    return defaultMaxDenom.get();
  }
  public static void setDefaultMaxDenominator(long d) {
    defaultMaxDenom.set(d);
  }
  
  public static Rational inBase(double d, int base, int maxDenomPower) {
    long denom = (long)Math.pow(base, maxDenomPower);
    long num = Math.round(d*denom);
    return new Rational(num, denom);
  }
  
  @Override
  public String toString() {
    if (denom == 1) {
      return String.format("%,d", num);
    } else {
      return String.format("%,d/%,d", num, denom);
    }
  }

  public long numerator() {
    return num;
  }
  
  public long denominator() {
    return denom;
  }
  
  private static long gcd(long x, long y) {
    if (x == y) {
      return x;
    }
    long a;
    long b;
    if (x > y) {
      a = x;
      b = y;
    } else {
      a = y;
      b = x;
    }
    
    while (b != 0) {
      long rem = a%b;
      a = b;
      b = rem;
    }
    return a;
  }


  @Override
  public int intValue() {
    return (int)longValue();
  }

  @Override
  public long longValue() {
    return num/denom;
  }

  @Override
  public float floatValue() {
    return (float)doubleValue();
  }

  @Override
  public double doubleValue() {
    return num/(double)denom;
  }
  
  @Override
  public boolean equals(Object obj) {
    if (obj == this) {
      return true;
    }
    if (obj == null) {
      return false;
    }
    if (obj instanceof Rational) {
      Rational other = (Rational)obj;
      return num==other.num && denom == other.denom;
    }
    if (obj instanceof Number) {
      Number other = (Number)obj;
      return doubleValue() == other.doubleValue();
    }
    return false;
  }
  
  @Override
  public int hashCode() {
    return HashCode.simple(Rational.class)
        .include(num)
        .include(denom)
        .value();
  }
  
  @Override
  public int compareTo(Rational o) {
    return Double.compare(doubleValue(), o.doubleValue());
  }
  
  
  private static void test(String desc, Rational r) {
    System.out.format("%s: %s%n", desc, r);
  }
  public static void main(String[] args) {
    test("new Rational(2,3)", new Rational(2,3));
    test("new Rational(6,8)", new Rational(6,8));
    test("new Rational(7)", new Rational(7));
    test("new Rational(0)", new Rational(0));
    test("new Rational(0,5)", new Rational(0,5));
    test("Rational.fromDouble(1.0/3)", Rational.fromDouble(1.0/3));
    test("Rational.fromDouble(11.0/16)", Rational.fromDouble(11.0/16));
    test("Rational.fromDouble(Math.PI)", Rational.fromDouble(Math.PI));
    test("Rational.fromDouble(Math.E)", Rational.fromDouble(Math.E));
    test("Rational.fromDouble(Math.PI,10)", Rational.fromDouble(Math.PI,10));
    test("Rational.fromDouble(Math.PI,1_000_000_000)", Rational.fromDouble(Math.PI,1_000_000_000));
    test("Rational.fromDouble(Math.E,10)", Rational.fromDouble(Math.E,10));
    test("Rational.inBase(Math.PI, 2, 10)", Rational.inBase(Math.PI, 2, 10));
    test("Rational.inBase(Math.PI, 10, 5)", Rational.inBase(Math.PI, 10, 5));
    test("Rational.inBase(1.0/10,2,10)", Rational.inBase(1.0/10, 2, 10));
    test("Rational.inBase(0.5, 10, 5)", Rational.inBase(0.5, 10, 5));
  }

}
