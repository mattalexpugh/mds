/*
 *
 *  Managed Data Structures
 *  Copyright © 2016 Hewlett Packard Enterprise Development Company LP.
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

/*
 * mds_ptr.h
 *
 *  Created on: Mar 31, 2015
 *      Author: Evan
 */

#ifndef mds_ptr_H_
#define mds_ptr_H_

#include "mds_common.h"
#include <memory>
#include <ostream>

namespace mds {
  
  template <typename T> struct is_mds_array : std::false_type {};
  template <typename T> struct is_mds_array<mds_array<T>> : std::true_type {};

  


  template <typename T>
  class mds_ptr {
    std::shared_ptr<T> _ptr;
    template <typename X, typename Y>
    friend bool operator==(const mds_ptr<X> &lhs, const mds_ptr<Y> &rhs);
    template <typename X>
    friend bool operator==(const mds_ptr<X> &lhs, nullptr_t);
    template <typename X> friend class mds_ptr;

    struct from_shared_ptr {};

    template <typename Y, typename = std::enable_if_t<std::is_convertible<Y*,T*>::value> >
    explicit mds_ptr(const std::shared_ptr<Y> &p) noexcept : _ptr{p} {}
    template <typename Y, typename = std::enable_if_t<std::is_convertible<Y*,T*>::value> >
    explicit mds_ptr(std::shared_ptr<Y> &&p) noexcept : _ptr{std::move(p)} {}


  public:
    template <typename Y, typename = std::enable_if_t<std::is_convertible<Y*,T*>::value> >
    static mds_ptr __from_shared(const std::shared_ptr<Y> &p) noexcept {
      return mds_ptr{p};
    }
    template <typename Y, typename = std::enable_if_t<std::is_convertible<Y*,T*>::value> >
    static mds_ptr __from_shared(std::shared_ptr<Y> &&p) noexcept {
      return mds_ptr{std::move(p)};
    }
    std::shared_ptr<T> as_shared_ptr() const {
      return _ptr;
    }
    using element_type = T;
    // No way to get there from a bare pointer, but you can do it from a shared pointer.
    mds_ptr() noexcept = default;
    mds_ptr(std::nullptr_t) noexcept : _ptr{nullptr} {}

    mds_ptr(const mds_ptr &) noexcept = default;
    template <typename Y, typename = std::enable_if_t<std::is_convertible<Y*,T*>::value> >
    mds_ptr(const mds_ptr<Y> &p) noexcept : _ptr{p._ptr} {}

    mds_ptr(mds_ptr &&) noexcept = default;
    template <typename Y, typename = std::enable_if_t<std::is_convertible<Y*,T*>::value> >
    mds_ptr(mds_ptr<Y> &&p) noexcept : _ptr{std::move(p._ptr)} {}
    mds_ptr &operator =(std::nullptr_t) noexcept {
      _ptr.reset();
      return *this;
    }

    mds_ptr &operator =(const mds_ptr &) noexcept = default;
    template <typename Y, typename = std::enable_if_t<std::is_convertible<Y*,T*>::value> >
    mds_ptr &operator =(const mds_ptr<Y> &p) noexcept {
      _ptr = p._ptr;
      return *this;
    }

    mds_ptr &operator =(mds_ptr &&) noexcept = default;
    template <typename Y, typename = std::enable_if_t<std::is_convertible<Y*,T*>::value> >
    mds_ptr &operator =(mds_ptr<Y> &&p) noexcept {
      _ptr = std::move(p._ptr);
      return *this;
    }

    // template <typename Y, typename = std::enable_if_t<std::is_convertible<Y*,T*>::value> >
    // mds_ptr &operator =(const std::shared_ptr<Y> &p) noexcept {
    //   _ptr = p;
    //   return *this;
    // }
    // template <typename Y, typename = std::enable_if_t<std::is_convertible<Y*,T*>::value> >
    // mds_ptr &operator =(std::shared_ptr<Y> &&p) noexcept {
    //   _ptr = std::move(p);
    //   return *this;
    // }
    // template <typename Y, typename Deleter,
    //           typename = std::enable_if_t<std::is_convertible<Y*,T*>::value> >
    // mds_ptr &operator =(std::unique_ptr<Y,Deleter> &&p) noexcept {
    //   _ptr = std::move(p);
    //   return *this;
    // }

    void swap(mds_ptr &other) noexcept {
      _ptr.swap(other._ptr);
    }
    template <typename As>
    mds_ptr<As> static_pointer_cast() const noexcept {
      return mds_ptr<As>{std::static_pointer_cast<As>(_ptr)};
    }
    template <typename As>
    mds_ptr<As> dynamic_pointer_cast() const noexcept {
      return mds_ptr<As>{std::dynamic_pointer_cast<As>(_ptr)};
    }
    template <typename As>
    mds_ptr<As> const_pointer_cast() const noexcept {
      return mds_ptr<As>{std::const_pointer_cast<As>(_ptr)};
    }

    T &operator *() const noexcept {
      return *_ptr;
    }

    T *operator->() const noexcept {
      return _ptr.get();
    }

    explicit operator bool() const noexcept {
      return _ptr != nullptr;
    }

    template <typename U=T,
              typename=std::enable_if_t<is_mds_array<std::decay_t<U> >::value> >
    auto operator[](std::size_t i) const
    {
      return _ptr->at(i);
    }

    template <typename U=T,
              typename=std::enable_if_t<is_mds_array<std::decay_t<U> >::value> >
    auto at(std::size_t i) const
    {
      return _ptr->at(i);
    }

    template <typename U=T,
              typename=std::enable_if_t<is_mds_array<std::decay_t<U> >::value> >
    auto cbegin() const
    {
      return _ptr==nullptr ? decltype(_ptr->cbegin()){} : _ptr->cbegin();
    }

    template <typename U=T,
              typename=std::enable_if_t<is_mds_array<std::decay_t<U> >::value> >
    auto begin() const
    {
      return _ptr==nullptr ? decltype(_ptr->begin()){} : _ptr->begin();
    }
    template <typename U=T,
              typename=std::enable_if_t<is_mds_array<std::decay_t<U> >::value> >
    auto cend() const
    {
      return _ptr==nullptr ? decltype(_ptr->cend()){} : _ptr->cend();
    }

    template <typename U=T,
              typename=std::enable_if_t<is_mds_array<std::decay_t<U> >::value> >
    auto end() const
    {
      return _ptr==nullptr ? decltype(_ptr->end()){} : _ptr->end();
    }

    template <typename U=T,
              typename=std::enable_if_t<is_mds_array<std::decay_t<U> >::value> >
    auto size() const
    {
      return _ptr==nullptr ? decltype(_ptr->size()){0} : _ptr->size();
    }

    template <typename U=T,
              typename=std::enable_if_t<is_mds_array<std::decay_t<U> >::value> >
    bool empty() const
    {
      return _ptr==nullptr ? true : _ptr->empty();
    }

    template <typename U=T,
              typename=std::enable_if_t<is_mds_array<std::decay_t<U> >::value> >
    void fill(const typename U::value_type &val) const
    {
      if (_ptr != nullptr) {
        _ptr->fill(val);
      }
    }

  private:
    static std::shared_ptr<T> *ptr_or_null(mds_ptr *p) {
      return p == nullptr ? nullptr : &(p->_ptr);
    }
    static const std::shared_ptr<T> *ptr_or_null(const mds_ptr *p) {
      return p == nullptr ? nullptr : &(p->_ptr);
    }
};

  /*
   * Note that unlike shared_ptr, mds_ptr checks the identity of the pointer
   * into the managed space.
   */
  template <class T, class U>
  inline
  bool operator==(const mds_ptr<T> &lhs, const mds_ptr<U> &rhs) {
    return ((lhs._ptr == rhs._ptr)
        || (lhs._ptr && rhs._ptr && *lhs == *rhs));
  }
  template <class T, class U>
  inline
  bool operator!=(const mds_ptr<T> &lhs, const mds_ptr<U> &rhs) {
    return !(lhs == rhs);
  }
  template <class T>
  inline
  bool operator==(const mds_ptr<T> &lhs, nullptr_t) {
    return lhs._ptr == nullptr;
  }
  template <class T>
  inline
  bool operator==(nullptr_t, const mds_ptr<T> &rhs) {
    return rhs == nullptr;
  }
  template <class T>
  inline
  bool operator!=(const mds_ptr<T> &lhs, nullptr_t) {
    return !(lhs == nullptr);
  }
  template <class T>
  inline
  bool operator!=(nullptr_t, const mds_ptr<T> &rhs) {
    return !(rhs == nullptr);
  }

  template <typename C, typename T, typename X>
  std::basic_ostream<C,T> &
  operator<<(std::basic_ostream<C,T> &s, const mds_ptr<X> &rhs) {
    return s << rhs.as_shared_ptr();
  }
}

namespace std {
  template <typename T>
  void swap(mds::mds_ptr<T> &lhs, mds::mds_ptr<T> &rhs) {
    lhs.swap(rhs);
  }

  template <typename T, typename U>
  mds::mds_ptr<T>
  static_pointer_cast(const mds::mds_ptr<U> &r) noexcept {
    return r.template static_pointer_cast<T>();
  }
  template <typename T, typename U>
  mds::mds_ptr<T>
  dynamic_pointer_cast(const mds::mds_ptr<U> &r) noexcept {
    return r.template dynamic_pointer_cast<T>();
  }
  template <typename T, typename U>
  mds::mds_ptr<T>
  const_pointer_cast(const mds::mds_ptr<U> &r) noexcept {
    return r.template const_pointer_cast<T>();
  }
  // Also want the atomic ops
}

#endif /* mds_ptr_H_ */
