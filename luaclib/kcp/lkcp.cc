#include "ikcp.h"
extern "C" {
#include <stdio.h>
#include <string.h>

#include "lauxlib.h"
#include "lua.h"
#include "skynet.h"
#include "skynet_malloc.h"
#include "skynet_socket.h"
}

#include <iostream>
#include <queue>
#include <string>

using namespace std;

const static char *LKCP_META = "LKCP_META";

struct Kcp_message {
  int cur_len, buf_len;
  string buf;

  void reset() {
    cur_len = buf_len = 0;
    buf.clear();
    buf.shrink_to_fit();
  }
};

struct Kcp_user {
  struct skynet_context *ctx;
  int host;
  int conv;
  char address[20];
  char buf[2048];
  Kcp_message uncomplete;
  queue<string> msgs;

  void fill_data(const char *p, int len);
};

void Kcp_user::fill_data(const char *p, int len) {
  if (len <= 0) {
    return;
  }
  if (0 == uncomplete.cur_len) {
    int high = (int)(*p);
    uncomplete.buf_len += high << 8;
    uncomplete.cur_len++;
    fill_data(++p, --len);
  } else if (1 == uncomplete.cur_len) {
    int low = (int)(*p);
    uncomplete.buf_len += low;
    uncomplete.buf.resize(uncomplete.buf_len);
    uncomplete.cur_len++;
    fill_data(++p, --len);
  } else if (uncomplete.cur_len >= 2) {
    int now_buf_len = uncomplete.cur_len - 2;
    if (now_buf_len + len < uncomplete.buf_len) {
      memcpy((void *)(uncomplete.buf.c_str() + now_buf_len), p, len);
      uncomplete.cur_len += len;
    } else {
      int recv_len = uncomplete.buf_len - now_buf_len;
      memcpy((void *)(uncomplete.buf.c_str() + now_buf_len), p, recv_len);
      msgs.push(uncomplete.buf);
      uncomplete.reset();
      fill_data(p + recv_len, len - recv_len);
    }
  }
}

struct Lkcp {
  static int netpack_pop(lua_State *L);
  static int netpack_input(lua_State *L);
  static int lkcp_send(lua_State *L);
  static int lkcp_recv(lua_State *L);
  static int lkcp_update(lua_State *L);
  static int lkcp_input(lua_State *L);

  static int lkcp_gc(lua_State *L);
  static void lkcp_meta(lua_State *L);
  static int udp_output(const char *buf, int len, ikcpcb *kcp, void *user);
  static int create_lkcp(lua_State *L);

  static int lkcp_client(lua_State *L);
  static int cli_output(const char *buf, int len, ikcpcb *kcp, void *user);
};

int Lkcp::lkcp_gc(lua_State *L) {
  ikcpcb **pp = (ikcpcb **)luaL_checkudata(L, 1, LKCP_META);
  ikcpcb *p = *pp;
  delete ((Kcp_user *)(p->user));
  ikcp_release(p);
  return 0;
}

int Lkcp::lkcp_send(lua_State *L) {
  ikcpcb **pp = (ikcpcb **)luaL_checkudata(L, 1, LKCP_META);
  ikcpcb *p = *pp;
  luaL_checktype(L, 2, LUA_TSTRING);
  size_t len = 0;
  const char *str = lua_tolstring(L, 2, &len);
  ikcp_send(p, str, len);
  return 0;
}

int Lkcp::lkcp_update(lua_State *L) {
  ikcpcb **pp = (ikcpcb **)luaL_checkudata(L, 1, LKCP_META);
  ikcpcb *p = *pp;
  luaL_checktype(L, 2, LUA_TNUMBER);
  ikcp_update(p, lua_tointeger(L, 2) * 10);
  return 0;
}

int Lkcp::lkcp_input(lua_State *L) {
  ikcpcb **pp = (ikcpcb **)luaL_checkudata(L, 1, LKCP_META);
  ikcpcb *p = *pp;
  luaL_checktype(L, 2, LUA_TSTRING);
  size_t len = 0;
  const char *str = lua_tolstring(L, 2, &len);
  ikcp_input(p, str, len);
  return 0;
}

int Lkcp::lkcp_recv(lua_State *L) {
  ikcpcb **pp = (ikcpcb **)luaL_checkudata(L, 1, LKCP_META);
  ikcpcb *p = *pp;

  struct Kcp_user *pk = (struct Kcp_user *)p->user;
  int len = ikcp_recv(p, pk->buf, sizeof(pk->buf));
  if (len > 0) {
    lua_pushlstring(L, pk->buf, len);
    return 1;
  } else {
    return 0;
  }
}

int Lkcp::netpack_input(lua_State *L) {
  ikcpcb **pp = (ikcpcb **)luaL_checkudata(L, 1, LKCP_META);
  ikcpcb *p = *pp;
  luaL_checktype(L, 2, LUA_TSTRING);
  size_t slen = 0;
  const char *str = lua_tolstring(L, 2, &slen);
  ikcp_input(p, str, slen);

  Kcp_user *pk = (Kcp_user *)p->user;
  int len = ikcp_recv(p, pk->buf, sizeof(pk->buf));
  while (len > 0) {
    pk->fill_data(pk->buf, len);
    len = ikcp_recv(p, pk->buf, sizeof(pk->buf));
  }
}

int Lkcp::netpack_pop(lua_State *L) {
  ikcpcb **pp = (ikcpcb **)luaL_checkudata(L, 1, LKCP_META);
  ikcpcb *p = *pp;

  Kcp_user *pk = (Kcp_user *)p->user;
  queue<string> &msgs = pk->msgs;
  auto &un = pk->uncomplete;
  if (msgs.empty()) {
    return 0;
  } else {
    const string &str = msgs.front();
    lua_pushlstring(L, str.c_str(), str.size());
    msgs.pop();
    return 1;
  }
}

void Lkcp::lkcp_meta(lua_State *L) {
  if (luaL_newmetatable(L, LKCP_META)) {
    luaL_Reg l[] = {{"send", lkcp_send},
                    {"recv", lkcp_recv},
                    {"update", lkcp_update},
                    {"input", lkcp_input},
                    {"netpack_input", netpack_input},
                    {"netpack_pop", netpack_pop},
                    {NULL, NULL}};
    luaL_newlib(L, l);
    lua_setfield(L, -2, "__index");
    lua_pushcfunction(L, lkcp_gc);
    lua_setfield(L, -2, "__gc");
  }
  lua_setmetatable(L, -2);
}

int Lkcp::udp_output(const char *buf, int len, ikcpcb *kcp, void *user) {
  struct Kcp_user *kuser = (struct Kcp_user *)user;
  struct socket_sendbuffer sbuf;
  sbuf.id = kuser->host;
  sbuf.type = SOCKET_BUFFER_RAWPOINTER;
  sbuf.buffer = buf;
  sbuf.sz = len;
  int err = skynet_socket_udp_sendbuffer(kuser->ctx, kuser->address, &sbuf);
  return 0;
}

int Lkcp::create_lkcp(lua_State *L) {
  lua_getfield(L, LUA_REGISTRYINDEX, "skynet_context");
  struct skynet_context *ctx = (struct skynet_context *)lua_touserdata(L, -1);
  if (ctx == NULL) {
    return luaL_error(L, "Init skynet context first");
  }

  luaL_checktype(L, 1, LUA_TNUMBER);
  luaL_checktype(L, 2, LUA_TNUMBER);
  Kcp_user *kuser = new Kcp_user();
  kuser->ctx = ctx;
  int conv = lua_tointeger(L, 1);
  kuser->conv = conv;
  int host = lua_tointeger(L, 2);
  kuser->host = host;
  size_t sz = 0;
  const char *str = luaL_checklstring(L, 3, &sz);
  if (sz >= sizeof(kuser->address)) {
    return luaL_error(L, "kcp address len error");
  }
  memcpy(kuser->address, str, sz);

  ikcpcb *p = ikcp_create(conv, kuser);
  p->output = udp_output;
  // ikcp_nodelay(p, 0, 10, 0, 0);
  ikcp_nodelay(p, 2, 10, 2, 1);
  ikcpcb **pp = (ikcpcb **)lua_newuserdata(L, sizeof(p));
  *pp = p;
  lkcp_meta(L);
  return 1;
}

int Lkcp::cli_output(const char *buf, int len, ikcpcb *kcp, void *user) {
  struct Kcp_user *kuser = (struct Kcp_user *)user;
  struct socket_sendbuffer sbuf;
  sbuf.id = kuser->host;
  sbuf.type = SOCKET_BUFFER_RAWPOINTER;
  sbuf.buffer = buf;
  sbuf.sz = len;
  int err = skynet_socket_sendbuffer(kuser->ctx, &sbuf);
  return 0;
}

int Lkcp::lkcp_client(lua_State *L) {
  lua_getfield(L, LUA_REGISTRYINDEX, "skynet_context");
  struct skynet_context *ctx = (struct skynet_context *)lua_touserdata(L, -1);
  if (ctx == NULL) {
    return luaL_error(L, "Init skynet context first");
  }

  luaL_checktype(L, 1, LUA_TNUMBER);
  luaL_checktype(L, 2, LUA_TNUMBER);
  struct Kcp_user *kuser = new Kcp_user();
  kuser->ctx = ctx;
  int conv = lua_tointeger(L, 1);
  kuser->conv = conv;
  int host = lua_tointeger(L, 2);
  kuser->host = host;

  ikcpcb *p = ikcp_create(1, kuser);
  p->output = cli_output;
  ikcp_nodelay(p, 2, 10, 2, 1);
  ikcpcb **pp = (ikcpcb **)lua_newuserdata(L, sizeof(p));
  *pp = p;
  lkcp_meta(L);
  return 1;
}

static const struct luaL_Reg l[] = {{"create_lkcp", Lkcp::create_lkcp},
                                    {"lkcp_client", Lkcp::lkcp_client},
                                    {NULL, NULL}};

extern "C" {
LUAMOD_API int luaopen_lkcp(lua_State *L) {
  luaL_newlib(L, l);
  return 1;
}
}
