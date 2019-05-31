#!/bin/bash
if [[ $# -gt 0 ]]
then
    if [[ $1 == 'new' ]]
    then
        if [[ $# -gt 1 ]]
        then
            echo "Creating new project, $2"

            # Set up directories and files
            mkdir $2
            cd $2
            git init
            touch CMakeLists.txt
            touch .gitignore
            mkdir benchmark
            touch benchmark/bm_foo.cpp
            touch benchmark/CMakeLists.txt
            mkdir build
            mkdir cmake
            touch cmake/cmake_uninstall.cmake.in
            touch cmake/${2}Config.cmake.in
            mkdir config
            touch config/config.hpp.in
            mkdir examples
            touch examples/bar.cpp
            touch examples/CMakeLists.txt
            mkdir -p include/${2}
            touch include/${2}/${2}.hpp
            mkdir src
            touch src/${2}.cpp
            touch src/CMakeLists.txt
            mkdir test
            touch test/test_foo.cpp
            touch test/CMakeLists.txt

            # Add initial contents to files

            #CMakeLists.txt
            echo "cmake_minimum_required(VERSION 3.10)" >> CMakeLists.txt
            echo "project(${2}" >> CMakeLists.txt
            echo "    LANGUAGES CXX" >> CMakeLists.txt
            echo "    VERSION 0.0.1" >> CMakeLists.txt
            echo "    DESCRIPTION \"My Library\"" >> CMakeLists.txt
            echo ")" >> CMakeLists.txt
            echo "" >> CMakeLists.txt
            echo "add_subdirectory(src)" >> CMakeLists.txt

            # benchmark/CMakeLists.txt
            echo "# Build benchmarks" >> benchmark/CMakeLists.txt
            echo "find_package(benchmark REQUIRED)" >> benchmark/CMakeLists.txt
            echo "macro(build_benchmark name)" >> benchmark/CMakeLists.txt
            echo '    add_executable(bm_${name} bm_${name}.cpp)' >> benchmark/CMakeLists.txt
            echo '    target_link_libraries(bm_${name} '"${2}::${2} benchmark::benchmark benchmark::benchmark_main)" >> benchmark/CMakeLists.txt
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
            echo "#include <${2}/${2}.hpp>" >> benchmark/bm_foo.cpp
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

            # cmake/${2}Config.cmake.in
            echo '@PACKAGE_INIT@' >> cmake/${2}Config.cmake.in
            echo "" >> cmake/${2}Config.cmake.in
            echo "if(NOT TARGET ${2}::${2})" >> cmake/${2}Config.cmake.in
            echo '    include(${CMAKE_CURRENT_LIST_DIR}'"/${2}Targets.cmake)" >> cmake/${2}Config.cmake.in
            echo "endif()" >> cmake/${2}Config.cmake.in

            # config/config.hpp.in
            echo "#pragma once" >> config/config.hpp.in
            echo "#include <string>" >> config/config.hpp.in
            echo "namespace ${2}" >> config/config.hpp.in
            echo "{" >> config/config.hpp.in
            echo 'const std::string kCMakeDirectory = "${CMAKE_INSTALL_INCLUDEDIR}";' >> config/config.hpp.in
            echo "}; // namespace ${2}" >> config/config.hpp.in

            # examples/CMakeLists.txt
            echo "# Build example executables" >> examples/CMakeLists.txt
            echo "macro(build_example name)" >> examples/CMakeLists.txt
            echo '    add_executable(example_${name} ${name}.cpp)' >> examples/CMakeLists.txt
            echo '    target_link_libraries(example_${name} PRIVATE '"${2}::${2})" >> examples/CMakeLists.txt
            echo '    target_compile_options(example_${name} PRIVATE ${PRIVATE_BUILD_FLAGS})' >> examples/CMakeLists.txt
            echo '    target_compile_features(example_${name} PRIVATE cxx_std_17)' >> examples/CMakeLists.txt
            echo 'endmacro()' >> examples/CMakeLists.txt
            echo "" >> examples/CMakeLists.txt
            echo "build_example(bar)" >> examples/CMakeLists.txt

            # examples/bar.cpp
            echo "// bar.cpp" >> examples/bar.cpp
            echo "#include <${2}/${2}.hpp>" >> examples/bar.cpp
            echo "int main(int argc, char *argv[])" >> examples/bar.cpp
            echo "{" >> examples/bar.cpp
            echo "    return 0;" >> examples/bar.cpp
            echo "}" >> examples/bar.cpp

            # include/${2}/${2}.hpp
            echo "#pragma once" >> include/${2}/${2}.hpp
            echo "namespace ${2}" >> include/${2}/${2}.hpp
            echo "{" >> include/${2}/${2}.hpp
            echo "}; // namespace ${2}" >> include/${2}/${2}.hpp

            # src/CMakeLists.txt
            echo "# ${2} Library" >> src/CMakeLists.txt
            echo "" >> src/CMakeLists.txt
            echo "include(GNUInstallDirs)" >> src/CMakeLists.txt
            echo "" >> src/CMakeLists.txt
            echo "# Set up source and header files" >> src/CMakeLists.txt
            echo 'set(PROJECT_HEADER_PATH ${'"${2}"'_SOURCE_DIR}/include/'"${2}"')' >> src/CMakeLists.txt
            echo 'set(PROJECT_SOURCE_PATH ${'"${2}"'_SOURCE_DIR}/src)' >> src/CMakeLists.txt
            echo 'set(PROJECT_PRIVATE_INCLUDE_PATH ${'"${2}"'_SOURCE_DIR}/src)' >> src/CMakeLists.txt
            echo 'set(PROJECT_PUBLIC_INCLUDE_PATH ${'"${2}"'_SOURCE_DIR}/include)' >> src/CMakeLists.txt
            echo "" >> src/CMakeLists.txt
            echo 'set(PROJECT_PUBLIC_HEADERS ${PROJECT_HEADER_PATH}/'"${2}"'.hpp)' >> src/CMakeLists.txt
            echo 'set(PROJECT_PRIVATE_HEADERS )' >> src/CMakeLists.txt
            echo 'set(PROJECT_SOURCES ${PROJECT_SOURCE_PATH}/'"${2}"'.cpp)' >> src/CMakeLists.txt
            echo "" >> src/CMakeLists.txt
            echo 'source_group("Public Headers" FILES ${PROJECT_PUBLIC_HEADERS})' >> src/CMakeLists.txt
            echo 'source_group("Private Header" FILES ${PROJECT_PRIVATE_HEADERS})' >> src/CMakeLists.txt
            echo 'source_group("Sources" FILES ${PROJECT_SOURCES})' >> src/CMakeLists.txt
            echo "" >> src/CMakeLists.txt
            echo '# Configure files' >> src/CMakeLists.txt
            echo 'configure_file(${'"${2}"'_SOURCE_DIR}/config/config.hpp.in config/'"${2}"'/config.hpp)' >> src/CMakeLists.txt
            echo  >> src/CMakeLists.txt
            echo '# Add project as a library' >> src/CMakeLists.txt
            echo 'add_library('"${2}"' SHARED ${PROJECT_SOURCES})' >> src/CMakeLists.txt
            echo 'add_library('"${2}"'::'"${2}"' ALIAS '"${2}"')' >> src/CMakeLists.txt
            echo 'target_include_directories('"${2}"' PUBLIC  $<BUILD_INTERFACE:${PROJECT_PUBLIC_INCLUDE_PATH}>' >> src/CMakeLists.txt
            echo '                                         $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/config>' >> src/CMakeLists.txt
            echo '                                         $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>' >> src/CMakeLists.txt
            echo '                                 PRIVATE ${PROJECT_PRIVATE_INCLUDE_PATH})' >> src/CMakeLists.txt
            echo '# target_link_libraries('"${2}"' PRIVATE ...)' >> src/CMakeLists.txt
            echo '# target_compile_features('"${2}"' PRIVATE cxx_std_17)' >> src/CMakeLists.txt
            echo 'set_target_properties('"${2}"' ' >> src/CMakeLists.txt
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
            echo '    TARGETS '"${2}"' ' >> src/CMakeLists.txt
            echo '    EXPORT '"${2}"'-targets ' >> src/CMakeLists.txt
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
            echo '    FILES ${CMAKE_CURRENT_BINARY_DIR}/config/'"${2}"'/config.hpp ' >> src/CMakeLists.txt
            echo '    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/'"${2}"'' >> src/CMakeLists.txt
            echo ')' >> src/CMakeLists.txt
            echo 'install(' >> src/CMakeLists.txt
            echo '    EXPORT '"${2}"'-targets ' >> src/CMakeLists.txt
            echo '    NAMESPACE '"${2}"':: ' >> src/CMakeLists.txt
            echo '    FILE '"${2}"'Targets.cmake'  >> src/CMakeLists.txt
            echo '    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/'"${2}"'' >> src/CMakeLists.txt
            echo ')' >> src/CMakeLists.txt
            echo "" >> src/CMakeLists.txt
            echo 'include(CMakePackageConfigHelpers)' >> src/CMakeLists.txt
            echo 'configure_package_config_file(' >> src/CMakeLists.txt
            echo '    ${'"${2}"'_SOURCE_DIR}/cmake/'"${2}"'Config.cmake.in' >> src/CMakeLists.txt
            echo '    ${CMAKE_CURRENT_BINARY_DIR}/cmake/'"${2}"'Config.cmake' >> src/CMakeLists.txt
            echo '    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/'"${2}"'' >> src/CMakeLists.txt
            echo ')' >> src/CMakeLists.txt
            echo 'write_basic_package_version_file(' >> src/CMakeLists.txt
            echo '    ${CMAKE_CURRENT_BINARY_DIR}/cmake/'"${2}"'ConfigVersion.cmake' >> src/CMakeLists.txt
            echo '    VERSION ${PACKAGE_VERSION}' >> src/CMakeLists.txt
            echo '    COMPATIBILITY AnyNewerVersion' >> src/CMakeLists.txt
            echo ')' >> src/CMakeLists.txt
            echo "" >> src/CMakeLists.txt
            echo 'install(' >> src/CMakeLists.txt
            echo '    FILES' >> src/CMakeLists.txt
            echo '        ${CMAKE_CURRENT_BINARY_DIR}/cmake/'"${2}"'Config.cmake' >> src/CMakeLists.txt
            echo '        ${CMAKE_CURRENT_BINARY_DIR}/cmake/'"${2}"'ConfigVersion.cmake' >> src/CMakeLists.txt
            echo '    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/'"${2}"'' >> src/CMakeLists.txt
            echo ')' >> src/CMakeLists.txt
            echo "" >> src/CMakeLists.txt
            echo '# Configure uninstall target' >> src/CMakeLists.txt
            echo 'if(NOT TARGET uninstall)' >> src/CMakeLists.txt
            echo '    configure_file(' >> src/CMakeLists.txt
            echo '        ${'"${2}"'_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in' >> src/CMakeLists.txt
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
            echo '    EXPORT '"${2}"'-targets' >> src/CMakeLists.txt
            echo '    FILE ${CMAKE_CURRENT_BINARY_DIR}/cmake/'"${2}"'Targets.cmake' >> src/CMakeLists.txt
            echo '    NAMESPACE '"${2}"'::' >> src/CMakeLists.txt
            echo ')' >> src/CMakeLists.txt

            # src/${2}.cpp
            echo "#include \"${2}/${2}.hpp\"" >> src/${2}.cpp
            echo "" >> src/${2}.cpp
            echo "#include \"${2}/config.hpp\"" >> src/${2}.cpp
            echo "namespace ${2}" >> src/${2}.cpp
            echo "{" >> src/${2}.cpp
            echo "}; // namespace ${2}" >> src/${2}.cpp

            # test/CMakeLists.txt
            echo '# Build unit tests' >> test/CMakeLists.txt
            echo 'find_package(GTest REQUIRED)' >> test/CMakeLists.txt
            echo 'macro(build_test name)' >> test/CMakeLists.txt
            echo '    add_executable(test_${name} test_${name}.cpp)' >> test/CMakeLists.txt
            echo '    target_link_libraries(test_${name} '"${2}"'::'"${2}"' GTest::GTest GTest::Main)' >> test/CMakeLists.txt
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
            echo '#include <'"${2}"'/'"${2}"'.hpp>' >> test/test_foo.cpp
            echo '' >> test/test_foo.cpp
            echo 'namespace' >> test/test_foo.cpp
            echo '{' >> test/test_foo.cpp
            echo '    TEST(FOOTest, Hello)' >> test/test_foo.cpp
            echo '    {' >> test/test_foo.cpp
            echo '        // Do something...' >> test/test_foo.cpp
            echo '    }' >> test/test_foo.cpp
            echo '} // namespace' >> test/test_foo.cpp


        else
            echo "Please provide a project name."
        fi
    elif [[ $1 == 'help' ]]
    then
        echo "Set up a new cpp cmake project."
        echo "Usage:"
        echo "new <project-name> <optionals>"
        echo "    Create a new project with name <project-name>."
        echo "    <options> include \'ros\'."
    fi
else
    echo "Type \"cpp_project.sh help\" for arguments"
fi





