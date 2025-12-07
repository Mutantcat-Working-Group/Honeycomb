# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "CMakeFiles\\appHoneycomb_autogen.dir\\AutogenUsed.txt"
  "CMakeFiles\\appHoneycomb_autogen.dir\\ParseCache.txt"
  "appHoneycomb_autogen"
  )
endif()
