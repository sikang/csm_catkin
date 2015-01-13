cmake_minimum_required(VERSION 2.8.3)
project(csm)

find_package(catkin REQUIRED)

catkin_package(INCLUDE_DIRS src src/lib
  LIBRARIES csm)

SET(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/src)

FIND_PACKAGE(GSL REQUIRED)
IF(GSL_FOUND)
	MESSAGE(STATUS "Found GSL:")
	MESSAGE(STATUS "   GSL_LIBRARIES = ${GSL_LIBRARIES}")
	MESSAGE(STATUS "   GSL_INCLUDE_DIR = ${GSL_INCLUDE_DIR}")
	MESSAGE(STATUS "   CMAKE_GSL_CXX_FLAGS = ${CMAKE_GSL_CXX_FLAGS}")
	MESSAGE(STATUS "   GSL_LINK_DIRECTORIES = '${GSL_LINK_DIRECTORIES}'")

 	
	set(csm_c_flags "${csm_c_flags} -I${GSL_INCLUDE_DIR}")
	if(GSL_LINK_DIRECTORIES)	
#		set(csm_link_flags "${csm_link_flags}
		set(csm_link_flags "-L${GSL_LINK_DIRECTORIES}")
	endif(GSL_LINK_DIRECTORIES)	

	set(csm_link_flags "${csm_link_flags} ${GSL_LIBRARIES}")
	
ELSE(GSL_FOUND)
	MESSAGE(FATAL_ERROR "GSL not found.")
ENDIF(GSL_FOUND)

FIND_PACKAGE(Cairo)
IF(CAIRO_FOUND)
	MESSAGE(STATUS "Found Cairo at.")
	MESSAGE(STATUS "   PREFIX_CAIRO= ${PREFIX_CAIRO}")
	MESSAGE(STATUS "   CAIRO_CFLAGS = ${CAIRO_CFLAGS}")
	MESSAGE(STATUS "   CAIRO_LIBRARY = ${CAIRO_LIBRARY}")
	MESSAGE(STATUS "   CAIRO_INCLUDE_DIR = ${CAIRO_INCLUDE_DIR}")
	
	set(csm_link_flags "${csm_link_flags} ${CAIRO_LIBRARY}")
	SET(csm_c_flags "${csm_c_flags} ${CAIRO_CFLAGS} -I${CAIRO_INCLUDE_DIR}")
	
ELSE(CAIRO_FOUND)
	MESSAGE(WARNING "* Cairo not found: plotting programs (e.g., 'log2pdf') will not be built.")
	MESSAGE(WARNING "* install Cairo from http://cairographics.org ")
ENDIF(CAIRO_FOUND)



MESSAGE(STATUS "csm_c_flags = ${csm_c_flags}")
MESSAGE(STATUS "csm_link_flags = ${csm_link_flags}")


SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${csm_c_flags}")
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ggdb -Wall")


# for realpath
IF("${CMAKE_SYSTEM}" MATCHES "Linux")
	ADD_DEFINITIONS(-DLINUX)
ENDIF("${CMAKE_SYSTEM}" MATCHES "Linux")

########### Options ########## 

SUBDIRS(src/lib/options)
SUBDIRS(src/lib/json-c)
SUBDIRS(src/lib/egsl)
SUBDIRS(src/lib/gpc)
SUBDIRS(src/csm)


INCLUDE_DIRECTORIES(include/csm ${CMAKE_CURRENT_SOURCE_DIR}/src/lib)

SET(csm_sources 
./src/csm/clustering.c
./src/csm/gpm/gpm.c
./src/csm/icp/icp.c
./src/csm/icp/icp_corr_dumb.c
./src/csm/icp/icp_corr_tricks.c
./src/csm/icp/icp_covariance.c
./src/csm/icp/icp_loop.c
./src/csm/icp/icp_outliers.c
./src/csm/icp/icp_debug.c
./src/csm/mbicp/mbicp_interface.c      
./src/csm/mbicp/MbICP.c      
./src/csm/mbicp/calcul.c     
./src/csm/mbicp/percolate.c  
./src/csm/mbicp/sp_matrix.c
./src/csm/hsm/hsm.c
./src/csm/hsm/hsm_interface.c
./src/csm/json_journal.c
./src/csm/laser_data.c
./src/csm/laser_data_carmen.c
./src/csm/laser_data_fisher.c
./src/csm/laser_data_json.c
./src/csm/laser_data_load.c
./src/csm/laser_data_drawing.c
./src/csm/laser_data_bbox.c
./src/csm/logging.c
./src/csm/math_utils.c
./src/csm/math_utils_gsl.c
./src/csm/orientation.c
./src/csm/sm_options.c
./src/csm/utils.c
./src/lib/egsl/egsl.c
./src/lib/egsl/egsl_conversions.c
./src/lib/egsl/egsl_misc.c
./src/lib/egsl/egsl_ops.c
./src/lib/gpc/gpc.c
./src/lib/gpc/gpc_utils.c
./src/lib/json-c/arraylist.c
./src/lib/json-c/debug.c
./src/lib/json-c/JSON_checker.c
./src/lib/json-c/json_more_utils.c
./src/lib/json-c/json_object.c
./src/lib/json-c/json_tokener.c
./src/lib/json-c/json_util.c
./src/lib/json-c/linkhash.c
./src/lib/json-c/printbuf.c
./src/lib/options/options.c
./src/lib/options/options_interface.c
)

IF(CAIRO_FOUND)
SET(csm_sources ${csm_sources} src/csm/laser_data_cairo.c)
ENDIF(CAIRO_FOUND)

ADD_LIBRARY(csm SHARED ${csm_sources})
TARGET_LINK_LIBRARIES(csm ${csm_link_flags})
INSTALL(TARGETS csm 
  ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
  LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
  RUNTIME DESTINATION ${CATKIN_GLOBAL_BIN_DESTINATION})

foreach(dir src/csm src/csm/hsm src/csm/mbicp src/csm/icp src/csm/gpm src/csm/structprior src/lib/json-c)
  FILE(GLOB csm_headers "${dir}/*.h")
  foreach(header ${csm_headers} )
    INSTALL(FILES ${header} DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION})
  endforeach(header ${csm_headers})
endforeach(dir . csm)
