# T12 DSP FPGA sources

T.
├── docs
├── Makefile
├── README.md
├── scripts
│   ├── adi
│   │   ├── adi_board_intel.tcl
│   │   ├── adi_board.tcl
│   │   ├── adi_env.tcl
│   │   ├── adi_fmc_constr_generator.tcl
│   │   ├── adi_intel_device_info_enc.tcl
│   │   ├── adi_intel_msg.tcl
│   │   ├── adi_ip_intel.tcl
│   │   ├── adi_ip_lattice.tcl
│   │   ├── adi_ip_xilinx.tcl
│   │   ├── adi_lattice_dev_select.tcl
│   │   ├── adi_make_boot_bin.tcl
│   │   ├── adi_make.tcl
│   │   ├── adi_pd.tcl
│   │   ├── adi_project_intel.tcl
│   │   ├── adi_project_lattice_pb.tcl
│   │   ├── adi_project_lattice.tcl
│   │   ├── adi_project_xilinx.tcl
│   │   ├── adi_tquest.tcl
│   │   ├── adi_xcvr_xilinx.tcl
│   │   ├── adi_xilinx_device_info_enc.tcl
│   │   ├── adi_xilinx_msg.tcl
│   │   ├── auto_timing_fix_xilinx.tcl
│   │   ├── gtwizard_generator.tcl
│   │   └── gtwiz_parser.pl
│   ├── adi_env.tcl
│   ├── build_ip.tcl
│   ├── msdr_bd.tcl
│   ├── system_bd.tcl
│   └── system_project.tcl
├── src
│   ├── hdl
│   │   ├── sys_info
│   │   │   └── system_infor.vh
│   │   └── top
│   │       └── system_top.v
│   ├── ip
│   │   ├── axi_adrv9001
│   │   │   ├── adrv9001_aligner4.v
│   │   │   ├── adrv9001_aligner8.v
│   │   │   ├── adrv9001_pack.v
│   │   │   ├── adrv9001_rx_link.v
│   │   │   ├── adrv9001_rx.v
│   │   │   ├── adrv9001_tx_link.v
│   │   │   ├── adrv9001_tx.v
│   │   │   ├── axi_adrv9001_constr.sdc
│   │   │   ├── axi_adrv9001_constr.ttcl
│   │   │   ├── axi_adrv9001_core.v
│   │   │   ├── axi_adrv9001_hw.tcl
│   │   │   ├── axi_adrv9001_if.v
│   │   │   ├── axi_adrv9001_ip.tcl
│   │   │   ├── axi_adrv9001_rx_channel.v
│   │   │   ├── axi_adrv9001_rx.v
│   │   │   ├── axi_adrv9001_sync_ctrl.v
│   │   │   ├── axi_adrv9001_sync.v
│   │   │   ├── axi_adrv9001_tdd.v
│   │   │   ├── axi_adrv9001_tx_channel.v
│   │   │   ├── axi_adrv9001_tx.v
│   │   │   ├── axi_adrv9001.v
│   │   │   └── intel
│   │   │       ├── adrv9001_rx.v
│   │   │       └── adrv9001_tx.v
│   │   ├── axi_dmac
│   │   │   ├── address_generator.v
│   │   │   ├── axi_dmac_burst_memory.v
│   │   │   ├── axi_dmac_constr.sdc
│   │   │   ├── axi_dmac_constr.ttcl
│   │   │   ├── axi_dmac_ext_sync.v
│   │   │   ├── axi_dmac_framelock.v
│   │   │   ├── axi_dmac_hw.tcl
│   │   │   ├── axi_dmac_ip.tcl
│   │   │   ├── axi_dmac_ltt.tcl
│   │   │   ├── axi_dmac_pkg_sv.ttcl
│   │   │   ├── axi_dmac_regmap_request.v
│   │   │   ├── axi_dmac_regmap.v
│   │   │   ├── axi_dmac_reset_manager.v
│   │   │   ├── axi_dmac_resize_dest.v
│   │   │   ├── axi_dmac_resize_src.v
│   │   │   ├── axi_dmac_response_manager.v
│   │   │   ├── axi_dmac_transfer.v
│   │   │   ├── axi_dmac.v
│   │   │   ├── axi_register_slice.v
│   │   │   ├── bd
│   │   │   │   └── bd.tcl
│   │   │   ├── data_mover.v
│   │   │   ├── dest_axi_mm.v
│   │   │   ├── dest_axi_stream.v
│   │   │   ├── dest_fifo_inf.v
│   │   │   ├── dmac_2d_transfer.v
│   │   │   ├── dmac_sg.v
│   │   │   ├── inc_id.vh
│   │   │   ├── interfaces
│   │   │   │   ├── if_framelock_rtl.xml
│   │   │   │   ├── if_framelock_v1_0.sv
│   │   │   │   ├── if_framelock.xml
│   │   │   │   └── interfaces_ip.tcl
│   │   │   ├── request_arb.v
│   │   │   ├── request_generator.v
│   │   │   ├── response_generator.v
│   │   │   ├── response_handler.v
│   │   │   ├── resp.vh
│   │   │   ├── splitter.v
│   │   │   ├── src_axi_mm.v
│   │   │   ├── src_axi_stream.v
│   │   │   ├── src_fifo_inf.v
│   │   │   └── tb
│   │   │       ├── axi_read_slave.v
│   │   │       ├── axi_slave.v
│   │   │       ├── axi_write_slave.v
│   │   │       ├── dma_read_shutdown_tb
│   │   │       ├── dma_read_shutdown_tb.v
│   │   │       ├── dma_read_tb
│   │   │       ├── dma_read_tb.v
│   │   │       ├── dma_write_shutdown_tb
│   │   │       ├── dma_write_shutdown_tb.v
│   │   │       ├── dma_write_tb
│   │   │       ├── dma_write_tb.v
│   │   │       ├── regmap_tb
│   │   │       ├── regmap_tb.v
│   │   │       ├── reset_manager_tb
│   │   │       ├── reset_manager_tb.v
│   │   │       └── tb_base.v
│   │   ├── axi_sysid
│   │   │   ├── axi_sysid_hw.tcl
│   │   │   ├── axi_sysid_ip.tcl
│   │   │   ├── axi_sysid_ltt.tcl
│   │   │   ├── axi_sysid.v
│   │   │   └── readme.rst
│   │   ├── common
│   │   │   ├── ad_3w_spi.v
│   │   │   ├── ad_addsub.v
│   │   │   ├── ad_adl5904_rst.v
│   │   │   ├── ad_axis_inf_rx.v
│   │   │   ├── ad_b2g.v
│   │   │   ├── ad_bus_mux.v
│   │   │   ├── ad_csc_CrYCb2RGB.v
│   │   │   ├── ad_csc_RGB2CrYCb.v
│   │   │   ├── ad_csc.v
│   │   │   ├── ad_datafmt.v
│   │   │   ├── ad_dds_1.v
│   │   │   ├── ad_dds_2.v
│   │   │   ├── ad_dds_cordic_pipe.v
│   │   │   ├── ad_dds_sine_cordic.v
│   │   │   ├── ad_dds_sine.v
│   │   │   ├── ad_dds.v
│   │   │   ├── ad_edge_detect.v
│   │   │   ├── ad_g2b.v
│   │   │   ├── ad_iobuf.v
│   │   │   ├── ad_iqcor.v
│   │   │   ├── ad_mem_asym.v
│   │   │   ├── ad_mem_dual.v
│   │   │   ├── ad_mem.v
│   │   │   ├── ad_mux_core.v
│   │   │   ├── ad_mux.v
│   │   │   ├── ad_pack.v
│   │   │   ├── ad_perfect_shuffle.v
│   │   │   ├── ad_pngen.v
│   │   │   ├── ad_pnmon.v
│   │   │   ├── ad_pps_receiver_constr.ttcl
│   │   │   ├── ad_pps_receiver.v
│   │   │   ├── ad_rst.v
│   │   │   ├── ad_ss_422to444.v
│   │   │   ├── ad_ss_444to422.v
│   │   │   ├── ad_sysref_gen.v
│   │   │   ├── ad_tdd_control.v
│   │   │   ├── ad_upack.v
│   │   │   ├── ad_xcvr_rx_if.v
│   │   │   ├── axi_ctrlif.vhd
│   │   │   ├── axi_streaming_dma_rx_fifo.vhd
│   │   │   ├── axi_streaming_dma_tx_fifo.vhd
│   │   │   ├── dma_fifo.vhd
│   │   │   ├── pl330_dma_fifo.vhd
│   │   │   ├── tb
│   │   │   │   ├── ad_mux_tb
│   │   │   │   ├── ad_mux_tb.v
│   │   │   │   ├── ad_pack_tb
│   │   │   │   ├── ad_pack_tb.v
│   │   │   │   ├── ad_upack_tb
│   │   │   │   ├── ad_upack_tb.v
│   │   │   │   ├── generate_xml.sh
│   │   │   │   ├── run_tb.sh
│   │   │   │   └── tb_base.v
│   │   │   ├── up_adc_channel.v
│   │   │   ├── up_adc_common.v
│   │   │   ├── up_axi.v
│   │   │   ├── up_clkgen.v
│   │   │   ├── up_clock_mon.v
│   │   │   ├── up_dac_channel.v
│   │   │   ├── up_dac_common.v
│   │   │   ├── up_delay_cntrl.v
│   │   │   ├── up_hdmi_rx.v
│   │   │   ├── up_hdmi_tx.v
│   │   │   ├── up_pmod.v
│   │   │   ├── up_tdd_cntrl.v
│   │   │   ├── up_xfer_cntrl.v
│   │   │   ├── up_xfer_status.v
│   │   │   ├── util_axis_upscale.v
│   │   │   ├── util_dec256sinc24b.v
│   │   │   ├── util_delay.v
│   │   │   ├── util_ext_sync.v
│   │   │   ├── util_pipeline_stage.v
│   │   │   └── util_pulse_gen.v
│   │   ├── intel
│   │   │   └── common
│   │   │       ├── ad_dcfilter.v
│   │   │       ├── ad_mul.v
│   │   │       ├── intel_mem_asym
│   │   │       │   └── intel_mem_asym_hw.tcl
│   │   │       ├── intel_serdes
│   │   │       │   └── intel_serdes_hw.tcl
│   │   │       ├── up_clock_mon_constr.sdc
│   │   │       ├── up_rst_constr.sdc
│   │   │       ├── up_xfer_cntrl_constr.sdc
│   │   │       └── up_xfer_status_constr.sdc
│   │   ├── interfaces
│   │   │   ├── fifo_rd_rtl.xml
│   │   │   ├── fifo_rd.xml
│   │   │   ├── fifo_wr_rtl.xml
│   │   │   ├── fifo_wr.xml
│   │   │   ├── if_do_ctrl_rtl.xml
│   │   │   ├── if_gt_qpll_rtl.xml
│   │   │   ├── if_xcvr_cm_rtl.xml
│   │   │   └── interfaces_ip.tcl
│   │   ├── interfaces_ltt
│   │   │   └── interfaces_ltt.tcl
│   │   ├── README.md
│   │   ├── sysid_rom
│   │   │   ├── sysid_rom_hw.tcl
│   │   │   ├── sysid_rom_ip.tcl
│   │   │   ├── sysid_rom_ltt.tcl
│   │   │   └── sysid_rom.v
│   │   ├── util_axis_fifo
│   │   │   ├── util_axis_fifo_address_generator.v
│   │   │   ├── util_axis_fifo_ip.tcl
│   │   │   └── util_axis_fifo.v
│   │   ├── util_cdc
│   │   │   ├── sync_bits.v
│   │   │   ├── sync_data.v
│   │   │   ├── sync_event.v
│   │   │   ├── sync_gray.v
│   │   │   ├── util_cdc_constr.tcl
│   │   │   └── util_cdc_ip.tcl
│   │   ├── util_cpack2
│   │   │   ├── util_cpack2_hw.tcl
│   │   │   ├── util_cpack2_impl.v
│   │   │   ├── util_cpack2_ip.tcl
│   │   │   └── util_cpack2.v
│   │   ├── util_pack_common
│   │   │   ├── pack_ctrl.v
│   │   │   ├── pack_interconnect.v
│   │   │   ├── pack_network.v
│   │   │   ├── pack_shell.v
│   │   │   └── tb
│   │   │       ├── cpack_tb
│   │   │       ├── cpack_tb.v
│   │   │       ├── tb_base.v
│   │   │       ├── underflow_tb
│   │   │       ├── underflow_tb.v
│   │   │       ├── upack_tb
│   │   │       └── upack_tb.v
│   │   ├── util_upack2
│   │   │   ├── util_upack2_hw.tcl
│   │   │   ├── util_upack2_impl.v
│   │   │   ├── util_upack2_ip.tcl
│   │   │   └── util_upack2.v
│   │   └── xilinx
│   │       ├── common
│   │       │   ├── ad_data_clk.v
│   │       │   ├── ad_data_in.v
│   │       │   ├── ad_data_out.v
│   │       │   ├── ad_dcfilter.v
│   │       │   ├── ad_mmcm_drp.v
│   │       │   ├── ad_mul.v
│   │       │   ├── ad_rst_constr.xdc
│   │       │   ├── ad_serdes_clk.v
│   │       │   ├── ad_serdes_in.v
│   │       │   ├── ad_serdes_out.v
│   │       │   ├── up_clock_mon_constr.xdc
│   │       │   ├── up_xfer_cntrl_constr.xdc
│   │       │   └── up_xfer_status_constr.xdc
│   │       ├── versal_xcvr_subsystem.tcl
│   │       └── xcvr_automation.tcl
│   └── xdc
│       ├── lvds_constr.xdc
│       └── system_constr.xdc
└── tree.txt
```

IP is stored directly under `src/ip/`, without `adi_library/`, `adi_hdl/`,
or reference-board project directories. IP-specific Tcl, TTcl templates, BD
callbacks, and test runners stay beside the corresponding IP sources, as in
T7. `scripts/` contains only project scripts and shared ADI helpers; no extra
Makefiles or compatibility links are needed inside `src/ip/`.

The design targets `xczu15eg-ffvb1156-2-i`, not the ZCU102 reference board.
The `axi_adrv9001` IP name is retained because this ADI IP supports ADRV9002.

## Building

Use Vivado 2024.1, with its tools available on `PATH`:

- `make` or `make msdr`: package IP, create the project, synthesize, implement,
  and export `msdr_gen/msdr.sdk/system_top.xsa`.
- `make lib`: package only the required IP.
- `ADI_SKIP_SYNTHESIS=1 make`: package IP and create/validate the project,
  without synthesis or implementation.
- `make clean`: remove only `msdr_gen/`, leaving source and other output
  directories untouched.

Only LVDS is supported (`CMOS_LVDS_N=0`, the default).

IP packaging runs from staged sources under `msdr_gen/ip/`. Vivado-generated
Tcl/XGUI files, component XML, constraints expanded from TTcl, logs, and caches
stay under `msdr_gen/`; authored IP Tcl/TTcl stays in `src/ip/`. Changes to IP
sources or packaging scripts trigger repackaging.

Generated Vivado/Simulink output and editor recovery files are excluded by
`.gitignore`. Keep HDL, IP packaging scripts, constraints, Simulink models,
and documentation as source; do not commit generated caches or build output.
