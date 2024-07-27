#include <am.h>
#include <klib.h>
#include <klib-macros.h>

char buf[128];

int main() {
    bool pass = true;
	char *ch =  "Hello world!\n";
	if (!(strcmp(ch, "Hello world!\n") == 0)) pass = false;

	ch = "1 + 1 = 2\n";
	if (!(strcmp(ch, "1 + 1 = 2\n") == 0)) pass = false;

	ch = "2 + 10 = 12\n";
	if (!(strcmp(ch, "2 + 10 = 12\n") == 0)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
