
# Test program guide

## structure

```sh
ysyxSoC/ysyx/prog
├── bin
│   ├── flash                    # programs that run directly on flash
│   │   ├── hello-flash.bin
│   │   ├── hello-flash.elf
│   │   ├── kdb-flash.bin
│   │   ├── kdb-flash.elf
│   │   ├── memtest-flash.bin
│   │   ├── memtest-flash.elf
│   │   ├── muldiv-flash.bin
│   │   ├── muldiv-flash.elf
│   │   ├── rtthread-flash.bin
│   │   └── rtthread-flash.elf
│   └── mem                      # programs that load from flash to memory, need to implement fence.i
│       ├── hello-mem.bin
│       ├── hello-mem.elf
│       ├── kdb-mem.bin
│       ├── kdb-mem.elf
│       ├── memtest-mem.bin
│       ├── memtest-mem.elf
│       ├── muldiv-mem.bin
│       ├── muldiv-mem.elf
│       ├── rtthread-mem.bin
│       └── rtthread-mem.elf
├── README.md                    # this document
└── src                          # source code of programs
    ├── ftom                     # simple loader
    ├── hello                    # print 'hello' string
    ├── kdb                      # keyboard input test
    ├── loader                   # flash loader
    ├── memtest                  # memory read and write test
    ├── muldiv                   # multiply and divide instruction test
    ├── rtthread                 # rt-thread RTOS
    └── run.py                   # compile script
```

## Introduction
The processor needs support RV64IM ISA, fence.i instruction and trap handles in machine privileged mode at lest. Programs running on flash are limited to 4-byte access and do not support AXI4 burst requests. Compiled test programs in this directory guarantee no such behavior.

### hello
This program tests whether the AXI4 bus and UART peripheral can handle read and write requests correctly. The reference output is as follows:

```sh
Hello World!
```

### memtest
This program tests whether AXI4 bus can correctly read and write data in ChipLink and SDRAM. First, this program writes the data to the ChipLink, and then read the data from same address to check if the read data is same as the data written earlier. The reference output is as follows:

```sh
start test...
mem tests prepared
mem tests passed!
sdram tests prepared
all tests passed!!
```

### rtthread
This program is a complex application to test if processor can handle timer interruption correctly. This program will create threads `thread1` and `thread2`, which will output the current count value and perform a 40ms blocking delay after output. When the thread runs 6 times, it exits and prints the result. If the thread is blocked, it will be suspended and switch thread at this time. Since the priority and time slice of the two threads are set to the same, the two threads are isochronous alternate execution. The decrementation of the thread time slice value in rtthread is carried out in accordance with the interrupt period of the system timer, and the system timer of rtthread is implemented by the hardware timer interrupt on processor. Note that the output position of `msh />` is not fixed, the specific reference output is as follows:
```sh
heap: [0x8000d4a8 - 0x8640d4a8]

 \ | /
- RT -     Thread Operating System
 / | \     4.0.4 build Sep 28 2022
 2006 - 2021 Copyright by rt-thread team
Hello RISC-V!
thread1 count: 0
thread2 count: 0
thread1 count: 1
thread2 count: 1
thread1 count: 2
thread2 count: 2
thread1 count: 3
msh />thread2 count: 3
thread1 count: 4
thread2 count: 4
thread1 count: 5
thread2 count: 5
thread1 count: 6
thread2 count: 6
thread1 exit
thread2 exit
```
### muldiv
This program tests if the multiplication and division instructions are implemented correctly. This program contains three numerical algorithm tests, which are Euclidean Algorithm(EA), Matrix Fast Eponentiation Algorithm(MFEA) and Fast Number Theory Transformation(FNTT). Because the FNTT requires 64-bit memory access，this program run on flash don't support FNTT test. The reference output of program run on flash is as follows：
```sh
gcd test pass!
fibonacci test pass!
all tests passed!!
```
The reference output of program run on memory is as follows：
```sh
gcd test pass!
fibonacci test pass!
polynomial multiplication test pass!
all tests passed!!
```

### kdb
This program tests ps2 keyboard peripheral. After running the keyboard test program in Linux graphical environment or on the command line in MobaXterm, and wait a few seconds, the following GUI(resolution: 400X300) will pop up:
<p align="center"><img src="../sim/asset/kdb.png" width="400"></p>

When the GUI is active, click the english letter keys on the keyboard and command line will print corresponding english letter and encode value. Because the key detection is carried out in a polling manner, it takes about 3 to 4 seconds to output the result on the command line after clicking a key. Click the exit button in the upper right corner of the pop-up GUI to exit the program.
```sh
try to press any key (keyboard)...
Got  (kbd): E (24)
Got  (kbd): A (1c)
14 val not support!!
Got  (kbd):   (14)
Got  (kbd): T (2c)
Got  (kbd): E (24)
Got  (kbd): Q (15)
Got  (kbd): I (43)
Got  (kbd): U (3c)
Frames per second: 11776.3
```