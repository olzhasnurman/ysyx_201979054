#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define N 20

int a[N] = {2, 12, 14, 6, 13, 15, 16, 10, 0, 18, 11, 19, 9, 1, 7, 5, 4, 3, 8, 17};

void bubble_sort() {
	int i, j, t;
	for(j = 0; j < N; j ++) {
		for(i = 0; i < N - 1 - j; i ++) {
			if(a[i] > a[i + 1]) {
				t = a[i];
				a[i] = a[i + 1];
				a[i + 1] = t;
			}
		}
	}
}

int main() {
    bool pass = true;
	bubble_sort();

	int i;
	for(i = 0; i < N; i ++) {
		if (!(a[i] == i)) pass = false;
	}

	if (!(i == N)) pass = false;

	bubble_sort();

	for(i = 0; i < N; i ++) {
		if (!(a[i] == i)) pass = false;
	}

	if (!(i == N)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
