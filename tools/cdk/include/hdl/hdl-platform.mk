#
#  This file is part of OpenCPI (www.opencpi.org).
#     ____                   __________   ____
#    / __ \____  ___  ____  / ____/ __ \ /  _/ ____  _________ _
#   / / / / __ \/ _ \/ __ \/ /   / /_/ / / /  / __ \/ ___/ __ `/
#  / /_/ / /_/ /  __/ / / / /___/ ____/_/ / _/ /_/ / /  / /_/ /
#  \____/ .___/\___/_/ /_/\____/_/    /___/(_)____/_/   \__, /
#      /_/                                             /____/
#
#  OpenCPI is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published
#  by the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  OpenCPI is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with OpenCPI.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################### #
# This makefile is for building platforms and platform configurations
# A platform worker is a device worker that implements the platform_spec.xml
# A platform worker is built, and then some number of platform configurations
# are built.  The platform configurations are used when bitstreams
# get built elsewhere based on assemblies and configurations

HdlMode:=platform
HdlLibraries+=platform
include $(OCPI_CDK_DIR)/include/hdl/hdl-make.mk
# Theses next lines are similar to what worker.mk does
ifneq ($(MAKECMDGOALS),clean)
$(if $(wildcard $(CwdName).xml),,\
  $(error The OWD for the platform and its worker, $(CwdName).xml, is missing))
endif
override Workers:=$(CwdName)
override Worker:=$(Workers)
Worker_$(Worker)_xml:=$(Worker).xml
OcpiLanguage:=vhdl
ComponentLibraries+=devices cards
LibDir=lib/hdl
# We are building a platform that is not known in the core or in the environment
ifeq (,$(filter $(Worker),$(HdlAllPlatforms)))
  HdlAllPlatforms+=$(Worker)
  include $(Worker).mk
  export OCPI_HDL_PLATFORM_PATH+=:$(call OcpiAbsPath,.)
endif
XmlIncludeDirs+=$(HdlPlatformsDir)/specs
ifndef HdlPlatforms
  override HdlPlatforms:=$(HdlPlatform)
endif
ifdef HdlPlatforms
  ifeq ($(filter $(Worker),$(HdlPlatforms)),)
    $(info Skipping platform ($(Worker)) since it is not in HdlPlatforms ($(HdlPlatforms)).)
    HdlSkip := 1
    skip:
  endif
endif
ifndef HdlSkip
override HdlPlatforms:=$(Worker)
override HdlPlatform:=$(Worker)
override HdlTargets:=$(call HdlGetFamily,$(Worker))
override HdlTarget:=$(call HdlGetFamily,$(Worker))
SubCores_$(HdlTarget):=$(Cores)
include $(OCPI_CDK_DIR)/include/hdl/hdl-pre.mk
ifndef HdlSkip
  HdlPlatform:=$(Worker)
  # add xml search in component libraries
  ifneq ($(MAKECMDGOALS),clean)
    $(call OcpiDbgVar,HdlExactPart)
    $(call OcpiDbgVar,HdlPlatform)
    HdlExactPart:=$(HdlPart_$(HdlPlatform))
    # Force targets to just be the family of the platform.
    override HdlTargets:=$(call HdlGetFamily,$(HdlPlatform))
    override HdlTarget:=$(HdlTargets)
    $(call OcpiDbgVar,HdlExactPart)
    $(call OcpiDbgVar,HdlTargets)
    $(eval $(HdlSearchComponentLibraries))
    $(call OcpiDbgVar,XmlIncludeDirsInternal)
    $(and $(shell \
       if test -d devices; then \
        ( \
	 echo ======= Entering the \"devices\" library for the \"$(Worker)\" platform.; \
         $(MAKE) -C devices \
           ComponentLibrariesInternal="$(call OcpiAdjustLibraries,$(ComponentLibraries))" \
           XmlIncludeDirsInternal="$(call AdjustRelative,$(XmlIncludeDirsInternal))" \
	   HdlPlatform="$(HdlPlatform)" ; \
	 echo ======= Exiting the \"devices\" library for th \"$(Worker)\" platform. \
        ) 1>&2 ; \
       fi),)
  endif
  ################################################################################
  # We are like a worker (and thus a core)
  # But we're VHDL only, so we only need to build the rv core
  # which is the "app" without container or the platform
  # FIXME: we can't do this yet because the BB library name depends on there being both cores...
  #Tops:=$(Worker)_rv
  ifneq ($(wildcard devices),)
    ComponentLibraries+=./devices
  endif
  $(eval $(HdlSearchComponentLibraries))
  include $(OCPI_CDK_DIR)/include/hdl/hdl-worker.mk
  ifndef HdlSkip

    ifneq ($(MAKECMDGOALS),clean)
      $(shell test -r $(GeneratedDir)/base.xml || echo '<HdlConfig/>' > $(GeneratedDir)/base.xml)
    endif
    ################################################################################
    # From here its about building the platform configuration cores
    ifndef Configurations
      ifneq ($(MAKECMDGOALS),clean)
        ifeq ($(origin Configurations),undefined)
          Configurations:=base
        else
          $(info No platform configurations will be built since none are specified.)
        endif
      endif
    endif
    ifdef Configurations
      HdlConfName=$(Worker)_$1
      HdlConfOutDir=$(OutDir)config-$1
      HdlConfDir=$(call HdlConfOutDir,$(call HdlConfName,$1))
      # We have containers to build locally.
      # We already build the directories for default containers, and we already
      # did a first pass parse of the container XML for these containers
      define doConfig
         .PHONY: $(call HdlConfOutDir,$1)
         all: $(call HdlConfOutDir,$1)
        $(call HdlConfOutDir,$1):
	  $(AT)mkdir -p $$@
	  $(AT)echo ======= Entering the \"$1\" configuration for the \"$(Worker)\" platform.
	  $(AT)$(MAKE) -C $$@ -f $(OCPI_CDK_DIR)/include/hdl/hdl-config.mk \
               HdlPlatforms=$(Worker) \
               HdlPlatformWorker=../../$(Worker) \
	       HdlLibrariesInternal="$(call OcpiAdjustLibraries,$(HdlLibraries))" \
	       Cores="$(call HdlAdjustLlibraries,$(Cores))" \
               ComponentLibrariesInternal="../lib $(call OcpiAdjustLibraries,$(ComponentLibraries))" \
               XmlIncludeDirsInternal="$(call AdjustRelative,$(XmlIncludeDirsInternal))"
	  $(AT)echo ======= Exiting the \"$1\" configuration for the \"$(Worker)\" platform.
      endef
      $(foreach c,$(Configurations),$(eval $(call doConfig,$c)))
    endif # have configurations
  endif # skip after hdl-workers.mk
endif # skip after hdl-pre.mk
endif # skip after platform check
clean::
	$(AT)if test -d devices; then make -C devices clean; fi
	$(AT) rm -r -f config-* lib

ifneq (,)
all: devices

.PHONY: devices

devices:
	$(AT)if test -d devices; then make -C devices; fi
endif
