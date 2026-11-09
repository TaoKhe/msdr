MSDR_ROOT := $(abspath ../../../../../../)
DIR_NAME ?= ../../../../../../msdr_gen_v4

PROJECT_NAME := msdr
PROJECT_TCL := $(MSDR_ROOT)/scripts/system_project.tcl
SYSTEM_BD_TCL := $(MSDR_ROOT)/scripts/system_bd.tcl

M_DEPS += $(MSDR_ROOT)/scripts/msdr_bd.tcl
M_DEPS += $(MSDR_ROOT)/src/hdl/top/system_top.v
M_DEPS += $(MSDR_ROOT)/src/xdc/system_constr.xdc
M_DEPS += $(MSDR_ROOT)/src/xdc/lvds_constr.xdc
M_DEPS += ../../scripts/adi_pd.tcl
M_DEPS += ../../../library/common/ad_iobuf.v

LIB_DEPS += axi_adrv9001
LIB_DEPS += axi_dmac
LIB_DEPS += axi_sysid
LIB_DEPS += sysid_rom
LIB_DEPS += util_pack/util_cpack2
LIB_DEPS += util_pack/util_upack2

include ../../scripts/project-xilinx.mk
