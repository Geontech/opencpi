# This file is protected by Copyright. Please refer to the COPYRIGHT file
# distributed with this source distribution.
#
# This file is part of OpenCPI <http://www.opencpi.org>
#
# OpenCPI is free software: you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# OpenCPI is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

# Makefile for RCC common definitions not specific to "workers"
ifndef RCC_MAKE_MK
RCC_MAKE_MK:=xxx
include $(OCPI_CDK_DIR)/include/util.mk
#
# The block below needs to happen prior to the assignments below for
# extracting RccTarget/Platform info from this makefile
ifdef ShellRccTargetsVars
$(OcpiIncludeProject)
# When collecting a list of RCC targets/platforms, you do not need to be inside a project.
# So, collect all projects in the Project Registry Dir into the project path for searching.
# If inside a project, the registry should be searched automatically via the project's imports.
ifeq ($(OCPI_PROJECT_DIR),)
  export OCPI_PROJECT_PATH:=$(OCPI_PROJECT_PATH):$(subst $(Space),:,$(wildcard $(OcpiProjectRegistryDir)/*))
endif
endif

RccOs=$(word 1,$(subst -, ,$(or $1,$(RccTarget))))
RccOsVersion=$(word 2,$(subst -, ,$1))
RccArch=$(word 3,$(subst -, ,$1))

$(call OcpiDbgVar,RccPlatforms)
$(call OcpiDbgVar,RccTargets)

# for a clean environment, ensure OCPI_TOOL_PLATFORM at least
$(eval $(OcpiEnsureToolPlatform))

# Allow the option of specifying an rcc platform by referencing the associated
# HDL platform, but only incurring the overhead of this search when this variable
# is specified.
ifdef RccHdlPlatform
  override RccHdlPlatforms+= $(RccHdlPlatform)
endif
ifdef RccHdlPlatforms
  include $(OCPI_CDK_DIR)/include/hdl/hdl-targets.mk
  $(foreach p,$(RccHdlPlatforms),\
     $(if $(filter $p,$(HdlAllPlatforms)),\
       $(if $(HdlRccPlatform_$p),\
         $(eval override RccPlatforms:=$(call Unique,$(RccPlatforms) $(HdlRccPlatform_$p))), \
         $(eval override RccPlatforms:=$(call Unique,$(RccPlatforms) $(OCPI_TOOL_PLATFORM)))$(warning There is no RCC platform associated with the HDL platform: $p. Using $(OCPI_TOOL_PLATFORM))),\
       $(eval override RccPlatforms:=$(call Unique,$(RccPlatforms) $(OCPI_TOOL_PLATFORM)))$(warning There is no HDL platform named: $p, so no RCC platform for it. Using $(OCPI_TOOL_PLATFORM))\
     ))
endif

ifdef RccPlatforms
  # nothing here - we process later
else ifdef RccPlatform
  RccPlatforms:=$(RccPlatform)
else ifdef RccTargets
  # nothing to do here
else ifdef RccTarget
  RccTargets:=$(RccTarget)
else ifeq ($(origin RccPlatforms),undefined)
  ifdef OCPI_TARGET_PLATFORM
    RccPlatforms:=$(OCPI_TARGET_PLATFORM)
  else ifdef OCPI_TOOL_PLATFORM
    RccPlatforms:=$(OCPI_TOOL_PLATFORM)
  else
    $(error Unexpected failure to figure out which RCC compiler to use.)
  endif
endif

$(call OcpiDbgVar,RccPlatforms)
$(call OcpiDbgVar,RccTargets)

ifdef OCPI_ALL_RCC_PLATFORMS
  RccAllPlatforms:=$(OCPI_ALL_RCC_PLATFORMS)
  RccAllTargets:=$(OCPI_ALL_RCC_TARGETS)
else
  $(foreach d,$(OcpiGetRccPlatformPaths),\
    $(foreach p,$(wildcard $d/*),\
      $(and $(wildcard $p/$(notdir $p)-target.mk),\
        $(eval RccAllPlatforms:=$(RccAllPlatforms) $(notdir $p))) \
      $(and $(wildcard $p/target),\
        $(eval RccAllTargets:=$(RccAllTargets) $(shell cat $p/target)))))
  RccAllTargets:=$(call Unique,$(RccAllTargets))
  export OCPI_ALL_RCC_PLATFORMS:=$(RccAllPlatforms)
  export OCPI_ALL_RCC_TARGETS:=$(RccAllTargets)
#  $(info OCPI_ALL_RCC_PLATFORMS is $(OCPI_ALL_RCC_PLATFORMS))
#  $(info OCPI_ALL_RCC_TARGETS is $(OCPI_ALL_RCC_TARGETS))
endif
ifdef RccPlatforms
  # FIXME: this logic is copied in ocl-make.mk
  override RccPlatforms:=$(filter-out $(ExcludePlatforms) $(RccExcludePlatforms),$(RccPlatforms))
  ifneq ($(OnlyPlatforms)$(RccOnlyPlatforms),)
    override RccPlatforms:=$(filter $(OnlyPlatforms) $(RccOnlyPlatforms),$(RccPlatforms))
  endif
  # We cannot perform this check since we may be inheriting changes made in a higher
  # level Makefile.  If the user tries this, it is simply ignored.
  # ifdef RccTargets
  #   $(error You cannot set both RccTarget(s) and RccPlatform(s))
  # endif
  RccTargets:=
  RccFound:=
  $(foreach p,$(RccPlatforms),\
    $(foreach d, $(call OcpiGetRccPlatformDir,$p),\
      $(foreach f,$d/target,\
         $(if $(wildcard $f),\
           $(foreach t,$(shell echo $$(< $f)),\
               $(eval RccTargets+=$t)\
               $(eval RccTarget_$p:=$t)\
               $(eval RccFound+=$p))))))\
  $(foreach p,$(RccPlatforms),\
    $(if $(findstring $p,$(RccFound)),,\
      $(error RccPlatform $p is unknown, $f does not exist)))
else
  # Derive a platform from each target (somewhat expensive, but we have shortcuts)
  # This can be deprecated or accelerated as it makes sense
  # An easy accelerator would be to make the target an actual file in the platform's dir
  # (A single wildcard then does it)
  # We could also cache this
  RccPlatforms:=
  RccFound:=\
  $(foreach d,$(OcpiGetRccPlatformPaths),\
    $(foreach f,$(wildcard $d/*/target),\
      $(foreach p,$(notdir $(patsubst %/,%,$(dir $f))),\
        $(foreach t,$(shell echo $$(< $f)),\
          $(if $(findstring $t,$(RccTargets)),\
            $(eval RccTarget_$p:=$t)\
            $(eval RccPlatforms+=$p)\
            $(eval RccFound+=$t))))))\
  $(foreach t,$(RccTargets),\
     $(if $(findstring $t,$(RccFound)),,\
        $(error The RccTarget $t is not the target for any software platform (in $(OCPI_CDK_DIR) or $(OCPI_PROJECT_PATH)))))
endif

$(call OcpiDbgVar,RccPlatforms)
$(call OcpiDbgVar,RccTargets)

# This should avoid confusion since they should not be used after this point
override RccTarget:=
override RccPlatform:=

# Read in all the tool sets indicated by the targets
#
ifeq ($(filter clean cleanrcc,$(MAKECMDGOALS)),)
# include all the rcc compilation files for all target platforms
$(foreach p,$(RccPlatforms), \
  $(foreach t,$(RccTarget_$p),\
    $(eval files:=)\
    $(eval cross:=)\
    $(foreach d, $(call OcpiGetRccPlatformDir,$p),\
      $(foreach m,$(if $(findstring $(OCPI_TOOL_PLATFORM),$p),rcc=$p,rcc=$(OCPI_TOOL_PLATFORM)=$p) \
                  $(if $(findstring $(OCPI_TOOL_HOST),$t),$t,$(OCPI_TOOL_HOST)=$t),\
        $(eval files:=$(files) $(or $(wildcard $(OCPI_CDK_DIR)/include/rcc/$m.mk),\
                                    $(wildcard $d/$m.mk)))\
        $(and $(findstring =,$(subst rcc=,,$m)),$(eval cross:=1)))\
      $(foreach n,$(words $(files)),\
         $(if $(filter 0,$n),\
	    $(if $(cross),\
               $(error There is no cross compiler defined from $(OCPI_TOOL_PLATFORM) to $p),\
               $(eval include $(OCPI_CDK_DIR)/include/rcc/default.mk)),\
	    $(if $(filter 1,$n),,\
               $(warning More than one file defined for compiling $(OCPI_TOOL_PLATFORM) to $p, using $(word 1,$(files)), others are $(wordlist 2,$(words $(files)),$(files)).))\
            $(eval include $(word 1,$(files))))))))
endif
endif

# Assignments that can be used to extract make variables into bash/python...
ifdef ShellRccTargetsVars
all:
$(info RccAllPlatforms="$(sort $(RccAllPlatforms))";\
       RccPlatforms="$(sort $(RccPlatforms))";\
       RccAllTargets="$(sort $(RccAllTargets))";\
       RccTargets="$(sort $(RccTargets))";\
       $(foreach p,$(sort $(RccAllPlatforms)),\
         $(if $(RccTarget_$p),RccTarget_$p="$(RccTarget_$p)";)))
endif
#$(foreach t,$(RccTopTargets),$(or $(RccTargets_$t),$t))";\
