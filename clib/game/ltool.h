#ifndef __LTOOL_H__
#define __LTOOL_H__

#include <cstdint>
#include <string>
#include <string_view>

struct Ltool {
  static uint16_t crc16(const unsigned char *buf, size_t len);
  static bool zstd_compress(std::string_view str, std::string& ret, int level);
  static bool zstd_decompress(std::string_view str, std::string& ret);
};

#endif