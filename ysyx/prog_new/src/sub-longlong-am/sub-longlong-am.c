#include <am.h>
#include <klib.h>
#include <klib-macros.h>

long long sub(long long a, long long b) {
	long long c = a - b;
	return c;
}

long long test_data[] = {0, 1, 2, 0x7fffffffffffffffLL, 0x8000000000000000LL, 0x8000000000000001LL, 0xfffffffffffffffeLL, 0xffffffffffffffffLL};
long long ans[] = {0LL, 0xffffffffffffffffLL, 0xfffffffffffffffeLL, 0x8000000000000001LL, 0x8000000000000000LL, 0x7fffffffffffffffLL, 0x2LL, 0x1LL, 0x1LL, 0LL, 0xffffffffffffffffLL, 0x8000000000000002LL, 0x8000000000000001LL, 0x8000000000000000LL, 0x3LL, 0x2LL, 0x2LL, 0x1LL, 0LL, 0x8000000000000003LL, 0x8000000000000002LL, 0x8000000000000001LL, 0x4LL, 0x3LL, 0x7fffffffffffffffLL, 0x7ffffffffffffffeLL, 0x7ffffffffffffffdLL, 0LL, 0xffffffffffffffffLL, 0xfffffffffffffffeLL, 0x8000000000000001LL, 0x8000000000000000LL, 0x8000000000000000LL, 0x7fffffffffffffffLL, 0x7ffffffffffffffeLL, 0x1LL, 0LL, 0xffffffffffffffffLL, 0x8000000000000002LL, 0x8000000000000001LL, 0x8000000000000001LL, 0x8000000000000000LL, 0x7fffffffffffffffLL, 0x2LL, 0x1LL, 0LL, 0x8000000000000003LL, 0x8000000000000002LL, 0xfffffffffffffffeLL, 0xfffffffffffffffdLL, 0xfffffffffffffffcLL, 0x7fffffffffffffffLL, 0x7ffffffffffffffeLL, 0x7ffffffffffffffdLL, 0LL, 0xffffffffffffffffLL, 0xffffffffffffffffLL, 0xfffffffffffffffeLL, 0xfffffffffffffffdLL, 0x8000000000000000LL, 0x7fffffffffffffffLL, 0x7ffffffffffffffeLL, 0x1LL, 0LL};

#define NR_DATA LENGTH(test_data)

int main() {
    bool pass = true;
	int i, j, ans_idx = 0;
	for(i = 0; i < NR_DATA; i ++) {
		for(j = 0; j < NR_DATA; j ++) {
			if (!(sub(test_data[i], test_data[j]) == ans[ans_idx ++])) pass = false;
		}
	}

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
