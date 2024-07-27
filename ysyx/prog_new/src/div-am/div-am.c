#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define N 10
int a[N];

int main() {
    bool pass = true;
  int i, j;
  for(i = 0; i < N; i ++)
    a[i] = i;
  for(i = 0; i < N; i ++)
    for(j = 1; j < N + 1; j ++)
      a[i] *= j;
  for(i = 0; i < N; i ++)
    for(j = 1; j < N + 1; j ++)
      a[i] /= j;

  for(i = 0; i < N; i ++)
    if (!(a[i] == i)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
  return 0;
}
