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

cdef class Record(MDSObject):
    """

    Development Notes:
    * skipped force -- not sure when this would be needed
    * not implemented token yet -- unsure why this is needed, for forward()? Check JAPI
    """
    def __init__(self):
        if not hasattr(self, '_ident'):
            raise TypeError('Record subclasses must have a static `_ident` type name')

        # Working on the assumption this is called at the end:
        self.__type_decl = RecordTypeDeclaration(self.ident, self, self.__field_decls)

    def __getattr__(self, key):
        try:
            return getattr(self.__type_decl, key).read()
        except:
            return super().__getattr__(key)

    def __setattr__(self, key, value):
        try:
            getattr(self.__type_decl, key).write(value)
        except:
            super().__setattr__(key, value)

    def _register_field(self, klass, label, make_const=False, initial_value=None):
        self.__field_decls[label] = record_member_factory(self.ident, klass, make_const, initial_value)

# mds_record(const rc_token &tok, handle_type &&h)
#     : _handle { std::move(h) } {
#   tok.cache_shared(this);
# }
#
# explicit mds_record(const rc_token &tok)
#     : _handle(tok.create()) {
#   /*
#    * By creating and caching a shared ptr, we make it possible
#    * for user ctors to call this_as_mds_ptr(), which requires
#    * shared_from_this(), which requires there to be an active
#    * shared pointer.
#    */
#   tok.cache_shared(this);
# }

    # NOTE Disabled until Cython 0.27
    # def __eq__(self, other):
    #     return self._handle == other._handle

    def bind_to_namespace(self, Namespace ns, *args):
        #template<typename First, typename ...Cpts>
        #void bind_in(const mds_ptr<mds_namespace> &ns, First &&first,
        #            Cpts &&...cpts) const {
        # ns->at(std::forward<First>(first), std::forward<Cpts>(cpts)...)
        #     .template as<mds_record>().bind(THIS_RECORD);

        pass

    @classmethod
    def lookup_in(cls, Namespace ns, *args):
        if not len(args):
            raise KeyError('Need at least one path for the namespace')
    
        root = ns

        if len(args) > 1:
            for arg in args[:-1]:
                try:
                    root = ns[arg]
                except:
                    raise KeyError(f'Couldn\'t find key {arg}')

        retval = cls()
        # Now we know that root[args[-1]] will be the record val
        # TODO: update retval's fields accordingly

        return retval
   
    @classmethod
    def lookup_name(cls, *args):
        return cls.lookup_in(Namespace.get_current(), *args)

    property ident:
        def __get__(self):
            return self._ident
    
    property type_decl:
        def __get__(self):
            return self.__type_decl

# START INJECTION

cdef class Bool(MDSPrimitiveBase):

    cdef mv_bool _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
    

cdef class BoolArray(MDSArrayBase):

    cdef h_marray_bool_t _handle
    _primitive = Bool

    def __cinit__(self, length=None):
        if length is not None:
            self._handle = create_bool_marray(length)
        else:  # TODO: Not sure this is the best, but will avoid segfaults
            self._handle = create_bool_marray(0)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, mv_bool(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t l = len(self)
            h_marray_bool_t h = create_bool_marray(l)

        for i in range(l):
            h.write(i, mv_bool(<bool> self[i]))

        return BoolArray_Init(h)

    @staticmethod
    def create(length):
        return BoolArray_Init(create_bool_marray(length))

    property dtype:
        def __get__(self):
            return type(True)


cdef BoolArray_Init(h_marray_bool_t handle):
    result = BoolArray()
    result._handle = handle
    return result


cdef class Byte(MDSIntPrimitiveBase):

    cdef mv_byte _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
    
    property MIN:
        def __get__(self):
            return -128

    property MAX:
        def __get__(self):
            return 127 


cdef class ByteArray(MDSIntArrayBase):

    cdef h_marray_byte_t _handle
    _primitive = Byte

    def __cinit__(self, length=None):
        if length is not None:
            self._handle = create_byte_marray(length)
        else:  # TODO: Not sure this is the best, but will avoid segfaults
            self._handle = create_byte_marray(0)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, mv_byte(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t l = len(self)
            h_marray_byte_t h = create_byte_marray(l)

        for i in range(l):
            h.write(i, mv_byte(<int8_t> self[i]))

        return ByteArray_Init(h)

    @staticmethod
    def create(length):
        return ByteArray_Init(create_byte_marray(length))


cdef ByteArray_Init(h_marray_byte_t handle):
    result = ByteArray()
    result._handle = handle
    return result


cdef class UByte(MDSIntPrimitiveBase):

    cdef mv_ubyte _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
    
    property MIN:
        def __get__(self):
            return 0

    property MAX:
        def __get__(self):
            return 255 


cdef class UByteArray(MDSIntArrayBase):

    cdef h_marray_ubyte_t _handle
    _primitive = UByte

    def __cinit__(self, length=None):
        if length is not None:
            self._handle = create_ubyte_marray(length)
        else:  # TODO: Not sure this is the best, but will avoid segfaults
            self._handle = create_ubyte_marray(0)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, mv_ubyte(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t l = len(self)
            h_marray_ubyte_t h = create_ubyte_marray(l)

        for i in range(l):
            h.write(i, mv_ubyte(<uint8_t> self[i]))

        return UByteArray_Init(h)

    @staticmethod
    def create(length):
        return UByteArray_Init(create_ubyte_marray(length))


cdef UByteArray_Init(h_marray_ubyte_t handle):
    result = UByteArray()
    result._handle = handle
    return result


cdef class Short(MDSIntPrimitiveBase):

    cdef mv_short _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
    
    property MIN:
        def __get__(self):
            return -32768

    property MAX:
        def __get__(self):
            return 32767 


cdef class ShortArray(MDSIntArrayBase):

    cdef h_marray_short_t _handle
    _primitive = Short

    def __cinit__(self, length=None):
        if length is not None:
            self._handle = create_short_marray(length)
        else:  # TODO: Not sure this is the best, but will avoid segfaults
            self._handle = create_short_marray(0)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, mv_short(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t l = len(self)
            h_marray_short_t h = create_short_marray(l)

        for i in range(l):
            h.write(i, mv_short(<int16_t> self[i]))

        return ShortArray_Init(h)

    @staticmethod
    def create(length):
        return ShortArray_Init(create_short_marray(length))


cdef ShortArray_Init(h_marray_short_t handle):
    result = ShortArray()
    result._handle = handle
    return result


cdef class UShort(MDSIntPrimitiveBase):

    cdef mv_ushort _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
    
    property MIN:
        def __get__(self):
            return 0

    property MAX:
        def __get__(self):
            return 65535 


cdef class UShortArray(MDSIntArrayBase):

    cdef h_marray_ushort_t _handle
    _primitive = UShort

    def __cinit__(self, length=None):
        if length is not None:
            self._handle = create_ushort_marray(length)
        else:  # TODO: Not sure this is the best, but will avoid segfaults
            self._handle = create_ushort_marray(0)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, mv_ushort(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t l = len(self)
            h_marray_ushort_t h = create_ushort_marray(l)

        for i in range(l):
            h.write(i, mv_ushort(<uint16_t> self[i]))

        return UShortArray_Init(h)

    @staticmethod
    def create(length):
        return UShortArray_Init(create_ushort_marray(length))


cdef UShortArray_Init(h_marray_ushort_t handle):
    result = UShortArray()
    result._handle = handle
    return result


cdef class Int(MDSIntPrimitiveBase):

    cdef mv_int _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
    
    property MIN:
        def __get__(self):
            return -2147483648

    property MAX:
        def __get__(self):
            return 2147483647 


cdef class IntArray(MDSIntArrayBase):

    cdef h_marray_int_t _handle
    _primitive = Int

    def __cinit__(self, length=None):
        if length is not None:
            self._handle = create_int_marray(length)
        else:  # TODO: Not sure this is the best, but will avoid segfaults
            self._handle = create_int_marray(0)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, mv_int(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t l = len(self)
            h_marray_int_t h = create_int_marray(l)

        for i in range(l):
            h.write(i, mv_int(<int32_t> self[i]))

        return IntArray_Init(h)

    @staticmethod
    def create(length):
        return IntArray_Init(create_int_marray(length))


cdef IntArray_Init(h_marray_int_t handle):
    result = IntArray()
    result._handle = handle
    return result


cdef class UInt(MDSIntPrimitiveBase):

    cdef mv_uint _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
    
    property MIN:
        def __get__(self):
            return 0

    property MAX:
        def __get__(self):
            return 4294967295 


cdef class UIntArray(MDSIntArrayBase):

    cdef h_marray_uint_t _handle
    _primitive = UInt

    def __cinit__(self, length=None):
        if length is not None:
            self._handle = create_uint_marray(length)
        else:  # TODO: Not sure this is the best, but will avoid segfaults
            self._handle = create_uint_marray(0)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, mv_uint(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t l = len(self)
            h_marray_uint_t h = create_uint_marray(l)

        for i in range(l):
            h.write(i, mv_uint(<uint32_t> self[i]))

        return UIntArray_Init(h)

    @staticmethod
    def create(length):
        return UIntArray_Init(create_uint_marray(length))


cdef UIntArray_Init(h_marray_uint_t handle):
    result = UIntArray()
    result._handle = handle
    return result


cdef class Long(MDSIntPrimitiveBase):

    cdef mv_long _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
    
    property MIN:
        def __get__(self):
            return -9223372036854775808

    property MAX:
        def __get__(self):
            return 9223372036854775807 


cdef class LongArray(MDSIntArrayBase):

    cdef h_marray_long_t _handle
    _primitive = Long

    def __cinit__(self, length=None):
        if length is not None:
            self._handle = create_long_marray(length)
        else:  # TODO: Not sure this is the best, but will avoid segfaults
            self._handle = create_long_marray(0)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, mv_long(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t l = len(self)
            h_marray_long_t h = create_long_marray(l)

        for i in range(l):
            h.write(i, mv_long(<int64_t> self[i]))

        return LongArray_Init(h)

    @staticmethod
    def create(length):
        return LongArray_Init(create_long_marray(length))


cdef LongArray_Init(h_marray_long_t handle):
    result = LongArray()
    result._handle = handle
    return result


cdef class ULong(MDSIntPrimitiveBase):

    cdef mv_ulong _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
    
    property MIN:
        def __get__(self):
            return 0

    property MAX:
        def __get__(self):
            return 18446744073709551615 


cdef class ULongArray(MDSIntArrayBase):

    cdef h_marray_ulong_t _handle
    _primitive = ULong

    def __cinit__(self, length=None):
        if length is not None:
            self._handle = create_ulong_marray(length)
        else:  # TODO: Not sure this is the best, but will avoid segfaults
            self._handle = create_ulong_marray(0)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, mv_ulong(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t l = len(self)
            h_marray_ulong_t h = create_ulong_marray(l)

        for i in range(l):
            h.write(i, mv_ulong(<uint64_t> self[i]))

        return ULongArray_Init(h)

    @staticmethod
    def create(length):
        return ULongArray_Init(create_ulong_marray(length))


cdef ULongArray_Init(h_marray_ulong_t handle):
    result = ULongArray()
    result._handle = handle
    return result


cdef class Float(MDSFloatPrimitiveBase):

    cdef mv_float _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
    

cdef class FloatArray(MDSFloatArrayBase):

    cdef h_marray_float_t _handle
    _primitive = Float

    def __cinit__(self, length=None):
        if length is not None:
            self._handle = create_float_marray(length)
        else:  # TODO: Not sure this is the best, but will avoid segfaults
            self._handle = create_float_marray(0)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, mv_float(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t l = len(self)
            h_marray_float_t h = create_float_marray(l)

        for i in range(l):
            h.write(i, mv_float(<float> self[i]))

        return FloatArray_Init(h)

    @staticmethod
    def create(length):
        return FloatArray_Init(create_float_marray(length))


cdef FloatArray_Init(h_marray_float_t handle):
    result = FloatArray()
    result._handle = handle
    return result


cdef class Double(MDSFloatPrimitiveBase):

    cdef mv_double _value

    def __cinit__(self, value):  # TODO: Set the value in _value
        value = self._sanitize(value)

    def _to_python(self):
        return to_core_val(self._value)

    def _to_mds(self):  # TODO: This needs to update _value
        pass
    

cdef class DoubleArray(MDSFloatArrayBase):

    cdef h_marray_double_t _handle
    _primitive = Double

    def __cinit__(self, length=None):
        if length is not None:
            self._handle = create_double_marray(length)
        else:  # TODO: Not sure this is the best, but will avoid segfaults
            self._handle = create_double_marray(0)

    def __len__(self):
        return self._handle.size()

    def _to_python(self, index):
        return to_core_val(self._handle.frozen_read(index))

    def _to_mds(self, index, value):
        # Delegate bounds checking etc. to the primitive wrapper
        wrapped = self._primitive(value)
        self._handle.write(index, mv_double(value))
    
    def copy(self):
        cdef:
            size_t i = 0
            size_t l = len(self)
            h_marray_double_t h = create_double_marray(l)

        for i in range(l):
            h.write(i, mv_double(<double> self[i]))

        return DoubleArray_Init(h)

    @staticmethod
    def create(length):
        return DoubleArray_Init(create_double_marray(length))


cdef DoubleArray_Init(h_marray_double_t handle):
    result = DoubleArray()
    result._handle = handle
    return result


# END INJECTION

cpdef RecordMemberBase record_member_factory(ident, klass, make_const, initial_value):
    # TODO: Wrap the specializations
    return RecordMemberBase(ident, klass, make_const, initial_value)

"""
TODO:
    * Implement comparisons
    * Test the heck out of unicode encoding / decoding
    * Have __repr__ give a streaming view of the string in the MDS heap
    * Deal with the '\n' ending char
    * Define str-like operations in this file, not delegating to str (invokes copy)
"""

cdef class String(MDSObject):
    """
    This class provides the functionality expected from the native str type,
    but backed by MDS. As with str, Strings are immutable.
    """

    def __cinit__(self, value=None):
        cdef interned_string_handle handle = convert_py_to_ish(value) 
        self._handle = managed_string_handle(handle)
        self.__iter_idx = 0

    def __len__(self):
        return self._handle.length()

    def __hash__(self):
        return self._handle.hash1()

    def __iter__(self):
        self.__iter_idx = 0
        return self

    def __next__(self):
        if self.__iter_idx < len(self):
            retval = self[self.__iter_idx]
            self.__iter_idx += 1
            return retval
        else:
            raise StopIteration

    def __str__(self):
        return <str> self._handle.utf8().decode("utf-8")

    def __repr__(self):
        return "'{}'".format(str(self))

    def __getitem__(self, item):
        cdef:
            string s
            int i
            char_type c

        if isinstance(item, int):
            c = self._handle.at(item)
            u = chr(c)
            return u
        elif isinstance(item, slice):
            # TODO: Check this
            s.reserve((item.stop - item.start) // item.step)

            for i in range(start=item.start, stop=item.stop, step=item.step):
                s.push_back(self._handle.at(i))

            return String(s)

        raise TypeError(
            "list indices must be integers or slices, not {}".format(
                type(item)
            )
        )

    def __add__(self, other):
        """
        Concatenates this string with another, returns this as a new String
        """
        # TODO: Could probably open this to [str, bytes] too.
        cdef:
            string s
            str c

        if isinstance(other, String):       
            s.reserve(<size_t> (len(self) + len(other)))

            # Chain the iterators to avoid any string copying
            for c in chain(iter(self), iter(other)):
                s.push_back(ord(c))  # Need as an int for char

            return String(s)

        raise TypeError("must be String")

    def __mul__(self, other):
        """
        Internal method to perform String multiplication without overhead
        """
        cdef:
            string s
            str c
            int it, l = len(self)

        if isinstance(other, int):
            s.reserve(l * other)

            for it in range(other):
                for c in self:
                    s.push_back(ord(c))

            return String(<unicode> s.decode("utf-8"))

        raise TypeError(
            "can't multiply sequence by non-int of type 'String'"
        )

    def __rmul__(self, other):
        pass

    def __mod__(self, other):
        pass

    def __rmod__(self, other):
        pass

    def __richcmp__(a, b, op):
        if op == 0:    # <
            return a._handle < b._handle
        elif op == 1:  # <=
            return a._handle <= b._handle
        elif op == 2:  # ==
            return a._handle == b._handle
        elif op == 3:  # !=
            return a._handle != b._handle
        elif op == 4:  # >
            return a._handle > b._handle
        elif op == 5:  # >=
            return a._handle >= b._handle

    def __sizeof__(self):
        return self._handle.size()

    # TODO: Write equivalents that use the MDS-stored data

    def capitalize(self):
        return String(str(self).capitalize())

    def casefold(self):
        return String(str(self).casefold())

    def center(self, *args, **kwargs):
        return String(str(self).center(*args, **kwargs))

    # TODO: encode(encoding="utf-8", errors="strict")

    def endswith(self, *args, **kwargs):
        return str(self).endswith(*args, **kwargs)

    def expandtabs(self, *args, **kwargs):
        return String(str(self).expandtabs(*args, **kwargs))

    def find(self, *args, **kwargs):
        return str(self).find(*args, **kwargs)

    def format(self, *args, **kwargs):
        return String(str(self).format(*args, **kwargs))

    def format_map(self, *args, **kwargs):
        return String(str(self).format_map(*args, **kwargs))

    def index(self, *args, **kwargs):
        return str(self).index(*args, **kwargs)

    def isalnum(self, *args, **kwargs):
        return str(self).isalnum(*args, **kwargs)

    def isalpha(self, *args, **kwargs):
        return str(self).isalpha(*args, **kwargs)

    def isdecimal(self, *args, **kwargs):
        return str(self).isdecimal(*args, **kwargs)

    def isdigit(self, *args, **kwargs):
        return str(self).isdigit(*args, **kwargs)
    
    def isidentifier(self, *args, **kwargs):
        return str(self).isidentifier(*args, **kwargs)
    
    def islower(self, *args, **kwargs):
        return str(self).islower(*args, **kwargs)

    def isnumeric(self, *args, **kwargs):
        return str(self).isnumeric(*args, **kwargs)

    def isprintable(self, *args, **kwargs):
        return str(self).isprintable(*args, **kwargs)

    def isspace(self, *args, **kwargs):
        return str(self).isspace(*args, **kwargs)

    def istitle(self, *args, **kwargs):
        return str(self).istitle(*args, **kwargs)

    def isupper(self, *args, **kwargs):
        return str(self).isupper(*args, **kwargs)

    def join(self, *args, **kwargs):
        return String(str(self).join(*args, **kwargs))

    def ljust(self, *args, **kwargs):
        return String(str(self).ljust(*args, **kwargs))

    def lower(self, *args, **kwargs):
        return String(str(self).lower(*args, **kwargs))

    def lstrip(self, *args, **kwargs):
        return String(str(self).lstrip(*args, **kwargs))

    def partition(self, *args, **kwargs):
        return tuple([String(x) for x in str(self).partition(*args, **kwargs)])

    def replace(self, *args, **kwargs):
        return String(str(self).replace(*args, **kwargs))

    def rfind(self, *args, **kwargs):
        return str(self).rfind(*args, **kwargs)

    def rindex(self, *args, **kwargs):
        return str(self).rindex(*args, **kwargs)

    def rjust(self, *args, **kwargs):
        return String(str(self).rjust(*args, **kwargs))

    def rpartition(self, *args, **kwargs):
        return tuple([String(x) for x in str(self).rpartition(*args, **kwargs)])

    def rsplit(self, *args, **kwargs):
        return [String(x) for x in str(self).rsplit(*args, **kwargs)]

    def rstrip(self, *args, **kwargs):
        return String(str(self).rstrip(*args, **kwargs))

    def split(self, *args, **kwargs):
        return [String(x) for x in str(self).split(*args, **kwargs)]

    def splitlines(self, *args, **kwargs):
        return [String(x) for x in str(self).split(*args, **kwargs)]

    def startswith(self, *args, **kwargs):
        return str(self).startswith(*args, **kwargs)

    def strip(self, *args, **kwargs):
        return String(str(self).strip(*args, **kwargs))
    
    def swapcase(self, *args, **kwargs):
        return String(str(self).swapcase(*args, **kwargs))

    def title(self, *args, **kwargs):
        return String(str(self).title(*args, **kwargs))

    # TODO: translate

    def upper(self, *args, **kwargs):
        return String(str(self).upper(*args, **kwargs))

    def zfill(self, *args, **kwargs):
        return String(str(self).zfill(*args, **kwargs))
