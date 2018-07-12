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

import readline
"""
This module a collection of OpenCPI utility functions.

Some of the utilities found here include string/number manipulation
and parsing functions as well as path calculation/manipulation functions.
There are also utilities for collecting variable values from GNU make.

Documentation and testing:
    Docstring tests can be executed as follows:
        $ python ocpiutil.py -v
    Documentation can be viewed by running:
        $ pydoc ocpiutil
Note on testing:
    When adding functions to this file, add unit tests to
    opencpi/tests/pytests/ocpiutil_test.py
"""
import sys
import os
import os.path
import re
import subprocess
from glob import glob
import logging
from contextlib import contextmanager
from functools import reduce

# Use python3's input name
try:
    input = raw_input
except NameError:
    pass

class OCPIException(Exception):
    """
    A exception class that we can throw and catch within OpenCPI code while ignoring other exception
    types. This class inherits from the built-in Exception class and doesn't extend it in any way
    """
    pass

def configure_logging(level=None, output_fd=sys.stderr):
    """
    Initialize the root logging module such that:
            OCPI_LOG_LEVEL <  8 : only log WARNINGS, ERRORS and CRITICALs
       8 <= OCPI_LOG_LEVEL <  10: also log INFOs
            OCPI_LOG_LEVEL >= 10: also log DEBUGs
    This can be used in other modules to change the default log level of the
    logging module. For example, from another module:
    >>> import logging
    >>> import ocpiutil
    >>> os.environ['OCPI_LOG_LEVEL'] = "11"
    >>> ocpiutil.configure_logging(output_fd=sys.stdout)
    <logging.RootLogger...>

    # Now, logging will be determined based on OCPI_LOG_LEVEL environment
    # variable. So, the following will only print if OCPI_LOG_LEVEL is >= 8
    >>> logging.info("info message")

    # You should see 'OCPI:INFO: info message', but it will print to stderr, not stdout
    """
    logging.basicConfig(stream=output_fd, format='OCPI:%(levelname)s: %(message)s')
    rootlogger = logging.getLogger()
    if level:
        rootlogger.setLevel(level=level)
    else:
        log_level = os.environ.get('OCPI_LOG_LEVEL')
        if not log_level or int(log_level) < 8:
            rootlogger.setLevel(level=logging.WARNING)
        elif int(log_level) < 10:
            rootlogger.setLevel(level=logging.INFO)
        else:
            rootlogger.setLevel(level=logging.DEBUG)
    return rootlogger

###############################################################################
# Utility functions for extracting variables and information from and calling
# Makefiles
###############################################################################

def execute_cmd(settings, directory, action=None):
    """
    This command is a wrapper around any calls to make in order to encapsulate the use of make to a
    minimal number of places.  The function contains a hard-coded dictionary of generic settings to
    make variables that it uses to construct the call to make at that given directory
    """
    settings_dict = {'rcc_plats'       : "RccPlatform",
                     'hdl_plats'       : "HdlPlatform",
                     'only_plats'      : "OnlyPlatform",
                     'ex_plats'        : "ExcludePlatform",
                     'keep_sims'       : "KeepSimulations",
                     'errors'          : "TestAccumulateErrors",
                     'cases'           : "Cases",
                     'run_before'      : "OcpiRunBefore",
                     'run_after'       : "OcpiRunAfter",
                     'run_args'        : "OcpiRunArgs",
                     'remote_test_sys' : "OCPI_REMOTE_TEST_SYSTEMS",
                     'verbose'         : "TestVerbose"}

    make_list = ["make", "-C", directory]

    if action is not None:
        make_list.extend(action)

    for setting, value in settings.items():
        if isinstance(value, bool):
            make_list.append(settings_dict[setting] + '=1')
        elif isinstance(value, list):
            make_list.append(settings_dict[setting] + '=' + ' '.join(value))
        else:
            raise OCPIException("Invalid setting data-type passed to execute_cmd().  Valid data-" +
                                "types are bool and list")

    logging.debug("running make command: " + " ".join(make_list))
    child = subprocess.Popen(make_list)
    child.wait()
    return child.returncode

def set_vars_from_make(mk_file, mk_arg="", verbose=None):
    """
    -------------------------------------------------------------------------------
    | Collect a dictionary of variables from a makefile
    |--------------------------------------------------
    | First arg is .mk file to use
    | Second arg is make arguments needed to invoke correct output
    |     The output can be an assignment or a target
    | Third arg is a verbosity flag
    | Return a dictionary of variable names mapped to values from make
    -------------------------------------------------------------------------------
    """
    with open(os.devnull, 'w') as fnull:
        make_exists = subprocess.Popen(["which", "make"],\
                      stdout=subprocess.PIPE, stderr=fnull).communicate()[0]
        if make_exists is None or make_exists == "":
            if verbose != None and verbose != "":
                logging.error("The '\"make\"' command is not available.")
            return 1

        # If mk_file is a "Makefile" then we use the -C option on the directory containing
        # the makefile else (is a .mk) use the -f option on the file
        if mk_file.endswith("/Makefile"):
            make_cmd = "make -n -r -s -C " + os.path.dirname(mk_file) + " " + mk_arg
        else:
            make_cmd = "make -n -r -s -f " + mk_file + " " + mk_arg

        logging.debug("Calling make via:" + str(make_cmd.split()))
        # If verbose is unset, redirect 'make' stderr to /dev/null
        if verbose is None or verbose == "":
            child = subprocess.Popen(make_cmd.split(), stderr=fnull, stdout=subprocess.PIPE)
            child.wait()
            mk_output = child.stdout.read()
            if child.returncode != 0:
                child.stdout.close()
                raise OCPIException("make command: " + make_cmd + "\n returned an error: " +
                                    str(mk_output))
            child.stdout.close()
        else:
            child = subprocess.Popen(make_cmd.split(), stderr=subprocess.PIPE, stdout=subprocess.PIPE)
            child.wait()
            mk_output = child.stdout.read()
            if child.returncode != 0:
                child.stdout.close()
                child.stderr.close()
                raise OCPIException("make command: " + make_cmd + "\n returned an error: " +
                                    str(mk_output))
            child.stdout.close()
            child.stderr.close()
        logging.debug("Output from make in set_vars_from_make: " + str(mk_output))
        try:
            grep_str = re.search(r'(^|\n)[a-zA-Z_][a-zA-Z_]*=.*',
                                 str(mk_output.strip(), 'utf-8')).group()
        except AttributeError:
            logging.warning("No variables are set from \"" + mk_file + "\"")
            return None

        assignment_strs = [x.strip() for x in grep_str.split(';') if len(x.strip()) > 0]
        make_vars = {}
        for var_assignment in assignment_strs:
            var_name, var_val = var_assignment.split('=')
            # If the value is an empty string or just matching quotes, assign [] as the value
            if var_val == "\"\"" or var_val == "\'\'" or var_val == "":
                assignment_value = []
            else:
                assignment_value = var_val.strip('"').strip().split(' ')
            make_vars[var_name] = assignment_value
        return make_vars

def get_make_vars_rcc_targets():
    """
    Get make variables from rcc-targets.mk
    Dictionary key examples are:
        RccAllPlatforms, RccPlatforms, RccAllTargets, RccTargets
    """
    return set_vars_from_make(os.environ["OCPI_CDK_DIR"] +
                              "/include/rcc/rcc-targets.mk",
                              "ShellRccTargetsVars=1", "verbose")

###############################################################################
# Utility functions for collecting information about the directories
# in a project
###############################################################################

def get_dirtype(directory="."):
    """
    Determine a directory's type by parsing it for the last 'include ... *.mk' line
    """
    match = None
    if os.path.isfile(directory + "/Makefile"):
        with open(directory + "/Makefile") as mk_file:
            for line in mk_file:
                result = re.match(r"^\s*include\s*.*OCPI_CDK_DIR.*/include/(hdl/)?(.*)\.mk.*", line)
                match = result.group(2) if result != None else match
    if match is None:
        if os.path.isfile(directory + "/project-package-id"):
            return "project"
        return None
    return match

def get_subdirs_of_type(dirtype, directory="."):
    """
    Return a list of directories underneath the given directory
    that have a certain type (library, worker, hdl-assembly...)
    """
    subdir_list = []
    if dirtype:
        for subdir, _, _ in os.walk(directory):
            if get_dirtype(subdir) == dirtype:
                subdir_list.append(subdir)
    return subdir_list

###############################################################################
# Utility function for exporting libraries in a project
###############################################################################
def export_libraries():
    """
    Build the lib directory and links to specs in each library in a project.
    This will allow specs to be exported before workers in a library are built.
    """
    for lib_dir in get_subdirs_of_type("library"):
        logging.debug("Library found at \"" + lib_dir + "\", running \"make speclinks\" there.")
        proc = subprocess.Popen(["make", "-C", lib_dir, "speclinks"],
                                stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE)
        proc.communicate()  # Don't care about the outputs
        if proc.returncode != 0:
            logging.warning("""Failed to export libraries in project at "{0}".
                               Check your permissions for this project.""".format(os.getcwd()))

###############################################################################
# Utility functions for determining paths to/from the top level of a project
# or a project's imports directory.
###############################################################################

def is_path_in_project(origin_path=".",):
    """
    Determine whether a path is inside a project
    """
    if os.path.exists(origin_path):
        abs_path = os.path.abspath(origin_path)
        if get_dirtype(origin_path) == "project":
            return True
        elif abs_path != "/":
            return is_path_in_project(os.path.dirname(abs_path))
    return False

# Get the path to the project containing 'origin_path'
# relative_mode : default=False
# If relative_mode is False,
#     an absolute path to the containing project is returned
# If relative_mode is True,
#     a relative path from origin_path is returned
# accum_path is an internal argument that accumulates the path to
#    return across recursive calls
def __get_path_to_project_top(origin_path, relative_mode, accum_path):
    if origin_path and os.path.exists(origin_path):
        abs_path = os.path.abspath(origin_path)
        if get_dirtype(origin_path) == "project":
            return abs_path if relative_mode is False else accum_path
        elif abs_path != "/":
            return __get_path_to_project_top(os.path.dirname(abs_path),
                                             relative_mode, accum_path + "/..")
    return None
def get_path_to_project_top(origin_path=".", relative_mode=False):
    """
    Get the path to the top of the project containing 'origin_path'.
    Optionally enable relative_mode for relative paths.
    Note: call aux function to set accum_path internal arg
    """
    path_to_top = __get_path_to_project_top(origin_path, relative_mode, ".")
    if path_to_top is None:
        if origin_path is None:
            logging.debug("Cannot get path to project for origin_path=None.")
        else:
            logging.debug("Path \"" + os.path.realpath(origin_path) + "\" is not in a project")
    return path_to_top

# Go to the project top and check if the project-package-id file is present.
def is_path_in_exported_project(origin_path):
    """
    Given a path, determine whether it is inside an exported project.
    """
    project_top = get_path_to_project_top(origin_path)
    if project_top is not None:
        if os.path.isfile(project_top + "/project-package-id"):
            logging.debug("Path \"" + os.path.realpath(origin_path) +
                          "\" is in an exported project.")
            return True
    return False


# Get the path from 'to_path's project top to 'to_path'.
# accum_path is an internal argument that accumulates the path to
#    return across recursive calls
def __get_path_from_project_top(to_path, accum_path):
    if os.path.exists(to_path):
        abs_path = os.path.abspath(to_path)
        if get_dirtype(to_path) == "project":
            return accum_path
        elif abs_path != "/":
            appended_accum = os.path.basename(abs_path)
            if accum_path != "":
                appended_accum = appended_accum + "/" + accum_path
            return __get_path_from_project_top(os.path.dirname(abs_path), appended_accum)
    return None
def get_path_from_project_top(to_path="."):
    """
    Get the path to a location from the top of the project containing it.
    The returned path STARTS AT THE PROJECT TOP and therefore does not include
    the path TO the project top.
    Note: call aux function to set accum_path internal arg
    """
    path_from_top = __get_path_from_project_top(to_path, "")
    if path_from_top is None:
        if to_path is None:
            logging.debug("Cannot get path from project for to_path=None.")
        else:
            logging.debug("Path \"" + os.path.realpath(to_path) + "\" is not in a project")
    return path_from_top

def get_project_imports(origin_path="."):
    """
    Get the contents of a project's imports directory.
    The current project is determined based on 'origin_path'
    """
    project_top = get_path_to_project_top(origin_path, False)
    return os.listdir(project_top + "/imports") if project_top is not None else None

# NOTE: This function is not thoroughly tested
def get_path_from_given_project_top(origin_top, dest_path, path_to_origin_top=""):
    """
    Determine the path from the top level of a project (origin_top) to the
    destination path (dest_path). Whenever possible, try to stay internal to
    the project or go through the project's imports directory. If that is not
    possible, return destination path as handed to this function.

    Optionally, a path TO the origin-path's top directory can be provided
    and prepended to the return value whenever possible (when the function
    determined a path inside the project or its imports.
    """
    dest_top = get_path_to_project_top(dest_path, False)
    if dest_top:
        path_from_dest_top = get_path_from_project_top(dest_path)
        prepend_path = path_to_origin_top + "/" if path_to_origin_top != "" else ""
        if os.path.samefile(origin_top, dest_top):
            return prepend_path + path_from_dest_top
        else:
            to_import = "imports/" + os.path.basename(dest_top)
            if os.path.isdir(origin_top + "/" + to_import):
                return prepend_path + to_import + "/" + path_from_dest_top
    return dest_path

# NOTE: This function is not thoroughly tested
def get_paths_from_project_top(origin_path, dest_paths):
    """
    Given an origin and a list of destination paths, return a list of paths
    from origin's project top to each destination (potentially through imports).
    If a destination path is not in the current or an imported project,
    return an absolute path.
    """
    origin_top = get_path_to_project_top(origin_path, False)
    if origin_top is None:
        raise ValueError("origin_path \"" + str(origin_path) + "\" is not in a project")
    paths_from_top = []
    for dest_p in dest_paths:
        paths_from_top.append(get_path_from_given_project_top(origin_top, dest_p))
    return paths_from_top

# NOTE: This function does is not thoroughly tested
def get_paths_through_project_top(origin_path, dest_paths):
    """
    origin to each destination going through the project top (and potentially
    imports) when possible.
    """
    origin_top = get_path_to_project_top(origin_path, False)
    origin_top_rel = get_path_to_project_top(origin_path, True)
    if origin_top is None:
        raise ValueError("origin_path \"" + str(origin_path) + "\" is not in a project")
    paths_through_top = []
    for dest_p in dest_paths:
        paths_through_top.append(
            get_path_from_given_project_top(origin_top, dest_p, origin_top_rel))
    return paths_through_top

###############################################################################
# Functions for determining project package information
###############################################################################
def get_project_package(origin_path="."):
    """
    Get the Package Name of the project containing 'origin_path'.
    """
    path_to_project = get_path_to_project_top(origin_path)
    if path_to_project is None:
        logging.debug("Path \"" + str(origin_path) + "\" is not inside a project")
        return None

    # From the project top, probe the Makefile for the projectpackage
    # which is printed in cdk/include/project.mk in the projectpackage rule
    # if ShellProjectVars is defined
    with cd(path_to_project):
        project_package = None
        # If the project-package-id file exists, set package-id to its contents
        if os.path.isfile(path_to_project + "/project-package-id"):
            with open(path_to_project + "/project-package-id", "r") as package_id_file:
                project_package = package_id_file.read().strip()
                logging.debug("Read Project-ID '" + project_package + "' from file: " +
                              path_to_project + "/project-package-id")

        # Otherwise, ask Makefile at the project top for the ProjectPackage
        if project_package is None or project_package == "":
            project_vars = set_vars_from_make("Makefile",
                                              "projectpackage ShellProjectVars=1", "verbose")
            if not project_vars is None and 'ProjectPackage' in project_vars and \
               len(project_vars['ProjectPackage']) > 0:
                # There is only one value associated with ProjectPackage, so get element 0
                project_package = project_vars['ProjectPackage'][0]
            else:
                logging.error("Could not determine Package-ID of project.")
                return None
    return project_package

def does_project_with_package_exist(origin_path=".", package=None):
    """
    Determine if a project with the given package exists and is registered. If origin_path is not
    specified, assume we are interested in the current project. If no package is given, determine
    the current project's package.
    """
    project_registry_dir_exists, project_registry_dir = get_project_registry_dir()
    if not project_registry_dir_exists:
        logging.debug("Registry does not exist, so project with any package cannot be found.")
        return False
    if package is None:
        package = get_project_package(origin_path)
        if package is None:
            logging.debug("No package was provided to the does_project_with_package_exist " +
                          "function, and the path provided does not have a package.")
            return False
    for project in glob(project_registry_dir + "/*"):
        if get_project_package(project) == package or os.path.basename(project) == package:
            return True
    return False

def is_path_in_registry(origin_path="."):
    """
    Is the path provided one of the projects in the registry?
    """
    project_registry_dir_exists, project_registry_dir = get_project_registry_dir()
    if not project_registry_dir_exists:
        # If registry does not exist, origin path cannot be a project in it
        return False
    origin_realpath = os.path.realpath(origin_path)
    # For each project in the registry, check equivalence to origin_path
    for project in glob(project_registry_dir + "/*"):
        if origin_realpath == os.path.realpath(project):
            # A project was found that matches origin path!
            return True
    # No matching project found. Project/path is not in registry
    return False

###############################################################################
# Functions for and accessing/modifying the project registry and collecting
# existing projects
###############################################################################
def get_default_project_registry_dir():
    """
    Get the default registry from the environment setup. Check in the following order:
    OCPI_PROJECT_REGISTRY_DIR, OCPI_CDK_DIR/../project-registry or /opt/opencpi/project-registry
    """
    project_registry_dir = os.environ.get('OCPI_PROJECT_REGISTRY_DIR')
    if project_registry_dir is None:
        cdkdir = os.environ.get('OCPI_CDK_DIR')
        if cdkdir:
            project_registry_dir = cdkdir + "/../project-registry"
        else:
            project_registry_dir = "/opt/opencpi/project-registry"
    return project_registry_dir

def get_project_registry_dir(directory="."):
    """
    Determine the project registry directory. If in a project, check for the imports link.
    Otherwise, get the default registry from the environment setup:
        OCPI_PROJECT_REGISTRY_DIR, OCPI_CDK_DIR/../project-registry or /opt/opencpi/project-registry

    Determine whether the resulting path exists.

    Return the exists boolean and the path to the project registry directory.
    """
    if is_path_in_project(directory) and \
       os.path.isdir(get_path_to_project_top(directory) + "/imports"):
        # allow imports to be a link OR a directory (needed for deep copies of exported projects)
        project_registry_dir = os.path.realpath(get_path_to_project_top(directory) + "/imports")
    else:
        project_registry_dir = get_default_project_registry_dir()

    exists = os.path.exists(project_registry_dir)
    if not exists:
        logging.warning("The project registry directory '" + project_registry_dir +
                        "' does not exist.\nCorrect " + "'OCPI_PROJECT_REGISTRY_DIR' or run: " +
                        "'ocpidev create registry " + project_registry_dir + "'")
    elif not os.path.isdir(project_registry_dir):
        raise OSError("The current project registry '" + project_registry_dir +
                      "' exists but is not a directory.\nCorrect " +
                      "'OCPI_PROJECT_REGISTRY_DIR'")
    return exists, project_registry_dir

def get_all_projects():
    """
    Iterate through the project path and project registry.
    If the registry does not exist, manually locate the CDK.
    Return the list of all projects.
    """
    projects = []
    project_path = os.environ.get('OCPI_PROJECT_PATH')
    if project_path:
        projects += project_path.split(':')
    exists, project_registry_dir = get_project_registry_dir()
    if exists:
        projects += glob(project_registry_dir + '/*')
    else:
        cdkdir = os.environ.get('OCPI_CDK_DIR')
        if cdkdir:
            projects.append(cdkdir)
    logging.debug("All projects: " + str(projects))
    return projects

###############################################################################
# String, number and dictionary manipulation utility functions
###############################################################################
# https://stackoverflow.com/questions/38987/how-to-merge-two-dictionaries-in-a-single-expression
# when code is moved to python 3.5+ this function goes away and becomes: z = {**x, **y}
def merge_two_dicts(x, y):
    """
    This function combines two dictionaries into a single dictionary, if both have the same key
    the value in y overwrites the value in x
    >>> x = {'a': 'avalue'}
    >>> y = {'b': 'bvalue'}
    >>> z = merge_two_dicts(x, y)
    >>> sorted(z.items())
    [('a', 'avalue'), ('b', 'bvalue')]
    """
    z = x.copy()   # start with x's keys and values
    z.update(y)    # modifies z with y's keys and values & returns None
    return z

def python_list_to_bash(pylist):
    """
    Convert a python list to a Makefile list (a space separated string)

    For example (docstring):
    >>> python_list_to_bash(["element1", "element2"])
    'element1 element2'
    >>> python_list_to_bash([""])
    ''
    >>> python_list_to_bash([])
    ''
    """
    mklist = ""
    for pyelem in pylist:
        mklist = mklist + " " + str(pyelem)
    return mklist.strip()

def bash_list_to_python(mklist):
    """
    Convert a bash list (a space separated string) to a python list

    For example (doctest):
    >>> bash_list_to_python("element0 element1 element2     element3     ")
    ['element0', 'element1', 'element2', 'element3']
    >>> bash_list_to_python(" element1 ")
    ['element1']
    >>> bash_list_to_python("  ")
    []
    >>> bash_list_to_python("")
    []
    """
    return [elem for elem in mklist.strip().split(" ") if elem != ""]


def isfloat(value):
    """
    Can the parameter be represented as an float?

    For example (doctest):
    >>> isfloat("1")
    True
    >>> isfloat("1.0")
    True
    >>> isfloat("")
    False
    >>> isfloat("string")
    False
    """
    try:
        float(value)
        return True
    except ValueError:
        return False

def isint(value):
    """
    Can the parameter be represented as an int?

    For example (doctest):
    >>> isint("1")
    True
    >>> isint("1.0")
    False
    >>> isint("")
    False
    >>> isint("string")
    False
    """
    try:
        int(value)
        return True
    except ValueError:
        return False

def freq_from_ns_period(prd_string):
    """
    Convert a string representing period in ns
    to a string representing frequency in MHz
    Return the string or "" on failure

    For example (doctest):
    >>> freq_from_ns_period("1000ns")
    '1.000'
    >>> freq_from_ns_period("1000")
    '1.000'

    Only ns period is supported
    >>> freq_from_ns_period("250ms")
    ''
    >>> freq_from_ns_period("250ns")
    '4.000'
    >>> freq_from_ns_period("")
    ''
    >>> freq_from_ns_period("string")
    ''
    """
    if prd_string is None:
        return ""
    period = 0.0
    prd = re.sub('ns', '', prd_string)
    if isfloat(prd):
        period = float(prd)
    if period != 0:
        freq = 1000/float(period)
        return '{0:.3f}'.format(freq)
    return ""

def first_num_in_str(parse_string):
    """
    Return the first number in a list of strings. Allow ',' or '.'  and trailing text
    (e.g. MHz, ns). Return "" if no number is found.

    For example (doctest):
    >>> first_num_in_str("Here is my number: 12345.12345 (here is a second number 222.222)")
    '12345.12345'
    >>> first_num_in_str("Another number: 12,345,123")
    '12,345,123'
    >>> first_num_in_str("A frequency: 123,000MHz")
    '123,000'
    >>> first_num_in_str("A period: 123,000ns")
    '123,000'
    >>> first_num_in_str("abcd1234efgh5678")
    '1234'
    >>> first_num_in_str("There is no string here!")
    """
    first_num_regex = re.compile(r"([-+]?([0-9]{1,3}\,?)+(\.[0-9]*)?)")
    result = re.search(first_num_regex, parse_string)
    if result:
        return result.group(0)
    else:
        return None

def match_regex(target_file, regex):
    """
    Parse the target file for a regex and return the first group/element
    of the first match

    For example (doctest):
    Here, we have a line of text below and we parse this current file
    using a regular expression to grab the 'ns' number from the string.
    # This text right here contains a number (2.000ns)!!!! It should match the regex
    >>> match_regex(os.path.realpath(__file__), "#.*This text right.*\((.*)ns\)!!!!.*")
    '2.000'
    """
    if isinstance(regex, str):
        regex = re.compile(regex)
    elif not isinstance(regex, type(re.compile(''))):
        raise ValueError("Error: regular expression invalid")
    matches = [re.findall(regex, line) for line in open(target_file)]
    matches = [m for m in matches if m != [] and m != None]
    if len(matches) > 0 and len(matches[0]) > 0:
        match = matches[0][0]
        if isinstance(match, tuple):
            return match[0]
        return match
    return "N/A"

# This function first finds the max-length of each 'column' and then iterates
# through each list and reformats each element to match the length corresponding
# to its 'column'
def normalize_column_lengths(lists):
    """
    This function takes a list of lists and treats each list like a row in a table.
    It then space-expands the length of each string element so that all elements in
    the same column have the same length.

    For example (doctest):
    >>> list1, list2 = normalize_column_lengths([["15 chr long str",\
                                                  "this is a longgg string"],\
                                                 ["< 15", "pretty short"]])
    >>> print (str(list1))
    ['15 chr long str', 'this is a longgg string']
    >>> print (str(list2))
    ['< 15           ', 'pretty short           ']
    """
    lists = [[str(elem) for elem in lst] for lst in lists]
    format_function = lambda length, string_elem: ("{0:<" + str(length) + "}").format(string_elem)
    newlens = []
    for column in zip(*lists):
        newlens.append(len(max(column, key=len)))
    newlists = []
    for oldlist in lists:
        newlists.append([format_function(length, elem) for elem, length in zip(oldlist, newlens)])
    return newlists

def print_table(rows, col_delim='|', row_delim=None, surr_cols_delim='|', surr_rows_delim='-'):
    """
    Print a table specified by the list of rows in the 'rows' parameter. Optionally specify
    col_delim and row_delim which are each a single character that will separate cols and rows.
    surr_rows_delim and surr_cols_delim determine the border of the border of the table
    For example (doctest):
    """
    rows = normalize_column_lengths(rows)
    row_strs = []
    for row in rows:
        row_strs.append(surr_cols_delim + ' '
                        + reduce(lambda x, y: x + ' ' + col_delim + ' ' + y, row)
                        + ' ' + surr_cols_delim)
    max_row_len = len(max(row_strs, key=len))
    if row_delim:
        row_line = row_delim * max_row_len
    print(surr_rows_delim * max_row_len)
    for line in row_strs:
        print(line)
        if row_delim:
            print(row_line)
    print(surr_rows_delim * max_row_len)

###############################################################################
# Functions to ease filesystem navigation
###############################################################################
def name_of_dir(directory="."):
    """
    Return the name of the directory provided. This will return the actual
    Directory name even if the argument is something like "."
    For example (doctest):
    >>> name_of_dir("/etc/.")
    'etc'
    >>> name_of_dir("/etc/../etc")
    'etc'
    """
    return os.path.basename(os.path.realpath(directory))

@contextmanager
def cd(target):
    """
    Change directory to 'target'. To be used with 'with' so that origin directory
    is automatically returned to on completion of 'with' block
    """
    origin = os.getcwd()
    os.chdir(os.path.expanduser(target))
    try:
        yield
    finally:
        os.chdir(origin)

###############################################################################
# Functions for prompting the user for input
###############################################################################
def get_ok(prompt=""):
    """Prompt the user to say okay"""
    print(prompt, end=' ')
    while True:
        ok = eval(input(" [y/n]? "))
        if ok.lower() in ('y', 'yes', 'ok'):
            return True
        if ok.lower() in ('', 'n', 'no', 'nope'):
            return False


if __name__ == "__main__":
    import doctest
    __LOG_LEVEL = os.environ.get('OCPI_LOG_LEVEL')
    __VERBOSITY = False
    if __LOG_LEVEL:
        try:
            if int(__LOG_LEVEL) >= 8:
                __VERBOSITY = True
        except ValueError:
            pass
    doctest.testmod(verbose=__VERBOSITY, optionflags=doctest.ELLIPSIS)
configure_logging()
