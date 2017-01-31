##
#
#  Managed Data Structures
#  Copyright © 2016 Hewlett Packard Enterprise Development Company LP.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  As an exception, the copyright holders of this Library grant you permission
#  to (i) compile an Application with the Library, and (ii) distribute the 
#  Application containing code generated by the Library and added to the 
#  Application during this compilation process under terms of your choice, 
#  provided you also meet the terms and conditions of the Application license.
#


include ../defs.mk


project_name = mds_java_api
projects_used = mds_core mpgc ruts

mpgc_project_dir ?= $(if $(wildcard $(git_base_dir)/mpgc/build),$(git_base_dir)/mpgc,$(git_base_dir)/gc)
ruts_project_dir ?= $(if $(wildcard $(mpgc_project_dir)/ruts/build),$(mpgc_project_dir)/ruts,$(git_base_dir)/common)
mds_core_project_dir ?= $(if $(wildcard $(git_base_dir)/mds/build),$(git_base_dir)/mds,$(git_base_dir)/core)

real_project_dir := $(project_dir)
project_dir := $(real_project_dir)/jni

lib_name = mds-jni
lib_targets = $(shared_lib)

JAVA_HOME ?= /opt/jdk1.8.0_51
extra_incl_dirs = $(src_dirs) $(JAVA_HOME)/include $(JAVA_HOME)/include/linux

include ../build.mk

template_dir := $(abspath $(project_dir)/../templates)
template_files := $(wildcard $(addsuffix JNI*.stg,$(template_dir)/))
template_dep_files := $(addprefix $(generated_src_dir)/,$(notdir $(patsubst %.stg,%.d,$(template_files))))

-include $(template_dep_files)

$(generated_src_dir)%.d: $(template_dir)%.stg
	@echo Generating from $<
	cd $(real_project_dir) && ant -f mds-src-generator.xml generate-specific -Dtemplates=$(notdir $(<:.stg=))
