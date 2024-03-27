# ACK for Cray X-MP and COS

This fork of the Amsterdam Compiler Kit supports the Cray X-MP supercomputer and the COS operating
system platform. All other machines and platforms are disabled in this fork by commenting out
references to them in the LUA build scripts. Currently, this fork builds and runs successfully on
MacOS and Linux.

ACK requires the following tools to be installed on MacOS and Linux before it will build
successfully:

- bison
- flex
- gcc
- gmake
- lua

For example, on Debian Linux (and derivatives), the tools may be installed using __apt__, as
in:

```
sudo apt install bison flex gcc lua5.3 make
```

On MacOS, if you have installed _Xcode_, you will have _bison_ and _flex_ already. A package
manager such as _Homebrew_ may be used to install _lua_. You will also need GNU _gcc_ and
_gmake_. ACK will not build successfully using the version of _gcc_ provided by _Xcode_ and _LLVM_. Using _Homebrew_, _lua_, _gcc_, and _gmake_ make be installed as in:

```
brew install gcc lua make
```

Another prerequisite for all platforms is that the tools from the following GitHub repository
are installed on your build platform. This repository provides a cross-assembler, cross-linker, and cross-library manager for the Cray X-MP. These are used by this fork of ACK to produce executables for the Cray X-MP and COS operating system.

[https://github.com/kej715/COS-Tools](https://github.com/kej715/COS-Tools)

After installing all of the prerequisite tools, the ACK for Cray X-MP and COS may be built
using the script provided in the top-level directory of the repo, as in:

```
./cray-build.sh
```

To install ACK after building:

```
sudo ./cray-build.sh install
```

After successfully building and installing ACK, the following cross-compilers will be
available, and you can use them to create executables for the Cray X-MP and COS:

- __BASIC__ The _ack_ command recognizes source files having the extension _.bas_ as BASIC programs.
- __C__ The _ack_ command recognizes source files having the extension _.c_ as C programs.
- __Pascal__ The _ack_ command recognizes source files having either the extension _.p_ or the extension _.pas_ as Pascal programs.

For example, the following command will compile a __C__ program named _hello.c_ and produce a file named _hello.abs_. _hello.abs_ is an absolute binary that will execute on a Cray X-MP after uploading it there (see [Running on Cray X-MP](#running), below).

```
ack -o hello hello.c
```

Similarly, the following command will compile a __Pascal__ program named _hello.pas_ and produce an absolute binary named _hello.abs_ that will execute on a Cray X-MP.

```
ack -o hello hello.pas
```

## <a id="running"></a>Running on Cray X-MP

Andras Tantos' Cray supercomputer simulator,
[cray-sim](https://github.com/andrastantos/cray-sim), supports the Cray X-MP with the
COS 1.17 operating system. He has published a delightful narrative of the project in
[The Cray Files](http://www.modularcircuits.com/blog/articles/the-cray-files/), and this
narrative includes documentation about installing and running COS 1.17 on the simulator.

Unfortunately, the copy of COS 1.17 recovered by Andras does not include any programming
language translators, and no other working copies of COS are currently known to exist.
This fork of ACK helps to resolve the lack of programming tools in the recovered
copy of COS by providing cross-compilers that will produce COS executables. This fork enables
hobbyists to create programs for the iconic Cray X-MP supercomputer and run them on the
simulator.

A significant challenge, however, is how to move cross-compiled executables onto a simulated
Cray X-MP. One solution is to install [DtCyber](https://github.com/kej715/DtCyber) and
leverage its ability to run _Cray Station_ software. DtCyber is a simulator for
[Control Data Corporation's (CDC)](https://en.wikipedia.org/wiki/Control_Data_Corporation)
_Cyber_ series of supercomputers. Installing the
[NOS 2.8.7](https://github.com/kej715/DtCyber/tree/main/NOS2.8.7#readme)
operating system on _DtCyber_ enables using Cray's _Cray Station_ software to exchange files
and batch jobs between the CDC and Cray supercomputers.

In addition to _Cray Station_, the NOS 2.8.7 operating system has a mature set of other data
communication software including TCP/IP applications (e.g., FTP),
[Kermit](https://en.wikipedia.org/wiki/Kermit_(protocol)),
and [XModem](https://en.wikipedia.org/wiki/XMODEM).
For example, it is possible to use an FTP client to upload a cross-compiled Cray binary to
a CDC machine running NOS 2.8.7 and then use _Cray Station_ to transfer the file to a
Cray X-MP running COS. Likewise, Kermit or XModem can be used to upload files to a CDC
machine running NOS 2.8.7.

Given this, the following log of a user session illustrates how a user could create a C
program, use ACK to cross-compile it, upload the cross-compiled executable to NOS 2.8.7 using
FTP, create a NOS CCL procedure to transfer it to and run it on a Cray X-MP, and view the
results returned.

First, display the source code, a C program that computes and displays the first 10 Fibonacci
numbers:

```
kej@Kevins-Air examples % cat fib.c
#include <stdio.h>

#define NUM_FIBS 10

int main(int argc, char *argv[]) {
    int i1, i2, i3, n;

    i1 = 0;
    i2 = 1;
    for (n = 1; n <= NUM_FIBS; n++) {
      printf(" %d: %d\n", n, i2);
      i3 = i1 + i2;
      i1 = i2;
      i2 = i3;
    }

    return 0;
}
```
Cross-compile it:
```
kej@Kevins-Air examples % ack -o fib fib.c
```
The cross-compiler produces a relocatable object file named _fib.o_ and an executable named
_fib.abs_:
```
-rw-r--r--@ 1 kej  staff  48232 Mar 20 10:01 fib.abs
-rw-r--r--@ 1 kej  staff    268 Mar 20 09:57 fib.c
-rw-r--r--@ 1 kej  staff    600 Mar 20 10:01 fib.o
```
Use FTP to upload it to the NOS 2.8.7 system (_kevins-max.local_) as an indirect access
permanent file named FIB, in binary mode:
```
kej@Kevins-Air examples % ftp kevins-max.local
Trying 192.168.1.238:21 ...
Connected to kevins-max.local.
220 SERVICE READY FOR NEW USER.
Name (kevins-max.local:kej): guest
331 USER NAME OKAY, NEED PASSWORD.
Password:
230 USER LOGGED IN, PROCEED.
Remote system type is NOS.
ftp> bin
200 COMMAND OKAY.
ftp> put fib.abs fib/ia
local: fib.abs remote: fib/ia
227 ENTERING PASSIVE MODE (192,168,1,238,30,7)
150 FILE STATUS OKAY; ABOUT TO OPEN DATA CONNECTION.
100% |*****************************************************************************************************************************************| 48232       32.55 MiB/s    00:00 ETA
226 CLOSING DATA CONNECTION.
48232 bytes sent in 00:01 (31.57 KiB/s)
ftp> quit
221 SERVICE CLOSING CONTROL CONNECTION. LOGGED OUT.
```
Use Telnet to log into the NOS 2.8.7 system:
```
kej@Kevins-Air examples % telnet kevins-max.local
Trying 192.168.1.238...
Connected to kevins-max.local.
Escape character is '^]'.

Connecting to host - please wait ...
Connected

WELCOME TO THE NOS SOFTWARE SYSTEM.
COPYRIGHT CONTROL DATA SYSTEMS INC. 1994.
24/03/20. 10.11.34. TE04P06
NCCMAX - CYBER 875.                     NOS 2.8.7 871/871.
FAMILY:
USER NAME: guest
PASSWORD:

JSN: ABXC, NAMIAF
/
```
Create and save a CCL procedure file containing a procedure named RUN. This procedure will
use the _Cray Station_ interface to submit a batch job to the Cray X-MP supercomputer.
When the job starts running on the Cray X-MP, it uses the _Cray Station_ interface to
retrieve a file containing a COS executable from the NOS 2.8.7 system. After retrieving the
file, it runs it. When the job completes, the _Cray Station_ interface will return the log
and any output produced by the executable to the NOS system, and this will appear as a
file in the user's wait queue.

This procedure file needs only to be created and saved once and can be re-used again and again
later, either to re-run the original executable, or to run other ones.
```
/new,cray
/text
 ENTER TEXT MODE.

.PROC,RUN*I,F=(*F,*N=CRAYBIN).
.IF,FILE(F,AS),LOCAL.
  REWIND,F.
.ELSE,LOCAL.
  GET,F.
.ENDIF,LOCAL.
COPYBF,F,ZZZCBIN.
REPLACE,ZZZCBIN=F.
CSUBMIT,CRAYJOB,TO.
REVERT,NOLIST.
.DATA,CRAYJOB.
JOB,JN=CRAYRUN,T=60.
ACCOUNT,AC=CRAY,APW=XYZZY,UPW=QUASAR.
ECHO,ON=ALL.
OPTION,STAT=ON.
FETCH,DN=F,MF=FE,DF=TR,^
TEXT='USER,GUEST,GUEST.GET,F.CTASK.'.
F.

 EXIT TEXT MODE.
/save,cray
```
Note that _Control-T_ is pressed to exit TEXT mode.

The CATLIST command displays all of the user's permanent files. This confirms that the
cross-compiled executable, FIB, uploaded previously and the procedure file, CRAY, just
created have been saved as indirect access files as expected.
```
/catlist
 CATALOG OF  GUEST            FM/CYBER   24/03/20. 10.29.45.



 INDIRECT ACCESS FILES

  CRAY      FIB       FTPPRLG   LOGIN     MAILBOX

 DIRECT ACCESS FILES

  GAMFILE   LIBRARY   RELFILE

         5 INDIRECT ACCESS FILES ON DISK.  TOTAL PRUS =       110.
         3 DIRECT ACCESS FILES ON DISK.    TOTAL PRUS =        72.
```
Use the BEGIN command to execute the procedure named RUN in the procedure file named CRAY
and pass the name of the file containing the cross-compiled executable as a parameter:
```
/begin,run,cray,fib
```
Use the STATUS command to monitor progress. First, the batch job destined for the Cray X-MP
may appear in the NOS system's INPUT queue.
```
/status,jsn

 JSN SC CS DS LID STATUS                JSN SC CS DS LID STATUS

 ABXL.B.  .BC.XMP.INPUT QUEUE           ABXC.T.ON.BC.   .EXECUTING
```
Then, it may seem to disappear. While actually running on the Cray X-MP, it may not be
visible to the NOS system.
```
/status,jsn

 JSN SC CS DS LID STATUS                JSN SC CS DS LID STATUS

 ABXC.T.ON.BC.   .EXECUTING
```
However, the _Cray Station_ interface will submit a batch job to the NOS system to
participate in transferring the cross-compiled executable from NOS to COS, so you might catch
the brief execution of that job.
```
/status,jsn

 JSN SC CS DS LID STATUS                JSN SC CS DS LID STATUS

 ABXC.T.ON.BC.   .EXECUTING             ABXM.B.NI.BC.   .EXECUTING
```
When the batch job on the Cray X-MP side has completed, its log and output will be
returned to the NOS 2.8.7 WAIT queue.
```
/status,jsn

 JSN SC CS DS LID STATUS                JSN SC CS DS LID STATUS

 ABXC.T.ON.BC.   .EXECUTING             ABXO.S.  .BC.MAX.WAIT QUEUE
```
Use the QGET command to retrieve the output by JSN from the WAIT queue, and then display it
using the LIST command:
```
/qget,abxo
 QGET COMPLETE.
/list,f=abxo
 1: 1
 2: 1
 3: 2
 4: 3
 5: 5
 6: 8
 7: 13
 8: 21
 9: 34
 10: 55
1
  09:40:43.4062       0.0007    CSP             CRAY XMP-14 SN 302      LEADING EDGE TECHNOLOGIES       03/20/84
  09:40:43.4091       0.0008    CSP
  09:40:43.4126       0.0010    CSP             CRAY OPERATING SYSTEM           COS 1.17  ASSEMBLY DATE 02/28/89
  09:40:43.4154       0.0011    CSP
  09:40:43.4178       0.0011    CSP
  09:40:43.4442       0.0013    CSP     JOB,JN=CRAYRUN,T=60.
  09:40:43.5433       0.0105    CSP     ACCOUNT,AC=,APW=,UPW=.
  09:40:43.5473       0.0109    CSP
  09:40:43.5500       0.0110    CSP     .......................................................................
  09:40:43.5528       0.0111    CSP
  09:40:43.5963       0.0122    CSP     ECHO,ON=ALL.
  09:40:43.6057       0.0128    CSP     OPTION,STAT=ON.
  09:40:43.6196       0.0158    CSP     FETCH,DN=FIB,MF=FE,DF=TR,^
  09:40:43.6256       0.0181    CSP     TEXT=.
  09:40:47.9952       0.0184    SCP     ABXW 11.05.17.USER,GUEST,.
  09:40:47.9972       0.0184    SCP     ABXW 11.05.17.CHARGE,   *                  ,
  09:40:47.9990       0.0184    SCP     ABXW 11.05.19. TRO - PF AND TAPE TRANSPARENT OUTPUT.
  09:40:48.0009       0.0184    SCP     ABXW 11.05.20.TRO: DATASET FIB    ,      14440B WORDS,     0.465
  09:40:48.3294       0.0184    SCP     SS004 - DATASET RECEIVED FROM FRONT END
  09:40:49.7924       0.0200    CSP     FIB.
  09:40:49.9634       0.0466    CSP     END OF JOB
  09:40:49.9682       0.0469    EXP     SY005 - FIB          6144 WRDS,    2 IOS,      2 REQ,      12 STRS,     .060 SEC
  09:40:49.9725       0.0469    EXP           - 29-1-32A       18 STRS   READ:         3 REQ,      12 STRS,     .099 SEC
  09:40:49.9780       0.0470    CSP
  09:40:49.9804       0.0471    CSP
  09:40:49.9866       0.0474    CSP     CHARGES
  09:40:49.9895       0.0475    CSP     CS032 - DATASET NOT LOCAL:
  09:40:49.9925       0.0476    ABORT   AB025 - USER PROGRAM REQUESTED ABORT
  09:40:49.9947       0.0476    ABORT         - P=00001417B   TASK-ID=0001
  09:40:49.9969       0.0476    ABORT         - BASE=00775000 LIMIT=01153000 CPU-NUMBER=00
  09:40:49.9990       0.0476    ABORT         - JOB STEP ABORTED.
```
