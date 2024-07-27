#include <am.h>
#include <klib.h>
#include <klib-macros.h>

unsigned test[] = {
	0x12345678, 0x98765432, 0x0, 0xeffa1000, 0x7fffffff, 0x80000000, 0x33, 0xffffffff
};

unsigned srl_ans[] = {
	0x2468ac, 0x130eca8, 0x0, 0x1dff420, 0xffffff, 0x1000000, 0x0, 0x1ffffff
};

unsigned srlv_ans[] = {
	0x1234567, 0x4c3b2a1, 0x0, 0x1dff420, 0x7fffff, 0x400000, 0x0, 0x1fffff
};

unsigned srav_ans[] = {
	0x1234567, 0xfcc3b2a1, 0x0, 0xffdff420, 0x7fffff, 0xffc00000, 0x0, 0xffffffff
};


int main() {
    bool pass = true;
	unsigned i;

	for(i = 0; i < LENGTH(test); i ++) {
		if (!((test[i] >> 7) == srl_ans[i])) pass = false;
	}

	for(i = 0; i < LENGTH(test); i ++) {
		if (!((unsigned)((int)test[i] >> (i + 4)) == srav_ans[i])) pass = false;
	}

	for(i = 0; i < LENGTH(test); i ++) {
		if (!((test[i] >> (i + 4)) == srlv_ans[i])) pass = false;
	}

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
