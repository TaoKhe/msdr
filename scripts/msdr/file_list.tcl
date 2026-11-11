###############################################################################
## Nguon TRX chuyen tu tvsdr_rfu_trx sang MSDR.
##
## Duoc system_project.tcl source sau adi_project_create, truoc adi_project_run.
## Bien msdr_root phai da duoc dat.
##
## Luu y ve cac entity trung ten: cay nguon chua nhieu ban cua cung mot entity
## (aurora/ vs aurora_mbu/, aurora_framer/ vs aurora_framer_tx/, fsm/ vs
## fsm/fsm_bk/, time_sync/ vs time_sync_v2/). Chi duoc them MOT ban moi loai,
## neu khong Vivado se bao trung khai bao. Lua chon o day:
##   aurora/            - ban RFU, co aurora_status_o (aurora_mbu/ la ban MBU)
##   aurora_framer/     - ban dang dung cua aurora_protocol
##   fsm/               - ban hien hanh (fsm_bk/ la ban luu truoc do)
##   time_sync_v2/      - ban moi, co ts_delay_cyc va vong VCXO
##   time_sync/         - CHI lay time_sync_axi_ro.vhd (v2 khong co file nay)
###############################################################################

set trx_hdl [file join $msdr_root src hdl]
set trx_ip  [file join $msdr_root src ip]

###############################################################################
## Tang tich hop MSDR
###############################################################################
## msdr_fpga is the project top, not a BD module reference, so it can use
## VHDL 2008. Keep the register module compatible with BD module references.
set trx_top_sources [list \
  [file join $trx_hdl top msdr_fpga_v3.vhd] \
  [file join $trx_hdl msdr_trx msdr_trx_regs.vhd] \
]

set trx_sources [list]

###############################################################################
## Link Aurora toi BBU: GTH + giao thuc khung + GFP
###############################################################################
lappend trx_sources \
  [file join $trx_hdl aurora aurora_wrapper.vhd] \
  [file join $trx_hdl aurora aurora_protocol.vhd] \
  [file join $trx_hdl aurora_framer aurora_framer.vhd] \
  [file join $trx_hdl aurora_deframer aurora_deframer.vhd] \
  [file join $trx_hdl gfp_module gfp_packer.vhd] \
  [file join $trx_hdl gfp_module gfp_depacker.vhd] \
  [file join $trx_hdl Waveform_streamer Waveform_streamer.vhd] \
  [file join $trx_hdl ub_tx_spi.vhd] \
  [file join $trx_hdl NB6L295_Driver NB6L295_Driver.vhd] \
  [file join $trx_hdl time_sync_v2 time_sync_v2 vcsco_wrapper.vhd]

###############################################################################
## Dong bo thoi gian (1PPS tu BBU + timestamp trong khung Aurora)
###############################################################################
set ts_v2 [file join $trx_hdl time_sync_v2 time_sync_v2]
lappend trx_sources \
  [file join $ts_v2 local_time_nco.vhd] \
  [file join $ts_v2 pps_cap.vhd] \
  [file join $ts_v2 ts_offset_calc.vhd] \
  [file join $ts_v2 error_combiner_filter.vhd] \
  [file join $ts_v2 time_servo_pi.vhd] \
  [file join $ts_v2 vcxo_freq_error.vhd] \
  [file join $ts_v2 vcxo_dac_mapper.vhd] \
  [file join $ts_v2 time_sync_top.vhd]

###############################################################################
## Dieu khien RF: may trang thai khung TDD va cac driver no goi
##
## fsm_main instantiate truc tiep AD_9164_Driver, AD9914_Driver, ADF41510_Driver,
## MAAD_011045_Driver, PLL_Driver va LB_TBPF_NetCom_5670_x_D_Driver. T12 KHONG co
## cac IC do -
## trong msdr_rf_ctrl.vhd moi ngo ra cua chung deu de "open" nen tong hop se
## loai bo het. Cac file van phai co mat thi fsm_main moi elaborate duoc; muon
## xoa han thi phai sua ben trong fsm_main, tuc la viet lai phan giai ma bang
## tan cho chuoi RF cua T12.
###############################################################################
lappend trx_sources \
  [file join $trx_hdl fsm fsm_main.vhd] \
  [file join $trx_hdl fsm gpio_fsm.vhd] \
  [file join $trx_hdl fsm spi_master.vhd] \
  [file join $trx_hdl fsm tx_ctrl.vhd] \
  [file join $trx_hdl fsm GPIO_Mux.vhd] \
  [file join $trx_hdl fsm GPIO_Mux_wrapper.vhd] \
  [file join $trx_hdl fsm gpio_band_decoder.vhd] \
  [file join $trx_hdl fsm bram_interface.vhd] \
  [file join $trx_hdl ADMV_8xxx_Driver ADMV8xxx_Driver.vhd] \
  [file join $trx_hdl AD9164_Driver AD_9164_Driver.vhd] \
  [file join $trx_hdl AD9914_Driver AD9914_Driver.vhd] \
  [file join $trx_hdl ADF41510_Driver ADF41510_Driver.vhd] \
  [file join $trx_hdl MAAD_011045_Driver MAAD_011045_Driver.vhd] \
  [file join $trx_hdl PLL PLL_Driver.vhd] \
  [file join $trx_hdl LB_TBPF_NetCom_5670_x_D_Driver LB_TBPF_NetCom_5670_x_D_Driver.vhd]

add_files -norecurse $trx_top_sources
set_property FILE_TYPE {VHDL} [get_files $trx_top_sources]
set_property FILE_TYPE {VHDL 2008} [get_files [file join $trx_hdl top msdr_fpga_v3.vhd]]

add_files -norecurse $trx_sources
add_files -norecurse [list \
  [file join $trx_hdl ad_3w_spi.v] \
  [file join $trx_hdl sys_info system_info_wrapper.v] \
  [file join $trx_hdl sys_info system_infor.vh] \
  [file join $trx_hdl sys_info system_info.vhd] ]
set_property FILE_TYPE {VHDL 2008} [get_files $trx_sources]

# Bang tra GPIO theo bang tan cua gpio_band_decoder, va song GMSK cho
# Waveform_streamer (ROM Wavefor_storer_4k nap tu file .coe nay).
add_files -norecurse [file join $trx_hdl fsm gpio.coe]
add_files -norecurse [file join $trx_hdl Waveform_streamer GMSK_2Mbps_BT_0p3_250Msps_rand_data_4k_HEX.coe]

###############################################################################
## IP. Tat ca deu da duoc dat lai muc tieu sang xczu15eg-ffvb1156-2-i.
###############################################################################
set trx_ips [list \
  aurora_64b66b_0 \
  GFP_fifo_0 \
  GFP_fifo_packetmode \
  SA_fifo_0 \
  SA_stream_FIFO \
  IQ_stream_FIFO \
  IQ_conver_width \
  fifo_test \
  Adder_32 \
  DAC_mult_B \
  mult_DDS \
  mult_INT \
  LB_TBPF_mult \
  gpio_BRAM \
  dds_compiler_1 \
  Wavefor_storer_4k \
  ila_framer \
  vio_0 \
  vio_ts \
  ila_deframer_meta_ip \
  ila_fsm_dbg \
]

foreach ip $trx_ips {
  set xci [file join $trx_ip $ip $ip.xci]
  if {![file exists $xci]} {
    error "Khong tim thay IP $ip tai $xci"
  }
  # import_ip chu khong phai add_files: cac .xci nay mang theo duong dan goc cua
  # project tvsdr cu, add_files se co sinh san pham ra duong do (Vivado 12-13650).
  # import_ip chep .xci vao trong project nen moi thu sinh ra dung cho.
  import_ip -quiet -files $xci
}

source [file join $msdr_root scripts msdr create_tx_fir_ip.tcl]

# Hai IP nap noi dung tu file .coe bang duong dan TUONG DOI so voi .xci goc.
# import_ip chep .xci vao trong project nen duong dan do gay; dat lai bang
# duong dan tuyet doi sau khi import.
foreach {ip coe} [list \
  gpio_BRAM        [file join $trx_hdl fsm gpio.coe] \
  Wavefor_storer_4k [file join $trx_hdl Waveform_streamer GMSK_2Mbps_BT_0p3_250Msps_rand_data_4k_HEX.coe] ] {
  set obj [get_ips -quiet $ip]
  if {$obj ne ""} {
    set_property CONFIG.Coe_File $coe $obj
  }
}

# IP nao con bi khoa vi tao tu part khac thi nang cap tai cho.
set locked [get_ips -quiet -filter {IS_LOCKED}]
if {[llength $locked] > 0} {
  puts "file_list.tcl: nang cap IP bi khoa: $locked"
  upgrade_ip -quiet $locked
}

update_compile_order -fileset sources_1

# T12 sheet 24 routes Aurora L1 to bank 230, channel 0.
set_property -dict [list CONFIG.CHANNEL_ENABLE {X1Y12} \
  CONFIG.C_START_QUAD {Quad_X1Y3} CONFIG.C_START_LANE {X1Y12} \
  CONFIG.C_REFCLK_SOURCE {MGTREFCLK0_of_Quad_X1Y3}] [get_ips aurora_64b66b_0]
