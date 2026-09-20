extern "C" {
#include "lauxlib.h"
}
#include <cstdint>
#include <map>
using namespace std;

static const char* SLOT = "SLOT";
struct Slot {
  map<int, int> slot_group_;

  static int find_group(lua_State* L) {
    Slot** pp = (Slot**)luaL_checkudata(L, 1, SLOT);
    int val = luaL_checkinteger(L, 2);
    Slot& slot = **pp;
    auto& slot_group = slot.slot_group_;
    auto it = slot_group.lower_bound(val);
    if (it == slot_group.end()) {
      auto bit = slot_group.begin();
      if (bit == slot_group.end()) return 0;
      lua_pushinteger(L, bit->second);
      return 1;
    } else {
      lua_pushinteger(L, it->second);
      return 1;
    }
    return 0;
  }

  static int gc(lua_State* L) {
    Slot** pp = (Slot**)luaL_checkudata(L, 1, SLOT);
    delete *pp;
    return 0;
  }

  static int create(lua_State* L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    map<int, int> cfg;
    lua_pushnil(L);
    while (0 != lua_next(L, 1)) {
      int slot = luaL_checkinteger(L, -2);
      int group = luaL_checkinteger(L, -1);
      cfg[slot] = group;
      lua_pop(L, 1);
    }
    Slot* p = new Slot();
    p->slot_group_ = std::move(cfg);
    Slot** pp = (Slot**)lua_newuserdata(L, sizeof(p));
    *pp = p;
    if (luaL_newmetatable(L, SLOT)) {
      luaL_Reg l[] = {{"find_group", find_group}, {NULL, NULL}};
      luaL_newlib(L, l);
      lua_setfield(L, -2, "__index");
      lua_pushcfunction(L, gc);
      lua_setfield(L, -2, "__gc");
    }
    lua_setmetatable(L, -2);
    return 1;
  }
};

extern "C" {
LUAMOD_API int luaopen_lgame_dbtool(lua_State* L) {
  luaL_Reg l[] = {{"create_slot", Slot::create}, {NULL, NULL}};
  luaL_newlib(L, l);
  return 1;
}
}