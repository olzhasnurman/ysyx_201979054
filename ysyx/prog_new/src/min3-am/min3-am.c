#include <am.h>
#include <klib.h>
#include <klib-macros.h>

int min3(int x, int y, int z) {
	int m;
	if(x < y) { m = x; }
	else { m = y; }
	if(z < m) m = z;
	return m;
}

int test_data[] = {0, 0x7fffffff, 0x80000000, 0xffffffff};
int ans [] = {0, 0, -2147483648, -1, 0, 0, -2147483648, -1, -2147483648, -2147483648, -2147483648, -2147483648, -1, -1, -2147483648, -1, 0, 0, -2147483648, -1, 0, 2147483647, -2147483648, -1, -2147483648, -2147483648, -2147483648, -2147483648, -1, -1, -2147483648, -1, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -2147483648, -1, -1, -2147483648, -1, -1, -1, -2147483648, -1, -2147483648, -2147483648, -2147483648, -2147483648, -1, -1, -2147483648, -1};

#define NR_DATA LENGTH(test_data)

int main() {
    bool pass = true;
	int i, j, k, ans_idx = 0;
	for(i = 0; i < NR_DATA; i ++) {
		for(j = 0; j < NR_DATA; j ++) {
			for(k = 0; k < NR_DATA; k ++) {
				if (!(min3(test_data[i], test_data[j], test_data[k]) == ans[ans_idx ++])) pass = false;
			}
			if (!(k == NR_DATA)) pass = false;
		}
		if (!(j == NR_DATA)) pass = false;
	}

	if (!(i == NR_DATA)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
