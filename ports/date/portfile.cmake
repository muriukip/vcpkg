include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  message(WARNING
    "You will need to also install http://unicode.org/repos/cldr/trunk/common/supplemental/windowsZones.xml into your install location.\n"
    "See https://howardhinnant.github.io/date/tz.html"
  )
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
#  REPO HowardHinnant/date
#  REF 429d9ba739184ee1eb3aac446d3a2c7c5024434e
#  SHA512 fcf201f528303a54d3fd015abd6bf7ae2d3248abb2d24a0ab56a0a4f94e22af01f6a82fa594b3bdd5f189cddf974707dec216defb754f2c7dc43a9c5aee9d917
  REPO muriukip/date
  REF 3f972be6d4c25044aa65dbe5747c96e96130683c
  SHA512 4efc1e31dea2d06875ad528c57bf5ac504de30e918cc0479e522e08fccd3be7e9b7648422a9b7e24f3b0d9855dcdea2bfdfafe93992d2685c0105ae21eac1358
  HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

set(HAS_REMOTE_API 0)
if("remote-api" IN_LIST FEATURES)
  set(HAS_REMOTE_API 1)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DHAS_REMOTE_API=${HAS_REMOTE_API}
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-date TARGET_PATH share/unofficial-date)

vcpkg_copy_pdbs()

set(HEADER "${CURRENT_PACKAGES_DIR}/include/date/tz.h")
file(READ "${HEADER}" _contents)
string(REPLACE "#define TZ_H" "#define TZ_H\n#undef HAS_REMOTE_API\n#define HAS_REMOTE_API ${HAS_REMOTE_API}" _contents "${_contents}")
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  string(REPLACE "ifdef DATE_BUILD_DLL" "if 1" _contents "${_contents}")
endif()
file(WRITE "${HEADER}" "${_contents}")

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/date RENAME copyright)
