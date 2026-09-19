extern "C" {
#include "lauxlib.h"
}
#include <cstdint>
#include <iostream>
#include <map>
using namespace std;

struct Slot {
  map<int, int> slot_cfg_;
};
static const char* META = "DBSLOT";

static int find_group(lua_State* L) {
  Slot** pp = (Slot**)luaL_checkudata(L, 1, META);
  int val = luaL_checkinteger(L, 2);
  Slot& slot = **pp;
  auto& cfg = slot.slot_cfg_;
  auto it = cfg.lower_bound(val);
  if (it == cfg.end()) {
    auto bit = cfg.begin();
    if (bit == cfg.end()) return 0;
    lua_pushinteger(L, bit->second);
    return 1;
  } else {
    lua_pushinteger(L, it->second);
    return 1;
  }
  return 0;
}

static int gc(lua_State* L) {
  Slot** pp = (Slot**)luaL_checkudata(L, 1, META);
  delete *pp;
  return 0;
}

static int create(lua_State* L) {
  luaL_checktype(L, 1, LUA_TTABLE);
  map<int, int> slot_cfg;
  lua_pushnil(L);
  while (lua_next(L, 1) != 0) {
    int slot = luaL_checkinteger(L, -2);
    int group = luaL_checkinteger(L, -1);
    auto [it, ok] = slot_cfg.insert({slot, group});
    if (!ok) return luaL_error(L, "dbslot create cfg err");
    lua_pop(L, 1);
  }

  Slot* p = new Slot();
  p->slot_cfg_ = std::move(slot_cfg);
  Slot** pp = (Slot**)lua_newuserdata(L, sizeof(p));
  *pp = p;
  if (luaL_newmetatable(L, META)) {
    luaL_Reg l[] = {{"find_group", find_group}, {NULL, NULL}};
    luaL_newlib(L, l);
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, gc);
    lua_setfield(L, -2, "__gc");
  }
  lua_setmetatable(L, -2);
  return 1;
}

extern "C" {
LUAMOD_API int luaopen_lgame_dbslot(lua_State* L) {
  luaL_Reg l[] = {{"create", create}, {NULL, NULL}};
  luaL_newlib(L, l);
  return 1;
}
}