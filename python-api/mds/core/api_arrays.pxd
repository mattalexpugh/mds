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

from mds.core.api_primitives cimport *

cdef extern from "mds_core_api.h" namespace "mds::api" nogil:
    cdef cppclass h_array_type_base_t "array_type_base_handle":
        h_array_type_base_t()
        bool is_same_as(const h_array_type_base_t&)

    cdef cppclass h_marray_base_t "managed_array_base_handle":
        h_marray_base_t()
        # TODO uniform_key uuid()

cdef extern from "helpers.h" namespace "mds::python::types":
# START INJECTION

    cdef cppclass h_array_bool_t "array_type_handle<mds::api::kind::BOOL>":
        # const_managed_type_handle<K> element_type()
        h_marray_bool_t create_array(size_t)
        bool is_same_as(const h_array_bool_t&)

    cdef cppclass h_marray_bool_t:
        mv_bool frozen_read(size_t)
        mv_bool write(size_t, mv_bool)
        size_t size()
        # TODO uniform_key uuid()
        bool has_value()
        h_marray_base_t as_base()
        

    h_marray_bool_t create_bool_marray(size_t)
    
    cdef cppclass h_array_byte_t "array_type_handle<mds::api::kind::BYTE>":
        # const_managed_type_handle<K> element_type()
        h_marray_byte_t create_array(size_t)
        bool is_same_as(const h_array_byte_t&)

    cdef cppclass h_marray_byte_t:
        mv_byte frozen_read(size_t)
        mv_byte write(size_t, mv_byte)
        size_t size()
        # TODO uniform_key uuid()
        bool has_value()
        h_marray_base_t as_base()
        
        int8_t add(const size_t&, const int8_t&)
        int8_t sub(const size_t&, const int8_t&)
        int8_t mul(const size_t&, const int8_t&)
        int8_t div(const size_t&, const int8_t&)


    h_marray_byte_t create_byte_marray(size_t)
    
    cdef cppclass h_array_ubyte_t "array_type_handle<mds::api::kind::UBYTE>":
        # const_managed_type_handle<K> element_type()
        h_marray_ubyte_t create_array(size_t)
        bool is_same_as(const h_array_ubyte_t&)

    cdef cppclass h_marray_ubyte_t:
        mv_ubyte frozen_read(size_t)
        mv_ubyte write(size_t, mv_ubyte)
        size_t size()
        # TODO uniform_key uuid()
        bool has_value()
        h_marray_base_t as_base()
        
        uint8_t add(const size_t&, const uint8_t&)
        uint8_t sub(const size_t&, const uint8_t&)
        uint8_t mul(const size_t&, const uint8_t&)
        uint8_t div(const size_t&, const uint8_t&)


    h_marray_ubyte_t create_ubyte_marray(size_t)
    
    cdef cppclass h_array_short_t "array_type_handle<mds::api::kind::SHORT>":
        # const_managed_type_handle<K> element_type()
        h_marray_short_t create_array(size_t)
        bool is_same_as(const h_array_short_t&)

    cdef cppclass h_marray_short_t:
        mv_short frozen_read(size_t)
        mv_short write(size_t, mv_short)
        size_t size()
        # TODO uniform_key uuid()
        bool has_value()
        h_marray_base_t as_base()
        
        int16_t add(const size_t&, const int16_t&)
        int16_t sub(const size_t&, const int16_t&)
        int16_t mul(const size_t&, const int16_t&)
        int16_t div(const size_t&, const int16_t&)


    h_marray_short_t create_short_marray(size_t)
    
    cdef cppclass h_array_ushort_t "array_type_handle<mds::api::kind::USHORT>":
        # const_managed_type_handle<K> element_type()
        h_marray_ushort_t create_array(size_t)
        bool is_same_as(const h_array_ushort_t&)

    cdef cppclass h_marray_ushort_t:
        mv_ushort frozen_read(size_t)
        mv_ushort write(size_t, mv_ushort)
        size_t size()
        # TODO uniform_key uuid()
        bool has_value()
        h_marray_base_t as_base()
        
        uint16_t add(const size_t&, const uint16_t&)
        uint16_t sub(const size_t&, const uint16_t&)
        uint16_t mul(const size_t&, const uint16_t&)
        uint16_t div(const size_t&, const uint16_t&)


    h_marray_ushort_t create_ushort_marray(size_t)
    
    cdef cppclass h_array_int_t "array_type_handle<mds::api::kind::INT>":
        # const_managed_type_handle<K> element_type()
        h_marray_int_t create_array(size_t)
        bool is_same_as(const h_array_int_t&)

    cdef cppclass h_marray_int_t:
        mv_int frozen_read(size_t)
        mv_int write(size_t, mv_int)
        size_t size()
        # TODO uniform_key uuid()
        bool has_value()
        h_marray_base_t as_base()
        
        int32_t add(const size_t&, const int32_t&)
        int32_t sub(const size_t&, const int32_t&)
        int32_t mul(const size_t&, const int32_t&)
        int32_t div(const size_t&, const int32_t&)


    h_marray_int_t create_int_marray(size_t)
    
    cdef cppclass h_array_uint_t "array_type_handle<mds::api::kind::UINT>":
        # const_managed_type_handle<K> element_type()
        h_marray_uint_t create_array(size_t)
        bool is_same_as(const h_array_uint_t&)

    cdef cppclass h_marray_uint_t:
        mv_uint frozen_read(size_t)
        mv_uint write(size_t, mv_uint)
        size_t size()
        # TODO uniform_key uuid()
        bool has_value()
        h_marray_base_t as_base()
        
        uint32_t add(const size_t&, const uint32_t&)
        uint32_t sub(const size_t&, const uint32_t&)
        uint32_t mul(const size_t&, const uint32_t&)
        uint32_t div(const size_t&, const uint32_t&)


    h_marray_uint_t create_uint_marray(size_t)
    
    cdef cppclass h_array_long_t "array_type_handle<mds::api::kind::LONG>":
        # const_managed_type_handle<K> element_type()
        h_marray_long_t create_array(size_t)
        bool is_same_as(const h_array_long_t&)

    cdef cppclass h_marray_long_t:
        mv_long frozen_read(size_t)
        mv_long write(size_t, mv_long)
        size_t size()
        # TODO uniform_key uuid()
        bool has_value()
        h_marray_base_t as_base()
        
        int64_t add(const size_t&, const int64_t&)
        int64_t sub(const size_t&, const int64_t&)
        int64_t mul(const size_t&, const int64_t&)
        int64_t div(const size_t&, const int64_t&)


    h_marray_long_t create_long_marray(size_t)
    
    cdef cppclass h_array_ulong_t "array_type_handle<mds::api::kind::ULONG>":
        # const_managed_type_handle<K> element_type()
        h_marray_ulong_t create_array(size_t)
        bool is_same_as(const h_array_ulong_t&)

    cdef cppclass h_marray_ulong_t:
        mv_ulong frozen_read(size_t)
        mv_ulong write(size_t, mv_ulong)
        size_t size()
        # TODO uniform_key uuid()
        bool has_value()
        h_marray_base_t as_base()
        
        uint64_t add(const size_t&, const uint64_t&)
        uint64_t sub(const size_t&, const uint64_t&)
        uint64_t mul(const size_t&, const uint64_t&)
        uint64_t div(const size_t&, const uint64_t&)


    h_marray_ulong_t create_ulong_marray(size_t)
    
    cdef cppclass h_array_float_t "array_type_handle<mds::api::kind::FLOAT>":
        # const_managed_type_handle<K> element_type()
        h_marray_float_t create_array(size_t)
        bool is_same_as(const h_array_float_t&)

    cdef cppclass h_marray_float_t:
        mv_float frozen_read(size_t)
        mv_float write(size_t, mv_float)
        size_t size()
        # TODO uniform_key uuid()
        bool has_value()
        h_marray_base_t as_base()
        
        float add(const size_t&, const float&)
        float sub(const size_t&, const float&)
        float mul(const size_t&, const float&)
        float div(const size_t&, const float&)


    h_marray_float_t create_float_marray(size_t)
    
    cdef cppclass h_array_double_t "array_type_handle<mds::api::kind::DOUBLE>":
        # const_managed_type_handle<K> element_type()
        h_marray_double_t create_array(size_t)
        bool is_same_as(const h_array_double_t&)

    cdef cppclass h_marray_double_t:
        mv_double frozen_read(size_t)
        mv_double write(size_t, mv_double)
        size_t size()
        # TODO uniform_key uuid()
        bool has_value()
        h_marray_base_t as_base()
        
        double add(const size_t&, const double&)
        double sub(const size_t&, const double&)
        double mul(const size_t&, const double&)
        double div(const size_t&, const double&)


    h_marray_double_t create_double_marray(size_t)
    
# END INJECTION

