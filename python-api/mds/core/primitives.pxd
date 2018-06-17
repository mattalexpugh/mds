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
# END INJECTION
