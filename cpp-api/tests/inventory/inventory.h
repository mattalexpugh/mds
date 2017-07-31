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

#ifndef INVENTORY_INVENTORY_H
#define INVENTORY_INVENTORY_H

#include "mds.h"
#include <ostream>
#include <random>
#include <vector>
#include <algorithm>
#include <string>
#include "util.h"

using namespace mds;
using namespace std;

class Product;

namespace mds {
  template <> struct is_record_type<Product> : true_type {};
}

class Product : public mds_record {
  using super = mds_record;
public:
  DECLARE_CONST_FIELD(Product, mds_string, name);
  DECLARE_FIELD(Product, int, count);
  DECLARE_FIELD(Product, int, count_target);
  DECLARE_FIELD(Product, int, value);
  DECLARE_FIELD(Product, int, sale_value);
  DECLARE_FIELD(Product, bool, sale_flag);
  DECLARE_FIELD(Product, int, asset_value);
  DECLARE_FIELD(Product, int, nbr_sold);
  DECLARE_FIELD(Product, int, revenue);
  DECLARE_FIELD(Product, float, revenue_percentage);
  DECLARE_FIELD(Product, Product, next);
  DECLARE_FIELD(Product, Product, prev);
  RECORD_SETUP(Product, super, "Product",
               REGISTER_FIELD(name),
               REGISTER_FIELD(count),
               REGISTER_FIELD(count_target),
               REGISTER_FIELD(value),
               REGISTER_FIELD(sale_value),
               REGISTER_FIELD(sale_flag),
               REGISTER_FIELD(asset_value),
               REGISTER_FIELD(nbr_sold),
               REGISTER_FIELD(revenue),
               REGISTER_FIELD(revenue_percentage),
               REGISTER_FIELD(next),
               REGISTER_FIELD(prev));
               
  Product(const rc_token &tok,
          const mds_string &name_,
          int count_,
          int value_)
    : super{tok}, name{name_}, count{count_}, value{value_}
  {
  }

  static string to_name(size_t n) {
    return ruts::format([n](auto &os) {
        os << "P" << setfill('0') << setw(6) << n;
      });
  }

  auto &print_name(ostream &os = cout) const {
    return os << "Product: name = " << name << endl;
  }

  auto &print(ostream &os = cout) const {
    return print_name(os);
  }

  auto &print_all(ostream &os = cout) const {
    print_name(os);
    os << "   count = " << count << endl
       << "   count_target = " << count_target << endl
       << "   value = " << as_currency(value) << endl
       << "   sale_value = " << as_currency(sale_value) << endl
       << "   sale_flag = " << sale_flag << endl
       << "   asset_value = " << as_currency(asset_value) << endl
       << "   nbr_sold = " << nbr_sold << endl
       << "   revenue = " << as_currency(revenue) << endl
       << "   revenue_percentage = " << revenue_percentage << "%" << endl;
    return os;
  }

};
  

class ListOfProducts : public mds_record {
  using super = mds_record;
public:
  DECLARE_FIELD(ListOfProducts, int, size);
  DECLARE_FIELD(ListOfProducts, Product, head);
  RECORD_SETUP(ListOfProducts, super, "ListOfProducts",
               REGISTER_FIELD(size),
               REGISTER_FIELD(head));

  explicit ListOfProducts(const rc_token &tok) : super{tok} {}

  template <typename Fn>
  mds_ptr<Product> find_before(Fn&& fn) const {
    mds_ptr<Product> prev = nullptr;
    for (mds_ptr<Product> current = head;
         current != nullptr;
         current = current->next)
      {
        if (!std::forward<Fn>(fn)(current)) {
          return prev;
        }
        prev = current;
      }
    return nullptr;
  }

  template <typename ST>
  mds_ptr<Product> find_before_name(const ST &target_name) const {
    return find_before([&](const mds_ptr<Product> &p) {
        return p->name > target_name;
      });
  }

  mds_ptr<Product> find_last() const {
    mds_ptr<Product> prev = nullptr;
    for (mds_ptr<Product> current = head;
         current != nullptr;
         current = current->next)
      {
        prev = current;
      }
    return prev;
  }
  

  void add(const mds_ptr<Product> p) {
    mds_ptr<Product> prev = find_before_name(p->name);
    p->prev = prev;
    if (prev == nullptr) {
      // adding to the head of the list
      p->next = head;
      head = p;
    } else {
      p->next = prev->next;
      prev->next = p;
    }
    size++;
  }

  bool append(const mds_ptr<Product> p) {
    mds_ptr<Product> prev = find_last();
    p->prev = prev;
    if (prev == nullptr) {
      // adding to the head of the list
      p->next = head;
      head = p;
    } else {
      // sanity check that the new product name should be last
      if (p->name >= prev->name) {
        prev->next = p;
      } else {
        return false;
      }
    }
    size++;
    return true;
  }

  template <typename ST>
  mds_ptr<Product> remove(const ST &pname) {
    mds_ptr<Product> prev = find_before_name(pname);
    mds_ptr<Product> candidate = prev == nullptr ? head : prev->next.read();
    if (candidate == nullptr) {
      return nullptr;
    }
    if (candidate->name() != pname) {
      return nullptr;
    }
    mds_ptr<Product> next = candidate->next();
    if (prev == nullptr) {
      head = next;
    } else {
      prev->next = next;
    }
    if (next != nullptr) {
      next->prev = candidate->prev;
    }
    candidate->prev = nullptr;
    candidate->next = nullptr;
    return candidate;
  }

  template <typename ST>
  mds_ptr<Product> get(const ST &name) const {
    auto prev = find_before_name(name);
    auto candidate = prev==nullptr ? head : prev->next.read();
    if (candidate == nullptr) {
      return nullptr;
    }
    if (candidate->name != name) {
      return nullptr;
    }
    return candidate;
  }

  template <typename Fn, typename...Args>
  void for_each(Fn&& fn, Args&&...args) const {
    for (mds_ptr<Product> p = head; p != nullptr; p=p->next) {
      std::forward<Fn>(fn)(p, std::forward<Args>(args)...);
    }
  }

  vector<mds_ptr<Product>> as_vector() const {
    vector<mds_ptr<Product>> v;
    v.reserve(size);
    for_each([&](const auto &p){
        v.push_back(p);
      });
    return v;
  }
};

struct Sale {
  const int number_requested;
  const int number_sold;
  const int unit_cost;
  const int total_cost;
  Sale(int nr, int ns, int uc, int tc)
    : number_requested{nr}, number_sold{ns},
      unit_cost{uc}, total_cost{tc}
  {}
};

class Inventory : public mds_record {
  using super = mds_record;
public:
  DECLARE_CONST_FIELD(Inventory, ListOfProducts, products);
  RECORD_SETUP(Inventory, super, "Inventory",
               REGISTER_FIELD(products));

  Inventory(const rc_token &tok)
    : super{tok},
      products{ new_record<ListOfProducts>() }
  {
  }

  void add(const mds_ptr<Product> &p) {
    products->add(p);
  }

  void append(const mds_ptr<Product> &p) {
    products->append(p);
  }

  template <typename ST>
  mds_ptr<Product> remove(const ST &name) {
    return products->remove(name);
  }

  template <typename ST>
  mds_ptr<Product> get(const ST &name) const {
    return products->get(name);
  }

  void stock_in(int units, const mds_ptr<Product> &p) {
    p->count++;
  }

  template <typename ST>
  void stock_in_name(int units, const ST &name) {
    auto p = get(name);
    if (p == nullptr) {
      int value = uniform_int_distribution<>{1000, 100000}(tl_rand());
      p = new_record<Product>(name, 0, value);
      add(p);
    }
    stock_in(units, p);
  }

  Sale order_out(int units, const mds_ptr<Product> &p) {
    if (p == nullptr) {
      return Sale{0,0,0,0};
    }
    int n_in_stock = p->count;
    int n = min(n_in_stock, units);
    int unit_price = p->value;
    int total_price = n * unit_price;

    p->count -= n;
    p->nbr_sold += n;
    p->revenue += total_price;

    return Sale{units, n, unit_price, total_price};
  }

  template <typename ST>
  Sale order_out_name(int units, const ST &name) {
    return order_out(units, get(name));
  }

  void print() {
    cout << "Inventory: size = " << products->size;
    products->for_each([](const auto &p) {
        p->print();
      });
  }
  void print_all() {
    cout << "Inventory: size = " << products->size;
    products->for_each([](const auto &p) {
        p->print_all();
      });
  }
};

#endif
