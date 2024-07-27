#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define ADDR 0x80400000

int temp[40] = {1, 1};
int *fib = (int*)ADDR;
//int fib[40] = {1, 1};


int ans[] = {1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946, 17711, 28657, 46368, 75025, 121393, 196418, 317811, 514229, 832040, 1346269, 2178309, 3524578, 5702887, 9227465, 14930352, 24157817, 39088169, 63245986, 102334155};

int main() {
	for (int i = 0; i < sizeof(temp)/sizeof(temp[0]); i++) {
		fib[i] = temp[i];
	}
  bool pass = true;
	int i;
	for(i = 2; i < 40; i ++) {
		fib[i] = fib[i - 1] + fib[i - 2];
		if (!(fib[i] == ans[i])) pass = false;
	}

	if (!(i == 40)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
