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

#include "inventory.h"
#include <vector>
#include <string>
#include <functional>
#include <ostream>
#include <getopt.h>
#include <unistd.h>
#include <iostream>
#include "ruts/util.h"

using namespace std;
using namespace mds;


int init(int argc, char *argv[], const string &inv_name, function<void()> usage) {
  struct option long_options[] = {
    {"max_prod_no",  required_argument, 0, 'P' },
    {"maxp",         required_argument, 0, 'P' },
    {"gap_size",     required_argument, 0, 'g' },
    {"min_val",      required_argument, 0, 'v' },
    {"minv",         required_argument, 0, 'v' },
    {"max_val",      required_argument, 0, 'V' },
    {"maxv",         required_argument, 0, 'V' },
    {"min_quant",    required_argument, 0, 'q' },
    {"minq",         required_argument, 0, 'q' },
    {"max_quant",    required_argument, 0, 'Q' },
    {"maxq",         required_argument, 0, 'Q' },
    {0,              0,                 0,  0 }
  };

  optind = 0;

  size_t max_prod_no = 100;
  size_t gap_size = 2;
  size_t min_val = 1;
  size_t max_val = 100;
  size_t min_quant = 100;
  size_t max_quant = 1000;

  while (true) {
    int c = getopt_long(argc, argv, "+", long_options, nullptr);
    if (c == -1) {
      break;
    }

    try {

      switch(c) {
      case 'P':
        max_prod_no = stoul(optarg);
        break;
      case 'g':
        gap_size = stoul(optarg);
        break;
      case 'v':
        min_val = stoul(optarg);
        break;
      case 'V':
        max_val = stoul(optarg);
        break;
      case 'q':
        min_quant = stoul(optarg);
        break;
      case 'Q':
        max_quant = stoul(optarg);
        break;
      case '?':
        usage();
        return -1;
      }
    } catch(invalid_argument &ex) {
      cerr << "Couldn't parse: " << optarg << endl << endl;
      usage();
      return -1;
    }
  }
  if (optind != argc) {
    cerr << "Unexpected argument: '" << argv[optind] << "' for " << argv[0] << endl <<endl;
    usage();
    return -1;
  }
  // cout << "Initializing" << endl;
  // cout << "  name = " << inv_name << endl;
  // cout << "  max_prod_no = " << max_prod_no << endl;
  // cout << "  gap_size = " << gap_size << endl;
  // cout << "  min_val = " << min_val << endl;
  // cout << "  max_val = " << max_val << endl;
  // cout << "  min_quant = " << min_quant << endl;
  // cout << "  max_quant = " << max_quant << endl;

  mds_ptr<Inventory> inv = new_record<Inventory>();
  inv->bind_to_name(inv_name);
  for (size_t i=0; i<max_prod_no; i += gap_size+1) {
    string pname = Product::to_name(i);
    int q = uniform_int_distribution<>(min_quant, max_quant+1)(tl_rand());
    int v = 100*uniform_int_distribution<>(min_val, max_val+1)(tl_rand());
    mds_ptr<Product> p = new_record<Product>(pname, q, v);
    cout << pname << ": " << q << " @ " << as_currency(v) << endl;
    inv->append(p);
  }
  return 0;
}
