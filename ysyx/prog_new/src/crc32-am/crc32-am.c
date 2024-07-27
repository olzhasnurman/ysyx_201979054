#include <am.h>
#include <klib.h>
#include <klib-macros.h>
/* from http://rosettacode.org/wiki/CRC-32#C */

#define ADDR_0 0x80400000
#define ADDR_1 (ADDR_0 + 256*(sizeof(uint32_t)))
#define ADDR_2 ADDR_1 + (sizeof(int))
#define ADDR_3 ADDR_2 + sizeof(uint32_t)
#define ADDR_4 ADDR_3 + sizeof(uint8_t)

#define STR "The quick brown fox jumps over the lazy dog"
#define STRLEN (sizeof(STR) - 1)
 
uint32_t rc_crc32(uint32_t crc, const char *buf, size_t len) {
  uint32_t *table = (uint32_t*)(ADDR_0);
	static int *have_table = (int*)(ADDR_1);
	*have_table = 0;
	uint32_t *rem = (uint32_t*)(ADDR_2);
	uint8_t octet;
	//uint32_t *crc_new = (uint32_t*)(ADDR_4);
	//*crc_new = crc;
	const char *p, *q;
 
	/* This check is not thread safe; there is no mutex. */
	if (*have_table == 0) {
		/* Calculate CRC table. */
		for (int i = 0; i < 256; i++) {
			*rem = i;  /* remainder from polynomial division */
			for (int j = 0; j < 8; j++) {
				if (*rem & 1) {
					*rem >>= 1;
					*rem ^= 0xedb88320;
				} else
					*rem >>= 1;
			}
			table[i] = *rem;
		}
		*have_table = 1;
	}
 
	crc = ~(crc);
	q = buf + len;
	for (p = buf; p < q; p++) {
		octet = (uint8_t)*p;  /* Cast to unsigned octet. */
		(crc) = ((crc) >> 8) ^ table[((crc) & 0xff) ^ (octet)];
	}
	return ~(crc);
}
 
int main() {
  bool pass = true;
  uint32_t res = rc_crc32(0, STR, STRLEN);
  if (!(res == 0x414FA339)) pass = false;
  if (pass) putstr("PASS\n");
  else putstr("FAIL\n");
	return 0;
}

