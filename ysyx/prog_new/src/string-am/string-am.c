#include <am.h>
#include <klib.h>
#include <klib-macros.h>

char *s[] = {
	"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
	"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab",
	"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
	", World!\n",
	"Hello, World!\n",
	"#####"
};

char str1[] = "Hello";
char str[20];

int main() {
  bool pass = true;
	if (!(strcmp(s[0], s[2]) == 0)) pass = false;
	if (!(strcmp(s[0], s[1]) < 0))  pass = false;
	if (!(strcmp(s[0] + 1, s[1] + 1) < 0)) pass = false;
	if (!(strcmp(s[0] + 2, s[1] + 2) < 0)) pass = false;
	if (!(strcmp(s[0] + 3, s[1] + 3) < 0)) pass = false;

  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}
