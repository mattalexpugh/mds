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

from libc.stdint cimport *
from libcpp cimport bool

from mds.core.api_strings cimport interned_string_handle

cdef extern from "mds_core_api.h" namespace "mds::api" nogil:
    cdef cppclass managed_record_handle:
        managed_record_handle()
        managed_record_handle(managed_record_handle&)

    cdef cppclass const_managed_record_handle:
        const_managed_record_handle()
        const_managed_record_handle(const_managed_record_handle&)

    cdef cppclass record_type_handle:
        record_type_handle()
        record_type_handle(record_type_handle &)
        record_type_handle(managed_record_handle&)
        record_type_handle(const_managed_record_handle&)

        managed_record_handle create_record()
        interned_string_handle name()

        bool is_created()
        bool is_null()
        bool is_same_as(record_type_handle&)
        bool is_super_of(record_type_handle&)
        bool operator!=(record_type_handle&)

        const_record_type_handle super_type()
        const_record_type_handle ensure_created()
        @staticmethod
        const_record_type_handle find(const interned_string_handle&)
        @staticmethod
        record_type_handle declare(const interned_string_handle&)
        @staticmethod
        record_type_handle declare(const interned_string_handle&, const_record_type_handle&)

    cdef cppclass const_record_type_handle:
        const_record_type_handle()
        const_record_type_handle(const_record_type_handle &)
        const_record_type_handle(managed_record_handle&)
        const_record_type_handle(const_managed_record_handle&)

        managed_record_handle create_record()
        interned_string_handle name()

        bool is_created()
        bool is_null()
        bool is_same_as(const_record_type_handle&)
        bool is_super_of(const_record_type_handle&)
        bool operator!=(const_record_type_handle&)

        const_record_type_handle super_type()
        const_record_type_handle ensure_created()
        @staticmethod
        const_record_type_handle find(const interned_string_handle&)
        @staticmethod
        record_type_handle declare(const interned_string_handle&)
        @staticmethod
        record_type_handle declare(const interned_string_handle&, const_record_type_handle&)

# START INJECTION | tmpl_api_records

    cdef cppclass h_rfield_bool_t "mds::api::record_field_handle<mds::api::kind::BOOL>":
        h_rfield_bool_t()
        h_rfield_bool_t(h_rfield_bool_t&)
        bool free_read(const managed_record_handle&)
        bool frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const bool&)
        bool is_null()

        bool write(const managed_record_handle&, const bool&)
        interned_string_handle name()
        
        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_const_rfield_bool_t "mds::api::const_record_field_handle<mds::api::kind::BOOL>":
        h_const_rfield_bool_t()
        h_const_rfield_bool_t(h_const_rfield_bool_t&)
        bool free_read(const managed_record_handle&)
        bool frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const bool&)
        bool is_null()

        bool write(const managed_record_handle&, const bool&)
        interned_string_handle name()
        
        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_rfield_byte_t "mds::api::record_field_handle<mds::api::kind::BYTE>":
        h_rfield_byte_t()
        h_rfield_byte_t(h_rfield_byte_t&)
        int8_t free_read(const managed_record_handle&)
        int8_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const int8_t&)
        bool is_null()

        int8_t write(const managed_record_handle&, const int8_t&)
        interned_string_handle name()
        
        int8_t add(const managed_record_handle&, int8_t)
        int8_t sub(const managed_record_handle&, int8_t)
        int8_t mul(const managed_record_handle&, int8_t)
        int8_t div(const managed_record_handle&, int8_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_const_rfield_byte_t "mds::api::const_record_field_handle<mds::api::kind::BYTE>":
        h_const_rfield_byte_t()
        h_const_rfield_byte_t(h_const_rfield_byte_t&)
        int8_t free_read(const managed_record_handle&)
        int8_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const int8_t&)
        bool is_null()

        int8_t write(const managed_record_handle&, const int8_t&)
        interned_string_handle name()
        
        int8_t add(const managed_record_handle&, int8_t)
        int8_t sub(const managed_record_handle&, int8_t)
        int8_t mul(const managed_record_handle&, int8_t)
        int8_t div(const managed_record_handle&, int8_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_rfield_ubyte_t "mds::api::record_field_handle<mds::api::kind::UBYTE>":
        h_rfield_ubyte_t()
        h_rfield_ubyte_t(h_rfield_ubyte_t&)
        uint8_t free_read(const managed_record_handle&)
        uint8_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const uint8_t&)
        bool is_null()

        uint8_t write(const managed_record_handle&, const uint8_t&)
        interned_string_handle name()
        
        uint8_t add(const managed_record_handle&, uint8_t)
        uint8_t sub(const managed_record_handle&, uint8_t)
        uint8_t mul(const managed_record_handle&, uint8_t)
        uint8_t div(const managed_record_handle&, uint8_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_const_rfield_ubyte_t "mds::api::const_record_field_handle<mds::api::kind::UBYTE>":
        h_const_rfield_ubyte_t()
        h_const_rfield_ubyte_t(h_const_rfield_ubyte_t&)
        uint8_t free_read(const managed_record_handle&)
        uint8_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const uint8_t&)
        bool is_null()

        uint8_t write(const managed_record_handle&, const uint8_t&)
        interned_string_handle name()
        
        uint8_t add(const managed_record_handle&, uint8_t)
        uint8_t sub(const managed_record_handle&, uint8_t)
        uint8_t mul(const managed_record_handle&, uint8_t)
        uint8_t div(const managed_record_handle&, uint8_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_rfield_short_t "mds::api::record_field_handle<mds::api::kind::SHORT>":
        h_rfield_short_t()
        h_rfield_short_t(h_rfield_short_t&)
        int16_t free_read(const managed_record_handle&)
        int16_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const int16_t&)
        bool is_null()

        int16_t write(const managed_record_handle&, const int16_t&)
        interned_string_handle name()
        
        int16_t add(const managed_record_handle&, int16_t)
        int16_t sub(const managed_record_handle&, int16_t)
        int16_t mul(const managed_record_handle&, int16_t)
        int16_t div(const managed_record_handle&, int16_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_const_rfield_short_t "mds::api::const_record_field_handle<mds::api::kind::SHORT>":
        h_const_rfield_short_t()
        h_const_rfield_short_t(h_const_rfield_short_t&)
        int16_t free_read(const managed_record_handle&)
        int16_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const int16_t&)
        bool is_null()

        int16_t write(const managed_record_handle&, const int16_t&)
        interned_string_handle name()
        
        int16_t add(const managed_record_handle&, int16_t)
        int16_t sub(const managed_record_handle&, int16_t)
        int16_t mul(const managed_record_handle&, int16_t)
        int16_t div(const managed_record_handle&, int16_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_rfield_ushort_t "mds::api::record_field_handle<mds::api::kind::USHORT>":
        h_rfield_ushort_t()
        h_rfield_ushort_t(h_rfield_ushort_t&)
        uint16_t free_read(const managed_record_handle&)
        uint16_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const uint16_t&)
        bool is_null()

        uint16_t write(const managed_record_handle&, const uint16_t&)
        interned_string_handle name()
        
        uint16_t add(const managed_record_handle&, uint16_t)
        uint16_t sub(const managed_record_handle&, uint16_t)
        uint16_t mul(const managed_record_handle&, uint16_t)
        uint16_t div(const managed_record_handle&, uint16_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_const_rfield_ushort_t "mds::api::const_record_field_handle<mds::api::kind::USHORT>":
        h_const_rfield_ushort_t()
        h_const_rfield_ushort_t(h_const_rfield_ushort_t&)
        uint16_t free_read(const managed_record_handle&)
        uint16_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const uint16_t&)
        bool is_null()

        uint16_t write(const managed_record_handle&, const uint16_t&)
        interned_string_handle name()
        
        uint16_t add(const managed_record_handle&, uint16_t)
        uint16_t sub(const managed_record_handle&, uint16_t)
        uint16_t mul(const managed_record_handle&, uint16_t)
        uint16_t div(const managed_record_handle&, uint16_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_rfield_int_t "mds::api::record_field_handle<mds::api::kind::INT>":
        h_rfield_int_t()
        h_rfield_int_t(h_rfield_int_t&)
        int32_t free_read(const managed_record_handle&)
        int32_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const int32_t&)
        bool is_null()

        int32_t write(const managed_record_handle&, const int32_t&)
        interned_string_handle name()
        
        int32_t add(const managed_record_handle&, int32_t)
        int32_t sub(const managed_record_handle&, int32_t)
        int32_t mul(const managed_record_handle&, int32_t)
        int32_t div(const managed_record_handle&, int32_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_const_rfield_int_t "mds::api::const_record_field_handle<mds::api::kind::INT>":
        h_const_rfield_int_t()
        h_const_rfield_int_t(h_const_rfield_int_t&)
        int32_t free_read(const managed_record_handle&)
        int32_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const int32_t&)
        bool is_null()

        int32_t write(const managed_record_handle&, const int32_t&)
        interned_string_handle name()
        
        int32_t add(const managed_record_handle&, int32_t)
        int32_t sub(const managed_record_handle&, int32_t)
        int32_t mul(const managed_record_handle&, int32_t)
        int32_t div(const managed_record_handle&, int32_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_rfield_uint_t "mds::api::record_field_handle<mds::api::kind::UINT>":
        h_rfield_uint_t()
        h_rfield_uint_t(h_rfield_uint_t&)
        uint32_t free_read(const managed_record_handle&)
        uint32_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const uint32_t&)
        bool is_null()

        uint32_t write(const managed_record_handle&, const uint32_t&)
        interned_string_handle name()
        
        uint32_t add(const managed_record_handle&, uint32_t)
        uint32_t sub(const managed_record_handle&, uint32_t)
        uint32_t mul(const managed_record_handle&, uint32_t)
        uint32_t div(const managed_record_handle&, uint32_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_const_rfield_uint_t "mds::api::const_record_field_handle<mds::api::kind::UINT>":
        h_const_rfield_uint_t()
        h_const_rfield_uint_t(h_const_rfield_uint_t&)
        uint32_t free_read(const managed_record_handle&)
        uint32_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const uint32_t&)
        bool is_null()

        uint32_t write(const managed_record_handle&, const uint32_t&)
        interned_string_handle name()
        
        uint32_t add(const managed_record_handle&, uint32_t)
        uint32_t sub(const managed_record_handle&, uint32_t)
        uint32_t mul(const managed_record_handle&, uint32_t)
        uint32_t div(const managed_record_handle&, uint32_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_rfield_long_t "mds::api::record_field_handle<mds::api::kind::LONG>":
        h_rfield_long_t()
        h_rfield_long_t(h_rfield_long_t&)
        int64_t free_read(const managed_record_handle&)
        int64_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const int64_t&)
        bool is_null()

        int64_t write(const managed_record_handle&, const int64_t&)
        interned_string_handle name()
        
        int64_t add(const managed_record_handle&, int64_t)
        int64_t sub(const managed_record_handle&, int64_t)
        int64_t mul(const managed_record_handle&, int64_t)
        int64_t div(const managed_record_handle&, int64_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_const_rfield_long_t "mds::api::const_record_field_handle<mds::api::kind::LONG>":
        h_const_rfield_long_t()
        h_const_rfield_long_t(h_const_rfield_long_t&)
        int64_t free_read(const managed_record_handle&)
        int64_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const int64_t&)
        bool is_null()

        int64_t write(const managed_record_handle&, const int64_t&)
        interned_string_handle name()
        
        int64_t add(const managed_record_handle&, int64_t)
        int64_t sub(const managed_record_handle&, int64_t)
        int64_t mul(const managed_record_handle&, int64_t)
        int64_t div(const managed_record_handle&, int64_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_rfield_ulong_t "mds::api::record_field_handle<mds::api::kind::ULONG>":
        h_rfield_ulong_t()
        h_rfield_ulong_t(h_rfield_ulong_t&)
        uint64_t free_read(const managed_record_handle&)
        uint64_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const uint64_t&)
        bool is_null()

        uint64_t write(const managed_record_handle&, const uint64_t&)
        interned_string_handle name()
        
        uint64_t add(const managed_record_handle&, uint64_t)
        uint64_t sub(const managed_record_handle&, uint64_t)
        uint64_t mul(const managed_record_handle&, uint64_t)
        uint64_t div(const managed_record_handle&, uint64_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_const_rfield_ulong_t "mds::api::const_record_field_handle<mds::api::kind::ULONG>":
        h_const_rfield_ulong_t()
        h_const_rfield_ulong_t(h_const_rfield_ulong_t&)
        uint64_t free_read(const managed_record_handle&)
        uint64_t frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const uint64_t&)
        bool is_null()

        uint64_t write(const managed_record_handle&, const uint64_t&)
        interned_string_handle name()
        
        uint64_t add(const managed_record_handle&, uint64_t)
        uint64_t sub(const managed_record_handle&, uint64_t)
        uint64_t mul(const managed_record_handle&, uint64_t)
        uint64_t div(const managed_record_handle&, uint64_t)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_rfield_float_t "mds::api::record_field_handle<mds::api::kind::FLOAT>":
        h_rfield_float_t()
        h_rfield_float_t(h_rfield_float_t&)
        float free_read(const managed_record_handle&)
        float frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const float&)
        bool is_null()

        float write(const managed_record_handle&, const float&)
        interned_string_handle name()
        
        float add(const managed_record_handle&, float)
        float sub(const managed_record_handle&, float)
        float mul(const managed_record_handle&, float)
        float div(const managed_record_handle&, float)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_const_rfield_float_t "mds::api::const_record_field_handle<mds::api::kind::FLOAT>":
        h_const_rfield_float_t()
        h_const_rfield_float_t(h_const_rfield_float_t&)
        float free_read(const managed_record_handle&)
        float frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const float&)
        bool is_null()

        float write(const managed_record_handle&, const float&)
        interned_string_handle name()
        
        float add(const managed_record_handle&, float)
        float sub(const managed_record_handle&, float)
        float mul(const managed_record_handle&, float)
        float div(const managed_record_handle&, float)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_rfield_double_t "mds::api::record_field_handle<mds::api::kind::DOUBLE>":
        h_rfield_double_t()
        h_rfield_double_t(h_rfield_double_t&)
        double free_read(const managed_record_handle&)
        double frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const double&)
        bool is_null()

        double write(const managed_record_handle&, const double&)
        interned_string_handle name()
        
        double add(const managed_record_handle&, double)
        double sub(const managed_record_handle&, double)
        double mul(const managed_record_handle&, double)
        double div(const managed_record_handle&, double)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

    cdef cppclass h_const_rfield_double_t "mds::api::const_record_field_handle<mds::api::kind::DOUBLE>":
        h_const_rfield_double_t()
        h_const_rfield_double_t(h_const_rfield_double_t&)
        double free_read(const managed_record_handle&)
        double frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const double&)
        bool is_null()

        double write(const managed_record_handle&, const double&)
        interned_string_handle name()
        
        double add(const managed_record_handle&, double)
        double sub(const managed_record_handle&, double)
        double mul(const managed_record_handle&, double)
        double div(const managed_record_handle&, double)

        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()

# END INJECTION

