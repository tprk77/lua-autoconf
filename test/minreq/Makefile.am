ACLOCAL_AMFLAGS = -I m4

lua_SCRIPTS = some_script.lua

luaexec_LTLIBRARIES = some_module.la

some_module_la_SOURCES = some_module.c
some_module_la_LDFLAGS = -module -avoid-version
some_module_la_CPPFLAGS = @LUA_INCLUDE@
some_module_la_LIBADD = @LUA_LIB@
