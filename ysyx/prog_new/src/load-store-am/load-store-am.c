#include <am.h>
#include <klib.h>
#include <klib-macros.h>

unsigned short mem[] = {
	0x0, 0x0258, 0x4abc, 0x7fff, 0x8000, 0x8100, 0xabcd, 0xffff
};

unsigned lh_ans[] = {
	0x00000000, 0x00000258, 0x00004abc, 0x00007fff, 0xffff8000, 0xffff8100, 0xffffabcd, 0xffffffff
};

unsigned lhu_ans[] = {
	0x00000000, 0x00000258, 0x00004abc, 0x00007fff, 0x00008000, 0x00008100, 0x0000abcd, 0x0000ffff
};

unsigned  sh_ans[] = {
	0x0000fffd, 0x0000fff7, 0x0000ffdf, 0x0000ff7f, 0x0000fdff, 0x0000f7ff, 0x0000dfff, 0x00007fff
};

unsigned  lwlr_ans[] = {
	0xbc025800, 0x7fff4a, 0xcd810080, 0xffffab
};

int main() {
    bool pass = true;
	unsigned i;

	for(i = 0; i < LENGTH(mem); i ++) {
		if (!((short)mem[i] == lh_ans[i])) pass = false;
	}

	for(i = 0; i < LENGTH(mem); i ++) {
		if (!(mem[i] == lhu_ans[i])) pass = false;
	}

	for(i = 0; i < ((LENGTH(mem) / 2) - 1); i ++) {
		unsigned x = ((unsigned*)((void*)mem + 1))[i];
		if (!(x == lwlr_ans[i])) pass = false;
	}

	for(i = 0; i < LENGTH(mem); i ++) {
		mem[i] = ~(1 << (2 * i + 1));
		if (!(mem[i] == sh_ans[i])) pass = false;
	}

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
