MSDR_ROOT := $(abspath .)
BUILD_DIR := msdr_gen
IP_NAMES := util_cdc util_axis_fifo axi_adrv9001 axi_dmac axi_sysid sysid_rom util_cpack2 util_upack2
IP_SOURCES := $(shell find src/ip -type f)
IP_SCRIPTS := $(wildcard scripts/adi/*.tcl)
IP_STAMP := $(BUILD_DIR)/ip/.packaged
PROJECT_TCL := $(MSDR_ROOT)/scripts/system_project.tcl
PROJECT_XSA := $(BUILD_DIR)/msdr.sdk/system_top.xsa

.DEFAULT_GOAL := all
.DELETE_ON_ERROR:

CMOS_LVDS_N ?= 0
ifneq ($(CMOS_LVDS_N),0)
$(error T12 XCZU15EG supports only LVDS. Use CMOS_LVDS_N=0)
endif
export CMOS_LVDS_N
export ADI_HDL_DIR := $(MSDR_ROOT)
export ADI_IP_REPO := $(MSDR_ROOT)/$(BUILD_DIR)/ip
export ADI_PROJECT_DIR := $(BUILD_DIR)/
export ADI_SYSTEM_BD_TCL := $(MSDR_ROOT)/scripts/system_bd.tcl

VIVADO := vivado -mode batch -notrace

.PHONY: all msdr lib clean

all: msdr

msdr: $(PROJECT_XSA)

lib: $(IP_STAMP)

$(IP_STAMP): $(IP_SOURCES) $(IP_SCRIPTS) scripts/build_ip.tcl scripts/adi_env.tcl Makefile
	@mkdir -p $(BUILD_DIR)
	$(VIVADO) -log $(BUILD_DIR)/ip_build.log -journal $(BUILD_DIR)/ip_build.jou \
		-tempDir $(BUILD_DIR)/.Xil -source scripts/build_ip.tcl -tclargs $(IP_NAMES)
	@for ip in $(IP_NAMES); do \
		test -f "$(BUILD_DIR)/ip/$$ip/component.xml" || \
		{ echo "Missing generated IP package: $$ip" >&2; exit 1; }; \
	done
	@touch $@

$(PROJECT_XSA): $(IP_STAMP) $(wildcard scripts/*.tcl) $(shell find src/hdl src/xdc -type f) Makefile
	$(VIVADO) -log $(BUILD_DIR)/vivado.log -journal $(BUILD_DIR)/vivado.jou \
		-tempDir $(BUILD_DIR)/.Xil -source $(PROJECT_TCL)
	@test -f $(BUILD_DIR)/msdr.xpr || { echo "Missing generated MSDR project" >&2; exit 1; }
	@if [ -z "$$ADI_SKIP_SYNTHESIS" ]; then \
		test -f $@ || { echo "Missing generated hardware export: $@" >&2; exit 1; }; \
	fi

clean:
	rm -rf -- $(MSDR_ROOT)/msdr_gen
