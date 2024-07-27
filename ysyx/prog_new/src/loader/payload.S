.section .rodata
.align 3
.global app_start, app_end
app_start:
#ifdef BIN_PATH
.incbin BIN_PATH
#endif
app_end:

.section .data
.align 3
.global _appmem_start
_appmem_start:
