#include <am.h>
#include <klib.h>
#include <klib-macros.h>

int ans[] = {6, 28};

int main() {
    bool pass = true;
	int n, sum, i, k = 0;
	for(n = 1; n < 30; n ++) {
		sum = 0;
		for(i = 1; i < n; i ++) {
			if(n % i == 0) {
				sum += i;
			}
		}

		if(sum == n) {
			if (!(n == ans[k])) pass = false;
			k ++;
		}
	}

	if (!(k == 2)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
