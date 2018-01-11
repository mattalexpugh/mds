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

from mds.core.mpgc cimport *


cdef class MemoryStats(object):
    """
    Provides a read-only interface to the low-level MPGC statistics.
    """

    def __cinit__(self):
        initialize_thread()

    def __str__(self):
        return f"""
MPGC Statistics:
    Cycle Number:           {self.cycle_number}
    Number of Processes:    {self.num_processes}
    Bytes:
        In Heap:            {self.bytes_in_heap}
        In Use:             {self.bytes_in_use}
        Currently In Use:   {self.bytes_currently_in_use}
    Objects:
        Number:             {self.num_objects}
        Current Number:     {self.num_current_objects}
    """.strip()

    property bytes_in_heap:
        def __get__(self):
            return control_block().mem_stats.bytes_in_heap()
            
    property bytes_in_use:
        def __get__(self):
            return control_block().mem_stats.bytes_in_use()
            
    property bytes_currently_in_use:
        def __get__(self):
            return control_block().mem_stats.bytes_currently_in_use()
            
    property bytes_free:
        def __get__(self):
            return control_block().mem_stats.bytes_free()
            
    property cycle_number:
        def __get__(self):
            return control_block().mem_stats.cycle_number()
            
    property num_processes:
        def __get__(self):
            return control_block().mem_stats.n_processes()
            
    property num_objects:
        def __get__(self):
            return control_block().mem_stats.n_objects()
            
    property num_current_objects:
        def __get__(self):
            return control_block().mem_stats.n_current_objects()
