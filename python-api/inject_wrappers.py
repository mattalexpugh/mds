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

from collections import namedtuple
from itertools import chain
from typing import Dict, Iterable, List, Text

import mds
from mds import MDSTypeInfo

TYPE_GROUPINGS = {
    'Primitives': mds.typing.primitives,
    'Composites': mds.typing.composites,
    'Arrays': mds.typing.arrays
}

__ensure_is_list = lambda elem: [elem] if not isinstance(elem, list) else elem

Payload = namedtuple('Payload', ['fn', 'targets'])
Target = namedtuple('Target', ['start', 'end', 'payload'])

def get_injection_payload(line: Text) -> Payload:
    line = line.split('|').pop().strip()
    print(line)
    # Now line is in the form tmpl_<id>([Group1, ...])
    # We could use regex, but that seems like too much work.
    line = line[:-1]
    fn_name, groups = line.split('(')
    groups = [TYPE_GROUPINGS[t] for t in groups.split(',')]

    return Payload(
        fn=globals()[fn_name],
        targets=chain(*[x.items() for x in groups])
    )


def find_and_inject(file_path: str, dry_run=True) -> None:
    with open(file_path, "r") as fp:
        lines = [l for l in fp]

    injection_points = []
    start = None
    payload = None

    for i, line in enumerate(lines):
        if "START INJECTION" in line:
            start = i + 1
            payload = get_injection_payload(line)
        elif start is not None and "END INJECTION" in line:
            injection_points.append(
                Target(start=start, end=i, payload=payload)
            )
            start = payload = None

    if not injection_points:
        return

    # If we're here, we have at least 1 injection point.
    # Let's assume we have N injection_points and L lines, progressing
    # and doing the injection i=1..N thru 1..L
    chunks = []
    start = 0

    for point in injection_points:
        chunks.extend(lines[start:point.start])

        for label, type_info in point.payload.targets:
            injected = point.payload.fn(type_info)
            
            if injected is not None:
                chunks.append(injected)

        start = point.end

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

def tmpl_api_primitives(t: MDSTypeInfo) -> str:
    compiled = f"""
    # BEGIN {t.api}
    # TODO: (field_in)
    # Throws incompatible_type_ex if the field exists but is of the wrong type
    # Throws unmodifiable_record_type_ex if the field doesn't exist, create_if_absent
    # is true, and the record type is fully created.

    cdef cppclass {t.managed_value} "mds::api::api_type<{t.kind}>":
        {t.managed_value}()
        {t.managed_value}({t.c_type})
        uint64_t hash1()

    cdef cppclass {t.primitive} "mds::api::managed_type_handle<{t.kind}>":
        {t.primitive}()
        {t.record_field} field_in(record_type_handle&, interned_string_handle&, bool) except+
        uint64_t hash1()

    cdef cppclass {t.const_primitive} "mds::api::const_managed_type_handle<{t.kind}>":
        {t.const_primitive}()
        {t.record_field} field_in(record_type_handle&, interned_string_handle&, bool) except+
        uint64_t hash1()

    cdef {t.primitive} {t.f_managed_type_handle} "mds::api::managed_type_handle<{t.kind}>"()
    cdef {t.const_primitive} {t.f_const_managed_type_handle} "mds::api::managed_type_handle<{t.kind}>"()
    {t.c_type} {t.f_to_core_val} "mds::api::to_core_val<{t.kind}>" (const {t.managed_value}&)

"""
    return compiled

def tmpl_primitives(t: MDSTypeInfo) -> str:
    compiled = f"""
cdef class {t.title}({t.PRIMITIVE}):
    cdef:
        {t.managed_value} _type

    def __cinit__(self, value):  # TODO: Set the value in _value
        self.update(value)

    def __hash__(self):
        return hash(self.python_value)

    def _to_python(self):
        return {t.f_to_core_val}(self._type)

    def update(self, value) -> None:
        self._type = {t.managed_value}(self._sanitize(value, self._to_python()))

    def bind_to_namespace(self, Namespace namespace, String name) -> None:
        cdef:
            interned_string_handle nhandle = name._ish
            namespace_handle h = namespace._handle

        h.{t.f_bind}(nhandle, <{t.c_type}> self._value)

    property dtype:
        def __get__(self):
            return {t.dtype}
    """

    if t.is_integral:
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

def tmpl_api_namespaces(t: MDSTypeInfo) -> str:
    compiled = f"""
        {t.c_type} {t.f_lookup} "lookup<{t.kind},mds::core::kind_type<{t.kind}>,false,true>"(interned_string_handle, const {t.primitive}&)
        {t.managed_array} {t.f_lookup_array} "lookup<{t.kind},false,true>"(const interned_string_handle&, const {t.array}&)
        bool {t.f_bind} "bind<{t.kind}>"(interned_string_handle, {t.c_type})
        # bool {t.f_bind_array} "bind<{t.kind}>"(interned_string_handle, {t.c_type})
    """
    return compiled

def tmpl_namespace_mapping(t: MDSTypeInfo) -> str:
    compiled = f"            {t.dtype}: {t.title_name_binding},\n"
    return compiled

def tmpl_namespace_typed_primitive_bindings(t: MDSTypeInfo) -> str:
    compiled = f"""
cdef class {t.title_name_binding}(MDSTypedNameBinding):
    cdef:
        {t.primitive} _type

    def get(self) -> Optional[{t.title}]:
        cdef:
            interned_string_handle nhandle = self._name._ish
            {t.primitive} thandle = self._type
            namespace_handle h = self._namespace._handle
        try:
            return {t.title}(h.{t.f_lookup}(nhandle, thandle))
        except:  # unbound_name_ex
            return None

    def bind(self, {t.title} val) -> None:
        cdef:
            interned_string_handle nhandle = self._name._ish
            namespace_handle h = self._namespace._handle

        h.{t.f_bind}(nhandle, <{t.c_type}> val.python_type)

    def check(self):
        cdef:
            interned_string_handle nhandle = self._name._ish
            {t.primitive} thandle = self._type
            namespace_handle h = self._namespace._handle

        try:
            h.{t.f_lookup}(nhandle, thandle)
            return True
        except:
            return False
"""
    return compiled

def tmpl_namespace_typed_array_bindings(t: MDSTypeInfo) -> str:
    compiled = f"""
cdef class {t.title_name_binding}(MDSTypedNameBinding):
    cdef:
        {t.primitive} _type

    def get(self) -> Optional[{t.title}]:
        # cdef:
        #     interned_string_handle nhandle = self._name._ish
        #     {t.primitive} thandle = self._type
        #     namespace_handle h = self._namespace._handle
        # try:
        #     return {t.title}(h.{t.f_lookup}(nhandle, thandle))
        # except:  # unbound_name_ex
        #     return None
        return None

    def bind(self, {t.title} val) -> None:
        # cdef:
        #     interned_string_handle nhandle = self._name._ish
        #     namespace_handle h = self._namespace._handle

        # h.{t.f_bind}(nhandle, <{t.c_type}> val.python_type)
        return None

    def check(self):
        # cdef:
        #     interned_string_handle nhandle = self._name._ish
        #     {t.primitive} thandle = self._type
        #     namespace_handle h = self._namespace._handle

        # try:
        #     h.{t.f_lookup}(nhandle, thandle)
        #     return True
        # except:
        #     return False
        return None
"""
    return compiled

# =========================================================================
#  Records
# =========================================================================

def tmpl_api_records(t: MDSTypeInfo) -> str:
    EXTRA = ""
    compiled = ""

    if t.is_arithmetic:
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

def tmpl_record_field(t: MDSTypeInfo) -> str:
    compiled = f"""
cdef class {t.title_record_field}(MDSRecordFieldBase):
    cdef:
        {t.record_field} _handle

    def declare(self, String name, MDSRecordTypeDeclaration rt):
        assert self._handle.is_null()
        print("?> Attempting to get a handle from {t.const_primitive}.field_in")
        self._handle = {t.record_field}({t.const_primitive}().field_in(rt._declared_type, name._ish, True))

    @staticmethod
    def get_reference_type(make_const=False) -> type:
        if make_const:
            return {t.title_const_record_field_reference}

        return {t.title_record_field_reference}
"""
    return compiled

def tmpl_record_field_reference(t: MDSTypeInfo) -> str:
    compiled = f"""

cdef class {t.title_const_record_field_reference}(MDSConstRecordFieldReferenceBase):
    cdef:
        {t.record_field} _field_handle
        Record _record

    def __cinit__(self, {t.title_record_field} field, Record record):
        self._record = record
        self._field_handle = {t.record_field}(field._handle)
        self._record_handle = managed_record_handle(record._handle)
"""

    if t.is_primitive:
        compiled += f"""
    def read(self):
        cdef {t.c_type} retval = self._field_handle.frozen_read(self._record_handle)
        return retval

    def peek(self):
        cdef {t.c_type} retval = self._field_handle.free_read(self._record_handle)
        return retval
"""

    compiled += f"""

cdef class {t.title_record_field_reference}({t.title_const_record_field_reference}):
"""
    
    if t.is_primitive:
        compiled += f"""
    def write(self, value):
        self._field_handle.write(self._record_handle, <{t.c_type}> (value))
"""
    elif t.is_composite:
        compiled += """
    pass
"""

    if t.is_arithmetic:
        compiled += f"""

    def __iadd__(self, other):
        self._field_handle.add(self._record_handle, <{t.c_type}> (other))

    def __isub__(self, other):
        self._field_handle.sub(self._record_handle, <{t.c_type}> (other))

    def __imul__(self, other):
        self._field_handle.mul(self._record_handle, <{t.c_type}> (other))

    def __itruediv__(self, other):
        self._field_handle.div(self._record_handle, <{t.c_type}> (other))
"""

    return compiled

def tmpl_record_member(t: MDSTypeInfo) -> str:
    compiled = f"""
cdef class {t.title_const_record_member}(MDSConstRecordMemberBase):
"""

    if t.is_primitive:
        compiled += f"""
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
"""
    elif t.is_composite:
        compiled += """
    pass
"""

    compiled += f"""

cdef class {t.title_record_member}(MDSRecordMemberBase):
"""

    if t.is_primitive:
        compiled += f"""
    def _field_ref(self) -> MDSConstRecordFieldReferenceBase:
        return {t.title_record_field}()[self]

    def read(self):
        return self._field_ref().read()

    def peek(self):
        return self._field_ref().peek()

    def write(self, value) -> None:
        self._field_ref().write(<{t.c_type}> value);
"""
    elif t.is_composite:
        compiled += """
    pass
"""

    if t.is_arithmetic:
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

    def __itruediv__(self, other):
        ref = self._field_ref()
        ref /= other
"""

    return compiled

# =========================================================================
#  Arrays
# =========================================================================

def tmpl_array(t: MDSTypeInfo) -> str:
    compiled = f"""
cdef class {t.title_array}({t.ARRAY}):

    cdef {t.managed_array} _handle
    _primitive = {t.title}

    def __cinit__(self, int length=0):
        if length:
            self._handle = {t.f_create_array}(<size_t> length)

    def __len__(self):
        return self._handle.size()

    def __hash__(self):
        return self._handle.hash1()

    property dtype:
        def __get__(self):
            return {t.dtype}

    @classmethod
    def from_namespace(cls, Namespace namespace, path):
        # cdef:
        #     String p = __cast_to_mds_string(path)
        #     {t.managed_array} handle = {t.f_lookup_array}(p._ish, {t.array}())

        # retval = cls()
        # retval._handle = handle
        # return retval
        # TODO: Re-enable when injection working correctly
        pass

    def bind_to_namespace(self, Namespace namespace):
        pass  # TODO: See how these properly bind
"""

    if t.is_arithmetic:
        compiled += f"""
    def _numeric_bounds_check(self, value):
        prim = {t.title}(value)
        return prim.python_value

    def _to_python(self, index):
        return {t.f_to_core_val}(self._handle.frozen_read(index))

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

    def __iadd__(self, other):
        return self._handle.add(self._last_index, <{t.c_type}> other)

    def __isub__(self, other):
        return self._handle.sub(self._last_index, <{t.c_type}> other)

    def __imul__(self, other):
        return self._handle.mul(self._last_index, <{t.c_type}> other)

    def __itruediv__(self, other):
        return self._handle.div(self._last_index, <{t.c_type}> other)
"""
    elif t.is_string:
        pass
    elif t.is_record:
        pass

    return compiled

def tmpl_api_arrays(t: MDSTypeInfo) -> str:
    EXTRA = ""

    if t.is_arithmetic:
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
        uint64_t hash1()

    cdef cppclass {t.const_array} "mds::api::const_array_type_handle<{t.kind}>":
        # const_managed_type_handle<K> element_type()
        {t.managed_array} create_array(size_t)
        bool is_same_as(const {t.const_array}&)
        uint64_t hash1()

    cdef cppclass {t.managed_array}:
        {t.managed_value} frozen_read(size_t)
        {t.managed_value} write(size_t, {t.managed_value})
        size_t size()
        bool has_value()
        h_marray_base_t as_base()
        uint64_t hash1()
        {EXTRA}

    cdef cppclass {t.const_managed_array}:
        {t.managed_value} frozen_read(size_t)
        {t.managed_value} write(size_t, {t.managed_value})
        size_t size()
        bool has_value()
        h_marray_base_t as_base()
        uint64_t hash1()

    {t.managed_array} {t.f_create_array}(size_t)
    {t.const_managed_array} {t.f_create_const_array}(size_t)    
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
