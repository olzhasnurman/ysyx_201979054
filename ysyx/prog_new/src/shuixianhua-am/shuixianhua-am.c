#include <am.h>
#include <klib.h>
#include <klib-macros.h>

int ans[] = {153, 370, 371, 407};

int cube(int n) {
	return n * n * n;
}

int main() {
    bool pass = true;
	int n, n2, n1, n0;
	int k = 0;
	for(n = 100; n < 500; n ++) {
		n2 = n / 100;
		n1 = (n / 10) % 10;
		n0 = n % 10;

		if(n == cube(n2) + cube(n1) + cube(n0)) {
			if (!(n == ans[k])) pass = false;
			k ++;
		}
	}

	if (!(k == 4)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
