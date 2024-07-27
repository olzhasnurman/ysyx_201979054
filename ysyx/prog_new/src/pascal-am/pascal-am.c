#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define N 31
#define ADDR 0x80400000

int *a = (int*)ADDR;
int ans[] = {1, 30, 435, 4060, 27405, 142506, 593775, 2035800, 5852925, 14307150, 30045015, 54627300, 86493225, 119759850, 145422675, 155117520, 145422675, 119759850, 86493225, 54627300, 30045015, 14307150, 5852925, 2035800, 593775, 142506, 27405, 4060, 435, 30, 1};

int main() {
  bool pass = true;
	int i, j;
	int t0, t1;
	a[0] = a[1] = 1;

	for(i = 2; i < N; i ++) {
		t0 = 1;
		for(j = 1; j < i; j ++) {
			t1 = a[j];
			a[j] = t0 + t1;
			t0 = t1;
		}
		a[i] = 1;
	}

	for(j = 0; j < N; j ++) {
		if (!(a[j] == ans[j])) pass = false;
	}

	if (!(j == N)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
