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

from mds.core.api_arrays cimport *
from mds.core.api_primitives cimport *
from mds.core.api_records cimport managed_record_handle
from mds.core.api_strings cimport interned_string_handle, intern

cdef extern from "mds_core_api.h" namespace "mds::api" nogil:
    cdef cppclass namespace_handle:
        namespace_handle()
        namespace_handle(const namespace_handle&)
        namespace_handle(namespace_handle&)

        bool is_bound(const interned_string_handle&)
        namespace_handle child_namespace(const interned_string_handle&, bool)

        @staticmethod
        namespace_handle _global "global"()
        managed_record_handle lookup(const interned_string_handle&, const record_type_handle&);

        #@staticmethod
        #namespace_handle from_existing_path(Iter start, Iter end)
        #@staticmethod
        #namespace_handle from_path(Iter start, Iter end)
    
# START INJECTION

        bool lookup "lookup<mds::api::kind::BOOL,mds::core::kind_type<mds::api::kind::BOOL>,false,true>"(interned_string_handle, const h_mbool_t&)
        h_marray_bool_t lookup "lookup<mds::api::kind::BOOL,false,true>"(const interned_string_handle&, const h_array_bool_t&)
        bool bind "bind<mds::api::kind::BOOL>"(interned_string_handle, bool)
    
        int8_t lookup "lookup<mds::api::kind::BYTE,mds::core::kind_type<mds::api::kind::BYTE>,false,true>"(interned_string_handle, const h_mbyte_t&)
        h_marray_byte_t lookup "lookup<mds::api::kind::BYTE,false,true>"(const interned_string_handle&, const h_array_byte_t&)
        bool bind "bind<mds::api::kind::BYTE>"(interned_string_handle, int8_t)
    
        uint8_t lookup "lookup<mds::api::kind::UBYTE,mds::core::kind_type<mds::api::kind::UBYTE>,false,true>"(interned_string_handle, const h_mubyte_t&)
        h_marray_ubyte_t lookup "lookup<mds::api::kind::UBYTE,false,true>"(const interned_string_handle&, const h_array_ubyte_t&)
        bool bind "bind<mds::api::kind::UBYTE>"(interned_string_handle, uint8_t)
    
        int16_t lookup "lookup<mds::api::kind::SHORT,mds::core::kind_type<mds::api::kind::SHORT>,false,true>"(interned_string_handle, const h_mshort_t&)
        h_marray_short_t lookup "lookup<mds::api::kind::SHORT,false,true>"(const interned_string_handle&, const h_array_short_t&)
        bool bind "bind<mds::api::kind::SHORT>"(interned_string_handle, int16_t)
    
        uint16_t lookup "lookup<mds::api::kind::USHORT,mds::core::kind_type<mds::api::kind::USHORT>,false,true>"(interned_string_handle, const h_mushort_t&)
        h_marray_ushort_t lookup "lookup<mds::api::kind::USHORT,false,true>"(const interned_string_handle&, const h_array_ushort_t&)
        bool bind "bind<mds::api::kind::USHORT>"(interned_string_handle, uint16_t)
    
        int32_t lookup "lookup<mds::api::kind::INT,mds::core::kind_type<mds::api::kind::INT>,false,true>"(interned_string_handle, const h_mint_t&)
        h_marray_int_t lookup "lookup<mds::api::kind::INT,false,true>"(const interned_string_handle&, const h_array_int_t&)
        bool bind "bind<mds::api::kind::INT>"(interned_string_handle, int32_t)
    
        uint32_t lookup "lookup<mds::api::kind::UINT,mds::core::kind_type<mds::api::kind::UINT>,false,true>"(interned_string_handle, const h_muint_t&)
        h_marray_uint_t lookup "lookup<mds::api::kind::UINT,false,true>"(const interned_string_handle&, const h_array_uint_t&)
        bool bind "bind<mds::api::kind::UINT>"(interned_string_handle, uint32_t)
    
        int64_t lookup "lookup<mds::api::kind::LONG,mds::core::kind_type<mds::api::kind::LONG>,false,true>"(interned_string_handle, const h_mlong_t&)
        h_marray_long_t lookup "lookup<mds::api::kind::LONG,false,true>"(const interned_string_handle&, const h_array_long_t&)
        bool bind "bind<mds::api::kind::LONG>"(interned_string_handle, int64_t)
    
        uint64_t lookup "lookup<mds::api::kind::ULONG,mds::core::kind_type<mds::api::kind::ULONG>,false,true>"(interned_string_handle, const h_mulong_t&)
        h_marray_ulong_t lookup "lookup<mds::api::kind::ULONG,false,true>"(const interned_string_handle&, const h_array_ulong_t&)
        bool bind "bind<mds::api::kind::ULONG>"(interned_string_handle, uint64_t)
    
        float lookup "lookup<mds::api::kind::FLOAT,mds::core::kind_type<mds::api::kind::FLOAT>,false,true>"(interned_string_handle, const h_mfloat_t&)
        h_marray_float_t lookup "lookup<mds::api::kind::FLOAT,false,true>"(const interned_string_handle&, const h_array_float_t&)
        bool bind "bind<mds::api::kind::FLOAT>"(interned_string_handle, float)
    
        double lookup "lookup<mds::api::kind::DOUBLE,mds::core::kind_type<mds::api::kind::DOUBLE>,false,true>"(interned_string_handle, const h_mdouble_t&)
        h_marray_double_t lookup "lookup<mds::api::kind::DOUBLE,false,true>"(const interned_string_handle&, const h_array_double_t&)
        bool bind "bind<mds::api::kind::DOUBLE>"(interned_string_handle, double)
    
# END INJECTION

        managed_record_handle lookup(interned_string_handle, record_type_handle)

