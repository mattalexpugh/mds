# -*- coding: utf-8 -*-
"""
Managed Data Structures
Copyright © 2017 Hewlett Packard Enterprise Development Company LP.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

As an exception, the copyright holders of this Library grant you permission
to (i) compile an Application with the Library, and (ii) distribute the
Application containing code generated by the Library and added to the
Application during this compilation process under terms of your choice,
provided you also meet the terms and conditions of the Application license.
"""

from libcpp cimport bool

from mds.core.arrays cimport *
from mds.core.primitives cimport *
from mds.core.records cimport h_mrecord_t, h_rtype_t
from mds.core.strings cimport h_istring_t, h_mstring_t, h_istring_t

cdef extern from "mds_core_api.h" namespace "mds::api" nogil:
    cdef cppclass namespace_handle:
        namespace_handle()
        namespace_handle(const namespace_handle&)
        namespace_handle(namespace_handle&)

        bool operator==(const namespace_handle)

        bool is_bound(const h_istring_t&)
        bool is_null()
        namespace_handle child_namespace(const h_istring_t&, bool)

        @staticmethod
        namespace_handle _global "global"()
        h_mrecord_t lookup(const h_istring_t&, const h_record_type_t&);
        uint64_t hash1()
    
        h_mstring_t lookup_string "lookup<mds::api::kind::STRING,mds::core::kind_type<mds::api::kind::STRING>,false,true>"(h_istring_t, const h_mstring_t&)
        bool bind_string "bind<mds::api::kind::STRING>"(h_istring_t, h_mstring_t)
        
        h_mrecord_t lookup_record "lookup<false,true>"(h_istring_t, const h_record_type_t&)
        bool bind_record "bind<mds::api::kind::RECORD>"(h_istring_t, h_rtype_t)

# START INJECTION | tmpl_api_namespaces_primitives(Primitives)
# END INJECTION

# START INJECTION | tmpl_api_namespaces_arrays(Arrays)
# END INJECTION

        # h_marray_string_t lookup_string_array "lookup<mds::api::kind::STRING,false,true>"(const h_istring_t&, const h_array_string_t&) except+
        # h_marray_record_t lookup_record_array "lookup<mds::api::kind::RECORD,false,true>"(const h_istring_t&, const h_array_record_t&) except+

ctypedef namespace_handle h_namespace_t