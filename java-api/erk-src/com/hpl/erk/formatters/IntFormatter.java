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

package com.hpl.erk.formatters;

import com.hpl.erk.util.Strings;


/*
 * Under construction
 */
public class IntFormatter implements Stringifier<Number> {
  private static final String DEFAULT_NEG_FORMAT = "-%s";
  public static final Padder DefaultPadder = new Padder() {
    @Override
    public String pad(boolean sign, String mag, int width, String pad,
                      IntFormatter formatter) {
      String s = sign ? "-"+mag : mag;
      return Strings.padLeft(s, width, pad);
    }
  };


  public static abstract class MagnitudeFormatter {
    public abstract String formatMagnitude(long u, IntFormatter fmtr);

    public abstract boolean defaultSigned();
  }
  
  public static abstract class Padder {
    public abstract String pad(boolean sign, String mag, int width, String pad, IntFormatter formatter);
  }
  
  private MagnitudeFormatter magFormatter = DigitStringMagFormatter.DECIMAL;
  private int minDigits = 0;
  private int groupSize = 0;
  private String separator = null;
  private Boolean signed = null;
  private String zeroForm = null;
  private int minFieldWidth = 0;
  private String pad = " ";
  private boolean ordinal = false;
  private boolean grouped = false;
  private String negFormat = DEFAULT_NEG_FORMAT;
  private long maxAsWords = Long.MAX_VALUE;
  
  

  
  public IntFormatter formatter(MagnitudeFormatter mf) {
    magFormatter = mf;
    return this;
  }
  
  public IntFormatter group(String sep, int groupSize) {
    return groupSep(sep).groupWidth(groupSize);
  }
  
  public IntFormatter grouped(boolean b) {
    this.grouped = b;
    return this;
  }
  public IntFormatter grouped() {
    return grouped(true);
  }
  public IntFormatter ungrouped() {
    return grouped(false);
  }
  
  public IntFormatter groupSep(String sep) {
    this.separator = sep;
    this.grouped = true;
    return this;
  }
  
  public IntFormatter groupWidth(int size) {
    this.groupSize = size;
    this.grouped = true;
    return this;
  }
  
  public IntFormatter commas() {
    return groupSep(",");
  }
  public IntFormatter underscores() {
    return groupSep("_");
  }
  public IntFormatter dots() {
    return groupSep(".");
  }
  public IntFormatter periods() {
    return groupSep(".");
  }
  public IntFormatter colons() {
    return groupSep(":");
  }
  public IntFormatter spaces() {
    return groupSep(" ");
  }
  public IntFormatter dashes() {
    return groupSep("-");
  }
  public IntFormatter commas(int width) {
    return groupSep(",").groupWidth(width);
  }
  public IntFormatter underscores(int width) {
    return groupSep("_").groupWidth(width);
  }
  public IntFormatter dots(int width) {
    return groupSep(".").groupWidth(width);
  }
  public IntFormatter periods(int width) {
    return groupSep(".").groupWidth(width);
  }
  public IntFormatter colons(int width) {
    return groupSep(":").groupWidth(width);
  }
  public IntFormatter spaces(int width) {
    return groupSep(" ").groupWidth(width);
  }
  public IntFormatter dashes(int width) {
    return groupSep("-").groupWidth(width);
  }
  
  public IntFormatter minDigits(int min) {
    this.minDigits = min;
    return this;
  }
  
  public IntFormatter maxAsWords(long max) {
    this.maxAsWords = max;
    return this;
  }
  
  public IntFormatter base(int radix) {
    return formatter(DigitStringMagFormatter.forRadix(radix));
  }
  public IntFormatter inWords() {
    return formatter(new EnglishWordsMagFormatter()).formatNeg("negative %s");
  }
  
  public IntFormatter signed(boolean b) {
    signed = b;
    return this;
  }
  
  public IntFormatter signed() {
    return signed(true);
  }
  
  public IntFormatter unsigned() {
    return signed(false);
  }
  
  public IntFormatter zero(String form) {
    zeroForm = form;
    return this;
  }
  
  public IntFormatter ordinal(boolean b) {
    ordinal = b;
    return this;
  }
  
  public IntFormatter ordinal() {
    return ordinal(true);
  }
  
  public IntFormatter cardinal() {
    return ordinal(false);
  }
  
  public IntFormatter formatNeg(String fmt) {
    negFormat = fmt;
    return this;
  }
  public IntFormatter leadingMinus() {
    return formatNeg("-%s");
  }
  public IntFormatter trailingMinus() {
    return formatNeg("%s-");
  }
  public IntFormatter accounting() {
    return formatNeg("(%s)");
  }
  
  public IntFormatter padTo(int width) {
    minFieldWidth = width;
    return this;
  }
  public IntFormatter padWith(String s) {
    pad = s;
    return this;
  }
  public IntFormatter padTo(int width, String s) {
    return padTo(width).padWith(s);
  }

  public static IntFormatter create() {
    return new IntFormatter();
  }
  public static IntFormatter inBase(int radix, int group, String sep) {
    return IntFormatter.create().base(radix).group(sep, group);
  }
  public static IntFormatter inBase(int radix) {
    return IntFormatter.create().base(radix);
  }
  
  public static IntFormatter hex(int group, String sep) {
    return inBase(16, group, sep);
  }
  public static IntFormatter decimal(int group, String sep) {
    return inBase(10, group, sep);
  }
  public static IntFormatter octal(int group, String sep) {
    return inBase(10, group, sep);
  }
  public static IntFormatter binary(int group, String sep) {
    return inBase(10, group, sep);
  }
  public static IntFormatter hex() {
    return inBase(16);
  }
  public static IntFormatter decimal() {
    return inBase(10);
  }
  public static IntFormatter octal() {
    return inBase(8);
  }
  public static IntFormatter binary() {
    return inBase(2);
  }
  public static IntFormatter english() {
    return IntFormatter.create().inWords();
  }

  public int minDigits() {
    return minDigits;
  }

  public String separator() {
    return separator;
  }

  public int groupSize() {
    return groupSize;
  }
  
  public boolean isOrdinal() {
    return ordinal;
  }
  
  public boolean isGrouped() {
    return grouped;
  }
  
  public long maxAsWords() {
    return maxAsWords;
  }
  
  public String fmtNeg(String pos) {
    String fmt = negFormat==null ? DEFAULT_NEG_FORMAT : negFormat;
    return String.format(fmt, pos);
  }
  
  public String format(long n) {
    boolean sgnd = signed == null ? magFormatter.defaultSigned() : signed;
    boolean neg = sgnd && n < 0;
    String mag;
    if (n == 0 && zeroForm != null) {
      mag = zeroForm;
    } else {
      mag = magFormatter.formatMagnitude(neg ? -n : n, this);
    }
    String s = neg ? fmtNeg(mag) : mag;
    return Strings.padLeft(s, minFieldWidth, pad);
  }


  @Override
  public String stringify(Number val) {
    return format(val.longValue());
  }
  
  

}
