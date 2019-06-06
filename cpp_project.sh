#!/bin/bash

# First check for top level options (eg -h)
while getopts ":h" opt; do
    case ${opt} in
        h )
            echo "Set up and manage cpp cmake projects."
            echo "Usage:"
            echo "    cpp_project.sh -h"
            echo "        Display this [h]elp message."
            echo "    cpp_project.sh new <project-name> <options>"
            echo "        Create a new project with name <project-name>."
            echo "    cpp_project.sh <sub-command> -h"
            echo "        Show [h]elp message for a subcommand."
            exit 0
            ;;
        \? )
            echo "Invalid Option: -$OPTARG" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

subcommand=$1
if [[ "$subcommand" = "" ]]
then
    echo "Please provide a subcommand."
    exit 1
fi
shift # Remove `cpp_project.sh` from the argument list

case "$subcommand" in
    new)
        # Check for new options top-level for the sub command (eg -h)
        while getopts ":h" opt; do
            case ${opt} in
                h )
                    echo "Set up a new cpp cmake project."
                    echo "Usage:"
                    echo "    cpp_project.sh new <project-name> <options>"
                    echo "        Create a new project with name <project-name>."
                    echo ""
                    echo "Options:"
                    echo "    -u <dependencies-list>"
                    echo "        Add p[u]blic dependencies"
                    echo "    -r <dependencies-list>"
                    echo "        Add p[r]ivate dependencies"
                    echo "    -i <dependencies-list>"
                    echo "        Add [i]nterface dependencies"
                    echo ""
                    echo "Supported Dependencies:"
                    echo "    opencv eigen sophus ceres boost openmp vc"
                    exit 0
                    ;;
                \? )
                    echo "Invalid Option: -$OPTARG" 1>&2
                    exit 1
                    ;;
            esac
        done

        # Get project name and remove 'new' from the argument list
        project_name=$1
        if [[ "$project_name" = "" ]]
        then
            echo "Please provide a project name."
            exit 1
        fi
        shift # Remove `new` from the argument list

        public_deps=""
        private_deps=""
        interface_deps=""

        # Populate lists of dependencies
        while getopts ":u:r:i:" opt; do
            case ${opt} in
                u )
                    public_deps=$OPTARG
                    ;;
                r )
                    private_deps=$OPTARG
                    ;;
                i )
                    interface_deps=$OPTARG
                    ;;
                \? )
                    echo "Invalid Option: -$OPTARG" 1>&2
                    exit 1
                    ;;
                : )
                    echo "Invalid Option: -$OPTARG requires an argument" 1>&2
                    exit 1
                    ;;
            esac
        done
        shift $((OPTIND -1))

        # Build include and link strings.
        find_packages_deps=""

        public_deps_inc=""
        private_deps_inc=""
        interface_deps_inc=""

        public_deps_link=""
        private_deps_link=""
        interface_deps_link=""

        for dep in ${public_deps}
        do
            case ${dep} in
                opencv )
                    find_packages_deps="${find_packages_deps}find_package(OpenCV 3.2.0 REQUIRED NO_MODULE)\n"
                    public_deps_inc="${public_deps_inc}        "'${OpenCV_INCLUDE_DIRS}'"\n"
                    public_deps_link="${public_deps_link}        "'${OpenCV_LIBS}'"\n        -lopencv_sfm\n        -lopencv_xfeatures2d\n"
                    ;;
                eigen )
                    find_packages_deps="${find_packages_deps}find_package(Eigen3 3.3 REQUIRED NO_MODULE)\n"
                    public_deps_inc="${public_deps_inc}"
                    public_deps_link="${public_deps_link}        Eigen3::Eigen\n"
                    ;;
                ceres )
                    find_packages_deps="${find_packages_deps}find_package(Ceres REQUIRED NO_MODULE)\n"
                    public_deps_inc="${public_deps_inc}        "'${CERES_INCLUDE_DIRS}'"\n"
                    public_deps_link="${public_deps_link}        "'${CERES_LIBRARIES}'"\n"
                    ;;
                sophus )
                    find_packages_deps="${find_packages_deps}find_package(Sophus REQUIRED)\n"
                    public_deps_inc="${public_deps_inc}"
                    public_deps_link="${public_deps_link}        Sophus::Sophus\n"
                    ;;
                boost )
                    find_packages_deps="${find_packages_deps}find_package(Boost REQUIRED)\n"
                    public_deps_inc="${public_deps_inc}        "'${Boost_INCLUDE_DIRS}'"\n"
                    public_deps_link="${public_deps_link}"
                    ;;
                openmp )
                    find_packages_deps="${find_packages_deps}find_package(OpenMP REQUIRED)\n"
                    public_deps_inc="${public_deps_inc}"
                    public_deps_link="${public_deps_link}        OpenMP::OpenMP_CXX\n"
                    ;;
                vc )
                    find_packages_deps="${find_packages_deps}find_package(Vc REQUIRED)\n"
                    public_deps_inc="${public_deps_inc}"
                    public_deps_link="${public_deps_link}        Vc::Vc\n"
                    ;;
                * )
                    echo "Dependency ${dep} not supported."
                    ;;
            esac
        done

        for dep in ${private_deps}
        do
            case ${dep} in
                opencv )
                    find_packages_deps="${find_packages_deps}find_package(OpenCV 3.2.0 REQUIRED NO_MODULE)\n"
                    private_deps_inc="${private_deps_inc}        "'${OpenCV_INCLUDE_DIRS}'"\n"
                    private_deps_link="${private_deps_link}        "'${OpenCV_LIBS}'"\n        -lopencv_sfm\n        -lopencv_xfeatures2d\n"
                    ;;
                eigen )
                    find_packages_deps="${find_packages_deps}find_package(Eigen3 3.3 REQUIRED NO_MODULE)\n"
                    private_deps_inc="${private_deps_inc}"
                    private_deps_link="${private_deps_link}        Eigen3::Eigen\n"
                    ;;
                ceres )
                    find_packages_deps="${find_packages_deps}find_package(Ceres REQUIRED NO_MODULE)\n"
                    private_deps_inc="${private_deps_inc}        "'${CERES_INCLUDE_DIRS}'"\n"
                    private_deps_link="${private_deps_link}        "'${CERES_LIBRARIES}'"\n"
                    ;;
                sophus )
                    find_packages_deps="${find_packages_deps}find_package(Sophus REQUIRED)\n"
                    private_deps_inc="${private_deps_inc}"
                    private_deps_link="${private_deps_link}        Sophus::Sophus\n"
                    ;;
                boost )
                    find_packages_deps="${find_packages_deps}find_package(Boost REQUIRED)\n"
                    private_deps_inc="${private_deps_inc}        "'${Boost_INCLUDE_DIRS}'"\n"
                    private_deps_link="${private_deps_link}"
                    ;;
                openmp )
                    find_packages_deps="${find_packages_deps}find_package(OpenMP REQUIRED)\n"
                    private_deps_inc="${private_deps_inc}"
                    private_deps_link="${private_deps_link}        OpenMP::OpenMP_CXX\n"
                    ;;
                vc )
                    find_packages_deps="${find_packages_deps}find_package(Vc REQUIRED)\n"
                    private_deps_inc="${private_deps_inc}"
                    private_deps_link="${private_deps_link}        Vc::Vc\n"
                    ;;
                * )
                    echo "Dependency ${dep} not supported."
                    ;;
            esac
        done

        for dep in ${interface_deps}
        do
            case ${dep} in
                opencv )
                    find_packages_deps="${find_packages_deps}find_package(OpenCV 3.2.0 REQUIRED NO_MODULE)\n"
                    interface_deps_inc="${interface_deps_inc}        "'${OpenCV_INCLUDE_DIRS}'"\n"
                    interface_deps_link="${interface_deps_link}        "'${OpenCV_LIBS}'"\n        -lopencv_sfm\n        -lopencv_xfeatures2d\n"
                    ;;
                eigen )
                    find_packages_deps="${find_packages_deps}find_package(Eigen3 3.3 REQUIRED NO_MODULE)\n"
                    interface_deps_inc="${interface_deps_inc}"
                    interface_deps_link="${interface_deps_link}        Eigen3::Eigen\n"
                    ;;
                ceres )
                    find_packages_deps="${find_packages_deps}find_package(Ceres REQUIRED NO_MODULE)\n"
                    interface_deps_inc="${interface_deps_inc}        "'${CERES_INCLUDE_DIRS}'"\n"
                    interface_deps_link="${interface_deps_link}        "'${CERES_LIBRARIES}'"\n"
                    ;;
                sophus )
                    find_packages_deps="${find_packages_deps}find_package(Sophus REQUIRED)\n"
                    interface_deps_inc="${interface_deps_inc}"
                    interface_deps_link="${interface_deps_link}        Sophus::Sophus\n"
                    ;;
                boost )
                    find_packages_deps="${find_packages_deps}find_package(Boost REQUIRED)\n"
                    interface_deps_inc="${interface_deps_inc}        "'${Boost_INCLUDE_DIRS}'"\n"
                    interface_deps_link="${interface_deps_link}"
                    ;;
                openmp )
                    find_packages_deps="${find_packages_deps}find_package(OpenMP REQUIRED)\n"
                    interface_deps_inc="${interface_deps_inc}"
                    interface_deps_link="${interface_deps_link}        OpenMP::OpenMP_CXX\n"
                    ;;
                vc )
                    find_packages_deps="${find_packages_deps}find_package(Vc REQUIRED)\n"
                    interface_deps_inc="${interface_deps_inc}"
                    interface_deps_link="${interface_deps_link}        Vc::Vc\n"
                    ;;
                * )
                    echo "Dependency ${dep} not supported."
                    ;;
            esac
        done

        # Begin generating and filling files for project
        echo "Creating new project, ${project_name}"

        # Set up directories and files
        mkdir ${project_name}
        cd ${project_name}
        git init
        touch CMakeLists.txt
        touch .gitignore
        mkdir benchmark
        touch benchmark/bm_foo.cpp
        touch benchmark/CMakeLists.txt
        mkdir build
        mkdir cmake
        touch cmake/cmake_uninstall.cmake.in
        touch cmake/${project_name}Config.cmake.in
        mkdir config
        touch config/config.hpp.in
        mkdir examples
        touch examples/bar.cpp
        touch examples/CMakeLists.txt
        mkdir -p include/${project_name}
        touch include/${project_name}/${project_name}.hpp
        mkdir src
        touch src/${project_name}.cpp
        touch src/CMakeLists.txt
        mkdir test
        touch test/test_foo.cpp
        touch test/CMakeLists.txt

        # Add initial contents to files

        #CMakeLists.txt
        echo "cmake_minimum_required(VERSION 3.10)" >> CMakeLists.txt
        echo "project(${project_name}" >> CMakeLists.txt
        echo "    LANGUAGES CXX" >> CMakeLists.txt
        echo "    VERSION 0.0.1" >> CMakeLists.txt
        echo "    DESCRIPTION \"My Library\"" >> CMakeLists.txt
        echo ")" >> CMakeLists.txt
        echo "" >> CMakeLists.txt
        echo "add_subdirectory(src)" >> CMakeLists.txt
        echo "add_subdirectory(examples)" >> CMakeLists.txt
        echo "enable_testing()" >> CMakeLists.txt
        echo "add_subdirectory(test)" >> CMakeLists.txt
        echo "add_subdirectory(benchmark)" >> CMakeLists.txt

        # benchmark/CMakeLists.txt
        echo "# Build benchmarks" >> benchmark/CMakeLists.txt
        echo "find_package(benchmark REQUIRED)" >> benchmark/CMakeLists.txt
        echo "macro(build_benchmark name)" >> benchmark/CMakeLists.txt
        echo '    add_executable(bm_${name} bm_${name}.cpp)' >> benchmark/CMakeLists.txt
        echo '    target_link_libraries(bm_${name} '"${project_name}::${project_name} benchmark::benchmark benchmark::benchmark_main)" >> benchmark/CMakeLists.txt
        echo '    target_compile_options(bm_${name} PRIVATE ${PRIVATE_BUILD_FLAGS})' >> benchmark/CMakeLists.txt
        echo '    target_compile_features(bm_${name} PRIVATE cxx_std_17)' >> benchmark/CMakeLists.txt
        echo '    add_test(NAME BM${name} COMMAND bm_${name})' >> benchmark/CMakeLists.txt
        echo "endmacro()" >> benchmark/CMakeLists.txt
        echo "" >> benchmark/CMakeLists.txt
        echo "build_benchmark(foo)" >> benchmark/CMakeLists.txt

        # benchmark/bm_foo.cpp
        echo "// Standard Headers" >> benchmark/bm_foo.cpp
        echo "" >> benchmark/bm_foo.cpp
        echo "// Library Headers" >> benchmark/bm_foo.cpp
        echo "#include <benchmark/benchmark.h>" >> benchmark/bm_foo.cpp
        echo "" >> benchmark/bm_foo.cpp
        echo "// Local Headers" >> benchmark/bm_foo.cpp
        echo "#include <${project_name}/${project_name}.hpp>" >> benchmark/bm_foo.cpp
        echo "" >> benchmark/bm_foo.cpp
        echo "namespace" >> benchmark/bm_foo.cpp
        echo "{" >> benchmark/bm_foo.cpp
        echo "    static void BM_foo(benchmark::State& state)" >> benchmark/bm_foo.cpp
        echo "    {" >> benchmark/bm_foo.cpp
        echo "        for (auto _ : state)" >> benchmark/bm_foo.cpp
        echo "        {" >> benchmark/bm_foo.cpp
        echo "            // Do something..." >> benchmark/bm_foo.cpp
        echo "        }" >> benchmark/bm_foo.cpp
        echo "    }" >> benchmark/bm_foo.cpp
        echo "    // Register the function as a benchmark" >> benchmark/bm_foo.cpp
        echo "    BENCHMARK(BM_foo);" >> benchmark/bm_foo.cpp
        echo "} // namespace" >> benchmark/bm_foo.cpp

        # cmake/cmake_uninstall.cmake.in
        echo 'if(NOT EXISTS "@CMAKE_BINARY_DIR@/install_manifest.txt")' >> cmake/cmake_uninstall.cmake.in
        echo '  message(FATAL_ERROR "Cannot find install manifest: @CMAKE_BINARY_DIR@/install_manifest.txt")' >> cmake/cmake_uninstall.cmake.in
        echo 'endif(NOT EXISTS "@CMAKE_BINARY_DIR@/install_manifest.txt")' >> cmake/cmake_uninstall.cmake.in
        echo "" >> cmake/cmake_uninstall.cmake.in
        echo 'file(READ "@CMAKE_BINARY_DIR@/install_manifest.txt" files)' >> cmake/cmake_uninstall.cmake.in
        echo 'string(REGEX REPLACE "\n" ";" files "${files}")' >> cmake/cmake_uninstall.cmake.in
        echo 'foreach(file ${files})' >> cmake/cmake_uninstall.cmake.in
        echo '  message(STATUS "Uninstalling $ENV{DESTDIR}${file}")' >> cmake/cmake_uninstall.cmake.in
        echo '  if(IS_SYMLINK "$ENV{DESTDIR}${file}" OR EXISTS "$ENV{DESTDIR}${file}")' >> cmake/cmake_uninstall.cmake.in
        echo '    exec_program(' >> cmake/cmake_uninstall.cmake.in
        echo '      "@CMAKE_COMMAND@" ARGS "-E remove \"$ENV{DESTDIR}${file}\""' >> cmake/cmake_uninstall.cmake.in
        echo '      OUTPUT_VARIABLE rm_out' >> cmake/cmake_uninstall.cmake.in
        echo '      RETURN_VALUE rm_retval' >> cmake/cmake_uninstall.cmake.in
        echo '      )' >> cmake/cmake_uninstall.cmake.in
        echo '    if(NOT "${rm_retval}" STREQUAL 0)' >> cmake/cmake_uninstall.cmake.in
        echo '      message(FATAL_ERROR "Problem when removing $ENV{DESTDIR}${file}")' >> cmake/cmake_uninstall.cmake.in
        echo '    endif(NOT "${rm_retval}" STREQUAL 0)' >> cmake/cmake_uninstall.cmake.in
        echo '  else(IS_SYMLINK "$ENV{DESTDIR}${file}" OR EXISTS "$ENV{DESTDIR}${file}")' >> cmake/cmake_uninstall.cmake.in
        echo '    message(STATUS "File $ENV{DESTDIR}${file} does not exist.")' >> cmake/cmake_uninstall.cmake.in
        echo '  endif(IS_SYMLINK "$ENV{DESTDIR}${file}" OR EXISTS "$ENV{DESTDIR}${file}")' >> cmake/cmake_uninstall.cmake.in
        echo 'endforeach(file)' >> cmake/cmake_uninstall.cmake.in

        # cmake/${project_name}Config.cmake.in
        echo '@PACKAGE_INIT@' >> cmake/${project_name}Config.cmake.in
        echo "" >> cmake/${project_name}Config.cmake.in
        echo "if(NOT TARGET ${project_name}::${project_name})" >> cmake/${project_name}Config.cmake.in
        echo '    include(${CMAKE_CURRENT_LIST_DIR}'"/${project_name}Targets.cmake)" >> cmake/${project_name}Config.cmake.in
        echo "endif()" >> cmake/${project_name}Config.cmake.in

        # config/config.hpp.in
        echo "#pragma once" >> config/config.hpp.in
        echo "#include <string>" >> config/config.hpp.in
        echo "namespace ${project_name}" >> config/config.hpp.in
        echo "{" >> config/config.hpp.in
        echo 'const std::string kCMakeDirectory = "${CMAKE_INSTALL_INCLUDEDIR}";' >> config/config.hpp.in
        echo "}; // namespace ${project_name}" >> config/config.hpp.in

        # examples/CMakeLists.txt
        echo "# Build example executables" >> examples/CMakeLists.txt
        echo "macro(build_example name)" >> examples/CMakeLists.txt
        echo '    add_executable(example_${name} ${name}.cpp)' >> examples/CMakeLists.txt
        echo '    target_link_libraries(example_${name} PRIVATE '"${project_name}::${project_name})" >> examples/CMakeLists.txt
        echo '    target_compile_options(example_${name} PRIVATE ${PRIVATE_BUILD_FLAGS})' >> examples/CMakeLists.txt
        echo '    target_compile_features(example_${name} PRIVATE cxx_std_17)' >> examples/CMakeLists.txt
        echo 'endmacro()' >> examples/CMakeLists.txt
        echo "" >> examples/CMakeLists.txt
        echo "build_example(bar)" >> examples/CMakeLists.txt

        # examples/bar.cpp
        echo "// bar.cpp" >> examples/bar.cpp
        echo "#include <${project_name}/${project_name}.hpp>" >> examples/bar.cpp
        echo "int main(int argc, char *argv[])" >> examples/bar.cpp
        echo "{" >> examples/bar.cpp
        echo "    return 0;" >> examples/bar.cpp
        echo "}" >> examples/bar.cpp

        # include/${project_name}/${project_name}.hpp
        echo "#pragma once" >> include/${project_name}/${project_name}.hpp
        echo "namespace ${project_name}" >> include/${project_name}/${project_name}.hpp
        echo "{" >> include/${project_name}/${project_name}.hpp
        echo "}; // namespace ${project_name}" >> include/${project_name}/${project_name}.hpp

        # src/CMakeLists.txt
        echo "# ${project_name} Library" >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo "include(GNUInstallDirs)" >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo "# Dependencies" >> src/CMakeLists.txt
        printf "${find_packages_deps}" >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo "# Set up source and header files" >> src/CMakeLists.txt
        echo 'set(PROJECT_HEADER_PATH ${'"${project_name}"'_SOURCE_DIR}/include/'"${project_name}"')' >> src/CMakeLists.txt
        echo 'set(PROJECT_SOURCE_PATH ${'"${project_name}"'_SOURCE_DIR}/src)' >> src/CMakeLists.txt
        echo 'set(PROJECT_PRIVATE_INCLUDE_PATH ${'"${project_name}"'_SOURCE_DIR}/src)' >> src/CMakeLists.txt
        echo 'set(PROJECT_PUBLIC_INCLUDE_PATH ${'"${project_name}"'_SOURCE_DIR}/include)' >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo 'set(PROJECT_PUBLIC_HEADERS ${PROJECT_HEADER_PATH}/'"${project_name}"'.hpp)' >> src/CMakeLists.txt
        echo 'set(PROJECT_PRIVATE_HEADERS )' >> src/CMakeLists.txt
        echo 'set(PROJECT_SOURCES ${PROJECT_SOURCE_PATH}/'"${project_name}"'.cpp)' >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo 'source_group("Public Headers" FILES ${PROJECT_PUBLIC_HEADERS})' >> src/CMakeLists.txt
        echo 'source_group("Private Header" FILES ${PROJECT_PRIVATE_HEADERS})' >> src/CMakeLists.txt
        echo 'source_group("Sources" FILES ${PROJECT_SOURCES})' >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo '# Configure files' >> src/CMakeLists.txt
        echo 'configure_file(${'"${project_name}"'_SOURCE_DIR}/config/config.hpp.in config/'"${project_name}"'/config.hpp)' >> src/CMakeLists.txt
        echo  >> src/CMakeLists.txt
        echo '# Add project as a library' >> src/CMakeLists.txt
        echo 'add_library('"${project_name}"' SHARED ${PROJECT_SOURCES})' >> src/CMakeLists.txt
        echo 'add_library('"${project_name}"'::'"${project_name}"' ALIAS '"${project_name}"')' >> src/CMakeLists.txt
        echo 'target_include_directories('"${project_name}"' ' >> src/CMakeLists.txt
        echo '    PUBLIC  ' >> src/CMakeLists.txt
        echo '        $<BUILD_INTERFACE:${PROJECT_PUBLIC_INCLUDE_PATH}>' >> src/CMakeLists.txt
        echo '        $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/config>' >> src/CMakeLists.txt
        echo '        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>' >> src/CMakeLists.txt
        if [[ -n ${public_deps_inc} ]]
        then
            printf "${public_deps_inc}" >> src/CMakeLists.txt
        fi
        echo '    PRIVATE ' >> src/CMakeLists.txt
        echo '        ${PROJECT_PRIVATE_INCLUDE_PATH}' >> src/CMakeLists.txt
        if [[ -n ${private_deps_inc} ]]
        then
            printf "${private_deps_inc}" >> src/CMakeLists.txt
        fi
        if [[ -n ${interface_deps_inc} ]]
        then
            echo '    INTERFACE' >> src/CMakeLists.txt
            printf "${interface_deps_inc}" >> src/CMakeLists.txt
        fi
        echo ')' >> src/CMakeLists.txt
        if [[ -n ${public_deps_link} ]] || [[ -n ${private_deps_link} ]] || [[ -n ${interface_deps_link} ]]
        then
            echo 'target_link_libraries('"${project_name}" >> src/CMakeLists.txt
            if [[ -n ${public_deps_link} ]]
            then
                echo '    PUBLIC' >> src/CMakeLists.txt
                printf "${public_deps_link}" >> src/CMakeLists.txt
            fi
            if [[ -n ${private_deps_link} ]]
            then
                echo '    PRIVATE' >> src/CMakeLists.txt
                printf "${private_deps_link}" >> src/CMakeLists.txt
            fi
            if [[ -n ${interface_deps_link} ]]
            then
                echo '    INTERFACE' >> src/CMakeLists.txt
                printf "${interface_deps_link}" >> src/CMakeLists.txt
            fi
            echo ')' >> src/CMakeLists.txt
        else 
            echo '# target_link_libraries('"${project_name} PRIVATE ..." >> src/CMakeLists.txt
        fi
        echo 'target_compile_features('"${project_name}"' PRIVATE cxx_std_17)' >> src/CMakeLists.txt
        echo 'set_target_properties('"${project_name}"' ' >> src/CMakeLists.txt
        echo '    PROPERTIES ' >> src/CMakeLists.txt
        echo '        VERSION ${PROJECT_VERSION}' >> src/CMakeLists.txt
        echo '        SOVERSION ${PROJECT_VERSION_MAJOR}' >> src/CMakeLists.txt
        echo '        ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib' >> src/CMakeLists.txt
        echo '        LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib' >> src/CMakeLists.txt
        echo '        RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin' >> src/CMakeLists.txt
        echo ')' >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo '# Configure install targets' >> src/CMakeLists.txt
        echo 'install(' >> src/CMakeLists.txt
        echo '    TARGETS '"${project_name}"' ' >> src/CMakeLists.txt
        echo '    EXPORT '"${project_name}"'-targets ' >> src/CMakeLists.txt
        echo '    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}' >> src/CMakeLists.txt
        echo '    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}' >> src/CMakeLists.txt
        echo '    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}' >> src/CMakeLists.txt
        echo '    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}' >> src/CMakeLists.txt
        echo ')' >> src/CMakeLists.txt
        echo 'install(' >> src/CMakeLists.txt
        echo '    DIRECTORY ${PROJECT_HEADER_PATH}' >> src/CMakeLists.txt
        echo '    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}' >> src/CMakeLists.txt
        echo ')' >> src/CMakeLists.txt
        echo 'install(' >> src/CMakeLists.txt
        echo '    FILES ${CMAKE_CURRENT_BINARY_DIR}/config/'"${project_name}"'/config.hpp ' >> src/CMakeLists.txt
        echo '    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/'"${project_name}"'' >> src/CMakeLists.txt
        echo ')' >> src/CMakeLists.txt
        echo 'install(' >> src/CMakeLists.txt
        echo '    EXPORT '"${project_name}"'-targets ' >> src/CMakeLists.txt
        echo '    NAMESPACE '"${project_name}"':: ' >> src/CMakeLists.txt
        echo '    FILE '"${project_name}"'Targets.cmake'  >> src/CMakeLists.txt
        echo '    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/'"${project_name}"'' >> src/CMakeLists.txt
        echo ')' >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo 'include(CMakePackageConfigHelpers)' >> src/CMakeLists.txt
        echo 'configure_package_config_file(' >> src/CMakeLists.txt
        echo '    ${'"${project_name}"'_SOURCE_DIR}/cmake/'"${project_name}"'Config.cmake.in' >> src/CMakeLists.txt
        echo '    ${CMAKE_CURRENT_BINARY_DIR}/cmake/'"${project_name}"'Config.cmake' >> src/CMakeLists.txt
        echo '    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/'"${project_name}"'' >> src/CMakeLists.txt
        echo ')' >> src/CMakeLists.txt
        echo 'write_basic_package_version_file(' >> src/CMakeLists.txt
        echo '    ${CMAKE_CURRENT_BINARY_DIR}/cmake/'"${project_name}"'ConfigVersion.cmake' >> src/CMakeLists.txt
        echo '    VERSION ${PACKAGE_VERSION}' >> src/CMakeLists.txt
        echo '    COMPATIBILITY AnyNewerVersion' >> src/CMakeLists.txt
        echo ')' >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo 'install(' >> src/CMakeLists.txt
        echo '    FILES' >> src/CMakeLists.txt
        echo '        ${CMAKE_CURRENT_BINARY_DIR}/cmake/'"${project_name}"'Config.cmake' >> src/CMakeLists.txt
        echo '        ${CMAKE_CURRENT_BINARY_DIR}/cmake/'"${project_name}"'ConfigVersion.cmake' >> src/CMakeLists.txt
        echo '    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/'"${project_name}"'' >> src/CMakeLists.txt
        echo ')' >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo '# Configure uninstall target' >> src/CMakeLists.txt
        echo 'if(NOT TARGET uninstall)' >> src/CMakeLists.txt
        echo '    configure_file(' >> src/CMakeLists.txt
        echo '        ${'"${project_name}"'_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in' >> src/CMakeLists.txt
        echo '        ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake' >> src/CMakeLists.txt
        echo '        IMMEDIATE @ONLY' >> src/CMakeLists.txt
        echo '    )' >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo '    add_custom_target(uninstall' >> src/CMakeLists.txt
        echo '        COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake' >> src/CMakeLists.txt
        echo '    )' >> src/CMakeLists.txt
        echo 'endif()' >> src/CMakeLists.txt
        echo "" >> src/CMakeLists.txt
        echo '# Export direct include targets' >> src/CMakeLists.txt
        echo 'export(' >> src/CMakeLists.txt
        echo '    EXPORT '"${project_name}"'-targets' >> src/CMakeLists.txt
        echo '    FILE ${CMAKE_CURRENT_BINARY_DIR}/cmake/'"${project_name}"'Targets.cmake' >> src/CMakeLists.txt
        echo '    NAMESPACE '"${project_name}"'::' >> src/CMakeLists.txt
        echo ')' >> src/CMakeLists.txt

        # src/${project_name}.cpp
        echo "#include \"${project_name}/${project_name}.hpp\"" >> src/${project_name}.cpp
        echo "" >> src/${project_name}.cpp
        echo "#include \"${project_name}/config.hpp\"" >> src/${project_name}.cpp
        echo "namespace ${project_name}" >> src/${project_name}.cpp
        echo "{" >> src/${project_name}.cpp
        echo "}; // namespace ${project_name}" >> src/${project_name}.cpp

        # test/CMakeLists.txt
        echo '# Build unit tests' >> test/CMakeLists.txt
        echo 'find_package(GTest REQUIRED)' >> test/CMakeLists.txt
        echo 'macro(build_test name)' >> test/CMakeLists.txt
        echo '    add_executable(test_${name} test_${name}.cpp)' >> test/CMakeLists.txt
        echo '    target_link_libraries(test_${name} '"${project_name}"'::'"${project_name}"' GTest::GTest GTest::Main)' >> test/CMakeLists.txt
        echo '    target_compile_options(test_${name} PRIVATE ${PRIVATE_BUILD_FLAGS})' >> test/CMakeLists.txt
        echo '    target_compile_features(test_${name} PRIVATE cxx_std_17)' >> test/CMakeLists.txt
        echo '    add_test(NAME TEST${name} COMMAND test_${name})' >> test/CMakeLists.txt
        echo 'endmacro()' >> test/CMakeLists.txt
        echo '' >> test/CMakeLists.txt
        echo 'build_test(foo)' >> test/CMakeLists.txt

        # test/test_foo.cpp
        echo '// Standard Headers' >> test/test_foo.cpp
        echo '' >> test/test_foo.cpp
        echo '// Library Headers' >> test/test_foo.cpp
        echo '#include "gtest/gtest.h"' >> test/test_foo.cpp
        echo '' >> test/test_foo.cpp
        echo '// Local Headers' >> test/test_foo.cpp
        echo '#include <'"${project_name}"'/'"${project_name}"'.hpp>' >> test/test_foo.cpp
        echo '' >> test/test_foo.cpp
        echo 'namespace' >> test/test_foo.cpp
        echo '{' >> test/test_foo.cpp
        echo '    TEST(FOOTest, Hello)' >> test/test_foo.cpp
        echo '    {' >> test/test_foo.cpp
        echo '        // Do something...' >> test/test_foo.cpp
        echo '    }' >> test/test_foo.cpp
        echo '} // namespace' >> test/test_foo.cpp

        ;;
esac





