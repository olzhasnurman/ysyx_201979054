#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define ADDR_0 0x80400000
#define ADDR_1 ADDR_0 + sizeof(int)

int f0(int, int);
int f1(int, int);
int f2(int, int);
int f3(int, int);

int (*func[])(int, int) = {
  f0, f1, f2, f3,
};

int *rec = (int*)(ADDR_0);
int *lvl = (int*)(ADDR_1);

void initialize_globals(void) {
    // Initialize the values at the addresses pointed to by rec and lvl
    *rec = 0;
    *lvl = 0;
}

int f0(int n, int l) {
  if (l > *lvl) *lvl = l;
  (*rec) ++;
  return n <= 0 ? 1 : func[3](n / 3, l + 1);
};

int f1(int n, int l) {
  if (l > *lvl) *lvl = l;
  (*rec) ++;
  return n <= 0 ? 1 : func[0](n - 1, l + 1);
};

int f2(int n, int l) {
  if (l > *lvl) *lvl = l;
  (*rec) ++;
  return n <= 0 ? 1 : func[1](n, l + 1) + 9;
};

int f3(int n, int l) {
  if (l > *lvl) *lvl = l;
  (*rec) ++;
  return n <= 0 ? 1 : func[2](n / 2, l + 1) * 3 + func[2](n / 2, l + 1) * 2;
};

int ans[] = {38270, 218, 20};

int main() {
	initialize_globals();
  bool pass = true;
  int x = func[0](14371, 0);
  if (!(x == ans[0])) pass = false;
  if (!(*rec == ans[1])) pass = false;
  if (!(*lvl == ans[2])) pass = false;
  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
  return 0;
}
