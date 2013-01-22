# ===========================================================================
#                               ax_lua2.m4
# ===========================================================================
#
# SYNOPSIS
#
#   AX_PATH_LUA([MINIMUM-VERSION], [TOO-BIG-VERSION],
#               [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
#   AX_CHECK_LUA_HEADERS([ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
#   AX_CHECK_LUA_LIBS([ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
#
# DESCRIPTION
#
#   Detect a Lua interpreter, optionally specifying a minimum and maximum
#   version number. Set up important Lua paths, such as the directories in
#   which to install scripts and modules (shared libraries).
#
#   Also detect Lua headers and libraries. The Lua version contained in the
#   header is checked to match the Lua interpreter version exactly. When
#   searching for Lua libraries, the version number is used as a suffix. This
#   is done with the goal of supporting multiple Lua installs (5.1 and 5.2
#   side-by-side).
#
#
#   AX_PATH_LUA([MINIMUM-VERSION], [TOO-BIG-VERSION],
#               [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
#   -----------------------------------------------------
#
#   Search for the Lua interpreter, and set up important Lua paths.
#   Adds precious variable LUA, which may contain the path of the Lua
#   interpreter. If LUA is blank, the user's path is searched for an
#   suitable interpreter. The Lua version number LUA_VERSION if found from
#   the interpreter, and substituted. LUA_PLATFORM is also found, but not
#   currently supported (no standard representation).
#
#   LUA_PREFIX is set to '${prefix}', and LUA_EXEC_PREFIX is set to
#   '${exec_prefix}'. These variables can be overwritten, but should probably
#   be left alone. These are not precious variables.
#
#   Finally, the macro finds four paths:
#
#     luadir             Directory to install Lua scripts.
#     pkgluadir          ${luadir}/$PACKAGE
#     luaexecdir         Directory to install Lua modules.
#     pkgluaexecdir      ${luaexecdir}/$PACKAGE
#
#   These paths a found based on $prefix, $exec_prefix, Lua's package.path,
#   and package.cpath. The first path of package.path beginning with $prefix
#   is selected as luadir. The first path of package.cpath beginning with
#   $exec_prefix is used as luaexecdir. This should work on all reasonable
#   Lua installations. If a path cannot be determined, a default path is
#   used. Of course, the user can override these later when invoking make.
#
#     luadir             Default: $LUA_PREFIX/share/lua/$LUA_VERSION
#     luaexecdir         Default: $LUA_EXEC_PREFIX/lib/lua/$LUA_VERSION
#
#
#   AX_CHECK_LUA_HEADERS([ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
#   --------------------------------------------------------------
#
#   Search for Lua headers. Requires AX_LUA_PATH, and will expand that macro
#   as necessary. Adds precious variable LUA_INCLUDES, which may contain
#   Lua specific include flags, e.g. -I/usr/include/lua5.1. If LUA_INCLUDES
#   is blank, and the headers cannot be found, then some common directories
#   are searched. If headers are then found, then LUA_INCLUDES is set to the
#   result.
#
#
#   AX_CHECK_LUA_LIBS([ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
#   -----------------------------------------------------------
#
#   Search for Lua libraries. Requires AX_LUA_PATH, and will expand that
#   macro as necessary. Adds precious variable LUA_LIBS, which may contain
#   Lua specific linker flags, e.g. -llua5.1. If LUA_LIBS is blank, then some
#   common flags are tested. If the link test succeeds, then LUA_INCLUDES is
#   set to the result.
#
#
# LICENSE
#
#   Copyright (C) 2012 Tim Perkins 2013 <tprk77@gmail.com>
#
#   This program is free software: you can redistribute it and/or modify it
#   under the terms of the GNU General Public License as published by the
#   Free Software Foundation, either version 3 of the License, or (at your
#   option) any later version.
#
#   This program is distributed in the hope that it will be useful, but
#   WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
#   Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program. If not, see <http://www.gnu.org/licenses/>.
#
#   As a special exception, the respective Autoconf Macro's copyright owner
#   gives unlimited permission to copy, distribute and modify the configure
#   scripts that are the output of Autoconf when processing the Macro. You
#   need not follow the terms of the GNU General Public License when using
#   or distributing such scripts, even though portions of the text of the
#   Macro appear in them. The GNU General Public License (GPL) does govern
#   all other use of the material that constitutes the Autoconf Macro.
#
#   This special exception to the GPL applies to versions of the Autoconf
#   Macro released by the Autoconf Archive. When you make and distribute a
#   modified version of the Autoconf Macro, you may extend this special
#   exception to the GPL to apply to your modified version as well.
#
# THANKS
#
#   This file was inspired by Andrew Dalke's and James Henstridge's python.m4
#   and Tom Payne's, Matthieu Moy's, and Reuben Thomas's ax_lua.m4 (serial
#   17). Basically, this file is a mashup of those two files. I like to think
#   it combines the best of the two!


dnl =========================================================================
dnl AX_PATH_LUA([MINIMUM-VERSION], [TOO-BIG-VERSION],
dnl             [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
dnl =========================================================================
dnl
dnl Adds support for distributing Lua modules and packages. To
dnl install modules, copy them to $(luadir), using the lua_???
dnl automake variable.  To install a package with the same name as the
dnl automake package, install to $(pkgluadir), or use the
dnl pkglua_??? automake variable.
dnl
dnl ??? would SCRIPTS work?
dnl
dnl The variables $(luaexecdir) and $(pkgluaexecdir) are provided as
dnl locations to install Lua extension modules (shared libraries).
dnl Another macro is required to find the appropriate flags to compile
dnl extension modules.
dnl
dnl If your package is configured with a different prefix to Lua,
dnl users will have to add the install directory to the LUA_PATH
dnl environment variable.
dnl
dnl If the MINIMUM-VERSION argument is passed, AX_PATH_LUA will
dnl cause an error if the version of Lua installed on the system
dnl doesn't meet the requirement.  MINIMUM-VERSION should consist of
dnl numbers and dots only. If the TOO-BIG-VERSION argument is
dnl passed in addition to the MINIMUM-VERSION argument, then that
dnl requirement will also be checked.
dnl
AC_DEFUN([AX_PATH_LUA], [_AX_LUA_PATH([$1], [$2], [$3], [$4])])


dnl =========================================================================
dnl _AX_LUA_PATH([MINIMUM-VERSION], [TOO-BIG-VERSION],
dnl              [ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
dnl =========================================================================
dnl
dnl Does the work of AX_PATH_LUA. This macro is used so that requisites
dnl work as expected. This macro is an implementation detail, and should not
dnl be used directly.
dnl
AC_DEFUN([_AX_LUA_PATH],
[
  dnl Make LUA a precious variable.
  AC_ARG_VAR([LUA], [The Lua interpreter, e.g. /usr/bin/lua5.1])

  dnl Find a Lua interpreter.
  m4_define_default([_AX_LUA_INTERPRETER_LIST],
    [lua lua5.2 lua5.1 lua50])

  m4_if([$1], [],
  [ dnl No version check is needed. Find any Lua interpreter.
    AS_IF([test "x$LUA" = 'x'],
      [AC_PATH_PROGS([LUA], [_AX_LUA_INTERPRETER_LIST], [:])])
    ax_display_LUA='lua'

    dnl At least check if this is a Lua interpreter.
    AC_MSG_CHECKING([if $LUA is a Lua interprester])
    _AX_CHECK_LUA([$LUA],
      [AC_MSG_RESULT([yes])],
      [ AC_MSG_RESULT([no])
        AC_MSG_ERROR([not a Lua interpreter])
      ])
  ],
  [ dnl A version check is needed.
    AS_IF([test "x$LUA" != 'x'],
    [ dnl Check if this is a Lua interpreter.
      AC_MSG_CHECKING([if $LUA is a Lua interprester])
      _AX_CHECK_LUA([$LUA],
        [AC_MSG_RESULT([yes])],
        [ AC_MSG_RESULT([no])
          AC_MSG_ERROR([not a Lua interpreter])
        ])
      dnl Check the version.
      m4_if([$2], [],
        [_ax_check_text="whether $LUA version >= $1"],
        [_ax_check_text="whether $LUA version >= $1, < $2"])
      AC_MSG_CHECKING([$_ax_check_text])
      _AX_CHECK_VERSION([$LUA], [$1], [$2],
        [AC_MSG_RESULT([yes])],
        [ AC_MSG_RESULT([no])
          AC_MSG_ERROR([version is out of range for specified LUA])])
      ax_display_LUA=$LUA
    ],
    [ dnl Try each interpreter until we find one that satisfies VERSION.
      m4_if([$2], [],
        [_ax_check_text="for a Lua interpreter with version >= $1"],
        [_ax_check_text="for a Lua interpreter with version >= $1, < $2"])
      AC_CACHE_CHECK([$_ax_check_text],
        [ax_cv_pathless_LUA],
        [ for ax_cv_pathless_LUA in _AX_LUA_INTERPRETER_LIST none; do
            test "x$ax_cv_pathless_LUA" = 'xnone' && break
            _AX_CHECK_LUA([$ax_cv_pathless_LUA], [], [continue])
            _AX_CHECK_VERSION([$ax_cv_pathless_LUA], [$1], [$2], [break])
          done
        ])
      dnl Set $LUA to the absolute path of $ax_cv_pathless_LUA.
      AS_IF([test "x$ax_cv_pathless_LUA" = 'xnone'],
        [LUA=':'],
        [AC_PATH_PROG([LUA], [$ax_cv_pathless_LUA])])
      ax_display_LUA=$ax_cv_pathless_LUA
    ])
  ])

  AS_IF([test "x$LUA" = 'x:'],
  [ dnl Run any user-specified action, or abort.
    m4_default([$4], [AC_MSG_ERROR([cannot find suitable Lua interpreter])])
  ],
  [ dnl Query Lua for its version number.
    AC_CACHE_CHECK([for $ax_display_LUA version], [ax_cv_lua_version],
      [ ax_cv_lua_version=`$LUA -e "print(_VERSION)" | \
          sed "s|^Lua \(.*\)|\1|" | \
          grep -o "^@<:@0-9@:>@\+\\.@<:@0-9@:>@\+"`
      ])
    AS_IF([test "x$ax_cv_lua_version" = 'x'],
      [AC_MSG_ERROR([invalid Lua version number])])
    AC_SUBST([LUA_VERSION], [$ax_cv_lua_version])
    AC_SUBST([LUA_SHORT_VERSION], [`echo "$LUA_VERSION" | sed 's|\.||'`])

    dnl Not supported: {{{
    dnl At times (like when building shared libraries) you may want
    dnl to know which OS platform Lua thinks this is.
    AC_CACHE_CHECK([for $ax_display_LUA platform], [ax_cv_lua_platform],
      [ax_cv_lua_platform=`$LUA -e "print('unknown')"`])
    AC_SUBST([LUA_PLATFORM], [$ax_cv_lua_platform])
    dnl }}}

    dnl Use the values of $prefix and $exec_prefix for the corresponding
    dnl values of LUA_PREFIX and LUA_EXEC_PREFIX.  These are made
    dnl distinct variables so they can be overridden if need be.  However,
    dnl general consensus is that you shouldn't need this ability.
    AC_SUBST([LUA_PREFIX], ['${prefix}'])
    AC_SUBST([LUA_EXEC_PREFIX], ['${exec_prefix}'])

    dnl Set up 4 directories:

    dnl luadir -- where to install Lua scripts.
    dnl Lua provides no way to query this directly, and instead provides
    dnl LUAPATH.  However, we should be able to make a safe educated
    dnl guess.  If the builtin search path contains a directory which
    dnl is prefixed by $prefix, then we can store scripts there. The
    dnl first matching path will be used.
    AC_CACHE_CHECK([for $ax_display_LUA script directory],
      [ax_cv_lua_luadir],
      [ AS_IF([test "x$prefix" = 'xNONE'],
          [ax_lua_prefix=$ac_default_prefix],
          [ax_lua_prefix=$prefix])

        dnl Initialize to the default path.
        ax_cv_lua_luadir="$LUA_PREFIX/share/lua/$LUA_VERSION"

        dnl Try to find a path with the prefix.
        _AX_LUA_FIND_PREFIXED_PATH([$LUA], [$ax_lua_prefix], [package.path])
        AS_IF([test "x$ax_lua_prefixed_path" != 'x'],
        [ dnl Fix the prefix.
          _ax_strip_prefix=`echo "$ax_lua_prefix" | sed 's|.|.|g'`
          ax_cv_lua_luadir=`echo "$ax_lua_prefixed_path" | \
            sed "s,^$_ax_strip_prefix,$LUA_PREFIX,"`
        ])
      ])
    AC_SUBST([luadir], [$ax_cv_lua_luadir])

    dnl pkgluadir -- $PACKAGE directory under luadir.
    AC_SUBST([pkgluadir], [\${luadir}/$PACKAGE])

    dnl luaexecdir -- directory for installing Lua modules.
    dnl Lua provides no way to query this directly, and instead provides
    dnl LUAPATH.  However, we should be able to make a safe educated
    dnl guess.  If the builtin search path contains a directory which
    dnl is prefixed by $prefix, then we can store modules there. The
    dnl first matching path will be used.
    AC_CACHE_CHECK([for $ax_display_LUA module directory],
      [ax_cv_lua_luaexecdir],
      [ AS_IF([test "x$exec_prefix" = 'xNONE'],
          [ax_lua_exec_prefix=$ax_lua_prefix],
          [ax_lua_exec_prefix=$exec_prefix])

        dnl Initialize to the default path.
        ax_cv_lua_luaexecdir="$LUA_EXEC_PREFIX/lib/lua/$LUA_VERSION"

        dnl Try to find a path with the prefix.
        _AX_LUA_FIND_PREFIXED_PATH([$LUA],
          [$ax_lua_exec_prefix], [package.cpathd])
        AS_IF([test "x$ax_lua_prefixed_path" != 'x'],
        [ dnl Fix the prefix.
          _ax_strip_prefix=`echo "$ax_lua_exec_prefix" | sed 's|.|.|g'`
          ax_cv_lua_luaexecdir=`echo "$ax_lua_prefixed_path" | \
            sed "s,^$_ax_strip_prefix,$LUA_EXEC_PREFIX,"`
        ])
      ])
    AC_SUBST([luaexecdir], [$ax_cv_lua_luaexecdir])

    dnl pkgluaexecdir -- $(luaexecdir)/$(PACKAGE)
    AC_SUBST([pkgluaexecdir], [\${luaexecdir}/$PACKAGE])

    dnl Run any user-specified action.
    $3
  ])
])


dnl =========================================================================
dnl _AX_CHECK_LUA(PROG, [ACTION-IF-TRUE], [ACTION-IF-FALSE])
dnl =========================================================================
dnl
dnl Run ACTION-IF-TRUE if PROG is a Lua interpreter, or else run
dnl ACTION-IF-FALSE otherwise. This macro is an implementation detail, and
dnl should not be used directly.
dnl
AC_DEFUN([_AX_CHECK_LUA],
[
  AS_IF([$1 -e "print('Hello ' .. _VERSION .. '!')" &>/dev/null],
    [$2], [$3])
])

dnl =========================================================================
dnl _AX_CHECK_VERSION(PROG, MINIMUM-VERSION, [TOO-BIG-VERSION],
dnl                   [ACTION-IF-TRUE], [ACTION-IF-FALSE])
dnl =========================================================================
dnl
dnl Run ACTION-IF-TRUE if the Lua interpreter PROG has version >= VERSION.
dnl Run ACTION-IF-FALSE otherwise. This macro is an implementation detail,
dnl and should not be used directly.
dnl
AC_DEFUN([_AX_CHECK_VERSION],
[
  _ax_test_ver=`$1 -e "print(_VERSION)" 2>/dev/null | \
    sed "s|^Lua \(.*\)|\1|" | grep -o "^@<:@0-9@:>@\+\\.@<:@0-9@:>@\+"`
  AS_IF([test "x$_ax_test_ver" = 'x'],
    [_ax_test_ver='0'])
  AX_COMPARE_VERSION([$_ax_test_ver], [ge], [$2])
  m4_if([$3], [], [],
    [ AS_IF([$ax_compare_version],
        [AX_COMPARE_VERSION([$_ax_test_ver], [lt], [$3])])
    ])
  AS_IF([$ax_compare_version], [$4], [$5])
])


dnl =========================================================================
dnl _AX_LUA_FIND_PREFIXED_PATH(PROG, PREFIX, LUA-PATH-VARIABLE)
dnl =========================================================================
dnl
dnl Invokes the Lua interpreter PROG to print the path variable
dnl LUA-PATH-VARIABLE, usually package.path or package.cpath. Paths are then
dnl matched against PREFIX. The first path to begin with PREFIX is set to
dnl ax_lua_prefixed_path. This macro is an implementation detail, and should
dnl not be used directly.
dnl
AC_DEFUN([_AX_LUA_FIND_PREFIXED_PATH],
[
  ax_lua_prefixed_path=''
  _ax_package_paths=`$1 -e 'print($3)' 2>/dev/null | sed 's|;|\n|g'`
  dnl Try the paths in order, looking for the prefix.
  for _ax_package_path in $_ax_package_paths; do
    dnl Copy the path, up to the use of a Lua wildcard.
    _ax_path_parts=`echo "$_ax_package_path" | sed 's|/|\n|g'`
    _ax_reassembled=''
    for _ax_path_part in $_ax_path_parts; do
      echo "$_ax_path_part" | grep '\?' >/dev/null && break
      _ax_reassembled="$_ax_reassembled/$_ax_path_part"
    done
    dnl Check the path against the prefix.
    _ax_package_path=$_ax_reassembled
    if echo "$_ax_package_path" | grep "^$2" >/dev/null; then
      dnl Found it.
      ax_lua_prefixed_path=$_ax_package_path
      break
    fi
  done
])


dnl =========================================================================
dnl AX_CHECK_LUA_HEADERS([ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
dnl =========================================================================
dnl
dnl Look for Lua headers. Always check if the Lua version in the headers
dnl matches the interpreter's version. The search is performed with the
dnl precious variable LUA_INCLUDES. If LUA_INCLUDES is blank, and the Lua
dnl headers cannot be found, then they will be searched for in the following
dnl locations:
dnl
dnl   * /usr/include/luaX.Y
dnl   * /usr/include/lua/X.Y
dnl   * /usr/include/luaXY
dnl   * /usr/local/include/luaX.Y
dnl   * /usr/local/include/lua/X.Y
dnl   * /usr/local/include/luaXY
dnl
dnl Where X.Y is the Lua version number, e.g. 5.1. If the search is
dnl successful, then the result is stored in LUA_INCLUDES.
dnl
dnl If the Lua headers are found, then ACTION-IF-FOUND is performed,
dnl otherwise ACTION-IF-NOT-FOUND is pereformed instead.
dnl
AC_DEFUN([AX_CHECK_LUA_HEADERS],
[
  dnl Requires LUA_VERSION from AX_PATH_LUA.
  AC_REQUIRE([_AX_LUA_PATH])

  dnl Check for LUA_VERSION.
  AC_MSG_CHECKING([if LUA_VERSION is defined])
  AS_IF([test "x$LUA_VERSION" != 'x'],
    [AC_MSG_RESULT([yes])],
    [ AC_MSG_RESULT([no])
      AC_MSG_ERROR([cannot check Lua headers without knowing LUA_VERSION])
    ])

  dnl Make LUA_INCLUDES a precious variable.
  AC_ARG_VAR([LUA_INCLUDES], [The Lua includes, e.g. -I/usr/include/lua5.1])

  dnl Some default directories to search.
  LUA_SHORT_VERSION=`echo "$LUA_VERSION" | sed 's|\.||'`
  m4_define_default([_AX_LUA_INCLUDES_LIST],
    [ /usr/include/lua$LUA_VERSION \
      /usr/include/lua/$LUA_VERSION \
      /usr/include/lua$LUA_SHORT_VERSION \
      /usr/local/include/lua$LUA_VERSION \
      /usr/local/include/lua/$LUA_VERSION \
      /usr/local/include/lua$LUA_SHORT_VERSION \
    ])

  dnl Try to find the headers.
  _ax_lua_saved_cppflags=$CPPFLAGS
  CPPFLAGS="$CPPFLAGS $LUA_INCLUDES"
  AC_CHECK_HEADERS([lua.h lualib.h lauxlib.h luaconf.h])
  CPPFLAGS=$_ax_lua_saved_cppflags

  dnl Try some other directories if LUA_INCLUDES was not set.
  AS_IF([test "x$LUA_INCLUDES" = 'x' &&
         test "x$ac_cv_header_lua_h" != 'xyes'],
    [ dnl Try some common include paths.
      for _ax_include_path in _AX_LUA_INCLUDES_LIST; do
        test ! -d "$_ax_include_path" && continue

        AC_MSG_CHECKING([for Lua headers in])
        AC_MSG_RESULT([$_ax_include_path])

        AS_UNSET([ac_cv_header_lua_h])
        AS_UNSET([ac_cv_header_lualib_h])
        AS_UNSET([ac_cv_header_lauxlib_h])
        AS_UNSET([ac_cv_header_luaconf_h])

        _ax_lua_saved_cppflags=$CPPFLAGS
        CPPFLAGS="$CPPFLAGS -I$_ax_include_path"
        AC_CHECK_HEADERS([lua.h lualib.h lauxlib.h luaconf.h])
        CPPFLAGS=$_ax_lua_saved_cppflags

        AS_IF([test "x$ac_cv_header_lua_h" = 'xyes'],
          [ LUA_INCLUDES="-I$_ax_include_path"
            break
          ])
      done
    ])

  AS_IF([test "x$ac_cv_header_lua_h" = 'xyes'],
    [ dnl Make a program to print LUA_VERSION defined in the header.
      dnl This probably shouldn't be a runtime test. Use grep CPP instead?

      AC_CACHE_CHECK([for Lua header version],
        [ax_cv_lua_header_version],
        [ _ax_lua_saved_cppflags=$CPPFLAGS
          CPPFLAGS="$CPPFLAGS $LUA_INCLUDES"
          AC_RUN_IFELSE(
            [ AC_LANG_SOURCE([[
#include <lua.h>
#include <stdlib.h>
#include <stdio.h>
int main(int argc, char ** argv)
{
  if(argc > 1) printf("%s", LUA_VERSION);
  exit(EXIT_SUCCESS);
}
]])
            ],
            [ ax_cv_lua_header_version=`./conftest$EXEEXT p | \
                sed "s|^Lua \(.*\)|\1|" | \
                grep -o "^@<:@0-9@:>@\+\\.@<:@0-9@:>@\+"`
            ],
            [ax_cv_lua_header_version='unknown'])
          CPPFLAGS=$_ax_lua_saved_cppflags
        ])

      dnl Compare this to the previously found LUA_VERSION.
      AC_MSG_CHECKING([if Lua header version matches $LUA_VERSION])
      AS_IF([test "x$ax_cv_lua_header_version" = "x$LUA_VERSION"],
        [ AC_MSG_RESULT([yes])
          ax_header_version_match='yes'
        ],
        [ AC_MSG_RESULT([yes])
          ax_header_version_match='no'
        ])
    ])

  dnl Was LUA_INCLUDES specified?
  AS_IF([test "x$ax_header_version_match" != 'xyes' &&
         test "x$LUA_INCLUDES" != 'x'],
    [AC_MSG_ERROR([cannot find headers for specified LUA_INCLUDES])])

  dnl Test the final result and run user code.
  AS_IF([test "x$ax_header_version_match" = 'xyes'], [$1],
    [m4_default([$2], [AC_MSG_ERROR([cannot find Lua includes])])])
])


dnl =========================================================================
dnl AX_CHECK_LUA_LIBS([ACTION-IF-FOUND], [ACTION-IF-NOT-FOUND])
dnl =========================================================================
dnl
dnl Look for Lua libaries. The search is performed with the precious variable
dnl LUA_LIBS. If LUA_LIBS is blank, then a search is performed with the
dnl following list of libraries: lua, luaX.Y, luaXY. Where X.Y is the Lua
dnl version number, e.g. 5.1. This search also looks for libm and libdl. If
dnl the search is successful, then the result is stored in LUA_LIBS.
dnl
dnl If the Lua libs are found, then ACTION-IF-FOUND is performed,
dnl otherwise ACTION-IF-NOT-FOUND is pereformed instead.
dnl
AC_DEFUN([AX_CHECK_LUA_LIBS],
[
  dnl Requires LUA_VERSION from AX_PATH_LUA.
  AC_REQUIRE([_AX_LUA_PATH])

  dnl Check for LUA_VERSION.
  AC_MSG_CHECKING([if LUA_VERSION is defined])
  AS_IF([test "x$LUA_VERSION" != 'x'],
    [AC_MSG_RESULT([yes])],
    [ AC_MSG_RESULT([no])
      AC_MSG_ERROR([cannot check Lua libs without knowing LUA_VERSION])
    ])

  dnl Make LUA_LIBS a precious variable.
  AC_ARG_VAR([LUA_LIBS], [The Lua library, e.g. -llua5.1])

  AS_IF([test "x$LUA_LIBS" != 'x'],
  [ dnl Try to find the Lua libs.
    _ax_lua_saved_libs=$LIBS
    LIBS="$LIBS $LUA_LIBS"
    AC_SEARCH_LIBS([lua_load], [],
      [_ax_found_lua_libs='yes'],
      [_ax_found_lua_libs='no'])
    LIBS=$_ax_lua_saved_libs

    dnl Check the result.
    AS_IF([test "x$_ax_found_lua_libs" != 'xyes'],
      [AC_MSG_ERROR([cannot find libs for specified LUA_LIBS])])
  ],
  [ dnl First search for extra libs.
    _ax_lua_extra_libs=''

    _ax_lua_saved_libs=$LIBS
    LIBS="$LIBS $LUA_LIBS"
    AC_SEARCH_LIBS([exp], [m])
    AC_SEARCH_LIBS([dlopen], [dl])
    LIBS=$_ax_lua_saved_libs

    AS_IF([test "x$ac_cv_search_exp" != 'xno' &&
           test "x$ac_cv_search_exp" != 'xnone required'],
      [_ax_lua_extra_libs="$_ax_lua_extra_libs $ac_cv_search_exp"])

    AS_IF([test "x$ac_cv_search_dlopen" != 'xno' &&
           test "x$ac_cv_search_dlopen" != 'xnone required'],
      [_ax_lua_extra_libs="$_ax_lua_extra_libs $ac_cv_search_dlopen"])

    dnl Try to find the Lua libs.
    _ax_lua_saved_libs=$LIBS
    LIBS="$LIBS $LUA_LIBS"
    AC_SEARCH_LIBS([lua_load], [lua$LUA_VERSION lua$LUA_SHORT_VERSION lua],
      [_ax_found_lua_libs='yes'],
      [_ax_found_lua_libs='no'],
      [$_ax_lua_extra_libs])
    LIBS=$_ax_lua_saved_libs

    AS_IF([test "x$ac_cv_search_lua_load" != 'xno' &&
           test "x$ac_cv_search_lua_load" != 'xnone required'],
      [LUA_LIBS="$ac_cv_search_lua_load $_ax_lua_extra_libs"])
  ])

  dnl Test the result and run user code.
  AS_IF([test "x$_ax_found_lua_libs" = 'xyes'], [$1],
    [m4_default([$2], [AC_MSG_ERROR([cannot find Lua libs])])])
])
