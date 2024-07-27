#include <am.h>
#include <klib.h>
#include <klib-macros.h>

volatile int A[10];
volatile int b;

int main() {
    bool pass = true;
	A[0] = 0;
	A[1] = 1;
	A[2] = 2;
	A[3] = 3;
	A[4] = 4;

	b = A[3];
	A[5] = b;

	if (!(A[0] == 0)) pass = false;
	if (!(A[1] == 1)) pass = false;
	if (!(A[2] == 2)) pass = false;
	if (!(A[3] == 3)) pass = false;
	if (!(A[4] == 4)) pass = false;
	if (!(b == 3)) pass = false;
	if (!(A[5] == 3)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
