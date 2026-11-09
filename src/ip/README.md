# IP sources

Each IP is a direct child of this directory, such as `axi_adrv9001/`,
`axi_dmac/`, `util_cpack2/`, and `util_upack2/`. Shared HDL and constraints are
kept in `common/`, `util_pack_common/`, and the vendor-specific directories.
Bus interface XML is kept in `interfaces/` and `axi_dmac/interfaces/`.

IP-specific Tcl, TTcl templates, BD callbacks, and test runners stay inside
their IP directory, alongside HDL and constraints. For example:

```text
axi_adrv9001/
  axi_adrv9001.v
  axi_adrv9001_ip.tcl
  axi_adrv9001_constr.ttcl
axi_dmac/
  axi_dmac.v
  axi_dmac_ip.tcl
  bd/bd.tcl
  interfaces/interfaces_ip.tcl
```

Only project scripts and shared ADI helpers live in
[`../../scripts/`](../../scripts/). The only build Makefile is
[`../../Makefile`](../../Makefile).

The build stages these sources and packages IP under `../../msdr_gen/ip/`.
Generated component XML, XGUI/BD Tcl, projects, logs, and caches do not belong
in this source directory. Authored BD callbacks are source files and stay
with their IP. Test runners resolve fixture paths relative to their own
location.
