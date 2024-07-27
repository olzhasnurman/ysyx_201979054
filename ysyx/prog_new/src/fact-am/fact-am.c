#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define ADDR 0x80400000

int ans[] = {1, 1, 2, 6, 24, 120, 720, 5040, 40320, 362880, 3628800, 39916800, 479001600};
int* f = (int*) ADDR;


int fact(int n) {
	if(n == 0 || n == 1) return 1;
	else return fact(n - 1) * n;
}

int main() {
	bool pass = true;
	int i;
	for(i = 0; i < 13; i ++) {
		f[i] = fact(i);
		if (!(f[i] == ans[i])) pass = false;
	}

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}

