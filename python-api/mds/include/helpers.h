/*
 *
 *  Managed Data Structures
 *  Copyright © 2017 Hewlett Packard Enterprise Development Company LP.
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  As an exception, the copyright holders of this Library grant you permission
 *  to (i) compile an Application with the Library, and (ii) distribute the 
 *  Application containing code generated by the Library and added to the 
 *  Application during this compilation process under terms of your choice, 
 *  provided you also meet the terms and conditions of the Application license.
 *
 */

#include <Python.h>
#include <functional>
#include <utility>
#include "mds_core_api.h"

/**
 * MDS Python API Helpers
 * ======================
 *
 * These functions deal with the fact that MDS uses templated code a lot, 
 * and that Python (Cython anyway) really doesn't like that. This file contains
 * a bunch of wrappers to make it all work.
 *
 * Naming conventions:
 *
 *  - h_<T>_t             A handle for MDS API type T
 *  - h_m<T>_t            A managed type T handle from MDS
 *  - h_marray_<T>_t      A managed array of type T
 *
 *  Author(s):
 *
 *  - Matt Pugh, 2017
 */


using h_isoctxt_t = ::mds::api::iso_context_handle;
using h_task_t = ::mds::api::task_handle;
using h_namespace_t = ::mds::api::namespace_handle;
using ::mds::api::kind;

namespace mds
{
    namespace python
    {
        typedef struct _py_callable_wrapper
        {
            PyObject *fn;
            PyObject *args;
        } py_callable_wrapper;

        namespace tasks
        {
            static inline void initialize_base_task(void) 
            {
                // TODO: Double check this should be thread_local
                static thread_local bool already_initialized = false;

                if (! already_initialized)
                {
                    h_task_t::init_thread_base_task([]() {
                        return h_task_t::default_task().pointer();
                    });

                    already_initialized = true;
                }
            }

            class TaskWrapper
            {
                private:
                    h_task_t _handle;

                    static h_task_t &_current()
                    {
                        static thread_local h_task_t t = h_task_t::default_task();
                        return t;
                    }
                public:
                    TaskWrapper()
                        : _handle{h_task_t::default_task()}
                    {}

                    TaskWrapper(h_task_t th)
                        : _handle{th}
                    {}

                    class Establish
                    {
                      public:
                        Establish(const h_task_t &t)
                        {
                            static size_t counter = 0;  // TODO DELETE 
                            printf("[%lu] _current() - %lu\n", counter, _current().hash1());  // TODO DELETE 
                            _current() = t;
                            printf("[%lu] Establish() - %lu\n", counter++, t.hash1());  // TODO DELETE 
                        }

                        ~Establish()
                        {
                            static size_t counter = 0;  // TODO DELETE 
                            printf("[%lu] ~_current() - %lu\n", counter, _current().hash1());  // TODO DELETE 
                            _current() = h_task_t::pop();
                            printf("[%lu] ~Establish() - %lu\n", counter++, _current().hash1());   // TODO DELETE 
                        }
                    };

                    static h_task_t default_task()
                    {
                        initialize_base_task();
                        return h_task_t::default_task();
                    }

                    static h_task_t current()
                    {
                        return _current();
                    }

                    void run(std::function<void(py_callable_wrapper)> &&fn,
                             py_callable_wrapper arg)
                    {
                        initialize_base_task();
                        std::forward<decltype(fn)>(fn)(arg);
                    }
            };
        } // End mds::python::tasks
        
        namespace isoctxts
        {
            static inline PyObject *run_in_iso_ctxt(
                    h_isoctxt_t &handle,
                    std::function<PyObject*(py_callable_wrapper)> &&fn,
                    py_callable_wrapper arg)
            {
                tasks::initialize_base_task();
                // TODO: This is clearly all wrong, but just making the compiler happy for now
                return std::forward<decltype(fn)>(fn)(arg);
            };
        } // End mds::python::isoctxt

        namespace types
        {
            #define _TYPE_WRAPPER_(K, name) \
            using h_marray_##name##_t = mds::api::managed_array_handle<K>; \
            using h_const_marray_##name##_t = mds::api::const_managed_array_handle<K>; \
            using h_m##name##_t = mds::api::managed_type_handle_cp<K, true>; \
            static inline h_marray_##name##_t create_##name##_marray(size_t n) \
            { \
                tasks::initialize_base_task(); \
                static auto h = mds::api::managed_array_handle_by_kind<K>(); \
                return h.create_array(n); \
            }

            _TYPE_WRAPPER_(kind::BOOL, bool)
            _TYPE_WRAPPER_(kind::BYTE, byte)
            _TYPE_WRAPPER_(kind::UBYTE, ubyte)
            _TYPE_WRAPPER_(kind::SHORT, short)
            _TYPE_WRAPPER_(kind::USHORT, ushort)
            _TYPE_WRAPPER_(kind::INT, int)
            _TYPE_WRAPPER_(kind::UINT, uint)
            _TYPE_WRAPPER_(kind::LONG, long)
            _TYPE_WRAPPER_(kind::ULONG, ulong)
            _TYPE_WRAPPER_(kind::FLOAT, float)
            _TYPE_WRAPPER_(kind::DOUBLE, double)
            _TYPE_WRAPPER_(kind::RECORD, record)
            _TYPE_WRAPPER_(kind::STRING, string)

            // _TYPE_WRAPPER_(kind::ARRAY, array)
            // _TYPE_WRAPPER_(kind::NAMESPACE, namespace)
        } // End mds::python::types
        namespace namespaces
        {
            static h_namespace_t &current_namespace()
            {
                static thread_local h_namespace_t ns = h_namespace_t::global();
                return ns;
            }
        } // End mds::python::namespaces
    } // End mds::python
} // End mds

