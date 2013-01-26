#include <lua.h>

int luaopen_module(lua_State * L)
{
	lua_newtable(L);
	lua_pushnumber(L, 1);
	lua_pushstring(L, "hello world");
	lua_rawset(L, -3);

	return 1;
}
