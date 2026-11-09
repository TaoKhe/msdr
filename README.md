# T12 DSP FPGA sources

The project is organized into source groups:

- `scripts/`: MSDR Vivado Tcl entrypoints and the build Makefile.
- `src/hdl/`: board-specific HDL, with the top-level module under `top/` and
  version metadata under `sys_info/`, following the T7 source layout.
- `src/ip/adi_library/`: ADI custom IP sources.
- `src/ip/adi_hdl/`: the local ADI HDL build framework. Its `library` link
  points to `../adi_library` so the same IP sources are not duplicated.
- `src/xdc/`: board constraints.

All board-specific Tcl files are kept in `scripts/`, and all board constraint
files are kept in `src/xdc/`. The ADI project directory contains only its
Makefile; framework and IP Tcl/XDC files remain with their corresponding
framework or IP sources.

Build the MSDR design with `make msdr` from this directory. The generated
Vivado project is written under `msdr_gen/msdr/`.

`src/ip/quiet.mk` and `src/ip/scripts` are compatibility links to the local
framework files in `src/ip/adi_hdl/`.
