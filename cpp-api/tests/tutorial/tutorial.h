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

#ifndef TURORIAL_H
#define TURORIAL_H

#include "mds.h"

using namespace std;
using namespace mds;

struct wrong_price {
  mds_string sku;
  float asked;
  float actual;
  
  wrong_price(const mds_string &s, float p1, float p2)
    : sku{s}, asked{p1}, actual{p2}
  {}
};

struct insufficient_quantity {
  mds_string sku;
  unsigned asked;
  unsigned actual;
  
  insufficient_quantity(const mds_string &s, unsigned q1, unsigned q2)
    : sku{s}, asked{q1}, actual{q2}
  {}
};

struct no_such_sku {
  string sku;
  no_such_sku(const string &s) : sku{s} {}
};

struct sku_exists {
  string sku;
  sku_exists(const string &s) : sku{s} {}
};

class Product;

namespace mds {
  template<> struct is_record_type<Product> : true_type{};
}

class Product : public mds_record {
  static const mds_ptr<mds_namespace> by_sku;

public:
  static const mds_ptr<mds_namespace> data_ns;
  static const mds_string first_product_key;

  DECLARE_CONST_FIELD(Product, mds_string, sku);
  DECLARE_FIELD(Product, unsigned, n_in_stock);
  DECLARE_FIELD(Product, unsigned, n_sold);
  DECLARE_FIELD(Product, float, price);
  DECLARE_FIELD(Product, float, revenue);
  DECLARE_FIELD(Product, Product, next_product);
  RECORD_SETUP(Product, mds_record, "Product",
               REGISTER_FIELD(sku),
               REGISTER_FIELD(n_in_stock),
               REGISTER_FIELD(n_sold),
               REGISTER_FIELD(price),
               REGISTER_FIELD(revenue),
               REGISTER_FIELD(next_product));

  Product(const rc_token& tok, const string &s, float p, unsigned n)
    : mds_record{tok},
      sku{s}, n_in_stock{n}, n_sold{0}, price{p}, revenue{0}
  {
    isolated([this]{
        next_product = Product::lookup_in(data_ns, first_product_key);
        THIS_RECORD->bind_in(data_ns, first_product_key);
      });
    THIS_RECORD->bind_in(by_sku, s);
  }

  void check(unsigned q, float p) {
    if (price != p) { throw wrong_price{sku, p, price}; }
    if (n_in_stock < q) { throw insufficient_quantity{sku, q, n_in_stock}; }
  }

  void sell(unsigned q, float p) {
    revenue += p*q;
    n_sold += q;
    n_in_stock -= q;
  }
  
  static bool exists(const string &sku) {
    return (*by_sku)[sku].is_bound();
  }

  static mds_ptr<Product> lookup(const string &sku) {
    mds_ptr<Product> p = Product::lookup_in(by_sku, sku);
    if (p == nullptr) {  throw no_such_sku{sku}; }
    return p;
  }

  static mds_ptr<Product> get_first_product() {
    return Product::lookup_in(data_ns, first_product_key);
  }
private:
  mds_ptr<Product> push_and_get_first() {
    mds_ptr<Product> old;
    isolated([this, &old]{
        old = Product::lookup_in(data_ns, first_product_key);
        THIS_RECORD->bind_in(data_ns, first_product_key);
      });
    return old;
  }

};

struct Report : public mds_record {
  static const mds_ptr<mds_namespace> data_ns;
  static const mds_string first_product_key;

  DECLARE_CONST_FIELD(Report, float, total_revenue);
  DECLARE_CONST_FIELD(Report, float, stock_value);
  DECLARE_CONST_FIELD(Report, mds_array<Product>, top_ten_products);
  RECORD_SETUP(Report, mds_record, "Report",
               REGISTER_FIELD(total_revenue),
               REGISTER_FIELD(stock_value),
               REGISTER_FIELD(top_ten_products));

  Report(const rc_token& tok, float r, float s,
         const vector<mds_ptr<Product>> &top10)
    : mds_record{tok},
      total_revenue{r}, stock_value{s},
      top_ten_products{top10.begin(), top10.end()}
  {
  }

};


#endif /* TURORIAL_H */
