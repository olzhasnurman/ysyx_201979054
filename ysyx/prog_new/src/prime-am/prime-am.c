#include <am.h>
#include <klib.h>
#include <klib-macros.h>

int ans[] = {101, 103, 107, 109, 113, 127, 131, 137, 139, 149};

int main() {
    bool pass = true;
	int m, i, n = 0;
	int prime;
	for(m = 101; m <= 150; m += 2) {
		prime = 1;
		for(i = 2; i < m; i ++) {
			if(m % i == 0) {
				prime = 0;
				break;
			}
		}
		if(prime) {
			if (!(i == ans[n])) pass = false;
			n ++;
		}
	}

	if (!(n == 10)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
