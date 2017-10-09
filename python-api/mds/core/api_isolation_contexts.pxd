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
from libcpp.vector cimport vector

from mds.core.api_tasks cimport task_handle
from mds.core.api_helpers cimport *

cdef extern from "helpers.h" namespace "mds::python::isoctxts":
    @staticmethod
    cdef inline object run_in_iso_ctxt(
        iso_context_handle&,
        object(*)(_py_callable_wrapper),
        _py_callable_wrapper
    ) except+ 

    cdef size_t hash_isoctxt(iso_context_handle &)

# enum classes not (yet) supported, workaround, first declare classes:
cdef extern from "core/core_fwd.h" namespace "mds::core" nogil:
    cdef cppclass view_type:
        pass

    cdef cppclass mod_type:
        pass

# Then, tread the classes as namespaces and make the appropriate declarations:
cdef extern from "core/core_fwd.h" namespace "view_type" nogil:
    cdef view_type live
    cdef view_type snapshot

cdef extern from "core/core_fwd.h" namespace "mod_type" nogil:
    cdef mod_type publishable
    cdef mod_type detached
    cdef mod_type read_only

# Start actually importing the classes and methods we're going to need:
cdef extern from "mds_core_api.h" namespace "mds::api" nogil:
    cdef cppclass publication_attempt_handle :
        publication_attempt_handle()
        publication_attempt_handle(const publication_attempt_handle)

        iso_context_handle source_context()

        vector[task_handle] redo_tasks_by_start_time()
        long n_to_redo()
        bool prepare_for_redo()
        bool succeeded()

    cdef cppclass iso_context_handle:
        iso_context_handle()
        iso_context_handle(const iso_context_handle)

        bool is_snapshot()
        bool is_read_only()
        bool is_publishable()

        iso_context_handle parent()
        # iso_context_handle ro_snapshot_at(core::timestamp_t ts)

        @staticmethod
        iso_context_handle _global "global"()

        @staticmethod
        iso_context_handle for_process()

        # iso_context_handle new_child(view_type vt, mod_type mt) except + 
        iso_context_handle new_snapshot_child() except +
        iso_context_handle new_nonsnapshot_child() except +
        iso_context_handle new_detached_snapshot_child() except +
        iso_context_handle new_detached_nonsnapshot_child() except + 
        iso_context_handle new_read_only_snapshot_child() except +
        iso_context_handle new_read_only_nonsnapshot_child() except +

        publication_attempt_handle publish()
        
        task_handle push_prevailing()
        task_handle top_level_task()
        task_handle creation_task()
        
        bool has_conflicts()
