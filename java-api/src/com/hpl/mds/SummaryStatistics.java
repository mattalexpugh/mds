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

package com.hpl.mds;

import com.hpl.mds.impl.AccumImpl;

import java.util.function.Consumer;
import java.util.function.BiConsumer;
import java.util.function.Function;
import java.util.function.Supplier;

public class SummaryStatistics {
  private static class State {
    long count = 0;
    double sum = 0;
    double sumSq = 0;
    void rollback(State other) {
      count -= other.count;
      sum -= other.sum;
      sumSq -= other.sumSq;
    }
    void add(double val, long weight) {
      count += weight;
      sum += val*weight;
      sumSq += val*val*weight;
    }
    long count() { return count; }
    double sum() { return sum; }
    double mean() { return sum/count; }
    double variance() {
      double m = mean();
      return (1.0/(count-1))*(sumSq-2*m*sum+m*m*count);
    }
    double sd() {
      return Math.sqrt(variance());
    }
    double se() {
      return sd()/Math.sqrt(count);
    }
    double high95() {
      return mean()+se()*1.96;
    }
    double low95() {
      return mean()-se()*1.96;
    }
  }

  private final Accumulator<State> accum;

  public SummaryStatistics(int expectedTasks) {
    accum = Accumulator.create(State::new, State::rollback, expectedTasks);
  }

  public SummaryStatistics() {
    accum = Accumulator.create(State::new, State::rollback);
  }

  
  public void add(double val, long weight) {
    accum.add(s->s.add(val, weight));
  }
  public void add(double val) {
    add(val, 1);
  }
  public long count() {
    return accum.get(State::count);
  }
  public double sum() {
    return accum.get(State::sum);
  }
  public double mean() {
    return accum.get(State::mean);
  }
  public double variance() {
    return accum.get(State::variance);
  }
  public double stdDeviation() {
    return accum.get(State::sd);
  }
  public double stdError() {
    return accum.get(State::se);
  }
  public double high95() {
    return accum.get(State::high95);
  }
  public double low95() {
    return accum.get(State::low95);
  }
}
