# SoC Integration Testing CheckList

> Note: Starting from the 2nd batch of the 4th session, in order to meet the teaching and examination requirements of the SoC part of PA, **ysyxSoC framework no longer provides simulation source programs, test programs, runtime environment**, all these need to be implemented by the students themselves. But in order to facilitate the testing of students in the 4th and 5th session, project team provide a repository named `ysyx4_sim` temporarily to save simulation source programs and test programs. **This repository will be private and removed in the 6th session** to support the new teaching and examination process of the 6th session. Before reading the following contents, you first need to download `ysyx4_sim` to the specified directory: first switch to `ysyxSoC/ysyx/utils` directory, then run `./setup.sh` in this directory to copy Verilator simulation source code directory `sim` and test programs directory `prog` of the 4th session to `ysyxSoC/ysyx` directory.

**All steps for SoC integration testing can be completed in the current directory**, the directory structure of ysyx is as follow:
```sh
ysyxSoC/ysyx
├── img                # Expected run result screenshots
├── lint               # Code lint check
├── perip              # Peripheral modules
│   ├── kdb            # Keyboard peripheral simulation
│   ├── ps2            # PS2 controller
│   ├── spi            # SPI controller
│   │   ├── doc
│   │   └── rtl
│   ├── spiFlash       # Flash peripheral simulation
│   ├── uart16550      # UART controller
│   │   ├── doc
│   │   └── rtl
│   └── vga            # VGA controllers
├── prog               # Test programs
│   ├── bin            # Compiled binary programs
│   │   ├── flash
│   │   └── mem
│   └── src            # Source codes of test programs
│       ├── ftom
│       ├── hello
│       ├── kdb
│       ├── loader
│       ├── memtest
│       ├── muldiv
│       └── rt-thread
├── ram                # RAM replacement model
├── sim                # Simulation test
│   └── src
├── soc                # SoC framework codes
├── stand              # Code specification test
├── submit             # Code submit repository
└── utils              # Tool codes
```

All test tasks of SoC intergration can be completed by running `main.py` in the current directory, We provide `main.py` script contains port naming check, code specification check and full functions of Verilator program compilation and simulation testing, you can input `./main.py -h` to get a list of supported functions:
```sh
$> ./main.py -h
usage: main.py [-h] [-s] [-l] [-lu] [-c] [-fc] [-t TEST TEST TEST TEST] [-r] [-fr] [-su] [-y] [-p]

OSCPU Season 4 SoC Test

optional arguments:
  -h, --help            show this help message and exit
  -s, --stand           run interface standard check
  -l, --lint            run code lint check
  -lu, --lint_unused    run code lint with unused check
  -c, --comp            compile core with SoC in normal flash mode
  -fc, --fst_comp       compile core with SoC in fast flash mode
  -t TEST TEST TEST TEST, --test TEST TEST TEST TEST
                        Example: ./main.py -t [flash|mem] [hello|memtest|rtthread|muldiv|kdb] [cmd|gui] [no-wave|wave]. note: some programs dont support gui mode, so need to set right mode carefully
  -r, --regress         run all test in normal flash mode
  -fr, --fst_regress    run all test in fast flash mode
  -su, --submit         submit code and spec to CICD
  -y, --ysyx            compile ysyxSoCFull framework[NOT REQUIRED]
  -p, --prog            compile all test prog[NOT REQUIRED]
```

In detail, every student needs to do it in order:

>Naming specification check -> CPU internal modification -> Verilator simulation -> Submit codes

Careful students may find that `main.py` is actually implemented by calling Makefile or Python scripts in each subdirectory. In addition, this integrated task Checklist is arranged according to **the order of tasks, so students should ensure that the previous task are completed before performing the next task.**

> Note: it is recommended to run `main.py` with `python3` instead of `python2`.

## Some Preparation
In order to use `main.py` to test, you need:
* Merge CPU codes into a `.v` file, file name is `ysyx_[8-bit student number].v`, such as `ysyx_22040228`.
    * It can be implemented on Linux by using the `cat` command:
    ```sh
    $> cat CPU.v ALU.v regs.v ... > ysyx_22040228.v
    ```
* Modify the top-level name of CPU to `ysyx_[8-bit student number].v`, such as `ysyx_22040228.v`.
* Modify the top-level's port name of CPU according to [CPU Port Naming Specification](./stand/interface.md).
* Add `ysyx_[8-bit student number]_` prefix to all module names of CPU.
    * Such as `module ALU` is modified to `module ysyx_22040228_ALU`.
    * Chisel welfare: We provide a [firrtl transform](./utils/AddModulePrefix.scala) to automatically add module name prefix, for usage, refer to [related documentations](./utils/README.md).
* For processor cores implemented with Verilog/SystemVerilog, the prefix of module name cannot be automatically added at present. Please add the prefix of module name manually.
* Add `ysyx_[8-bit student number]_` prefix to all `define` of CPU, this is to avoid the occurence of multiple students' core variable definitions with the same name during the back-end physical design.
* **Put the modified `ysyx_[8-bit student number].v`, such as `ysyx_22040228.v` in the `./soc` directory.**
* Set `stud_id` in `main.py` to **8-bit student number**, for example, for a student with number 22040228, set `stud_id='22040228'`.
> Note: The students who use Verilog/SystemVerilog should delete or comment all `include` lines when they merge codes, and make sure all codes and parameter definitions for the core are only in the `ysyx_[8-bit student number].v` file. At the same time, delete or comment the DPI-C functions that may be introduced when connecting to difftest. The specific operation of merging codes can be implemented by writing a script yourself.

## Naming Specification Check (Completed before 2022/10/07 23:59:59, Beijing time)
Run the script to perform the naming specification check. The script will check whether the .v file implemented by the students meets the naming specification and generate the log file `check.log`. The executable test environments are `Debian10`, `Ubuntu 20.04`, `WSL2-Ubuntu 20.04` and `Windows10`.
* Run `./main.py -s` in the current directory.
* Finally, you can see the check results in the terminal. If the check passes, it will be printed out in the terminal:
    ```sh
    $> Your core is FINE in module name and signal interface
    ```
* At the same time, the log file `check.log` will be generated under the `./stand`. If the test fails, an error message will be given and whether it is a `module name` error or a `signal interface` error. You can also open the generated `check.log` log file to view the error reason and prompts.
> Note: The port definition of the processor core must be modified strictly in accordance with the [CPU Port Naming Convention](./stand/interface.md). **There can be no redundant comments in the port, nor between `input` and `output` Add extra `wire` after it. In addition, other custom signals are not allowed in the interface**, otherwise it may cause problems in subsequent tests. In addition, the One Student One Chip 4th SoC uses the shared SRAM method to implement Cache, so 8 additional sets of SRAM interfaces need to be added to the CPU port. The specific method is as follows [CPU Internal Modification](#cpu-internal-modification-completed-before-20221007-235959-beijing-time).

## CPU Internal Modification (Completed before 2022/10/07 23:59:59, Beijing time)
* All triggers need to have a reset port so that they have an initial value after reset.
    * **Chisel welfare: You can use the following command to scan the compiled `.fir` file to find the registers without reset port:**
    ```sh
    $> grep -rn "^ *reg " -A1 myCPU.fir | sed ":a;N;s/:\n//g;ba" | sed ":a;N;s/--\n//g;ba" | grep -v "reset =>"
    ```
    The file name of `xxx.fir` is related to the top-level module name and is usually located in the `./build` directory. If there is no output from the above command, it means that all registers have been reset. If there is output above, you need to go to the specified line in `xxx.fir` according to the line number to view. Since the `reset =>` of reg may cause a line break, this line break will also cause command line output. So you need to check whether there is `reset =>` in the content of the next line.
    > Note: chisel may not be able to accurately determine the initialization of the register based only on the reset of firrtl, because reset sometimes only initializes some bits of the register. If the initialized register is a bundle, the problem is more obvious. Therefore, it is recommended that students who use chisel to implement code still need to manually check whether all registers are reset correctly. It may not be possible to check all problems only through the `grep reset` method above.

* For Cache, you need:
    * Confirm that the size of the data array of ICache and DCache is not greater than 4KB, and the sum is not greater than 8KB.
    * Confirm that the data array of ICache and DCache both use single-port RAM.
    * Port replacement of the data array: We provide a simplified behavioral model consistent with the RAM port used for tape-out, using the [single-port RAM model with write mask](./ram/S011HD1P_X32Y2D128_BW.v). `ysyxSoCFull.v` has integrated 8 RAMs with write mask on the top level. The specification of each RAM is 128X64bits, totaling 8KB. **Students need to replace the Cache with the SRAM port that accesses the top layer of the core**.
    > Note: Cores that implement a Cache larger than 8KB must reduce the Cache size, and cores that implement a Cache smaller than 8KB must still retain unused ports in the top layer of the core. To implement a core smaller than 8KB, disable the unused SRAM port enable interface on the top layer of the core, leave the input floating, and set the output address and data signals to `0`. **The write mask of RAM is low effective**. If students do not need to use the write mask of the RAM when accessing the RAM with **write mask** provided by us, they need to set the write mask of the RAM to `1` (disable it). In addition, the tag array does not need to be replaced, and it is not allowed to instantiate RAM in the core for other designs. At the same time, students need to maintain the cache consistency when loading the program. For specific RAM port definitions, please see [here](./ram/README.md).
* If you use Verilog/SystemVerilog to develop, you need:
    * Confirm that the latch in the code has been removed.
        * **Chisel welfare：Chisel does not generate latches**
    * Confirm that the asynchronous reset trigger in the code has been removed, or synchronous evacuation has been implemented.
        * **Chisel welfare：Chisel generates synchronous reset triggers by default**
* For unused core top-level ports (io_interrupt and AXI4 slave) except the SRAM port, the output port needs to be set to `0` and the input port is left floating.
> Note: Although the simulation efficiency of open source Verilator is much higher than that of commercial simulators (such as VCS). However, Verilator's support for SystemVerilog is not yet complete, and its inspection of RTL code is also optimistic. For this reason, we will use VCS to simulate the cores submitted by the students again before officially starting the back-end design. In order to avoid simulation problems caused by **inconsistent simulation behavior between Verilator and VCS**, <sup>[[2]](#id_verilator_sim)</sup>**please `avoid` using the following content in your own core:**
* Non-synthesizable syntax, such as delay and DPI-C.
* initial statement.
* unpacked array, structure.
* interface, package, class.
* Little endian sequence number, such as [0:31].
* Latch generation due to missing else
* Logic type X state and high impedance Z state.
* Use clock falling edge trigger.
* Asynchronous reset and cross-clock domain.
* Try to block the global clock signal.

> Note, let we emphasize again:
> 1. All registers **must be reset**, otherwise the students' core may pass the Verilator test, but not the VCS test. For example, during the VCS simulation stage, the Cache that students core may have problems in the simulation. One possible reason is that the Cache register forgot to reset when performing a write-back operation, resulting in an unknown state that cannot be selected.
> 2. For AXI4 bus, **don’t just use ready as the signal to switch the state**, **because the default ready of SoC simulated on VCS is always pulled high**, which may cause AXI4 handshake and state machine switching problems in students' cores under VCS simulation.

## Code Specification Check (Completed before 2022/10/07 23:59:59, Beijing time)
Perform specification checks on the code and clear warnings in reports. Specific steps are as follows:
* Run `./main.py -l`, Verilator will report all categories of Warning except `DECLFILENAME` and `UNUSED`, you need to modify the code to clean them up. For the meaning of Warning, please refer to [Verilator Manual Instructions](https://veripool.org/guide/latest/warnings.html#list-of-warnings).
* When running `./main.py -lu`, Verilator will additionally report Warnings of the `UNUSED` category. You need to modify the code to clean them up as much as possible.
* If some `UNUSED` category Warnings cannot be cleared, or **there are some Warnings that students cannot decide whether to clear**, you need to fill in the [warning.md](./lint/warning.md) and give the reasons to provide reference to the SoC team and back-end design team. Among them, [warning.md](./lint/warning.md) has given format examples, and students can delete them by themselves when filling in the form.
> Note: <sup>[[1]](#id_verilator_unopt)</sup>Verilator usually reports a `UNOPT` or `UNOPTFLAT` warning for **combinational logic loop**. This is because the combinational logic loop requires multiple iterations to obtain the final result (convergence). The difference between these two warnings is that one is reported before Verilator generates `flatten netlist`, and the other is reported after it is generated. Although Verilator claims that ignoring these warnings will not affect the correctness of the simulation, there is also a possibility that there are indeed combinatorial logic loops in the students' cores. If so, it is likely that there is a bug somewhere in the core. According to our experience, it is easier for everyone to write combinational logic loops when writing the hazard part of the pipeline.

> Regarding the `UNOPT` warning reported by Verilator, **in some cases it is not necessarily true that a combinational logic cycle exists**. This is because, for the sake of simulation performance, Verilator does not calculate each bit of the signal separately, but usually calculates many signals together. **At this time, if it is determined that there is indeed no combinational logic loop in the processor core, you can use `/* verilator split_var */` to eliminate the warning and continue with the following test process.** For specific examples of combinational logic rings and UNPOT, see <sup>[[1]](#id_verilator_unopt)</sup>.

## Verilator Simulation (completed before 2022/10/07 23:59:59, Beijing time)
> <sup>[[3]](#id_verilator_cycle)</sup>Verilator is a cycle-accurate open source simulator that supports Verilog/SystemVerilog, but it cannot replace event-driven simulators such as Vivado xsim. <sup>[[4]](#id_verilator_intro)</sup>The so-called cycle-accurate simulation is to calculate the output of the module after a sufficient period of time after determining the module input. Therefore there is no concept of delay in cycle accurate simulation. It can be understood that each update is the output of the calculation module when it is in a steady state after infinite time. For a design like the CPU driven by a clock signal, the outer code (C++ code) only needs to repeatedly change the value of the clock signal (from 0 to 1, and then from 1 to 0) to obtain the CPU's value in each cycle status output.

><sup>[[4]](#id_verilator_intro)</sup>Since Verilator is a cycle-based simulator, this means that it does not evaluate time within a single cycle, nor does it simulate precise circuit timing. Therefore, glitches within one clock cycle cannot be observed in the waveform, and timing signal delays are not supported. In addition, since Verilator is a cycle-driven simulator, it cannot be used for timing simulation, back-annotated netlists, asynchronous (no clock) logic, or generally any signal changes involving the concept of time, that is, whenever Verilator evaluates the circuit , all outputs switch immediately. It is precisely because everything between clock edges is ignored that Verilator's simulation speed can be very fast, so Verilator is very suitable for simulating the functions of synchronous digital logic circuits with one or more clocks, or for converting from Verilog/SystemVerilog code creates software models.

The One Student One Chip 4th SoC framework will use Verilator for integration testing and simulation of students' processor core codes. The address space of the SoC is allocated as follows:
| Device | Address Space |
| --- | --- |
| Reserve           | `0x0000_0000~0x01ff_ffff`|
| CLINT             | `0x0200_0000~0x0200_ffff`|
| Reserve           | `0x0201_0000~0x0fff_ffff`|
| UART16550         | `0x1000_0000~0x1000_0fff`|
| SPI               | `0x1000_1000~0x1000_1fff`|
| VGA               | `0x1000_2000~0x1000_2fff`|
| PS2               | `0x1000_3000~0x1000_3fff`|
| Ethernet          | `0x1000_4000~0x1000_4fff`|
| Reserve           | `0x1000_5000~0x1bff_ffff`|
| Frame Buffer      | `0x1c00_0000~0x2fff_ffff`|
| SPI-flash XIP Mode| `0x3000_0000~0x3fff_ffff`|
| ChipLink MMIO     | `0x4000_0000~0x7fff_ffff`|
| MEM               | `0x8000_0000~0xfbff_ffff`|
| SDRAM             | `0xfc00_0000~0xffff_ffff`|

* The reset PC of the processor needs to be set to `0x3000_0000`, and the first instruction is taken out from the flash.
* The CLINT module is located inside the processor core and is not provided by SoC. Students need to implement it by themselves.
* To access external interrupts, students need to **design their own arbitration logic** (the top layer of the core has reserved the io_interrupt interface, which will be led from the SoC and connected to the FPGA through ChipLink. Students need to design their own arbitration logic to implement PLIC on the FPGA. When the core receives an interrupt, it will jump to the exception handler, and then read the relevant registers of ChipLink MMIO to view the interrupt source information and respond. After the exception is handled, the interrupt source can be cleared by writing to the relevant registers of ChipLink MMIO. **The external interrupt function is optional, but if it is not implemented, the io_interrupt interface must still be retained**).
* VGA and Frame Buffer ranges of MMIO addresses will access vga ctrl. 0x1000_2000~0x1000_2fff is to access the axi4 slave port of vga for function configuration. The frame buffer of vga is actually stored in memory, but we want to write to the frame buffer through the MMIO bus, so a mapping module is added to the vga module, and the processor sends the write of a certain pixel to the MMIO Frame On the address of the Buffer, vga adds an offset to this address to obtain the address of the pixel in the memory, and forwards the read and write requests to the memory through its own axi4 host port.
* Access to the devices designed by students needs to be implemented in the core and the device registers are allocated to the **Reserve address range**.
> Note: There are no functional registers related to the SoC clock and pins in the address space of the 4th session SoC, **which means that it is not supported to set SoC related parameters by accessing a certain address through software**.

### Verilator Simulation Requirements Are as Follows:
* Use Verilator to correctly compile your own core `ysyx_[8-bit student number].v` and `ysyxSoCFull.v` into the executable simulation program `emu`.
* Confirm that the code after clearing the Warning can successfully start programs such as hello, memtest, and rtthread. **A new test program has been added to the 4th session of SoC. For the specific content and requirements of the test program, please see [here](./prog/README.md)**.
* Simulate the flash through fast mode (skip SPI transmission, cannot be synthesized, suitable for quick debugging and iteration), run and pass the test program provided by this framework. In order to turn on the fast mode of flash, you need to define the macro `FAST_FLASH` at the beginning of `./perip/spi/rtl/spi.v`:
  ```Verilog
  // define this macro to enable fast behavior simulation
  // for flash by skipping SPI transfers
  `define FAST_FLASH
  ```
  > Note: **In fact, students do not need to actually add the `FAST_FLASH` macro, because we have already added it, and we have maintained the function of automatically switching the `FAST_FLASH` macro in `main.py`**. This section just introduces the process of Verilator simulation to students. Students are not required to modify the code, but the next section [The Specific Steps of Verilator Simulation](#the-specific-steps-of-verilator-simulation-are-as-follows) is the part that students need to actually operate.

  Specifically, in this mode, the spi controller will directly use the DPI-C function to read the required programs and data to the AXI4 bus side, avoiding the original `AXI4<--->SPI<--->DPI-C` conversion process of AXI4 to SPI protocol improves the speed of program simulation. Every student needs to pass:
  * Programs that run directly on flash (located in the `./prog/bin/flash` directory):
    * hello-flash.bin
    * memtest-flash.bin
    * rtthread-flash.bin
    * ...
  * Load the program into memory through loader, and then jump to run (located in the `./prog/bin/mem` directory). **Note that additional implementation of the `fence.i` instruction is required**
    * hello-mem.bin
    * memtest-mem.bin
    * rtthread-mem.bin
    * ...
* Simulate the flash through normal mode (no skipping SPI transmission, slow simulation speed, used for final system testing), and rerun the above test program. You need to undefine the macro `FAST_FLASH` at the beginning of `./perip/spi/rtl/spi.v`:
  ```Verilog
  // define this macro to enable fast behavior simulation
  // for flash by skipping SPI transfers
  // `define FAST_FLASH
  ```
    * Then rerun the flash and mem mentioned above respectively:
        * hello-flash.bin
        * memtest-flash.bin
        * rtthread-flash.bin
        * hello-mem.bin
        * memtest-mem.bin
        * rtthread-mem.bin
        * ...

### The Specific Steps of Verilator Simulation Are as Follows:
The previous section [Verilator Simulation Requirements](#verilator-simulation-requirements-are-as-follows) introduces the structure of the entire test program, but in order to facilitate students to conduct Verilator testing, we **have implemented Verilator compilation, simulation testing and regression testing functions in `main.py`**, and can make the Verilator simulation program `emu` automatically switch between fast mode and normal mode, without students needing to manually modify `define FAST_FLASH`. Students only need to:
* Run `./main.py -c` to compile and generate the emulation executable file `emu` in flash normal mode. Run `./main.py -fc` to compile and generate the simulation executable file `emu` in flash fast mode. In order to improve the compilation speed, you can modify the `-j6` option of `build` in `./sim/Makefile`.
* After generating `emu`, use:
    ```sh
    $> ./main.py -t APP_TYPE APP_NAME SOC_SIM_MODE SOC_WAV_MODE
    ```
    To simulate a specific test program, the optional values ​​of `APP_TYPE` are `flash` and `mem`, which represent the two startup methods of flash and memory loading respectively. Optional values for `APP_NAME` include `hello`, `memtest`, `rtthread`, etc. See the list of `-t` options in `./main.py -h` for all supported program names. The optional values ​​of `SOC_SIM_MODE` are `cmd` and `gui`, which respectively represent the simulation execution environment. `cmd` represents the command line execution environment. The program will output the simulation results on the command line. `gui` represents the graphical execution environment, and the program will use SDL2 to graphically interactively display RTL data. Optional values for `SOC_WAV_MODE` are `no-wave` and `wave`. For example, running `./main.py -t flash hello cmd no-wave` can simulate the hello test program of the command line execution environment in flash mode without outputting the waveform. Run `./main.py -t mem hello cmd wave` to simulate the hello test program of the command line execution environment in flash mode and output the waveform. The path of the waveform file is `./ysyx/soc.wave`. The default format of the waveform is `FST`. FST is a binary waveform format developed by GTKWave itself. It is smaller in size than VCD files. Run `./main.py -t mem kdb gui` to simulate the keyboard test program of the graphical execution environment in mem loading mode.
    > Note: **All test programs can only be run in one execution environment. For details on which environment to run, see [document](./prog/README.md)**. If you need to output a wave file in VCD format, you only need to change `WAVE_FORMAT ?= FST` to `WAVE_FORMAT ?= VCD` at the beginning of [./sim/Makefile](./sim/Makefile), and then recompile. **One thing that needs to be emphasized is that after using the `wave` option to enable waveform output, the program running time will become longer. If the program ends without running out the results, please modify the "preset running time" introduced in the following section.**
* Run `./main.py -r` and `./main.py -fr` to run the regression test of flash normal mode and fast mode in sequence. The regression test only tests the program in the `cmd` execution environment, programs in the `gui` execution environment are not subject to regression testing.
* During the testing process, we set a **preset running time** for each test. When the program exceeds the **preset running time**, it will stop running on its own. Students can modify `./main.py`:
    ```python
    app = [('hello', 40), ('memtest', 70), ('rtthread', 450)...]
    ```
    The number part is to adapt to the operation of your own core, where the number represents the **preset running time** in seconds. Since the mem test program needs to be loaded, the time required will be longer than running it directly in flash. Therefore, the preset running time here is set based on the running time of the simulation program under mem. If you want to terminate the program in advance , you can enter `ctrl-c` directly. If you want the simulation to not stop, you can set a larger number. The number should be at least of type int32. In addition, in order to ensure that the code is always up to date during testing, the code will be recompiled during regression testing, and then tested again after compilation.
> Recommendation: After debugging a single test program, you can directly run the regression test instructions `./main.py -r` and `./main.py -fr` to test all programs in the command line execution environment.

> Note: If the processor core is modified in order to run the test program correctly, **you need to follow the above process again and start testing from scratch**.

## Submit Code (Completed before 2022/10/07 23:59:59, Beijing time)
> Note: The purpose of submitting here is to run the synthesis process as soon as possible and discover new problems. After that, you can continue to debug the implementation of the processor core.

After accessing the ysyxSoC framework and completing all the above tests, you can start the code submission process. Please make sure all triggers are reset before submitting. The specific preparation work required is as follows:
* Place the screenshot file `rtthread-mem.png` of the flash normal mode `rtthread-mem.bin` that successfully runs this framework in the `./submit` directory.
* Fill in the cache specification document [cache_spec.md](./submit/cache_spec.md) in the `./submit` directory.
* Confirm that [warning.md](./lint/warning.md) has been filled in according to the code specifications and completed in the `./lint` directory.
* Make a processor architecture diagram with data flow direction, briefly explain each module in the diagram, organize it into a `ysyx_[8-bit student number].pdf` file and place it in the `./submit` directory.
* Create your own gitee open source repository and confirm that the default main branch of the repository is `master`.
* Confirm that the repository is cloned to the `./submit` directory through ssh and fill in the `user.email` and `user.name` of git. Then run `./main.py -su`. The script will first check whether the above submitted files are complete. If they are complete, the files will be copied to the local clone repository and pushed to the remote gitee repository.
  > Note: In addition to the gitee repository of clone's `./submit`, do not add additional folders in `./submit`, because the submission script automatically determines the local clone repository name through `os.path.isdir()`, if there are multiple folders in `./submit`, the program cannot distinguish which one is the local cloned repository.
* Send the `HTTPS format URL` and `ysyx_[8-bit student number]` of your own repository to the teaching assistant in the group to complete the first code submission. Subsequent submissions only require re-running the `./main.py -su` command.
* After the code is submitted, it will be automatically pulled by the CI/CD program and tested accordingly. The code can also be submitted manually, **but you need to ensure that each submission must use `dc & vcs` as the commit information**. The CI/CD program will only recognize the commit information of `dc & vcs`.

> Note: Cache specifications cannot be modified in subsequent submissions, and bugs can only be fixed based on report feedback. The SoC and back-end teams will use the CI/CD program to regularly check the newly submitted code, conduct comprehensive and simulation tests, and upload the results in the form of log reports to the **ysyx4 branch** of the ysyx_submit repository. For specific instructions, please refer to [ysyx_submit repository documentation](https://gitee.com/OSCPU/ysyx_submit/blob/ysyx4).

## Assist the SoC Team to Start RT-Thread in the Tape-out Simulation Environment (Completed before 2022/11/07 23:59:59, Beijing time)
After submitting the code, please pay attention to the feedback from the SoC team in time.

> Note: **The SoC in this project is only used for verification in Verilator and does not participate in the tape-out process!** In addition, there are still a few differences between this project and the tape-out SoC simulation environment. Passing the test in this project does not mean that it can also pass the test in the tape-out SoC simulation environment. The running results in the tape-out SoC simulation environment , based on the feedback from the SoC team, so please be sure to pay attention to the feedback from the SoC team.

Specifically, compared to simulation based on the tape-out SoC simulation environment, simulation based on Verilator:
* There is no problem of indefinite state (x-state) signal propagation.
* There is no cross-clock domain and asynchronous bridge.
* No PLL.
* No delay information for real devices.

> **When this step is completed, students who pass the simulation tests of Verilator and VCS at the same time, and the dc synthesis also meets the timing and area requirements, can obtain pre tape-out qualifications. After passing the online assessment organized by the project team, you will be officially qualified for tape-out of One Student One Chip 4th.**

## Extended Content
> Note: **The following content is not a task that students must complete, but is provided for students who have customized needs for the SoC simulation framework we provide. The following introduces the necessary steps to compile and generate your own test program, generate your own Verilator simulation program, and the process and key points to note when using chisel to generate the ysyxSoCFull framework**.

## Generate Your Own Test Program

Starting from the second batch of the 4th session, the project team **no longer provides `abstract-machine` adapted to the ysyxSoC environment** . The runtime environment (am) of the program needs to be implemented by students themselves, but the framework provides an implementation reference. details as follows:
* Correctly set the `AM_HOME` environment variable.
* Place your own test program source code directory under `./prog/src`. There needs to be a Makefile in the source code directory. For its content format, please refer to `./prog/src/hello/Makefile`:
    ```Makefile
    SRCS = hello.c # All source code paths
    NAME = hello   # Generated executable program name

    include $(AM_HOME)/Makefile
    ```
* Then switch to `./prog/src` and modify the values ​​of `APP_NAME` and `APP_TYPE` in `run.py`. Among them, `APP_NAME` is changed to the `NAME` filled in the Makefile in the previous step, `APP_TYPE` is changed to `flash` or `mem`, indicating the loading type of the generated program, `flash` means that the program is executed directly from flash, ` mem` means that the program is first loaded from flash into mem and then executed.
* Execute `./prog/src/run.py`. If the compilation passes, you can get the executable program under `./prog/bin/$(FLASH_TYPE)`.

## ysyxSoCFull Custom Integration Steps
* Add all `.v` files in the `ysyxSoC/ysyx/perip` directory and its subdirectories to verilator's Verilog/SystemVerilog file list.
* Add the `ysyxSoC/ysyx/soc/ysyxSoCFull.v` file to verilator's Verilog/SystemVerilog file list.
* Add processor Verilog/SystemVerilog files to verilator's Verilog/SystemVerilog file list.
* Add the two directories `ysyxSoC/ysyx/perip/uart16550/rtl` and `ysyxSoC/ysyx/perip/spi/rtl` to the include path (use the `-I` option of verilator).
* Add the `ysyxSoC/ysyx/perip/spiFlash/spiFlash.cpp` file to verilator's C++ file list.
* Set the processor's reset PC to `0x3000_0000`.
* Add `--timescale "1ns/1ns"` to verilator compilation options.
* There are two ways to initialize flash when verilator is initialized:
    * Call the `flash_init(img)` function in `spiFlash.cpp` to place the instruction sequence in the bin file in flash, where the parameter `img` is the path to the bin file. Some examples are provided in the `ysyxSoC/ysyx/prog/bin/flash` and `ysyxSoC/ysyx/prog/bin/mem` directories.
    * Call the `flash_memcpy(src, len)` function in `spiFlash.cpp` to place the instruction sequence that has been read into the memory in flash, where the parameter `src` is the address of the instruction sequence and `len` is the length of the instruction sequence.
* Set the `ysyxSoCFull` module (defined in `ysyxSoC/ysyx/soc/ysyxSoCFull.v`) as the top level of verilator simulation.
* Modify the `ysyx_000000` module name in `ysyxSoC/ysyx/soc/ysyxSoCFull.v` to your own processor module name.
* Just perform simulation through Verilator.

## The Steps of Compile and Generate ysyxSoCFull.v by Yourself
* Update and pull the submodules of the current repository:
    ```sh
    $> git submodule update --init
    ```
* Specify the RISCV environment variable as the installation directory of the toolchain, which is the root directory of the `riscv64-unknown-elf-xxx` development version:
    ```sh
    $> export RISCV=/path/to/riscv/toolchain/installation
    ```
* Enter the `./ysyx` directory and execute `./main.py -y` to compile the SoC framework. The source code structure of the framework is as follows:
    ```sh
    ysyxSoC/src/main/scala/ysyx
    ├── chiplink
    │   └── ...                        # Implementation of ChipLink
    └── ysyx
        ├── AXI4ToAPB.scala            # AXI4-APB transfer bridge, which does not support burst and only supports access below 4 bytes
        ├── ChipLinkBridge.scala       # ChipLink-AXI4 transfer bridge
        ├── CPU.scala                  # CPU wrapper, which will instantiate a CPU instance according to the SoC port specification
        ├── PS2.scala                  # PS2 wrapper, which will instantiate the Verilog version of the PS2 controller
        ├── RAM.scala                  # RAM wrapper, which will instantiate the Verilog version of the RAM simulation model
        ├── SoC.scala                  # SoC top level
        ├── SPI.scala                  # SPI wrapper, which will instantiate the Verilog version of the SPI controller
        └── Uart16550.scala            # UART16550 wrapper, which will instantiate the Verilog version of the UART16550 controller
    ```
> Note: You need to use Java 11 when compiling. Higher versions of Java will throw exceptions. For details, see: https://github.com/chipsalliance/rocket-chip/issues/2789.

## Acknowledgments and Statement
* AXI4 crossbar (from the Rocket Chip project, it has been tape-out verified in the project of the Computing Institute team).
* ChipLink (from [sifive-blocks](https://github.com/sifive/sifive-blocks/tree/master/src/main/scala/devices/chiplink), it has been tape-out verified in the project of the Computing Institute team.).
* UART16550 (from OpenCores, it has been tape-out verified in the project of the Computing Institute team).
* SPI controller (from OpenCores, it has been tape-out verified in the project of the Computing Institute team).
* SoC integration (implemented based on diplomacy DSL).
* Thanks to [Guoqi Li (ysyx_22040228)](https://github.com/xunqianxun) for the docking test. Guoqi Li helped test out the memory access width bug in the multiplication and division test of the flash version, and summarized the experience in the AXI debugging process. When introducing this framework, We also used Guoqi Li’s core as an example.
* Thanks to [Yongyu Zheng (ysyx_22040450)](./) for his suggestions on modifying the code specification checking script.
* Thanks to [Ziqi Wan (ysyx_22040698)](./) for the tip on typos in README.md.
* Thanks to [Yawei Ding (ysyx_22040561)](./) for pointing out the core top-level file name error in the ysyxSoCFull.v file and the newline bug in the submission script.
* Thanks to [Kun Lu (ysyx_22041812)](./) for proposing a better command to reset the register in chisel.
* Thanks to [Xun Wang (ysyx_22040053)](./) for discovering the illegal memory access bug in the sdl2 image loading address and providing code modifications.
* Thanks to [Kun Lu (ysyx_22041812)](./) for discovering the incompleteness of only using `grep reset` to check in chisel and for making corresponding debugging suggestions.

## Reference
[1] [FDU NSCSCC Additional Information: Combinational Logic Rings and UNOPT (GPL-3.0)](https://fducslg.github.io/ICS-2021Spring-FDU/misc/unopt.html)<span id="id_verilator_unopt" ></span>

[2] [FDU NSCSCC Additional Information: Verilator Simulation (GPL-3.0)](https://fducslg.github.io/ICS-2021Spring-FDU/misc/verilate.html?highlight=sdl#verilator-%E4%BB%BF%E7%9C%9F)<span id="id_verilator_sim"></span>

[3] [FDU NSCSCC Additional Information: Cycle Accurate Simulation (GPL-3.0)](https://fducslg.github.io/ICS-2021Spring-FDU/misc/verilate.html?highlight=sdl#%E5%91%A8%E6%9C%9F%E7%B2%BE%E7%A1%AE%E4%BB%BF%E7%9C%9F)<span id="id_verilator_cycle"></span>

[4] [KuangjuX Blog Verilator Learning Notes (CC BY-NC-SA 4.0)](http://blog.kuangjux.top/2022/02/20/verilator-learning/)<span id="id_verilator_intro"></span>