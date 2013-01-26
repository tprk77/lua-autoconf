# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#                         Compatibility Macros!
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#
# These macros provide backwards compatibility to ax_lua.m4. If you want to
# replace ax_lua.m4 in your project, you can do either of the following:
#
#   * Delete ax_lua.m4, and put ax_lua_check.m4 in your project's m4
#     directory. Update your project's configure.ac.
#
#   * Delete ax_lua.m4, and put ax_lua_check.m4 and ax_lua_compat.m4 in
#     your project's m4 directory. (Don't update configure.ac.)
#
# Backwards compatibility is not 100%. --with-lua-suffix will no longer
# exist. AX_LUA_HEADERS_VERSION is no longer necessary because the header
# version is always compared to the interpreter version.

AC_DEFUN([AX_WITH_LUA], [AX_LUA_CHECK_INTERP])
AC_DEFUN([AX_PROG_LUA], [AX_LUA_CHECK_INTERP([$1], [$2])])
AC_DEFUN([AX_LUA_HEADERS], [AX_LUA_CHECK_HEADERS])
AC_DEFUN([AX_LUA_HEADERS_VERSION], [])
AC_DEFUN([AX_LUA_LIBS], [AX_LUA_CHECK_LIBS])
