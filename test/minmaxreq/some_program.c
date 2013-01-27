#include <lua.h>

#if LUA_VERSION_NUM >= 501
#include <lauxlib.h>
#endif

int main(void)
{
#if LUA_VERSION_NUM >=501
	lua_State * L = luaL_newstate();
#else
	lua_State * L = lua_open();
#endif
	lua_pushstring(L, "hello world");

	return 0;
}
