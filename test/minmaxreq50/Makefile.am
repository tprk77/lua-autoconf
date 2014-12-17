ACLOCAL_AMFLAGS = -I m4

lua_SCRIPTS = some_script.lua

luaexec_LTLIBRARIES = some_module.la

bin_PROGRAMS = some_program

some_module_la_SOURCES = some_module.c
some_module_la_LDFLAGS = -module -avoid-version
some_module_la_CPPFLAGS = @LUA_INCLUDE@
some_module_la_LIBADD = @LUA_LIB@

some_program_SOURCES = some_program.c
some_program_CPPFLAGS = @LUA_INCLUDE@
some_program_LDADD = @LUA_LIB@
