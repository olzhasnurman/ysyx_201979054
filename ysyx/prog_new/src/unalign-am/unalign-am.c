#include <am.h>
#include <klib.h>
#include <klib-macros.h>

volatile unsigned x = 0xffffffff;
volatile unsigned char buf[16];

int main() {
    bool pass = true;

	for(int i = 0; i < 4; i++) {
		*((volatile unsigned*)(buf + 3)) = 0xaabbccdd;

		x = *((volatile unsigned*)(buf + 3));
		if (!(x == 0xaabbccdd)) pass = false;

		buf[0] = buf[1] = 0;
	}

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
