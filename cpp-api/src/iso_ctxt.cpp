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

#include "iso_ctxt.h"

#include <unordered_map>
#include <vector>
using namespace mds;
using namespace std;
using namespace std::chrono;

class task::info {
  mutable std::mutex _mutex;
  vector<pfr_fn_type> _prepare_for_redo;
public:
  task_fn_type function;

  info(task_fn_type &&fn)
    : function(move(fn))
  {}

  bool needs_prepare_for_redo() const {
    return !_prepare_for_redo.empty();
  }

  void on_prepare_for_redo(pfr_fn_type fn) {
    lock_guard<mutex> lock(_mutex);
    _prepare_for_redo.push_back(fn);
  }

  bool prepare_for_redo(const task &t) const {
    lock_guard<mutex> lock(_mutex);
    for (const auto &fn : _prepare_for_redo) {
      if (!fn(t)) {
        return false;
      }
    }
    return true;
  }
};


namespace {
  class task_func_map {
    unordered_map<task, shared_ptr<task::info>> _map;
    mutex _mutex;
  public:
    shared_ptr<task::info> get(const task &t) {
      lock_guard<mutex> lock(_mutex);
      return _map[t];
    }

    void set(const task &t, const shared_ptr<task::info> &i)
    {
      lock_guard<mutex> lock(_mutex);
      _map[t] = i;
    }
    shared_ptr<task::info> lookup(const task &t) {
      lock_guard<mutex> lock(_mutex);
      auto p = _map.find(t);
      if (p == _map.end()) {
        return nullptr;
      }
      return p->second;
    }
  };

  struct ctxt_task_map {
    unordered_map<iso_ctxt, shared_ptr<task_func_map>> _map;
    std::mutex _mutex;

    shared_ptr<task_func_map> get(const iso_ctxt &ctxt) {
      lock_guard<mutex> lock(_mutex);
      shared_ptr<task_func_map> &tfm = _map[ctxt];
      if (!tfm) {
        tfm = make_shared<task_func_map>();
      }
      return tfm;
    }
    shared_ptr<task_func_map> lookup(const iso_ctxt &ctxt) {
      lock_guard<mutex> lock(_mutex);
      auto p = _map.find(ctxt);
      if (p == _map.end()) {
        return nullptr;
      }
      return p->second;
    }
  };

  ctxt_task_map ctm;
}

shared_ptr<task::info>
task::get_info() const {
  shared_ptr<task_func_map> tfm = ctm.get(context());
  return tfm->get(*this);
}

shared_ptr<task::info>
task::lookup_info() const {
  shared_ptr<task_func_map> tfm = ctm.lookup(context());
  if (tfm == nullptr) {
    return nullptr;
  }
  return tfm->lookup(*this);
}

void
task::remember_and_call(function<void()> &&fn) {
  shared_ptr<task_func_map> tfm = ctm.get(context());
  shared_ptr<info> i = make_shared<info>(std::move(fn));
  tfm->set(*this, i);
  _establish e(*this);
  (i->function)();
}

void
task::on_prepare_for_redo(const task::pfr_fn_type &fn) {
  shared_ptr<info> i = lookup_info();
  if (i == nullptr) {
    /*
     * We can't redo, so don't bother preparing
     */
    return;
  }
  i->on_prepare_for_redo(fn);
}


bool pub_result::resolve(const report_opts &reports) const {
  auto tasks = redo_tasks_by_start_time();
  if (tasks.empty()) {
    return true;
  }
  reports.before_resolve(*this);
  iso_ctxt ctxt = source_context();
  shared_ptr<task_func_map> task_map = ctm.lookup(ctxt);
  if (task_map == nullptr) {
    return false;
  }
  vector<pair<task, shared_ptr<task::info> > > infos;
  infos.reserve(tasks.size());
  bool need_task_prepare = false;
  for (const task &t : tasks) {
    std::shared_ptr<task::info> ti = task_map->lookup(t);
    if (ti == nullptr) {
      return false;
    }
    if (ti->needs_prepare_for_redo()) {
      need_task_prepare = true;
    }
    infos.push_back(make_pair(t, ti));
  }

  /*
   * We do this in two separate loops so that we fail faster if
   * there are any tasks that can't be redone.
   *
   * At the moment, we're in the parent context.  Since we're
   * delegating to user code out of our control, we force any
   * prepareForRedo() code to take place in the top-level task of
   * the child context.  
   */
  if (need_task_prepare) {
    task tl_task = ctxt.top_level_task();
    if (!tl_task.establish_and_run([&](){
          for (const auto &p : infos) {
            const task &t = p.first;
            const std::shared_ptr<task::info> &ti = p.second;
            if (ti == nullptr) {
              continue;
            }
            if (!ti->prepare_for_redo(t)) {
              return false;
            }
          }
          return true;
        }))
      {
        return false;
      }
  }
  if (!prepare_for_redo()) {
    return false;
  }
  /*
   * For now, we're going to simply do them linearly in the same
   * thread.  Eventually, we'll need to pay attention to the bounds
   * and get the necessary parallelism going.
   */
  for (const auto &p : infos) {
    const task &t = p.first;
    // cout << "Reestablishing task " << t << endl;
    const std::shared_ptr<task::info> &ti = p.second;
    t.establish_and_run(ti->function);
  }
  return true;
  
}

void
pub_result::redo_tasks_by_start_time(vector<task> &tasks) const {
  tasks.clear();
  for (task th : _handle.redo_tasks_by_start_time()) {
    tasks.push_back(th);
  }
}



