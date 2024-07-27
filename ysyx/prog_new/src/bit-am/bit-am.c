#include <am.h>
#include <klib.h>
#include <klib-macros.h>

typedef unsigned char uint8_t;
__attribute__((noinline))
bool getbit(void *buf, int offset){
	int byte = offset >> 3;
	offset &= 7;
	uint8_t mask = 1 << offset;
	return (((uint8_t *)buf)[byte] & mask) != 0;
}
__attribute__((noinline))
void setbit(void *buf, int offset, bool bit){
	int byte = offset >> 3;
	offset &= 7;
	uint8_t mask = 1 << offset;

	uint8_t * volatile p = buf + byte;
	*p = (bit == 0 ? (*p & ~mask) : (*p | mask));
}

int main() {
    bool pass = true;
	uint8_t buf[2];

	buf[0] = 0xaa;
	buf[1] = 0x0;
	if (!(getbit(buf, 0) == 0)) pass = false;
	if (!(getbit(buf, 1) == 1)) pass = false;
	if (!(getbit(buf, 2) == 0)) pass = false;
	if (!(getbit(buf, 3) == 1)) pass = false;
	if (!(getbit(buf, 4) == 0)) pass = false;
	if (!(getbit(buf, 5) == 1)) pass = false;
	if (!(getbit(buf, 6) == 0)) pass = false;
	if (!(getbit(buf, 7) == 1)) pass = false;

	setbit(buf, 8, 1);
	setbit(buf, 9, 0);
	setbit(buf, 10, 1);
	setbit(buf, 11, 0);
	setbit(buf, 12, 1);
	setbit(buf, 13, 0);
	setbit(buf, 14, 1);
	setbit(buf, 15, 0);
	if (!(buf[1] == 0x55)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
