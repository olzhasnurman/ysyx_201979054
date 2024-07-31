#include <am.h>
#include <klib.h>
#include <klib-macros.h>

uint32_t get_mvendorid() {
    uint32_t mvendorid;
    asm volatile ("csrr %0, mvendorid" : "=r" (mvendorid));
    return mvendorid;
}

uint64_t get_marchid() {
    uint64_t marchid;
    asm volatile ("csrr %0, marchid" : "=r" (marchid));
    return marchid;
}

uint64_t get_mimpid() {
    uint64_t mimpid;
    asm volatile ("csrr %0, mimpid" : "=r" (mimpid));
    return mimpid;
}

int main(){
    putstr("Hello RISC-V!\n");

		uint64_t mvendorid = get_mvendorid();
		uint64_t marchid = get_marchid();
		uint64_t mimpid = get_mimpid();
		
		char message_0[9];
		char message_1[9];
		char message_2[9];

    for (int i = 0; i < 8; ++i) {
        message_0[i] = (char)(mvendorid & 0xFF); // Extract each byte
			  message_1[i] = (char)(marchid & 0xFF); // Extract each byte
			  message_2[i] = (char)(mimpid & 0xFF); // Extract each byte
			  mvendorid >>= 8;
				mimpid >>= 8;
        marchid >>= 8; // Shift right by 8 bits to get the next byte
    }
		message_0[4] = '\n';
		message_0[5] = '\0';
		message_1[7] = '\n';
    message_1[8] = '\0'; // Null-terminate the string
		message_2[7] = '\n';
		message_2[8] = '\0';

		putstr("mvendorid: ");
		putstr(message_0);
		putstr("marchid: ");
    putstr(message_1);
		putstr("mimpid: ");
		putstr(message_2);
    return 0;
}
