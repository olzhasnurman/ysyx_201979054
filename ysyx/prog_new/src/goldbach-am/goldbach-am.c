#include <am.h>
#include <klib.h>
#include <klib-macros.h>

int is_prime(int n) {
	if(n < 2) return 0;

	int i;
	for(i = 2; i < n; i ++) {
		if(n % i == 0) {
			return 0;
		}
	}

	return 1;
}

int goldbach(int n) {
	int i;
	for(i = 2; i < n; i ++) {
		if(is_prime(i) && is_prime(n - i)) {
			return 1;
		}
	}

	return 0;
}

int main() {
    bool pass = true;
	int n;
	for(n = 4; n <= 30; n += 2) {
		if (!(goldbach(n) == 1)) pass = false;
	}

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
