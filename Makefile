# Copyright 2020-2021 Robert Newgard
#
# This file is part of CxxJsonPath.
#
# CxxJsonPath is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# CxxJsonPath is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with CxxJsonPath.  If not, see <https://www.gnu.org/licenses/>.

# -- make environment ----------------------------------------------------------
undefine FALSE
undefine NULL

SHELL  := /bin/bash
PHONYS := $(NULL)
CLEANS := $(NULL)

SP     := $(shell printf "\x20")
TRUE   := true

# get_list <path> - returns contents of existing file at <path>; otherwise returns ""
# get_str  <path> - returns first string from existing file at <path>; otherwise returns ""
# get_bool <path> - returns "1" if existing file at <path> contains "1"; otherwise returns ""
get_list = $(strip $(file < $(strip $(1))))
get_str  = $(firstword $(call get_list,$(strip $(1))))
get_bool = $(filter 1,$(call get_str, $(strip $(1))))


# -- project -------------------------------------------------------------------
TMP  := tmp
CFG  := cfg

$(shell if [ ! -d "$(TMP)" ] ; then (set -x ; mkdir -p $(TMP)) ; fi)


# -- Remote Libraries ----------------------------------------------------------
RMT_LIB_CFG   := $(CFG)/Git
RMT_LIB_NAMS  := $(shell ls $(RMT_LIB_CFG))
RMT_LIB_TARGS := $(foreach LIB,$(RMT_LIB_NAMS),$(call get_list,$(RMT_LIB_CFG)/$(LIB)/Targ))
RMT_LIB_LIBS  := $(foreach LIB,$(RMT_LIB_NAMS),-l$(LIB))
RMT_LIB_PATHS := $(subst $(SP),$(NULL),$(foreach LIB,$(RMT_LIB_NAMS),:$(TMP)/$(LIB)))
RMT_CLONES    := $(NULL)
RMT_LIBS      := $(NULL)
RMT_CLEANS    := $(NULL)
RMT_IFLAGS    := $(NULL)
RMT_LFLAGS    := $(NULL)

$(if $(FALSE),$(info RMT_LIB_NAMS: $(RMT_LIB_NAMS)))
$(if $(FALSE),$(info RMT_LIB_TARGS: $(RMT_LIB_TARGS)))
$(if $(FALSE),$(info RMT_LIB_LIBS: $(RMT_LIB_LIBS)))
$(if $(FALSE),$(info RMT_LIB_PATHS: "$(RMT_LIB_PATHS)"))

define rmt_lib_cfg_chk_recipe
    $(if $(wildcard $(RMT_LIB_CFG)/$(1)/Repo),$(NULL),$(error ERR: Remote repo $(1) config file $(RMT_LIB_CFG)/$(1)/Repo missing))
    $(if $(wildcard $(RMT_LIB_CFG)/$(1)/Incl),$(NULL),$(error ERR: Remote repo $(1) config file $(RMT_LIB_CFG)/$(1)/Incl missing))
    $(if $(wildcard $(RMT_LIB_CFG)/$(1)/Targ),$(NULL),$(error ERR: Remote repo $(1) config file $(RMT_LIB_CFG)/$(1)/Targ missing))
    @echo "[INF] Remote repo $(1) config okay."
endef

define rmt_lib_clone_recipe
    $(call rmt_lib_cfg_chk_recipe,$(1))
    @echo "[INF] Cloning $(1)..."
    rm -rf $(TMP)/$(1)
    git clone $(call get_str, $(RMT_LIB_CFG)/$(1)/Repo) $(TMP)/$(1)
    @echo "[INF] $(1) Cloned."
endef

define rmt_lib_build_recipe
    @echo "[INF] Creating $(2)..."
    cd $(TMP)/$(1) && make $(notdir $(2))
    @echo "[INF] $(2) done."
endef

define rmt_lib_clone_targs
    $(TMP)/$(1)/Makefile : $(NULL)              ; $$(call rmt_lib_clone_recipe,$(1))
    $(1)-clone           : $(TMP)/$(1)/Makefile ; $(NULL)

    RMT_CLONES += $(1)-clone
endef

define rmt_lib_incl_targs
    $(2)      : $(TMP)/$(1)/Makefile ; $(NULL)
    $(1)-incl : $(2)                 ; $(NULL)

    RMT_IFLAGS += -I $(TMP)/$(1)
endef

define rmt_lib_build_targs
    $(2)                 : $(TMP)/$(1)/Makefile ; $$(call rmt_lib_build_recipe,$(1),$(2))
    $(1)-lib             : $(2)                 ; $(NULL)
    $(1)-clean           : $(NULL)              ; rm -f $(2)

    RMT_LFLAGS += -L $(TMP)/$(1)
    RMT_LIBS   += $(1)-lib
    RMT_CLEANS += $(1)-clean
endef

$(foreach NAM,$(RMT_LIB_NAMS),$(eval $(call rmt_lib_clone_targs,$(NAM))))
$(foreach NAM,$(RMT_LIB_NAMS),$(eval $(call rmt_lib_incl_targs,$(NAM),$(call get_list,$(RMT_LIB_CFG)/$(NAM)/Incl))))
$(foreach NAM,$(RMT_LIB_NAMS),$(eval $(call rmt_lib_build_targs,$(NAM),$(call get_list,$(RMT_LIB_CFG)/$(NAM)/Targ))))


# -- C++ Environment -----------------------------------------------------------
C_VER     := -x c -std=gnu11
CXX_VER   := -x c++ -std=c++11
CFLAGS    := -Wall -m64 -g -pthread -fPIC -fmax-errors=5
DFLAGS    := $(NULL)
IFLAGS    := $(RMT_IFLAGS) -I .
LFLAGS    := $(RMT_LFLAGS) -L .


# -- Parser Build --------------------------------------------------------------
PARSER_CFG    := $(CFG)/lex-yacc
PARSER_NAMS   := $(shell ls $(PARSER_CFG))
PARSER_DIRS   := $(foreach NAM,$(PARSER_NAMS),$(TMP)/$(NAM))
PARSER_DFLAGS := -DYY_NO_INPUT
PARSER_TARGS  := $(foreach NAM,$(PARSER_NAMS),$(TMP)/$(NAM)/$(NAM).o)
PARSER_BLDS   := $(NULL)
PARSER_OBJS   := $(NULL)
PARSER_CLNS   := $(NULL)
 
$(if $(FALSE),$(info PARSER_DIRS: $(PARSER_DIRS)))
$(if $(FALSE),$(info PARSER_TARGS: $(PARSER_TARGS)))

$(foreach DIR,$(PARSER_DIRS),$(shell if [ ! -d "$(DIR)" ] ; then (set -x ; mkdir -p $(DIR)) ; fi))

define parser_cfg_chk_recipe
    $(if $(wildcard $(PARSER_CFG)/$(1)/incl),$(NULL), $(error ERR: Parser $(1) config file $(PARSER_CFG)/$(1)/incl missing))
    $(if $(wildcard $(PARSER_CFG)/$(1)/lex),$(NULL),  $(error ERR: Parser $(1) config file $(PARSER_CFG)/$(1)/lex missing))
    $(if $(wildcard $(PARSER_CFG)/$(1)/yacc),$(NULL), $(error ERR: Parser $(1) config file $(PARSER_CFG)/$(1)/yacc missing))
    @echo "[INF] Parser \"$(1)\" config okay."
endef

define parser_bld_recipe
    $(call parser_cfg_chk_recipe,$(1))
    @echo "[INF] Creating $(TMP)/$(1)/$(1).c..."
    cd $(TMP)/$(1) && bison $(abspath $(3))
    cd $(TMP)/$(1) && flex $(abspath $(2))
    @echo "[INF] done."
endef

define parser_obj_recipe
    @echo "[INF] Creating $(TMP)/$(1)/$(1).o..."
    g++ $(C_VER) $(PARSER_DFLAGS) -c -I . -I $(TMP)/$(1) $(CFLAGS) -o $@ $<
    @echo "[INF] done."
endef

define parser_targs
    $(1)_LEX  = $(call get_str,$(PARSER_CFG)/$(1)/lex)
    $(1)_YACC = $(call get_str,$(PARSER_CFG)/$(1)/yacc)
    $(1)_INCL = $(call get_list,$(PARSER_CFG)/$(1)/incl)

    $(TMP)/$(1)/$(1).o : $(TMP)/$(1)/$(1).c $$($(1)_INCL) ; $$(call parser_obj_recipe,$(1))
    $(1)-obj           : $(TMP)/$(1)/$(1).o               ; $(NULL)
    $(TMP)/$(1)/$(1).c : $$($(1)_LEX) $$($(1)_YACC)       ; $$(call parser_bld_recipe,$(1),$$($(1)_LEX),$$($(1)_YACC))
    $(1)-bld           : $(TMP)/$(1)/$(1).c               ; $(NULL)
    $(1)-clean         : $(NULL)                          ; rm -f $(TMP)/$(1)/*

    PARSER_OBJS  += $(1)-obj
    PARSER_BLDS  += $(1)-bld
    PARSER_CLNS  += $(1)-clean
endef

$(foreach NAM,$(PARSER_NAMS),$(eval $(call parser_targs,$(NAM))))


# -- Library -------------------------------------------------------------------
LIB_NAME     := CxxJsonPath
LIB_OBJ_DIR  := $(TMP)/libobj
LIB_CFG      := $(CFG)/Lib
LIB_OBJ_NAMS := $(shell ls $(LIB_CFG))
LIB_REQS     := $(foreach OBJ,$(LIB_OBJ_NAMS),$(LIB_OBJ_DIR)/$(OBJ).o) $(PARSER_TARGS)
LIB_TARG     := lib$(LIB_NAME).so

$(shell if [ ! -d "$(LIB_OBJ_DIR)" ] ; then (set -x ; mkdir -p $(LIB_OBJ_DIR)) ; fi)

define compile-for-obj
    g++ $(CXX_VER) -c $(DFLAGS) $(CFLAGS) $(IFLAGS) -o $@ $<
endef

define link-for-shared-obj
    g++ -shared -Wl,-soname,$(LIB_TARG) -o $@ $^
endef

define lib-obj-targs
    $(LIB_OBJ_DIR)/$(1).o : $(1).cxx $(call get_list,$(LIB_CFG)/$(1)/incl) ; $$(call compile-for-obj)
endef

$(if $(FALSE),$(info LIB_OBJ_NAMS: $(LIB_OBJ_NAMS)))
$(if $(FALSE),$(info LIB_REQS: $(LIB_REQS)))

$(foreach NAM,$(LIB_OBJ_NAMS),$(eval $(call lib-obj-targs,$(NAM))))


# -- Apps ----------------------------------------------------------------------
APP_CFG       := $(CFG)/Apps
APP_EXE_NAMS  := $(shell ls $(APP_CFG))
APP_EXE_LIBS  := -l$(LIB_NAME) $(RMT_LIB_LIBS)
APP_EXE_REQS  := $(LIB_TARG) $(RMT_LIB_TARGS)
APP_RUN_TARGS := $(NULL)

define compile-for-exe
    g++ $(CXX_VER) $(DFLAGS) $(CFLAGS) $(IFLAGS) $(LFLAGS) -o $@ $< $(APP_EXE_LIBS)
endef

define app-run-exe
    @ echo Running $(1)...
    export LD_LIBRARY_PATH=.$(RMT_LIB_PATHS) && ./$(1)
    @ echo done.
endef

define app-exe-targs
    $(1)     : $(1).cxx $(call get_list,$(APP_CFG)/$(1)/incl) $(APP_EXE_REQS) ; $$(call compile-for-exe)
    run-$(1) : $(1)                                                           ; $$(call app-run-exe,$(1))

    APP_RUN_TARGS += run-$(1)
endef

$(if $(FALSE),$(info APP_EXE_NAMS: $(APP_EXE_NAMS)))

$(foreach NAM,$(APP_EXE_NAMS),$(eval $(call app-exe-targs,$(NAM))))


# -- Doxygen -------------------------------------------------------------------
define dox
    doxygen dox.conf
endef


# -- Hints ---------------------------------------------------------------------
HINTS_TF := %-17s

define hints_def
    printf "$(HINTS_TF) %s\n" "$(strip $(1))" "$(strip $(2))" ;
endef

define hints_h1_def
    $(call hints_def,target,description)
endef

define hints_h2_def
    $(call hints_def,------------,--------------------------------------------------------)
endef

define hints_rmt_lib_def
    @ $(foreach TARG,$(RMT_CLONES), $(call hints_def , $(TARG) , Clone repo                     ))
    @ $(foreach TARG,$(RMT_LIBS),   $(call hints_def , $(TARG) , Build library                  ))
    @ $(foreach TARG,$(RMT_CLEANS), $(call hints_def , $(TARG) , Remove library build products  ))
endef

define hints_parser_def
    @ $(foreach TARG,$(PARSER_BLDS), $(call hints_def , $(TARG) , Build parser with flex and bison ))
    @ $(foreach TARG,$(PARSER_OBJS), $(call hints_def , $(TARG) , Create parser object file        ))
    @ $(foreach TARG,$(PARSER_CLNS), $(call hints_def , $(TARG) , Delete parser build products     ))
endef

define hints_apps_def
    @ $(foreach TARG,$(APP_RUN_TARGS), $(call hints_def , $(TARG) , Run app ))
endef

define top_hints_def
    @ $(hints_h1_def)
    @ $(hints_h2_def)
    @ $(call hints_def , show-cfg          , Show build config - aka 'sc'                      )
    @ $(call hints_rmt_lib_def)
    @ $(call hints_parser_def)
    @ $(call hints_def , lib               , Create library $(LIB_TARG) from source            )
    @ $(call hints_def , lib-clean         , Remove library build products                     )
    @ $(call hints_def , apps              , Create executables $(APP_EXE_NAMS)                )
    @ $(call hints_def , apps-clean        , Remove executables                                )
    @ $(call hints_apps_def)
    @ $(call hints_def , dox               , Create dox                                        )
    @ $(call hints_def , dox-clean         , Remove doxygen build products                     )
    @ $(call hints_def , clean             , Remove all generated files and directories        )
endef


# -- Phonys --------------------------------------------------------------------
define phonys_def
    nil
    hints
    show-cfg
    sc
    $(RMT_CLONES)
    $(RMT_LIBS)
    $(RMT_CLEANS)
    lib
    lib-clean
    apps
    apps-clean
    $(APP_RUN_TARGS)
    dox
    dox-clean
    clean
endef
PHONYS += $(strip $(phonys_def))


# -- Cleans --------------------------------------------------------------------
CLEANS += $(PARSER_CLNS)
CLEANS += lib-clean
CLEANS += apps-clean
CLEANS += dox-clean


# -- rules ---------------------------------------------------------------------
nil             : $(NULL)         ; @true
hints           : $(NULL)         ; $(top_hints_def)
show-cfg        : $(NULL)         ; bin/cfg-show
sc              : show-cfg        ; $(NULL)
$(LIB_TARG)     : $(LIB_REQS)     ; $(link-for-shared-obj)
lib             : $(LIB_TARG)     ; $(NULL)
lib-clean       : $(NULL)         ; rm -rf $(LIB_OBJ_DIR)/* $(LIB_TARG)
apps            : $(APP_EXE_NAMS) ; $(NULL)
apps-clean      : $(NULL)         ; rm -rf $(APP_EXE_NAMS)
dox             : $(NULL)         ; doxygen dox.conf
dox-clean       : $(NULL)         ; rm -rf doxygen
clean           : $(CLEANS)       ; rm -rf $(TMP)

.PHONY          : $(PHONYS)

.DEFAULT_GOAL := hints
