# IP sources

`adi_library/` contains the ADI custom IP repository used by the Vivado build.
`adi_hdl/` contains the local ADI HDL build framework; its `library` link points
to `../adi_library` so the IP source is maintained only once. The board design
Tcl is the source of truth for MSDR; Vivado generates `.xci` files under
`msdr_gen/` during project creation. Do not copy generated files here as
independent inputs.

`quiet.mk` and `scripts/` at this directory level are compatibility links to
the framework files under `adi_hdl/`. Keep these links in place unless the
corresponding framework paths are updated together.

The shared IP packaging helper normalizes source paths before adding them to
Vivado so packaged files resolve correctly through the `adi_hdl/library` link.
