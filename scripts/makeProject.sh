#!/bin/bash

# ocpidev verbosity
#V=" -v"
# Less verbose: redirect ocpidev output to /dev/null
#QUIET=1
# Trace commands executed
#set -x

case "$OCPI_LOG_LEVEL" in
  ([1-7]) V=" -v"; QUIET=1;;
  ([8-9]) V=" -v";;
  ([1][0-9]) V=" -v"; set -x;;
  (0|*) QUIET=1; echo "Valid Log Levels are 0-19. Using default=0";;
esac

if [ -z "$SKELETON" ] ; then
  SKELETON=0
fi

if [ -z "$OCPI_BASE" ] ; then
  OCPI_BASE=0
fi

# Extract a project, creating it at $1, using ocpidev to do everything we can.

function bad {
  echo Failed: $*
  exit 1
}

function get_first {
  grep '^[ 	]*<[^!]' $1 | head -1 | sed 's/^[ 	]*<[ 	]*\([^ 	].*\)>/\1/' > $2
}

function get_attrs {
  get_first $1 $2
  lang=$(sed -n "s/.*[lL]anguage=['\"]\([^'\"]*\)['\"].*\$/\1/p" $2)
  # Here we check first for spec=*-spec, to handle situations like in
  # certain emulators where there is a spec=emulator-spec AND
  # a spec=emulator. This probably needs to be resolved in those OWDs
  spec=$(sed -n "s/.*[sS]pec=['\"]\([^'\"]*-spec\)['\"].*\$/\1/p" $2)
  if [ -z "$spec" ] ; then
    spec=$(sed -n "s/.*[sS]pec=['\"]\([^'\"]*\)['\"].*\$/\1/p" $2)
  fi
  wname=$(sed -n "s/.*[nN]ame=['\"]\([^'\"]*\)['\"].*\$/\1/p" $2)
  slave=$(sed -n "s/.*[sS]lave=['\"]\([^'\"]*\)['\"].*\$/\1/p" $2)
  emulate=$(sed -n "s/.*[eE]mulate=['\"]\([^'\"]*\)['\"].*\$/\1/p" $2)
  supported=($(sed -n "s/.*<\s*[sS]upports\s*[wW]orker=['\"]\([^'\"]*\)['\"].*\$/\1/p" $1))

  if [ -z "$spec" ] ; then
    spec=$(sed -n '/href=/s/^.*href="\([^"]*\)".*$/\1/p' $1)
    [ -z $spec ] && {
      if grep -q -i componentspec $1; then
        spec=none
      else
        bad spec cannot be found: $(dirname $1)
      fi
    }
  fi
  return 0
}

# devices in hdl/cards or hdl/platforms/*/devices may use
# spec files or workers from hdl/devices. Therefore,
# we include directories in the search path for specs.
function do_ocpidev {
  if [ "$QUIET" == 1 ] ; then
    XmlIncludeDirs=$xmldirs ocpidev $V $@ &> /dev/null
  else
    echo "Calling: ocpidev $V $@"
#    echo "         With: XmlIncludeDirs=$xmldirs"
    XmlIncludeDirs=$xmldirs ocpidev $V $@
  fi

}

# Get the directory type (ie library, platform, core) by parsing the Makefile
# And determining which .mk file it includes from the cdk
function get_dirtype {
  if [ -e "$1/Makefile" ] ; then
    dirtype=$(sed -n 's=^[        ]*include[      ]*.*OCPI_CDK_DIR.*/include/\(.*\)\.mk.*=\1=p' $1/Makefile)
    dirtype=${dirtype##*hdl\/}
    for i in ${dirtype[@]} ; do
      case "$i" in
        (hdl-lib|hdl-library)
          dirtype=lib
          break
          ;;
        (hdl-core)
          dirtype=core
          break
          ;;
        (hdl-platform)
          dirtype=platform
          ;;
        (hdl-assembly)
          dirtype=assembly
          ;;
        (libraries)
          dirtype=libraries
          ;;
        (library)
          dirtype=library
          ;;
        (*)
          echo "The Makefile include \"$i\" does not specify a known dirtype."
          ;;
      esac
    done
  else
    dirtype=none
  fi
}

# Parse Makefile ($1), cat lines together that end in '\'
# Fine Makefile variable ($2) and grab its values
# Set the result to $3 as return value
# If this fails, output a message explaining that this
# Make variable for this instance needs to be handled
# manually.
function get_make_option {
  get_make_opt $1 $2 $3 2> /dev/null || {
    [ "$QUIET" == 1 ] || echo "String in \"$1\" for variable \"$2\" is too complicated to parse and pass to ocpidev. Skipping. You will have to do this manually."
    eval "$3=()"
#    failedmakeoption=1
  }
}

# This function gets the values of a Makefile variable. It continues on the next line if a backslash is used, and ignores comments
function get_make_opt {
    eval "$3=($(sed -e :a -e '/\\\s*$/N; s/#.*//; s/\\\s*\n//; ta' $1 \
                | sed -n "/^[         ]*$2/s/^[      ]*$2[  ]*:*=[    ]*\(.*\)$/\1/p" ))"
}

# Look for all of the known make options in a given makefile
function get_make_options {
#    failedmakeoption=0
    unset workers
    unset others
    unset cores
    unset onlys
    unset exes
    unset onlyplats
    unset explats
    unset includes
    unset xmlincludes
    unset liblibs
    unset complibs
    unset package
    unset hdlnolib
    unset hdlnoelab
    unset module
    unset prebuiltcore
    unset rccstatprereqs
    unset rccdynprereqs
    if [ "$2" != noworkers ] ; then
      get_make_option $1 Workers             workers
    fi
    get_make_option $1 SourceFiles         others
    get_make_option $1 Cores               cores
    get_make_option $1 OnlyTargets         onlys
    get_make_option $1 ExcludeTargets      exes
    get_make_option $1 OnlyPlatforms       onlyplats
    get_make_option $1 ExcludePlatforms    explats
    get_make_option $1 IncludeDirs         includes
    get_make_option $1 XmlIncludeDirs      xmlincludes
    get_make_option $1 Libraries            liblibs
    get_make_option $1 HdlLibraries         hdllibs
    # Support HdlLibraries for backwards compatibility
    liblibs=(${liblibs[@]} ${hdllibs[@]})
    get_make_option $1 ComponentLibraries   complibs
    get_make_option $1 Package             package
    get_make_option $1 HdlNoLibraries      hdlnolib
    get_make_option $1 HdlNoElaboration    hdlnoelab
    get_make_option $1 Top                 module
    get_make_option $1 PreBuiltCore        prebuiltcore
    get_make_option $1 RccStaticPrereqLibs rccstatprereqs
    get_make_option $1 RccDynamicPrereqLibs rccdynprereqs
}

# Check all of the known make options in a given makefile against the last ones found by get_make_options
function check_make_options {
    unset workers2
    unset others2
    unset cores2
    unset onlys2
    unset exes2
    unset onlyplats2
    unset explats2
    unset includes2
    unset xmlincludes2
    unset liblibs2
    unset complibs2
    unset package2
    unset hdlnolib2
    unset hdlnoelab2
    unset module2
    unset prebuiltcore2
    unset rccstatprereqs2
    unset rccdynprereqs2
    if [ "$2" != noworkers ] ; then
      get_make_option $1 Workers             workers2
      [ "${workers[*]}" == "${workers2[*]}" ] || bad "Workers do not match in original and generated Makefile for asset generated at \"$1\""
    fi
    get_make_option $1 SourceFiles         others2
    [ "${others[*]}" == "${others2[*]}" ] || bad "SourceFiles do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 Cores               cores2
    [ "${cores[*]}" == "${cores2[*]}" ] || bad "Core does not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 OnlyTargets         onlys2
    [ "${onlys[*]}" == "${onlys2[*]}" ] || bad "OnlyTargets do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 ExcludeTargets      exes2
    [ "${exes[*]}" == "${exes2[*]}" ] || bad "ExcludeTargets do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 OnlyPlatforms       onlyplats2
    [ "${onlyplats[*]}" == "${onlyplats2[*]}" ] || bad "OnlyPlatforms do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 ExcludePlatforms    explats2
    [ "${explats[*]}" == "${explats2[*]}" ] || bad "ExcludePlatforms do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 IncludeDirs         includes2
    [ "${includes[*]}" == "${includes2[*]}" ] || bad "IncludeDirs do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 XmlIncludeDirs      xmlincludes2
    [ "${xmlincludes[*]}" == "${xmlincludes2[*]}" ] || bad "XmlIncludeDirs do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 Libraries            liblibs2
    [ "${liblibs[*]}" == "${liblibs2[*]}" ] || bad "Libraries do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 ComponentLibraries   complibs2
    [ "${complibs[*]}" == "${complibs2[*]}" ] || bad "ComponentLibraries do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 Package             package2
    [ "$package" == "$package2" ] || bad "Package do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 HdlNoLibraries       hdlnolib2
    [ "$hdlnolib" == "$hdlnolib2" ] || bad "HdlNoLibraries do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 HdlNoElaboration    hdlnoelab2
    [ "$hdlnoelab" == "$hdlnoelab2" ] || bad "HdlNoElaboration do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 Top                 module2
    [ "${module[*]}" == "${module2[*]}" ] || bad "Top does not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 PreBuiltCore        prebuiltcore2
    [ "${prebuiltcore[*]}" == "${prebuiltcore2[*]}" ] || bad "PreBuiltCore do not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 RccStaticPrereqLibs rccstatprereqs2
    [ "${rccstatprereqs[*]}" == "${rccstatprereqs2[*]}" ] || bad "RccStaticPrereqLibs does not match in original and generated Makefile for asset generated at \"$1\""
    get_make_option $1 RccDynamicPrereqLibs rccdynprereqs2
    [ "${rccdynprereqs[*]}" == "${rccdynprereqs2[*]}" ] || bad "RccDynamicPrereqLibs does not match in original and generated Makefile for asset generated at \"$1\""
}



# This was an attempt to grab a raw string value from a Makefile when the value of a Make variable is actually
# some complicated expression. This a future TODO.
#function get_make_expr {
#    tmp="$(sed -e :a -e '/\\\s*$/N; s/\\\s*\n//; ta' $1 \
#                | sed -n "/^[         ]*$2/s/^[      ]*$2[  ]*:*=[    ]*\(.*\)$/\1/p" )"; eval "$3='\'$tmp\''" ;
#}

# Helper function. List $1 contains $2 ?
function contains {
  local lst
  lst=("$@")
  ((search_for_idx=${#lst[@]} - 1))
    search_for=${lst[search_for_idx]}
    unset lst[search_for_idx]
  for elem in ${lst[@]} ; do
    [ "$elem" != "$search_for" ] || return 0
  done
  return 1
}


# Copy files for a library from the source repo to the destination library.
# This should be run after ocpidev creates the library. After we overwrite
# the makefile, we should clean and run make (no Workers) incase the package
# name has changed.
function copy_extra_files {
  if [ -d "$libdir" ] ; then
    cp $from/$libdir/Makefile $libdir/ || true
    make clean -C $libdir
    make --no-print-directory -C $libdir Workers=""
    # Copy scripts and includes for this library.
    [ "$QUIET" == 1 ] || echo "Copying library's include dirs, test dirs, READMEs, scripts"
    # Ignore errors
    if [ -d $from/$libdir/include ] ; then
      mkdir -p $libdir/include
      cp $from/$libdir/include/*.h $libdir/include/  2> /dev/null || true
    fi
    if [ -d $from/$libdir/scripts ] ; then
      mkdir -p $libdir/scripts
      cp $from/$libdir/scripts/* $libdir/scripts/ 2> /dev/null || true
    fi
    cp -rf $from/$libdir/{*README*,*.mk,*.sh} $libdir/ 2> /dev/null || true
  fi
}

set -e

if [ -z "$1" -o "$1" == "-h" -o "$1" == "--help" ] ; then
  echo "===================================================================
Usage: <path-to>/makeProject.sh <new-project-location>
   Run this from an existing project to recreate this project with ocpidev.
===========================================================================
SKELETON
- Set SKELETON=1 if you do NOT want to ultimately copy over all of your project's source
- Leave default SKELETON=0 to create the project skeleton with ocpidev AND copy
  the source from the existing project.

OCPI_BASE
- In general you will want to leave the default OCPI_BASE=0 to recreate
  any project. Only set this option to remove/add custom content associated
  with the base/assets repos.
- Set OCPI_BASE=1 if recreating base project from the opencpi.git repo
- Set OCPI_BASE=-1 if recreating assets project from the ocpiassets repo

OCPI_LOG_LEVEL
- As used elsewhere
"
  exit
fi

mkdir -p $(dirname $1)

if [ "$OCPI_BASE" == "1" ] ; then
  project_type=Base
  pkg=ocpi
elif [ "$OCPI_BASE" == "-1" ] ; then
  project_type=Assets
  pkg=ocpiassets
else
  project_type=Custom
  get_make_option $(pwd)/Project.mk ProjectPackage pjpackage
  pkg=$pjpackage
fi

do_ocpidev ${pkg:+-K $pkg} -d $(dirname $1) create project $(basename $1)

echo "Creating $project_type project with name \"$(basename $1)\""

if [ -f "$(pwd)/Project.mk" -a -n "$pkg" ] ; then
  get_make_option $1/Project.mk ProjectPackage pkg2
  [ "${pkg[*]}" == "${pkg2[*]}" ] || bad "ProjectPackage do not match in original and generated Project.mk for asset generated at \"$1\""
fi

from=$(pwd)
fullproj="$(pwd)/$1"
t=/tmp/$(basename $0).$$
cd $1

# Initialize libs to iterate through. This can be automated
# similar to the platforms subtree as seen below. For now,
# hardcoding libs and then adding on platforms subdirs
complibdirs=(components)
get_dirtype $from/components
if [ "$dirtype" == libraries ] ; then
  complibdirs=()
  for complib in $from/components/* ; do
    if [ -d "$complib" ] ; then
      get_dirtype $complib
      if [ "$dirtype" == library ] ; then
        complibdirs=(${complibdirs[@]} components/"$(basename $complib)")
      fi
    fi
  done
fi

hdllibdirs=(hdl/devices hdl/cards hdl/adapters)
libs=(${complibdirs[@]} ${hdllibdirs[@]})

###################################################################################
# hdl/primitives                                                                  #
# Iterate through the primitive subtree and create primitive cores and libraries  #
# Copy the source files over afterwards                                           #
###################################################################################

# For each subdir of primitives, determine if it is a lib or core.
# Then do ocpidev create hdl primitive <lib|core>
# Copy over source files
# check subdirs for other source files?
echo "=================== Primitives ========================="
for primdir in $from/hdl/primitives/* ; do
  if [ -d $primdir ] ; then
    # get the directory type of this primitive subdir. store it in dirtype
    get_dirtype $primdir
    case "$dirtype" in
      (lib)
        [ "$QUIET" == 1 ] || echo Operating on a primitive libarary
        ;;
      (core)
        [ "$QUIET" == 1 ] || echo Operating on a primitive core
        ;;
      (*)
        [ "$QUIET" == 1 ] || echo Dir in hdlprimitives of type \"$dirtype\" is not a core or lib. Skipping.
        continue
        ;;
    esac
    primname=$(basename $primdir)
    get_make_options $primdir/Makefile
    primoptions="
${others[@]/#/-O } \
${cores[@]/#/-C } \
${onlys[@]/#/-T } \
${exes[@]/#/-Z } \
${onlyplats[@]/#/-G } \
${explats[@]/#/-Q } \
${liblibs[@]/#/-Y } \
${hdlnolib:+-H} \
${hdlnoelab:+-J} \
${module[@]/#/-M } \
${prebuiltcore[@]/#/-B } \
"
    case "$dirtype" in
      (lib)
        do_ocpidev create hdl primitive library $primname $primoptions
        ;;
      (core)
        do_ocpidev create hdl primitive core $primname $primoptions
        ;;
      (*) bad invalid primitive subdir \"$primdir\" ;;
    esac
    check_make_options hdl/primitives/$primname/Makefile
    #cat  hdl/primitives/$primname/Makefile
    [ -n "$others" ] && {
      for o in ${others[@]} ; do
        if [ ! -r "$primdir/$o" ] ; then
          [ "$QUIET" == 1 ] || echo "Warning: missing other file $o. It may be in primitives"
          #bad for $i missing other file $o
          continue
        else
          mkdir -p $(dirname hdl/primitives/$primname/$o)
          if [ "$SKELETON" == 1 ] ; then
            touch hdl/primitives/$primname/$o
          else
            cp -rf $primdir/$o hdl/primitives/$primname/$o
          fi
        fi
      done
    }
    # Need to do this for now otherwise the primitives wont build
#    if [ "$failedmakeoption" == "1" ] ; then
#      echo Overwriting makefile for prim =====================================================================
      cp $primdir/Makefile hdl/primitives/$primname/
#    fi
    [ "$SKELETON" == 1 ] || {
     rm -rf hdl/primitives/$primname/*
    }
    cp -rf $primdir/* hdl/primitives/$primname/
  fi
done
cp $from/hdl/primitives/Makefile hdl/primitives 2> /dev/null || true
[ "$SKELETON" == 1 ] || cp  $from/hdl/primitives/* hdl/primitives/ 2> /dev/null || true

###################################################################################
# hdl/platforms                                                                   #
# Iterate through the platforms directories and create each platform              #
# If the platform has a devices subdir, add it to the libs list so that its       #
# devices can be created in the next section                                      #
###################################################################################

# Loop through the folders in platforms.
# Check if it is a platform (ie platform.mk)
# If so append hdl/platforms/<plat>/devices to libdir list
echo "=================== Platforms ========================="
for platdir in $from/hdl/platforms/* ; do
  if [ -d $platdir ] ; then
    # get the directory type of this platform subdir. store it in dirtype
    get_dirtype $platdir
    if [ "$dirtype" == "platform" ] ; then
      platname=$(basename $platdir)
      get_make_options $platdir/Makefile
      get_make_option $platdir/"$platname".mk HdlPart_$platname hdlpart
      do_ocpidev create hdl platform $platname \
${others[@]/#/-O } \
${cores[@]/#/-C } \
${onlys[@]/#/-T } \
${exes[@]/#/-Z } \
${onlyplats[@]/#/-G } \
${explats[@]/#/-Q } \
${liblibs[@]/#/-Y } \
${complibs[@]/#/-y } \
${includes[@]/#/-I } \
${xmlincludes[@]/#/-A } \
${configs[@]/#/-G } \
${hdlpart[@]/#/-g } \
-q 100e6 \

      check_make_options hdl/platforms/$platname/Makefile
      #cat hdl/platforms/$platname/Makefile
      # cant check this for base because in base there are platforms without *.mk files
      [ ! -f $platdir/"$platname".mk ] || {
        get_make_option hdl/platforms/$platname/"$platname".mk HdlPart_$platname hdlpart2
        [ "$hdlpart" == "$hdlpart2" ] || bad HdlPart does not match in created mk file for platform "$platname"
      }
      [ -n "$others" ] && {
        for o in ${others[@]} ; do
          if [ ! -r "$platdir/$o" ] ; then
            [ "$QUIET" == 1 ] || echo "Warning: missing other file $o. It may be in primitives"
            #bad for $i missing other file $o
            continue
          else
            mkdir -p $(dirname hdl/platforms/$platname/$n/$o)
            cp $platdir/$o hdl/platforms/$platname/$n/$o
          fi
        done
      }
      if [ -d $platdir/devices ] ; then
        libs=(${libs[@]} hdl/platforms/$platname/devices)
        hdllibdirs=(${hdllibdirs[@]} hdl/platforms/$platname/devices)
      fi
      [ "$SKELETON" == 1 ] || cp -rf $platdir/* hdl/platforms/$platname/ 2> /dev/null || true
      [ "$SKELETON" == 1 ] || [ -d "hdl/platforms/$platname/devices" ] && rm -rf hdl/platforms/$platname/devices
    fi
  fi
done
[ "$SKELETON" == 1 ] || cp $from/hdl/platforms/* hdl/platforms 2> /dev/null || true

# Some platform.mk and xml files need to be held off because
# the platform is not fully supported yet
[ "$SKELETON" == 1 ] || [ "$OCPI_BASE" != 1 ] || {
  rm hdl/platforms/ml555/ml555.mk 2> /dev/null || true
  rm hdl/platforms/ml555/ml555.xml 2> /dev/null || true
  cp $from/hdl/platforms/ml555/ml555.mk.hold hdl/platforms/ml555 2> /dev/null || true
  rm hdl/platforms/schist/schist.mk 2> /dev/null || true
  rm hdl/platforms/schist/schist.xml 2> /dev/null || true
  cp $from/hdl/platforms/schist/schist.mk.hold hdl/platforms/schist 2> /dev/null || true
}
###################################################################################
# Create Specs, Workers, Devices ...                                              #
# Iterate through each worker/device library and create the OCSs and OWDs         #
# This includes components libraries, hdl (devices, cards, adapters, platforms)   #
###################################################################################
for libdir in ${libs[@]} ; do
  # Make sure this library exists in the source project
  if [ ! -d "$from/$libdir" ] ; then
    [ "$QUIET" == 1 ] || echo "Skipping $libdir ... does not exist in source project."
    continue
  fi
  libname=${libdir##components/}
  libname=${libname##hdl/}
  get_make_options $from/$libdir/Makefile
  if contains ${hdllibdirs[@]} $libdir ; then
    do_ocpidev create hdl library $libname \
${complibs[@]/#/-y } \
${xmlincludes[@]/#/-A } \
${package:+-K $package} \

    liboption=" -h "
    # Ignore the Workers= lines in the library Makefile because these cannot be set at creation
    check_make_options $libdir/Makefile "noworkers"
  elif contains ${complibdirs[@]} $libdir ; then
    do_ocpidev create library $libname \
${complibs[@]/#/-y } \
${xmlincludes[@]/#/-A } \
${package:+-K $package} \

    liboption=" -l "
    # Ignore the Workers= lines in the library Makefile because these cannot be set at creation
    check_make_options $libdir/Makefile "noworkers"
  fi
  [ "$QUIET" == 1 ] || echo "Created the $libdir library. Now copying our custom Makefile and other files."
  [ "$SKELETON" == 1 ] || copy_extra_files || true
  # Use the following line if we decide to include .test directories in the project
  #[ "$SKELETON" == 1 ] || cp -rf $from/$libdir/*.test $libdir/ 2> /dev/null || true
  # grab the library name (ie devices, adapters, platforms/zed_zipper/devices
  # Generate the worker/device creationg string and any library options
  xmldirs=""
  libopt="$liboption $libname"
  case $libdir in
    (hdl/devices)
      cmd=" hdl device"
      ;;
    (hdl/cards)
      cmd=" hdl device"
      libopt="-h cards"
      xmldirs="$1/hdl/devices/specs $1/hdl/devices/lib/hdl"
      ;;
    (hdl/adapters)
      cmd=" worker"
      ;;
    (components*)
      cmd=" worker"
      ;;
    (hdl/platforms/*)
      cmd=" hdl device"
      platname=${libname%devices*}
      libopt="-P $(basename $platname)"
      xmldirs="$1/hdl/devices/specs $1/hdl/devices/lib/hdl"
      ;;
    (*) bad invalid lib: $libdir ;;
  esac
  [ "$QUIET" == 1 ] || echo "Operating in library: $libdir, with options: $libopt. We will create our workers/devices with \"ocpidev create $cmd\""

  ###################################################################################
  # Create Specs, Properties, Protocols, Cards, Slots in each library               #
  ###################################################################################
  if [ ! -d $from/$libdir/specs ] ; then
    [ "$QUIET" == 1 ] || echo "This library has no specs. Need to create an empty spec to make sure that the directory structure is created if this is a platform dir."
    blankname=BLANK-DELETE-ME-spec.xml
    do_ocpidev create spec $blankname $libopt
    rm -rf $libdir/specs
    [ "$QUIET" == 1 ] || echo "Now that we have actually forced ocpidev to create $libdir as a library, we can copy our custom makefile and other files"
    [ "$SKELETON" == 1 ] || copy_extra_files  || true
  fi
  echo "=====Creating specs, properties, cards, slots for library \"$libdir\""
  for i in $from/$libdir/specs/*; do
    if [ ! -d $from/$libdir/specs ] ; then
      [ "$QUIET" == 1 ] || echo "No specs directory in this library"
      break
    fi
    if [ -L "$i" -a ! -e "$i" ] ; then
      [ "$QUIET" == 1 ] || echo "File \"$i\" is a broken symlink. Skipping this spec"
      continue
    fi
    get_first $i $t
    x="$(sed 's/^\([a-zA-Z]*\)[^a-zA-Z]*.*$/\1/' $t | tr A-Z a-z)"
    case "$x" in
      (protocol|properties)
        do_ocpidev create $x $(basename $i) $libopt
        [ -e $from/$libdir/specs/$(basename $i) ] || bad $x not there for $i
        [ "$SKELETON" == 1 ] || cp $i $libdir/specs/$(basename $i)
        ;;
      (signals)
        do_ocpidev create hdl $x $(basename $i) $libopt
        [ -e $from/$libdir/specs/$(basename $i) ] || bad $x not there for $i
        [ "$SKELETON" == 1 ] || cp $i $libdir/specs/$(basename $i)
        ;;
      (componentspec)
        do_ocpidev create spec $(basename $i .xml) $libopt
        [ -e $from/$libdir/specs/$(basename $i) ] || bad spec not there for $i
        [ "$SKELETON" == 1 ] || cp $i $libdir/specs/$(basename $i)
        ;;
      (card)
        do_ocpidev create hdl card $(basename $i .xml)
        [ -e $from/$libdir/specs/$(basename $i) ] || bad properties not there for $
        [ "$SKELETON" == 1 ] || cp $i $libdir/specs/$(basename $i)
        ;;
      (slottype)
        do_ocpidev create hdl slot $(basename $i .xml)
        [ -e $from/$libdir/specs/$(basename $i) ] || bad slot not there for $
        [ "$SKELETON" == 1 ] || cp $i $libdir/specs/$(basename $i)
        ;;
      (hdlimplementation)
        [ "$QUIET" == 1 ] || echo "ocpidev does not yet support the 'HdlImplementation' xml tag for spec files."
        [ "$QUIET" == 1 ] || echo "We will therefore just copy the xml file to the new project instead"
        [ "$QUIET" == 1 ] || echo "of creating it with ocpidev."
        [ -e $from/$libdir/specs/$(basename $i) ] || bad hdlimplementation not there for $
        [ "$SKELETON" == 1 ] || cp $i $libdir/specs/$(basename $i)
        ;;
      (*)
        bad unexpected spec file name: $i:$x;;
   esac
  done


  ############################################################
  # Create workers and devices for each library              #
  ############################################################
  echo "=====Creating workers or devices for library \"$libdir\""
  # Use make -s showall to determine which components we want to build
  comp_names=$(make -s showall -C $from/$libdir)
  # For now, only consider hdl/rcc workers because the script fails
  # for ocl.
  # Add .ocl here once they are supported
  # ie change to: ... grep '.hdl$\|.rcc$\|.ocl$'
  comps=$((for c in ${comp_names}; do echo ${c}; done | grep '.hdl$\|.rcc$') | sort)
  # Now reorder the components because device workers need to exist prior to
  # the creation of their proxies/emulators
  workers=()
  proxies=()
  emulators=()
  for c in $comps ; do
    if [[ $c == *"proxy.rcc" ]] ; then
      proxies=(${proxies[@]} $c)
    elif [[ $c == *"_em.hdl" ]] ; then
      emulators=(${emulators[@]} $c)
    else
      workers=(${workers[@]} $c)
    fi
  done

  # Recombine the lists in new order
  comps=(${workers[@]} ${proxies[@]} ${emulators[@]})
  # This is a list of subdevices which needed to be revisited after
  # their supported devices were created. The subdevices are added
  # to this list when they fail creation. If they fail again when
  # revisited, they should ACTUALLY fail.
  revisit=()
  [ "$QUIET" == 1 ] || echo "My components are: ${comps[@]}"
  # Process the 0th element in comps. Then remove that element. Continue until comps is empty
  while [ ${#comps[@]} -gt 0 ] ; do
    c=${comps[0]}
    comps=("${comps[@]:1}")
    i=$from/$libdir/$c
    [ "$QUIET" == 1 ] || echo "Creating worker from: $i"
    n=$(basename $i)
    x=(${n/./ })
    model=${x[1]}
    wvals=()
    workers=()
    wsf=()
    slave=
    emulate=
    # Initialize list of devices supported by subdevices to empty
    supported=
    # Parse the Makefile for these different variables
    get_make_options $i/Makefile
    if [ -e $i/${x[0]}.xml ] ; then
      get_attrs $i/${x[0]}.xml $t
      specoption=
      [[ "$spec" == *.xml ]] && spec=${spec/.xml/}
      ospec=$spec
      [[ "$spec" == *[-_]spec ]] && spec=${spec/%[-_]spec/}
      [[ "$spec" == ${x[0]} ]] && spec=
      [ -z $spec ] || spec=$ospec
      [ "$QUIET" == 1 ] || echo Spec for $n is $ospec
    else
      # No single OWD
      multlang=
      for w in ${workers[@]} ; do
        get_attrs $i/$w.xml $t
        [ -n "$lang" ] && {
           [ -n "$multlang" -a "$lang" != "$multlang" ] && bad language mismatch with multiple workers
           multlang=$lang
        }
        wvals=(${wvals[@]} ${w}:${spec}:${wname})
      done
      lang=$multlang
      spec=
      wname=
    fi
    # Param and WorkerSourceFiles are done separately since they have a different format
    params=($(sed -n '/^[ 	]*Param/s/^[ 	]*\(Param.*\)$/\1/p' $i/Makefile))
    wsf=($(sed -n '/^[ 	]*WorkerSourceFiles/s/^[ 	]*\(WorkerSourceFiles.*\)$/\1/p' $i/Makefile))
    [ -n "$wsf" ] && params=(${params[@]} ${wsf[@]})
    if [ $n == "si5351_proxy.rcc" -o $n == "si5338_proxy.rcc" -o $n == "matchstiq_z1_i2c.hdl" ] ; then
      [ "$QUIET" == 1 ] || echo "Just copying \"$n\". It has missing parameter values & default values and therefore codegen cannot handle it"
       if [ "$SKELETON" == 1 ] ; then
         spec=none
       else
         cp -rf $i $libdir/
         continue
       fi
    fi
    finalcmd=$cmd
    case $libdir in
      (hdl/devices|hdl/cards|hdl/platforms/*)
        if [ $model == rcc ] ; then
          finalcmd=" worker "
          if [ -n "$slave" ] ; then
            # Here we have determined that we are creating a proxy
            finalcmd=" -V $slave worker"
            [ "$QUIET" == 1 ] || echo "Modifying command for proxy creation."
          fi
        fi
        if [ -n "$emulate" ] ; then
          finalcmd=" -E $emulate $cmd "
          if [ "${spec[0]}" == "none" ] ; then
            spec=("emulator-spec")
          fi
        fi
        ;;
      (*)
        [ "$QUIET" == 1 ] || echo "Using generic command/options for this library." ;;
    esac

    {
      do_ocpidev create $finalcmd $n $libopt  \
${wname:+-N }${wname} \
${lang:+-L }${lang} \
${spec:+-S }${spec[0]} \
${includes[@]/#/-I } \
${xmlincludes[@]/#/-A } \
${others[@]/#/-O } \
${cores[@]/#/-C } \
${onlys[@]/#/-T } \
${exes[@]/#/-Z } \
${onlyplats[@]/#/-G } \
${explats[@]/#/-Q } \
${wvals[@]/#/-W } \
${supported[@]/#/-U } \
${rccstatprereqs[@]/#/-R } \
${rccdynprereqs[@]/#/-r } \
${liblibs[@]/#/-Y } \
${complibs[@]/#/-y } \

    } || {

      if ! contains ${revisit[@]} $n ; then
        [ "$QUIET" == 1 ] || echo "Failed to create device/worker. Adding it to the end of the list and continuing."
        [ "$QUIET" == 1 ] || echo "It is possible this happened because one of the worker's dependencies"
        [ "$QUIET" == 1 ] || echo "has not yet been created. If it fails on next visit, it will truly fail."
        comps=(${comps[@]} $n)
        revisit=(${revisit[@]} $n)
        continue
      else
        bad failed to create worker/device $n
      fi
    }

    # This section is now obsolete (AV-2913)
    # ocpidev automatically adds ComponentLibraries=devices to the makefile of an emulator 
    # because they need to access the baseproject\'s hdl/devices/specs/emulator-spec.xml
    # if [ -n "$emulate" -a -z "$comlibs" ] ; then
    #   complibs=(devices)
    # fi
    check_make_options $libdir/$n/Makefile
    #cat $libdir/$n/Makefile

    [ -n "$others" ] && {
      for o in ${others[@]} ; do
        if [ ! -r "$i/$o" ] ; then
          [ "$QUIET" == 1 ] || echo "Warning: missing other file $o. It may be in primitives"
          #bad for $i missing other file $o
          continue
        else
          mkdir -p $(dirname $libdir/$n/$o)
          if [ "$SKELETON" == 1 ] ; then
            touch $libdir/$n/$o
          else
            cp $i/$o $libdir/$n/$o
          fi
        fi
      done
    }
    [ -n "$params" ] && {
      for p in ${params[@]}; do
        (ed -s $libdir/$n/Makefile <<EOF
/^[ 	]*include/
i
$p
.
w
EOF
) > /dev/null
      done
    }
    if [ -n "$workers" ] ; then
      [ "$QUIET" == 1 ] || echo Multiple from $i wsf:${wsf}
      # if specified worker sources, copy them
      [ -n "$wsf" ] && {
        # If we are making a skeleton, do not copy the source files, just create an empty file.
        if [ "$SKELETON" == 1 ] ; then
          touch components/$n/${wsf/WorkerSourceFiles=/}
        else
          cp $i/${wsf/WorkerSourceFiles=/} components/$n
        fi
      }
      for w in ${workers[@]} ; do
        #diff $i/$w.xml $libdir/$n || true
        #mv $libdir/$n/$w.xml{,.gen}
        [ "$SKELETON" == 1 ] || cp $i/$w.xml $libdir/$n 2> /dev/null || true
        # Is this right??
        [ -z "$wsf" ] && {
          [ "$SKELETON" == 1 ] || cp $i/$w.c* $libdir/$n
        }
      done
    else
      [ "$QUIET" == 1 ] || echo Single from $i
      # The next couple of lines are for debugging ocpidevs output
      #  diff  $libdir/$n/${x[0]}.xml $i || true
      #mv $libdir/$n/${x[0]}.xml{,.gen}
      # Ignore failure - workers can omit OWD
      [ "$SKELETON" == 1 ] || cp $i/${x[0]}.xml $libdir/$n 2> /dev/null || true
      [ "$SKELETON" == 1 ] || cp $i/${x[0]}.[cv]* $libdir/$n 2> /dev/null || true
    fi
    # grep -v '^[ 	]*#' $i/Makefile | diff $libdir/$n/Makefile - || true
    [ "$SKELETON" == 1 ] || {
      rm -rf $libdir/$n/*
      cp -rf $i/* $libdir/$n
      rm -rf "$libdir/$n/test" 2> /dev/null || true
    }
  done
  cp $from/$libdir/Makefile $libdir/
done

##############################################################################
# assemblies                                                                 #
# Iterating through the assemblies subtree and creating each assembly        #
##############################################################################
echo ================== Creating Assemblies ==============
for assemb in $from/hdl/assemblies/* ; do
  if [ -d $assemb ] ; then
     get_dirtype $assemb
     if [ $dirtype == assembly ] ; then
       [ "$QUIET" == 1 ] || echo "====Creating hdl assembly $(basename $assemb)"
       assembname=$(basename $assemb)
       get_make_options $assemb/Makefile
       do_ocpidev create hdl assembly $assembname \
${onlys[@]/#/-T } \
${exes[@]/#/-Z } \
${onlyplats[@]/#/-G } \
${explats[@]/#/-Q } \
       check_make_options hdl/assemblies/$assembname/Makefile
       #cat hdl/assemblies/$assembname/Makefile
       [ "$SKELETON" == 1 ] || cp $assemb/{*.xml,Makefile,*.input} hdl/assemblies/$assembname/ 2> /dev/null || true
     fi
  fi
done
cp $from/hdl/assemblies/Makefile hdl/assemblies/ 2> /dev/null || true


##############################################################################
# applications                                                               #
# Iterating through the examples subtree and creating the applications dir   #
# Flattening examples/xml into xml to do so                                  #
##############################################################################
echo ================== Creating Applications ============
if [ -d "$from/applications" ] ; then
  appdir=applications
  xmldir=applications
else
  appdir=examples
  xmldir=examples/xml
fi
for x in $from/$appdir/* ; do
  app=$(basename $x)
  # These apps are not fully supported and therefore cause a failure when we run
  # make clean. Excluding them for now
  [ $app == bestfit_test ] || [ $app == canny ] || [ $app == feature_detection ] || [ $app == image_filtering ] || [ $app == optical_flow ] || [ $app == optical_flow_xml ] || [ $app == dds_ports ] || [ $app == fsk_modem_xml ] && continue
  if [ -d "$from/$appdir/$app" ] && [ $app != xml ] ; then
    [ "$QUIET" == 1 ] || echo "====Creating application dir $app"
    if [ -f "$from/$appdir/$app/$app".xml ] ; then
      xmloption="-x"
    else
      xmloption=
    fi
    do_ocpidev create application $app $xmloption
    # This is probably not a good idea long term. Need to remove the contents of $app/
    # because some of the xml files created have different names from the desired ones
    [ "$SKELETON" == 1 ] || {
      rm applications/$app/* || true
      cp -r $x/* applications/$app || true
    }
  fi
done

[ "$SKELETON" == 1 ] || [ "$OCPI_BASE" != 1 ] || {
  cp $from/$appdir/Makefile.base applications/Makefile 2> /dev/null || true
  cp $from/$appdir/setup.mk applications 2> /dev/null || true
  rm -f applications/opencv.mk 2> /dev/null || true # we do not want this file in base
}

for x in $from/$xmldir/* ; do
  if [[ "$x" == *".xml" ]] ; then
    app=$(basename $x .xml)
    [ "$QUIET" == 1 ] || echo "====Creating application $app"
    do_ocpidev create application -X $app
    [ -r $x ] || bad wierd unreadable app
    [ -r applications/$app.xml ] || bad not established app
    [ "$SKELETON" == 1 ] || cp $x applications
  fi
done

[ "$SKELETON" == 1 ] || [ "$OCPI_BASE" != 1 ] || cp $from/$xmldir/test.input* applications 2> /dev/null || true
[ "$SKELETON" == 1 ] || [ "$OCPI_BASE" != 1 ] || cp $from/$xmldir/run.sh applications 2> /dev/null || true


######################################################
# Copy some remaining files                          #
######################################################
[ "$SKELETON" == 1 ] || [ "$OCPI_BASE" != 1 ] || {
  cp $from/README* . 2> /dev/null || true
  # Copy over hdl/* (ie Makefile, README)
  cp $from/hdl/* hdl/ 2> /dev/null || true
  cp -rf $from/hdl/vendors hdl/ 2> /dev/null || true
}


if [ "$OCPI_BASE" == "-1" ] ; then
  get_make_option $from/Project.mk ComponentLibraries+ complibs
  get_make_option $from/Project.mk HdlLibraries+ liblibs
  echo "ComponentLibraries+=misc_comps util_comps dsp_comps comms_comps devices
HdlLibraries+=misc_prims util_prims dsp_prims comms_prims" >> $1/Project.mk

  get_make_option $1/Project.mk ComponentLibraries+ complibs2
  [ "${complibs[*]}" == "${complibs2[*]}" ] || bad "ComponentLibraries do not match in original and generated Makefile for asset generated at \"$1\""
  get_make_option $1/Project.mk HdlLibraries+ liblibs2
  [ "${liblibs[*]}" == "${liblibs2[*]}" ] || bad "Libraries do not match in original and generated Makefile for asset generated at \"$1\""

  # These platforms exist in assets, but do not have a platform makefile
  # So, ocpidev does not treat them like platforms. For now, copy them over
  # If not doing a skeleton build.
  [ "$SKELETON" == 1 ] || {
    cp -rf $from/hdl/platforms/alst4 $1/hdl/platforms 2> /dev/null || true
    cp -rf $from/hdl/platforms/ml605 $1/hdl/platforms 2> /dev/null || true
    cp -rf $from/hdl/platforms/picoflexor $1/hdl/platforms 2> /dev/null || true
    cp -rf $from/hdl/platforms/zed $1/hdl/platforms 2> /dev/null || true
  }
fi

echo "Finished $project_type creating project source."
# If this is base project, it is cleaned during the RPM build process. It
# still needs to be cleaned here because the RPM script uses different
# environment variables to choose what *.so files to generate and copy to
# the CDK. Additionally, some of the skeletons may need to be regenerated
# after custom makefiles are copied over.
echo "Cleaning $project_type project. (takes ~30 seconds)"
if [ "$QUIET" == 1 ] ; then
  make clean > /dev/null
else
  make clean
fi

# Copying some remaining directories after clean is done.
[ "$OCPI_BASE" != 1 ] || {
  # The following are needed in order to build even just skeleton of the base project
  # Needed for emulators to build without OCPI_PROJECT_PATH pointing to another base
  cp $from/hdl/devices/specs/emulator-spec.xml hdl/devices/specs 2> /dev/null || true
  # The following are needed for default platform skeletons to build
  cp $from/hdl/devices/time_server.hdl/* hdl/devices/time_server.hdl 2> /dev/null || true
  cp -rf $from/hdl/devices/sdp* hdl/devices/ 2> /dev/null || true
}

echo "Done creating $project_type project"