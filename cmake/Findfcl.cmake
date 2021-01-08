include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

find_path(
	FCL_INCLUDE_DIR
	NAMES fcl/config.h
)
find_library(
	FCL_LIBRARY_DEBUG
	NAMES fcld
)
find_library(
	FCL_LIBRARY_RELEASE
	NAMES fcl
)
select_library_configurations(FCL)

if(FCL_INCLUDE_DIR AND EXISTS "${FCL_INCLUDE_DIR}/fcl/config.h")
	file(STRINGS "${FCL_INCLUDE_DIR}/fcl/config.h" _FCL_VERSION_DEFINE REGEX "[\t ]*#define[\t ]+FCL_VERSION[\t ]+\"[^\"]*\".*")
	string(REGEX REPLACE "[\t ]*#define[\t ]+FCL_VERSION[\t ]+\"([^\"]*)\".*" "\\1" FCL_VERSION "${_FCL_VERSION_DEFINE}")
	unset(_FCL_VERSION_DEFINE)
	file(STRINGS "${FCL_INCLUDE_DIR}/fcl/config.h" _FCL_OCTOMAP_DEFINE REGEX "[\t ]*#define[\t ]+FCL_HAVE_OCTOMAP[\t ]+[01]")
	string(REGEX REPLACE "[\t ]*#define[\t ]+FCL_HAVE_OCTOMAP[\t ]+([01])" "\\1" FCL_HAVE_OCTOMAP "${_FCL_OCTOMAP_DEFINE}")
	unset(_FCL_OCTOMAP_DEFINE)
endif()

unset(FCL_DEFINITIONS)
unset(_FCL_FIND_PACKAGE_ARGS)
set(FCL_INCLUDE_DIRS ${FCL_INCLUDE_DIR})
unset(_FCL_INTERFACE_COMPILE_DEFINITIONS)
unset(_FCL_INTERFACE_LINK_LIBRARIES)
set(FCL_LIBRARIES ${FCL_LIBRARY})
unset(_FCL_REQUIRED_VARS)

if(fcl_FIND_QUIETLY)
	list(APPEND _FCL_FIND_PACKAGE_ARGS QUIET)
endif()
if(fcl_FIND_REQUIRED)
	list(APPEND _FCL_FIND_PACKAGE_ARGS REQUIRED)
endif()

if(FCL_VERSION AND FCL_VERSION VERSION_LESS 0.5)
	find_package(Boost ${_FCL_FIND_PACKAGE_ARGS})
	list(APPEND FCL_DEFINITIONS -DBOOST_ALL_NO_LIB -DBOOST_SYSTEM_NO_DEPRECATED)
	list(APPEND FCL_INCLUDE_DIRS ${Boost_INCLUDE_DIRS})
	list(APPEND _FCL_INTERFACE_COMPILE_DEFINITIONS BOOST_ALL_NO_LIB BOOST_SYSTEM_NO_DEPRECATED)
	list(APPEND _FCL_INTERFACE_LINK_LIBRARIES Boost::headers)
	list(APPEND _FCL_REQUIRED_VARS Boost_FOUND)
endif()

find_package(ccd ${_FCL_FIND_PACKAGE_ARGS})
list(APPEND FCL_INCLUDE_DIRS ${CCD_INCLUDE_DIRS})
list(APPEND _FCL_INTERFACE_LINK_LIBRARIES ccd::ccd)
list(APPEND FCL_LIBRARIES ${CCD_LIBRARIES})
list(APPEND _FCL_REQUIRED_VARS ccd_FOUND)

if(FCL_VERSION AND NOT FCL_VERSION VERSION_LESS 0.6)
	find_package(Eigen3 ${_FCL_FIND_PACKAGE_ARGS})
	list(APPEND FCL_INCLUDE_DIRS ${EIGEN3_INCLUDE_DIRS})
	list(APPEND _FCL_INTERFACE_LINK_LIBRARIES Eigen3::Eigen)
	list(APPEND _FCL_REQUIRED_VARS Eigen3_FOUND)
endif()

if(FCL_HAVE_OCTOMAP)
	find_package(octomap ${_FCL_FIND_PACKAGE_ARGS})
	list(APPEND FCL_INCLUDE_DIRS ${OCTOMAP_INCLUDE_DIRS})
	list(APPEND _FCL_INTERFACE_LINK_LIBRARIES octomap::octomap)
	list(APPEND FCL_LIBRARIES ${OCTOMAP_LIBRARIES})
	list(APPEND _FCL_REQUIRED_VARS octomap_FOUND)
endif()

find_package_handle_standard_args(
	fcl
	FOUND_VAR fcl_FOUND
	REQUIRED_VARS FCL_INCLUDE_DIR FCL_LIBRARY ${_FCL_REQUIRED_VARS}
	VERSION_VAR FCL_VERSION
)

if(fcl_FOUND AND NOT TARGET fcl::fcl)
	add_library(fcl::fcl UNKNOWN IMPORTED)
	if(FCL_LIBRARY_RELEASE)
		set_property(TARGET fcl::fcl APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
		set_target_properties(fcl::fcl PROPERTIES IMPORTED_LOCATION_RELEASE "${FCL_LIBRARY_RELEASE}")
	endif()
	if(FCL_LIBRARY_DEBUG)
		set_property(TARGET fcl::fcl APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
		set_target_properties(fcl::fcl PROPERTIES IMPORTED_LOCATION_DEBUG "${FCL_LIBRARY_DEBUG}")
	endif()
	set_target_properties(fcl::fcl PROPERTIES INTERFACE_COMPILE_DEFINITIONS "${_FCL_INTERFACE_COMPILE_DEFINITIONS}")
	set_target_properties(fcl::fcl PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${FCL_INCLUDE_DIRS}")
	set_target_properties(fcl::fcl PROPERTIES INTERFACE_LINK_LIBRARIES "${_FCL_INTERFACE_LINK_LIBRARIES}")
endif()

mark_as_advanced(FCL_DEFINITIONS)
mark_as_advanced(FCL_INCLUDE_DIR)
unset(_FCL_FIND_PACKAGE_ARGS)
unset(_FCL_INTERFACE_COMPILE_DEFINITIONS)
unset(_FCL_INTERFACE_LINK_LIBRARIES)
unset(_FCL_REQUIRED_VARS)
