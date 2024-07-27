#include <am.h>
#include <klib.h>
#include <klib-macros.h>

int main() {
    bool pass = true;
	int i = 1;
	volatile int sum = 0;
	while(i <= 100) {
		sum += i;
		i ++;
	}

	if (!(sum == 5050)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
