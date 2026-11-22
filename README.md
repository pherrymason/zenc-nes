# zenc-nes

A NES emulator written in [Zen C](https://zenc-lang-ce.github.io/docs/tour/).

It is a port of [nes-golang](https://github.com/pherrymason/nes-golang), an
emulator written in Go. The port is not literal: where the Go code differed
from the hardware, the Zen C version follows the hardware as documented on
the [nesdev wiki](https://www.nesdev.org/wiki/), and adds tests for it.

## Status

| Part | State |
|---|---|
| CPU (6502 / 2A03) | The 151 official opcodes. Passes the 5003 lines of `nestest.log`. Unofficial opcodes stop the emulator with a message. |
| PPU | Background, scrolling, sprites (8x8 and 8x16, flipping, priority), sprite 0 hit, sprite overflow, left column masking, greyscale. |
| OAM DMA | Copies the page at once and halts the CPU for 513/514 cycles. |
| Controllers | Two standard controllers; the keyboard is controller 1. |
| Cartridges | iNES headers, mapper 0 (NROM) only, CHR ROM or CHR RAM. |
| APU | Not emulated: no sound. |

The CPU runs a whole instruction on its first cycle and then waits out the
rest, so tests that measure timing to the cycle can fail.

### Test ROMs

| ROM | Result |
|---|---|
| nestest (official opcodes) | passes |
| blargg `palette_ram`, `sprite_ram`, `vram_access` | pass |
| blargg `vbl_clear_time` | fails (`$03`, CPU timing) |
| blargg `power_up_palette` | fails (`$02`, power-up palette contents) |
| blargg `sprite_hit_tests_2005.10.05` (11 ROMs) | all pass |
| blargg `sprite_overflow_tests` | 3 of 5 pass; `Timing` and `Obscure` fail (the hardware's evaluation bug is not emulated) |

## Requirements

- The Zen C compiler, `zc`, in your `PATH` (or pass `ZC=/path/to/zc` to
  `make`).
- [raylib](https://www.raylib.com/)

## Build and run

```sh
make build
make run ARGS="-rom path/to/game.nes -scale 3"
```

Options:

| Option | Meaning |
|---|---|
| `-rom <file>` | iNES file to load (required) |
| `-scale <n>` | Window scale; the window is sized to fit (default 1) |


### Controls

| Key | Button |
|---|---|
| Arrows | D-pad |
| Z | A |
| X | B |
| S | Start |
| A | Select |

## Tests

```sh
make test
```

Each `tests/*_test.zc` file is compiled and run with `zc run`. The suite
covers the addressing modes, every instruction, the CPU bus, the cartridge
header and mapper, the PPU registers and memory, rendering (background and
sprites, checked pixel by pixel against the CHR data), the controllers, and
runs nestest against its official log. The nestest ROM and log are in
`tests/roms/nestest/`.

## Layout

```
src/
  main.zc              command line
  emulator/            window, keyboard and drawing (raylib)
  gamepak/             iNES header, cartridge loading, mappers
  nes/
    nes.zc             the console: master clock, CPU/PPU interleaving, DMA halt
    cpu_bus.zc         what the CPU sees at each address
    controller.zc      standard controller shift register
    cpu/               6502: registers, addressing modes, instructions
    ppu/               registers, memory, background and sprite rendering
tests/                 one file per part, plus test ROMs
```
