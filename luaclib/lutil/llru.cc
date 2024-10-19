extern "C" {
#include "lauxlib.h"
#include "lua.h"
}

#include "lru.hpp"
static const char *LLRU_META = "LLRU_META";

struct Llru {
  static int update(lua_State *L);
  static int set_size(lua_State *L);
  static int dump(lua_State *L);

  static int lru_gc(lua_State *L);
  static void lru_meta(lua_State *L);
  static int create_lru(lua_State *L);
};

int Llru::dump(lua_State *L) {
  auto pp = (Lru **)luaL_checkudata(L, 1, LLRU_META);
  auto &lru = **pp;

  string s;
  lru.dump(s);
  lua_pushlstring(L, s.c_str(), s.size());
  return 1;
}

int Llru::update(lua_State *L) {
  auto pp = (Lru **)luaL_checkudata(L, 1, LLRU_META);
  luaL_checktype(L, 2, LUA_TSTRING);
  auto &lru = **pp;

  size_t len;
  const char *p = lua_tolstring(L, 2, &len);
  string evict;

  bool b = lru.update({p, len}, evict);
  if (b) {
    lua_pushlstring(L, evict.c_str(), evict.size());
    return 1;
  }

  return 0;
}

int Llru::set_size(lua_State *L) {
  auto pp = (Lru **)luaL_checkudata(L, 1, LLRU_META);
  luaL_checktype(L, 2, LUA_TNUMBER);
  auto &lru = **pp;

  int size = lua_tointeger(L, 2);
  lru.cache_size_ = size;
  return 0;
}

int Llru::lru_gc(lua_State *L) {
  auto pp = (Lru **)luaL_checkudata(L, 1, LLRU_META);
  delete *pp;
  return 0;
}

void Llru::lru_meta(lua_State *L) {
  if (luaL_newmetatable(L, LLRU_META)) {
    luaL_Reg l[] = {
        {"update", update},
        {"set_size", set_size},
        {"dump", dump},
        {NULL, NULL},
    };
    luaL_newlib(L, l);
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, lru_gc);
    lua_setfield(L, -2, "__gc");
  }
  lua_setmetatable(L, -2);
}

int Llru::create_lru(lua_State *L) {
  auto p = new Lru();
  auto pp = (Lru **)lua_newuserdata(L, sizeof(p));
  *pp = p;
  lru_meta(L);
  lua_settop(L, 1);
  return 1;
}

static const struct luaL_Reg funcs[] = {{"create_lru", Llru::create_lru},
                                        {NULL, NULL}};

extern "C" {
LUAMOD_API int luaopen_lutil_lru(lua_State *L) {
  luaL_newlib(L, funcs);
  return 1;
}
}