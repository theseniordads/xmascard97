# Xmas Card 97

Full assembler source for the "Xmas Car 97" demo by The Senior Dads, which was released on the Atari Falcon 030 on the 24th December 1997.

## Specifications
* An Atari Falcon 030 with 4 megabytes of memory, TOS 4.04, and an internal hard drive.
* ... Alternatively, a decent emulator like Hatari, configured as above.
* Devpac 3 to assemble the code.
* Atomix packer or better to pack the executable.

## How to assemble
* Load "MAIN.S" into Devpac 3.
* Make sure settings are set to assemble to Motorola 68030!
* Assemble to executable file "MAIN.PRG".
* Rename exectuable to "XMAS97.PRG".
* Pack "XMAS97.PRG" with packer.
* Run "XMAS97.PRG".

## Folders
* `XMAS97.SED` - Original compiled demo and accompanying [README](https://github.com/theseniordads/xmascard97/blob/main/XMAS97.SED/r3Adm3.tXt).
* `GRAPHICS` - Graphics, in Degas Elite PI1 files and raw 16-bit 320x200 true colour images. There's also `.FNT` 1 plane graphics using De Janeiro of The Avenger's Map Editor, and various `.ASA` files which contain screen configuration data.
* `INCLUDES` - Various macro and helpers code. Also includes `VSCROLL.S`, which contains the text for the credits at the end of the demo.
* `SOUND` - Sound and assoicated handling routines. `.MOP` files are modules packed using Delta Force's module packer, and depacked using `NMDEPACK.S`. All other files are concerned with the module replay routines.
* `SRC_DATA` - Original versions of sound and graphics, as well as precalculation.
  * `GFX` - Source graphics. Formats used are:
    * `.PC1` - Low res Degas Elite image.
    * `.TIF` - Low res true colour image.
    * `.TPI` - Low res True Paint image.
  * `SOUND` - `.MOD` files are Noisetracker compatible modules.
