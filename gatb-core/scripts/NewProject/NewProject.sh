#!/bin/bash

echo ""
echo "--------------------------------------------------------------------------------"
echo "          CREATE PROJECT '"$1"' in directory '"$2"'"
echo "--------------------------------------------------------------------------------"
echo ""


# We get the directory of the script (absolute path)
_scripts_dir=$( cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P )

# We define the new project directory
_project_dir="$2/$1"

# We set the GATB-CORE directory
_gatb_core_dir="$_scripts_dir/../.."

# We check that we found the GATB-CORE submodule directory
[ ! -d "$_gatb_core_dir" ] && { echo "Error: Directory for GATB-CORE submodule not found"; exit 2; }

# We check that the new project doesn't already exist
[ -d "$_project_dir" ] && { echo "Error: Directory '$_project_dir' for new project already exists"; exit 2; }

# We create the project directory
mkdir $_project_dir

# We create the project source directory
mkdir $_project_dir/src

# If no $3 argument is provided, we copy GATB-CORE as thirdparty.
# => in GATB-TOOLS context, we can provide a $3 argument and so
#    we don't have a copy of GATB-CORE
if test -z "$3"
then
    # We copy gatb-core as thirdparty
    mkdir $_project_dir/thirdparty
    mkdir $_project_dir/thirdparty/gatb-core
    cp -r $_gatb_core_dir/cmake             $_project_dir/thirdparty/gatb-core/
    cp -r $_gatb_core_dir/src               $_project_dir/thirdparty/gatb-core/
    cp -r $_gatb_core_dir/tools             $_project_dir/thirdparty/gatb-core/
    cp -r $_gatb_core_dir/thirdparty        $_project_dir/thirdparty/gatb-core/
    cp -r $_gatb_core_dir/examples          $_project_dir/thirdparty/gatb-core/
    cp -r $_gatb_core_dir/doc               $_project_dir/thirdparty/gatb-core/
    cp -r $_gatb_core_dir/CMakeLists.txt    $_project_dir/thirdparty/gatb-core/
fi
    
# We init the CMakeLists.txt
touch $_project_dir/CMakeLists.txt

# Note: we do it this way because it is cumbersome to do it with sed because of special characters in _gatb_core_dir

echo "project($1)"                                                                                  >> $_project_dir/CMakeLists.txt
echo ""                                                                                             >> $_project_dir/CMakeLists.txt
echo "cmake_minimum_required(VERSION 2.6)"                                                          >> $_project_dir/CMakeLists.txt
echo ""                                                                                             >> $_project_dir/CMakeLists.txt
echo "################################################################################"             >> $_project_dir/CMakeLists.txt
echo "# Define cmake modules directory"                                                             >> $_project_dir/CMakeLists.txt
echo "################################################################################"             >> $_project_dir/CMakeLists.txt
echo "FOREACH (path \"cmake\" \"../cmake\"  \"thirdparty/gatb-core/cmake\"  \"../../thirdparty/gatb-core/gatb-core/cmake\")"  >> $_project_dir/CMakeLists.txt
echo "IF (EXISTS \"\${CMAKE_CURRENT_SOURCE_DIR}/${path}\")"                                         >> $_project_dir/CMakeLists.txt
echo "SET (CMAKE_MODULE_PATH  \"\${CMAKE_MODULE_PATH}\" \"\${CMAKE_CURRENT_SOURCE_DIR}/\${path}\")" >> $_project_dir/CMakeLists.txt
echo "ENDIF()"                                                                                      >> $_project_dir/CMakeLists.txt
echo "ENDFOREACH(path)"                                                                             >> $_project_dir/CMakeLists.txt
echo ""                                                                                             >> $_project_dir/CMakeLists.txt
echo "################################################################################"             >> $_project_dir/CMakeLists.txt
echo "# THIRD PARTIES"                                                                              >> $_project_dir/CMakeLists.txt
echo "################################################################################"             >> $_project_dir/CMakeLists.txt
echo ""                                                                                             >> $_project_dir/CMakeLists.txt
echo "# We don't want to install some GATB-CORE artifacts"                                          >> $_project_dir/CMakeLists.txt
echo "#SET (GATB_CORE_EXCLUDE_TOOLS     1)"                                                         >> $_project_dir/CMakeLists.txt
echo "#SET (GATB_CORE_EXCLUDE_TESTS     1)"                                                         >> $_project_dir/CMakeLists.txt
echo "#SET (GATB_CORE_EXCLUDE_EXAMPLES  1)"                                                         >> $_project_dir/CMakeLists.txt
echo ""                                                                                             >> $_project_dir/CMakeLists.txt
echo "# GATB CORE"                                                                                  >> $_project_dir/CMakeLists.txt
echo "include (GatbCore)"                                                                           >> $_project_dir/CMakeLists.txt
echo ""                                                                                             >> $_project_dir/CMakeLists.txt

# We copy the remaining of the file
cat $_scripts_dir/CMakeLists.txt | sed 's/__PROJECT_NAME__/'$1'/g' >> $_project_dir/CMakeLists.txt

# We copy the default main.cpp file
cat $_scripts_dir/main.cpp | sed s/XXX/$1/g  > $_project_dir/src/main.cpp
cat $_scripts_dir/XXX.hpp  | sed s/XXX/$1/g  > $_project_dir/src/$1.hpp
cat $_scripts_dir/XXX.cpp  | sed s/XXX/$1/g  > $_project_dir/src/$1.cpp

# We copy the default README
cp $_scripts_dir/README.md $_project_dir/README.md

# We go to the new project
echo "PROJECT CREATED IN DIRECTORY '$_project_dir'"
echo ""
