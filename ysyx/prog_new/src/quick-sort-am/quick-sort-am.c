#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define N 20
#define ADDR 0x80400000

int temp[N] = {2, 12, 14, 6, 13, 15, 16, 10, 0, 18, 11, 19, 9, 1, 7, 5, 4, 3, 8, 17};
int* a = (int*) ADDR;

int partition(int *a, int p, int q) {
	int pivot = a[p];
	int i = p, j = q;
	while(i < j) {
		while(i < j && a[j] > pivot) j --;
		a[i] = a[j];

		while(i < j && a[i] <= pivot) i ++;
		a[j] = a[i];
	}

	a[i] = pivot;
	return i;
}

void quick_sort(int *a, int p, int q) {
	if(p >= q) return;

	int m = partition(a, p, q);
	quick_sort(a, p, m - 1);
	quick_sort(a, m + 1, q);
}

int main() {
  for (int i = 0; i < sizeof(temp)/sizeof(temp[0]); i++) {
    a[i] = temp[i];
  }
  bool pass = true;
	quick_sort(a, 0, N - 1);

	int i;
	for(i = 0; i < N; i ++) {
		if (!(a[i] == i)) pass = false;
	}

	if (!(i == N)) pass = false;

	quick_sort(a, 0, N - 1);

	for(i = 0; i < N; i ++) {
		if (!(a[i] == i)) pass = false;
	}

	if (!(i == N)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
