#include <am.h>
#include <klib.h>
#include <klib-macros.h>
int main() {
    bool pass = true;
  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
  return 0;
}
