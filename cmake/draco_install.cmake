if(DRACO_CMAKE_DRACO_INSTALL_CMAKE_)
  return()
endif() # DRACO_CMAKE_DRACO_INSTALL_CMAKE_
set(DRACO_CMAKE_DRACO_INSTALL_CMAKE_ 1)

# Sets up the draco install targets. Must be called after the static library
# target is created.
macro(draco_setup_install_target)
  include(GNUInstallDirs)

  # HUNTER: commenting this out to do it the Hunter way
  # # pkg-config: draco.pc
  # set(prefix "${CMAKE_INSTALL_PREFIX}")
  # set(exec_prefix "\${prefix}")
  # set(libdir "\${prefix}/${CMAKE_INSTALL_LIBDIR}")
  # set(includedir "\${prefix}/${CMAKE_INSTALL_INCLUDEDIR}")
  # set(draco_lib_name "draco")

  # configure_file("${draco_root}/cmake/draco.pc.template"
  #                "${draco_build}/draco.pc" @ONLY NEWLINE_STYLE UNIX)
  # install(FILES "${draco_build}/draco.pc"
  #         DESTINATION "${prefix}/${CMAKE_INSTALL_LIBDIR}/pkgconfig")

  # # CMake config: draco-config.cmake
  # set(DRACO_INCLUDE_DIRS "${prefix}/${CMAKE_INSTALL_INCLUDEDIR}")
  # configure_file("${draco_root}/cmake/draco-config.cmake.template"
  #                "${draco_build}/draco-config.cmake" @ONLY NEWLINE_STYLE UNIX)
  # install(
  #   FILES "${draco_build}/draco-config.cmake"
  #   DESTINATION "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/cmake")

  ### Install (https://github.com/forexample/package-example) ###
  set(generated_dir "${CMAKE_CURRENT_BINARY_DIR}/generated")

  set(config_install_dir "lib/cmake/${PROJECT_NAME}")
  set(include_install_dir "include")

  set(version_config "${generated_dir}/${PROJECT_NAME}ConfigVersion.cmake")
  set(project_config "${generated_dir}/${PROJECT_NAME}Config.cmake")
  set(targets_export_name "${PROJECT_NAME}Targets")
  set(namespace "${PROJECT_NAME}::")

  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(
    "${version_config}" COMPATIBILITY AnyNewerVersion
  )

  # Note: use 'targets_export_name'
  configure_package_config_file(
    "${draco_root}/cmake/Config.cmake.in"
    "${project_config}"
    INSTALL_DESTINATION "${config_install_dir}"
  )

  foreach(file ${draco_sources})
    if(file MATCHES "h$")
      list(APPEND draco_api_includes ${file})
    endif()
  endforeach()

  # Strip $draco_src_root from the file paths: we need to install relative to
  # $include_directory.
  list(TRANSFORM draco_api_includes REPLACE "${draco_src_root}/" "")
  set(include_directory "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}")

  foreach(draco_api_include ${draco_api_includes})
    get_filename_component(file_directory ${draco_api_include} DIRECTORY)
    set(target_directory "${include_directory}/draco/${file_directory}")
    install(FILES ${draco_src_root}/${draco_api_include}
            DESTINATION "${target_directory}")
  endforeach()

  install(
    FILES "${draco_build}/draco/draco_features.h"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR}/draco/")

  install(TARGETS draco_decoder DESTINATION
                  EXPORT "${targets_export_name}"
                  INCLUDES DESTINATION "${include_install_dir}"
                  RUNTIME DESTINATION "bin"
                  LIBRARY DESTINATION "lib"
                  ARCHIVE DESTINATION "lib")
  install(TARGETS draco_encoder DESTINATION
                  EXPORT "${targets_export_name}"
                  INCLUDES DESTINATION "${include_install_dir}"
                  RUNTIME DESTINATION "bin"
                  LIBRARY DESTINATION "lib"
                  ARCHIVE DESTINATION "lib")

  if(WIN32)
    install(TARGETS draco
                  EXPORT "${targets_export_name}"
                  INCLUDES DESTINATION "${include_install_dir}"
                  RUNTIME DESTINATION "bin"
                  LIBRARY DESTINATION "lib"
                  ARCHIVE DESTINATION "lib")
  else()
    install(TARGETS draco_static DESTINATION
                  EXPORT "${targets_export_name}"
                  INCLUDES DESTINATION "${include_install_dir}"
                  RUNTIME DESTINATION "bin"
                  LIBRARY DESTINATION "lib"
                  ARCHIVE DESTINATION "lib")
    if(BUILD_SHARED_LIBS)
      install(TARGETS draco_shared DESTINATION
                  EXPORT "${targets_export_name}"
                  INCLUDES DESTINATION "${include_install_dir}"
                  RUNTIME DESTINATION "bin"
                  LIBRARY DESTINATION "lib"
                  ARCHIVE DESTINATION "lib")
    endif()
  endif()

  if(DRACO_UNITY_PLUGIN)
    install(TARGETS dracodec_unity DESTINATION
                  EXPORT "${targets_export_name}"
                  INCLUDES DESTINATION "${include_install_dir}"
                  RUNTIME DESTINATION "bin"
                  LIBRARY DESTINATION "lib"
                  ARCHIVE DESTINATION "lib")
  endif()
  if(DRACO_MAYA_PLUGIN)
    install(TARGETS draco_maya_wrapper DESTINATION
                  EXPORT "${targets_export_name}"
                  INCLUDES DESTINATION "${include_install_dir}"
                  RUNTIME DESTINATION "bin"
                  LIBRARY DESTINATION "lib"
                  ARCHIVE DESTINATION "lib")
  endif()

  install(
    FILES "${project_config}" "${version_config}"
    DESTINATION "${config_install_dir}"
  )

  install(
    EXPORT "${targets_export_name}"
    NAMESPACE "${namespace}"
    DESTINATION "${config_install_dir}"
  )

endmacro()
