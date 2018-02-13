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

from mds.core.records cimport *
from mds.core.strings cimport h_istring_t, h_istring_t

cdef extern from "mds_core_api.h" namespace "mds::api" nogil:
    # TODO Not sure these guys are correct, or are the same as below...
    # NOTE string at least could just go into the injection
    cdef cppclass mv_string "mv_wrapper<mds::api::kind::STRING>":
        pass

    cdef cppclass mv_array "mv_wrapper<mds::api::kind::ARRAY>":
        pass

    cdef cppclass mv_record "mv_wrapper<mds::api::kind::RECORD>":
        pass

# START INJECTION | tmpl_api_primitives(Primitives)

    # BEGIN bool
    # field_in:
    #  * Throws incompatible_type_ex if the field exists but is of the wrong type
    #  * Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    #    is true, and the record type is fully created.

    cdef cppclass mv_bool "mds::api::api_type<mds::api::kind::BOOL>":
        mv_bool()
        mv_bool(bool)
        uint64_t hash1()

    cdef cppclass h_mbool_t "mds::api::managed_type_handle<mds::api::kind::BOOL>":
        h_mbool_t()
        h_rfield_bool_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef cppclass h_const_mbool_t "mds::api::const_managed_type_handle<mds::api::kind::BOOL>":
        h_const_mbool_t()
        h_rfield_bool_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef h_mbool_t managed_bool_type_handle "mds::api::managed_type_handle<mds::api::kind::BOOL>"()
    cdef h_const_mbool_t const_managed_bool_type_handle "mds::api::managed_type_handle<mds::api::kind::BOOL>"()
    bool bool_to_core_val "mds::api::to_core_val<mds::api::kind::BOOL>" (const mv_bool&)


    # BEGIN byte
    # field_in:
    #  * Throws incompatible_type_ex if the field exists but is of the wrong type
    #  * Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    #    is true, and the record type is fully created.

    cdef cppclass mv_byte "mds::api::api_type<mds::api::kind::BYTE>":
        mv_byte()
        mv_byte(int8_t)
        uint64_t hash1()

    cdef cppclass h_mbyte_t "mds::api::managed_type_handle<mds::api::kind::BYTE>":
        h_mbyte_t()
        h_rfield_byte_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef cppclass h_const_mbyte_t "mds::api::const_managed_type_handle<mds::api::kind::BYTE>":
        h_const_mbyte_t()
        h_rfield_byte_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef h_mbyte_t managed_byte_type_handle "mds::api::managed_type_handle<mds::api::kind::BYTE>"()
    cdef h_const_mbyte_t const_managed_byte_type_handle "mds::api::managed_type_handle<mds::api::kind::BYTE>"()
    int8_t byte_to_core_val "mds::api::to_core_val<mds::api::kind::BYTE>" (const mv_byte&)


    # BEGIN ubyte
    # field_in:
    #  * Throws incompatible_type_ex if the field exists but is of the wrong type
    #  * Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    #    is true, and the record type is fully created.

    cdef cppclass mv_ubyte "mds::api::api_type<mds::api::kind::UBYTE>":
        mv_ubyte()
        mv_ubyte(uint8_t)
        uint64_t hash1()

    cdef cppclass h_mubyte_t "mds::api::managed_type_handle<mds::api::kind::UBYTE>":
        h_mubyte_t()
        h_rfield_ubyte_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef cppclass h_const_mubyte_t "mds::api::const_managed_type_handle<mds::api::kind::UBYTE>":
        h_const_mubyte_t()
        h_rfield_ubyte_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef h_mubyte_t managed_ubyte_type_handle "mds::api::managed_type_handle<mds::api::kind::UBYTE>"()
    cdef h_const_mubyte_t const_managed_ubyte_type_handle "mds::api::managed_type_handle<mds::api::kind::UBYTE>"()
    uint8_t ubyte_to_core_val "mds::api::to_core_val<mds::api::kind::UBYTE>" (const mv_ubyte&)


    # BEGIN short
    # field_in:
    #  * Throws incompatible_type_ex if the field exists but is of the wrong type
    #  * Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    #    is true, and the record type is fully created.

    cdef cppclass mv_short "mds::api::api_type<mds::api::kind::SHORT>":
        mv_short()
        mv_short(int16_t)
        uint64_t hash1()

    cdef cppclass h_mshort_t "mds::api::managed_type_handle<mds::api::kind::SHORT>":
        h_mshort_t()
        h_rfield_short_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef cppclass h_const_mshort_t "mds::api::const_managed_type_handle<mds::api::kind::SHORT>":
        h_const_mshort_t()
        h_rfield_short_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef h_mshort_t managed_short_type_handle "mds::api::managed_type_handle<mds::api::kind::SHORT>"()
    cdef h_const_mshort_t const_managed_short_type_handle "mds::api::managed_type_handle<mds::api::kind::SHORT>"()
    int16_t short_to_core_val "mds::api::to_core_val<mds::api::kind::SHORT>" (const mv_short&)


    # BEGIN ushort
    # field_in:
    #  * Throws incompatible_type_ex if the field exists but is of the wrong type
    #  * Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    #    is true, and the record type is fully created.

    cdef cppclass mv_ushort "mds::api::api_type<mds::api::kind::USHORT>":
        mv_ushort()
        mv_ushort(uint16_t)
        uint64_t hash1()

    cdef cppclass h_mushort_t "mds::api::managed_type_handle<mds::api::kind::USHORT>":
        h_mushort_t()
        h_rfield_ushort_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef cppclass h_const_mushort_t "mds::api::const_managed_type_handle<mds::api::kind::USHORT>":
        h_const_mushort_t()
        h_rfield_ushort_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef h_mushort_t managed_ushort_type_handle "mds::api::managed_type_handle<mds::api::kind::USHORT>"()
    cdef h_const_mushort_t const_managed_ushort_type_handle "mds::api::managed_type_handle<mds::api::kind::USHORT>"()
    uint16_t ushort_to_core_val "mds::api::to_core_val<mds::api::kind::USHORT>" (const mv_ushort&)


    # BEGIN int
    # field_in:
    #  * Throws incompatible_type_ex if the field exists but is of the wrong type
    #  * Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    #    is true, and the record type is fully created.

    cdef cppclass mv_int "mds::api::api_type<mds::api::kind::INT>":
        mv_int()
        mv_int(int32_t)
        uint64_t hash1()

    cdef cppclass h_mint_t "mds::api::managed_type_handle<mds::api::kind::INT>":
        h_mint_t()
        h_rfield_int_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef cppclass h_const_mint_t "mds::api::const_managed_type_handle<mds::api::kind::INT>":
        h_const_mint_t()
        h_rfield_int_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef h_mint_t managed_int_type_handle "mds::api::managed_type_handle<mds::api::kind::INT>"()
    cdef h_const_mint_t const_managed_int_type_handle "mds::api::managed_type_handle<mds::api::kind::INT>"()
    int32_t int_to_core_val "mds::api::to_core_val<mds::api::kind::INT>" (const mv_int&)


    # BEGIN uint
    # field_in:
    #  * Throws incompatible_type_ex if the field exists but is of the wrong type
    #  * Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    #    is true, and the record type is fully created.

    cdef cppclass mv_uint "mds::api::api_type<mds::api::kind::UINT>":
        mv_uint()
        mv_uint(uint32_t)
        uint64_t hash1()

    cdef cppclass h_muint_t "mds::api::managed_type_handle<mds::api::kind::UINT>":
        h_muint_t()
        h_rfield_uint_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef cppclass h_const_muint_t "mds::api::const_managed_type_handle<mds::api::kind::UINT>":
        h_const_muint_t()
        h_rfield_uint_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef h_muint_t managed_uint_type_handle "mds::api::managed_type_handle<mds::api::kind::UINT>"()
    cdef h_const_muint_t const_managed_uint_type_handle "mds::api::managed_type_handle<mds::api::kind::UINT>"()
    uint32_t uint_to_core_val "mds::api::to_core_val<mds::api::kind::UINT>" (const mv_uint&)


    # BEGIN long
    # field_in:
    #  * Throws incompatible_type_ex if the field exists but is of the wrong type
    #  * Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    #    is true, and the record type is fully created.

    cdef cppclass mv_long "mds::api::api_type<mds::api::kind::LONG>":
        mv_long()
        mv_long(int64_t)
        uint64_t hash1()

    cdef cppclass h_mlong_t "mds::api::managed_type_handle<mds::api::kind::LONG>":
        h_mlong_t()
        h_rfield_long_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef cppclass h_const_mlong_t "mds::api::const_managed_type_handle<mds::api::kind::LONG>":
        h_const_mlong_t()
        h_rfield_long_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef h_mlong_t managed_long_type_handle "mds::api::managed_type_handle<mds::api::kind::LONG>"()
    cdef h_const_mlong_t const_managed_long_type_handle "mds::api::managed_type_handle<mds::api::kind::LONG>"()
    int64_t long_to_core_val "mds::api::to_core_val<mds::api::kind::LONG>" (const mv_long&)


    # BEGIN ulong
    # field_in:
    #  * Throws incompatible_type_ex if the field exists but is of the wrong type
    #  * Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    #    is true, and the record type is fully created.

    cdef cppclass mv_ulong "mds::api::api_type<mds::api::kind::ULONG>":
        mv_ulong()
        mv_ulong(uint64_t)
        uint64_t hash1()

    cdef cppclass h_mulong_t "mds::api::managed_type_handle<mds::api::kind::ULONG>":
        h_mulong_t()
        h_rfield_ulong_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef cppclass h_const_mulong_t "mds::api::const_managed_type_handle<mds::api::kind::ULONG>":
        h_const_mulong_t()
        h_rfield_ulong_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef h_mulong_t managed_ulong_type_handle "mds::api::managed_type_handle<mds::api::kind::ULONG>"()
    cdef h_const_mulong_t const_managed_ulong_type_handle "mds::api::managed_type_handle<mds::api::kind::ULONG>"()
    uint64_t ulong_to_core_val "mds::api::to_core_val<mds::api::kind::ULONG>" (const mv_ulong&)


    # BEGIN float
    # field_in:
    #  * Throws incompatible_type_ex if the field exists but is of the wrong type
    #  * Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    #    is true, and the record type is fully created.

    cdef cppclass mv_float "mds::api::api_type<mds::api::kind::FLOAT>":
        mv_float()
        mv_float(float)
        uint64_t hash1()

    cdef cppclass h_mfloat_t "mds::api::managed_type_handle<mds::api::kind::FLOAT>":
        h_mfloat_t()
        h_rfield_float_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef cppclass h_const_mfloat_t "mds::api::const_managed_type_handle<mds::api::kind::FLOAT>":
        h_const_mfloat_t()
        h_rfield_float_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef h_mfloat_t managed_float_type_handle "mds::api::managed_type_handle<mds::api::kind::FLOAT>"()
    cdef h_const_mfloat_t const_managed_float_type_handle "mds::api::managed_type_handle<mds::api::kind::FLOAT>"()
    float float_to_core_val "mds::api::to_core_val<mds::api::kind::FLOAT>" (const mv_float&)


    # BEGIN double
    # field_in:
    #  * Throws incompatible_type_ex if the field exists but is of the wrong type
    #  * Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    #    is true, and the record type is fully created.

    cdef cppclass mv_double "mds::api::api_type<mds::api::kind::DOUBLE>":
        mv_double()
        mv_double(double)
        uint64_t hash1()

    cdef cppclass h_mdouble_t "mds::api::managed_type_handle<mds::api::kind::DOUBLE>":
        h_mdouble_t()
        h_rfield_double_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef cppclass h_const_mdouble_t "mds::api::const_managed_type_handle<mds::api::kind::DOUBLE>":
        h_const_mdouble_t()
        h_rfield_double_t field_in(h_record_type_t&, h_istring_t&, bool) except+
        uint64_t hash1()

    cdef h_mdouble_t managed_double_type_handle "mds::api::managed_type_handle<mds::api::kind::DOUBLE>"()
    cdef h_const_mdouble_t const_managed_double_type_handle "mds::api::managed_type_handle<mds::api::kind::DOUBLE>"()
    double double_to_core_val "mds::api::to_core_val<mds::api::kind::DOUBLE>" (const mv_double&)

# END INJECTION
