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

import glob
import os
import os.path
import sys

from typing import Iterable, List
from collections import namedtuple

import mds
from mds import TypeInfo

__generate_specializations = lambda fn: [fn(t) for t in mds.typing.mappings] + ['\n']
__ensure_is_list = lambda elem: [elem] if not isinstance(elem, list) else elem

def find_and_inject(file_path: str, dry_run=True, generator_separator='|') -> None:
    with open(file_path, "r") as fp:
        lines = [l for l in fp]

    Target = namedtuple("Target", ["start", "end", "fn_name"])
    targets = []
    start = None
    fn_name = None

    for i, line in enumerate(lines):
        if f"START INJECTION {generator_separator}" in line:
            start = i + 1
            fn_name = line.split(generator_separator).pop().strip()
        elif start is not None and "END INJECTION" in line:
            targets.append(Target(start, i, fn_name))
            start = fn_name = None

    if not targets:
        return

    # If we're here, we have at least 1 injection point.
    # Let's assume we have N targets and L lines, progressing
    # and doing the injection i=1..N thru 1..L
    chunks = []
    start = 0

    for target in targets:
        chunks.extend(lines[start:target.start])

        try:
            injected = __generate_specializations(globals()[target.fn_name])
            
            if injected is not None:
                chunks.extend(injected)
        except KeyError:
            print(f"The template function `{target.fn_name}` wasn't found.")

        start = target.end

    chunks.extend(lines[start:])

    if dry_run:
        print(file_path)

        for line in chunks:
            print(line)
    else:
        with open(file_path, "w") as fp:
            fp.writelines(chunks)

def generate_and_inject_all_sources(dry_run=True, root=os.getcwd(), exts=('pyx', 'pxd')) -> None:
    print(f"Injecting Cython Wrappers (simulated={dry_run})")

    def get_all_cython_files(root: str, exts: Iterable[str]) -> List[str]:
        paths = set()

        for ext in exts:
            for found in glob.glob(pathname=f"{root}/**/**.{ext}", recursive=True):
                paths.add(found)

        return sorted(list(paths))

    for source in get_all_cython_files(root=root, exts=exts):
        if dry_run:
            print(f"Evaluating {source}")

        find_and_inject(file_path=source, dry_run=dry_run)


# =========================================================================
#  Primitives
# =========================================================================

def tmpl_api_primitives(t: TypeInfo) -> str:
    compiled = f"""
    # BEGIN {t.api}

    cdef cppclass {t.managed_value} "mds::api::api_type<{t.kind}>":
        {t.managed_value}()
        {t.managed_value}({t.c_type})

    cdef cppclass {t.primitive} "mds::api::managed_type_handle<{t.kind}>":
        {t.primitive}()
        # TODO:
        # Throws incompatible_type_ex if the field exists but is of the wrong type
        # Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
        # is true, and the record type is fully created.
        {t.record_field} field_in(record_type_handle&, interned_string_handle&, bool) except+

    cdef {t.primitive} {t.managed_type_handle} "mds::api::managed_type_handle<{t.kind}>"()

    cdef cppclass {t.const_primitive} "mds::api::const_managed_type_handle<{t.kind}>":
        {t.const_primitive}()
        # TODO:
        # Throws incompatible_type_ex if the field exists but is of the wrong type
        # Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
        # is true, and the record type is fully created.
        {t.const_record_field} field_in(record_type_handle&, interned_string_handle&, bool) except+

    cdef {t.const_primitive} {t.const_managed_type_handle} "mds::api::managed_type_handle<{t.kind}>"()
    cdef {t.c_type} to_core_val "mds::api::to_core_val<{t.kind}>" (const {t.managed_value}&)
"""
    return compiled

def tmpl_primitives(t: TypeInfo) -> str:
    compiled = f"""
cdef class {t.title}({t.primitive_parent}):

    cdef {t.managed_value} _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
"""

    if t.taxonomy == TypeInfo.MDS_INTEGRAL:
        compiled += f"""
    property MIN:
        def __get__(self):
            return {t.bounds.min}

    property MAX:
        def __get__(self):
            return {t.bounds.max} 
"""
    return compiled

# =========================================================================
#  Namespaces
# =========================================================================

def tmpl_api_namespaces(t: TypeInfo) -> str:
    compiled = f"""
        {t.c_type} lookup "lookup<{t.kind},mds::core::kind_type<{t.kind}>,false,true>"(interned_string_handle, const {t.primitive}&)
        {t.managed_array} lookup "lookup<{t.kind},false,true>"(const interned_string_handle&, const {t.array}&)
        bool bind "bind<{t.kind}>"(interned_string_handle, {t.c_type})
    """
    return compiled

# =========================================================================
#  Records
# =========================================================================

def tmpl_api_records(t: TypeInfo) -> str:
    EXTRA = ""
    compiled = ""

    if t.use_atomic_math:
        EXTRA = f"""
        {t.c_type} add(const managed_record_handle&, {t.c_type})
        {t.c_type} sub(const managed_record_handle&, {t.c_type})
        {t.c_type} mul(const managed_record_handle&, {t.c_type})
        {t.c_type} div(const managed_record_handle&, {t.c_type})
"""

    for prefix in ("", "const_"):
        wrapper_name = t.record_field if prefix == "" else t.const_record_field
        compiled += f"""
    cdef cppclass {wrapper_name} "mds::api::{prefix}record_field_handle<{t.kind}>":
        {wrapper_name}()
        {wrapper_name}({wrapper_name}&)
        {t.c_type} free_read(const managed_record_handle&)
        {t.c_type} frozen_read(const managed_record_handle&)

        bool has_value(const managed_record_handle&)
        bool write_initial(const managed_record_handle&,const {t.c_type}&)
        bool is_null()

        {t.c_type} write(const managed_record_handle&, const {t.c_type}&)
        interned_string_handle name()
        {EXTRA}
        const_record_type_handle rec_type()
        #const_type_handle_for<K> field_type()
"""
    return compiled

def tmpl_record_field(t: TypeInfo) -> str:
    compiled = f"""
cdef class {t.title_record_field}(MDSRecordFieldBase):
    cdef:
        {t.record_field} _handle
        {t.primitive} _mtype

    def declare(self, String name, MDSRecordTypeDeclaration rt):
        assert self._handle.is_null()
        self._handle = self._mtype.field_in(rt._declared_type, name._ish, True)

    @staticmethod
    def get_reference_type(make_const=False) -> type:
        if make_const:
            return {t.title_const_record_field_reference}

        return {t.title_record_field_reference}
"""
    return compiled

def tmpl_record_field_reference(t: TypeInfo) -> str:
    """
    TODO:
        1. Change to python 3 annotation when upgrade to Cython 0.28
    """
    compiled = f"""
cdef class {t.title_const_record_field_reference}(MDSConstRecordFieldReferenceBase):
    cdef:
        {t.record_field} _field_handle
        Record _record

    def __cinit__(self, {t.title_record_field} field, Record record):
        self._record = record
        self._field_handle = {t.record_field}(field._handle)
        self._record_handle = managed_record_handle(record._handle)

    def read(self):
        cdef {t.c_type} retval = self._field_handle.frozen_read(self._record_handle)
        return retval

    def peek(self):
        cdef {t.c_type} retval = self._field_handle.free_read(self._record_handle)
        return retval


cdef class {t.title_record_field_reference}({t.title_const_record_field_reference}):
    
    def write(self, value):
        self._field_handle.write(self._record_handle, <{t.c_type}> (value))
"""
    
    if t.use_atomic_math:
        compiled += f"""
    def __iadd__(self, other):
        self._field_handle.add(self._record_handle, <{t.c_type}> (other))

    def __isub__(self, other):
        self._field_handle.sub(self._record_handle, <{t.c_type}> (other))

    def __imul__(self, other):
        self._field_handle.mul(self._record_handle, <{t.c_type}> (other))

    def __idiv__(self, other):
        self._field_handle.div(self._record_handle, <{t.c_type}> (other))
"""

    return compiled

def tmpl_record_member(t: TypeInfo) -> str:
    compiled = f"""
cdef class {t.title_const_record_member}(MDSConstRecordMemberBase):
    cdef {t.c_type} _cached_val

    def _field_ref(self) -> MDSConstRecordFieldReferenceBase:
        return {t.title_record_field}()[self]

    def read(self):
        if not self._is_cached:
            field_ref = self._field_ref()
            self._cached_val = field_ref.read()
            self._is_cached = True

        return self._cached_val

    def peek(self):
        return self.read()

cdef class {t.title_record_member}(MDSRecordMemberBase):

    def _field_ref(self) -> MDSConstRecordFieldReferenceBase:
        return {t.title_record_field}()[self]

    def read(self):
        return self._field_ref().read()

    def peek(self):
        return self._field_ref().peek()

    def write(self, value) -> None:
        self._field_ref().write(<{t.c_type}> value);
"""
    if t.use_atomic_math:
        compiled += f"""
    def __iadd__(self, other):
        ref = self._field_ref()
        ref += other

    def __isub__(self, other):
        ref = self._field_ref()
        ref -= other

    def __imul__(self, other):
        ref = self._field_ref()
        ref *= other

    def __idiv__(self, other):
        ref = self._field_ref()
        ref /= other
"""

    return compiled

# =========================================================================
#  Arrays
# =========================================================================

def tmpl_array(t: TypeInfo) -> str:
    compiled = f"""
cdef inline {t.title_array_cinit}({t.title_array} cls, size_t length):
    cls._handle = {t.f_create_array}(length)

cdef class {t.title_array}({t.array_parent}):

    cdef {t.managed_array} _handle
    _primitive = {t.title}

    def __cinit__(self, length=None):
        if length is not None:
            {t.title_array_cinit}(self, length)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, {t.managed_value}(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t n = len(self)

        retval = {t.title_array}(length=len(self))

        for i in range(n):
            retval[i] = self[i]

        return retval
"""

    if t.use_atomic_math:
        compiled += f"""
    def __iadd__(self, other):
        return self._handle.add(self._last_index, <{t.c_type}> other)

    def __isub__(self, other):
        return self._handle.sub(self._last_index, <{t.c_type}> other)

    def __imul__(self, other):
        return self._handle.mul(self._last_index, <{t.c_type}> other)

    def __idiv__(self, other):
        return self._handle.div(self._last_index, <{t.c_type}> other)
"""

    # Sometimes we need to be creative to coerce the correct Python type
    if t.python_type is not None:
        compiled += f"""
    property dtype:
        def __get__(self):
            return type({t.python_type})
"""
    return compiled

def tmpl_api_arrays(t: TypeInfo) -> str:
    EXTRA = ""

    if t.use_atomic_math:
        EXTRA = f"""
        {t.c_type} add(const size_t&, const {t.c_type}&)
        {t.c_type} sub(const size_t&, const {t.c_type}&)
        {t.c_type} mul(const size_t&, const {t.c_type}&)
        {t.c_type} div(const size_t&, const {t.c_type}&)
"""
    compiled = f"""
    cdef cppclass {t.array} "mds::api::array_type_handle<{t.kind}>":
        # const_managed_type_handle<K> element_type()
        {t.managed_array} create_array(size_t)
        bool is_same_as(const {t.array}&)

    cdef cppclass {t.managed_array}:
        {t.managed_value} frozen_read(size_t)
        {t.managed_value} write(size_t, {t.managed_value})
        size_t size()
        bool has_value()
        h_marray_base_t as_base()
        {EXTRA}
    {t.managed_array} {t.f_create_array}(size_t)
"""
    return compiled

# =========================================================================
#  Run
# =========================================================================

if __name__ == '__main__':
    for arg in sys.argv:
        if 'dry' in arg:
            generate_and_inject_all_sources(dry_run=True)
            break
    else:
        generate_and_inject_all_sources(dry_run=False)
