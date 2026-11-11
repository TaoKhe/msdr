###############################################################################
## MSDR FPGA build
##
## Each design variant lives in scripts/<variant>/ and is built by running
## Vivado there; the generated project is written to <variant>_gen/.
###############################################################################

SHELL := /bin/bash

ADI_HDL := src/hdl
MSDR_PROJECT_DIR ?= msdr_v3_16bit_cdcfix_gen

# Nguon TRX chuyen tu tvsdr_rfu_trx nam trong src/hdl/msdr_trx, src/hdl/aurora*,
# src/hdl/gfp_module, src/hdl/time_sync*, src/hdl/fsm va cac *_Driver. Chung
# duoc nap qua scripts/msdr/file_list.tcl, khong phai qua LIB_DEPS duoi day:
# do la HDL thuong chu khong phai IP dong goi cua ADI.

# ADI IP libraries the block design instantiates. Built into $(ADI_HDL)/library,
# which is the IP repository path Vivado is pointed at.
LIB_DEPS := axi_adrv9001
LIB_DEPS += axi_dmac
LIB_DEPS += axi_sysid
LIB_DEPS += sysid_rom
LIB_DEPS += util_pack/util_cpack2
LIB_DEPS += util_pack/util_upack2


.DEFAULT_GOAL := msdr
.PHONY: all msdr adrv9001_zcu102 lib help project-msdr-v4 build-msdr-v4 \
        project-msdr project-adrv9001_zcu102 \
        gui-msdr gui-adrv9001_zcu102 \
        clean clean-msdr clean-adrv9001_zcu102 clean-lib clean-ipcache

all: msdr adrv9001_zcu102   ## Build every variant (bare `make` builds msdr only)

help:          ## List the available targets
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[1m%-16s\033[0m %s\n", $$1, $$2}'

project-msdr-v4: ## Recreate current v3 configuration and generate HDL/IP into msdr_recreated_v4_gen/
	MSDR_CREATE_ONLY=1 vivado -mode batch -nojournal -nolog -source scripts/msdr/build_recreated_v4.tcl

build-msdr-v4: ## Recreate current v3 configuration and build a bitstream into a new v4 directory
	vivado -mode batch -nojournal -nolog -source scripts/msdr/build_recreated_v4.tcl

# build_variant <variant-name>
#   Runs Vivado from scripts/<variant>, which is both where system_project.tcl
#   lives and the directory adi_project_create resolves "system_bd.tcl" against.
#   ADI_PROJECT_DIR redirects generated artefacts into the selected output dir.
define build_variant
	@set -e; \
	  project_dir="$(if $(3),$(3),$(1)_gen)"; \
	  if [[ -e "$$project_dir" ]]; then \
	    echo "Refusing to overwrite existing output directory: $$project_dir"; exit 1; \
	  fi; \
	  mkdir -p "$$project_dir"; \
	  echo -n "Building $(1) project [$$project_dir/$(1)_vivado.log] ..."; \
	  cd scripts/$(1) && \
	    ADI_PROJECT_DIR=../../$$project_dir/ \
	    ADI_CREATE_ONLY=$(2) \
	    vivado -tempDir ../../$$project_dir/.Xil \
	           -log ../../$$project_dir/vivado.log \
	           -journal ../../$$project_dir/vivado.jou \
	           -mode batch -source system_project.tcl \
	      > ../../$$project_dir/$(1)_vivado.log 2>&1 \
	    && echo " OK" \
	    || { echo " FAILED"; echo "For details see $$project_dir/$(1)_vivado.log"; exit 1; }
endef

msdr: lib   ## Create and implement current MSDR sources (xczu15eg) -> msdr_v3_16bit_cdcfix_gen/
	$(call build_variant,msdr,0,$(MSDR_PROJECT_DIR))

adrv9001_zcu102: lib   ## Create and implement ADRV9001/ZCU102 (xczu9eg) -> adrv9001_zcu102_gen/
	$(call build_variant,adrv9001_zcu102,0)

# Chi tao project + block design, khong synth/impl. Vai phut thay vi vai gio.
# Dung khi muon mo ra xem hoac sua block design.
project-msdr: lib   ## Create current MSDR project only (no synth/impl), then open with gui-msdr
	$(call build_variant,msdr,1,$(MSDR_PROJECT_DIR))

project-adrv9001_zcu102: lib ## Create ADRV9001/ZCU102 project only (no synth/impl)
	$(call build_variant,adrv9001_zcu102,1)

lib:           ## Build the ADI IP libraries into the local IP repository
	@for lib in $(LIB_DEPS); do \
	  flock $(ADI_HDL)/library/$$lib/.lock \
	    $(MAKE) --no-print-directory -C $(ADI_HDL)/library/$$lib xilinx || exit 1; \
	done

gui-msdr:      ## Open the current generated MSDR project in the Vivado GUI
	vivado -nolog -notrace -nojournal $(MSDR_PROJECT_DIR)/msdr.xpr &

gui-adrv9001_zcu102: ## Open the generated ADRV9001/ZCU102 project in the Vivado GUI
	vivado -nolog -notrace -nojournal adrv9001_zcu102_gen/adrv9001_zcu102.xpr &

clean: clean-msdr clean-adrv9001_zcu102   ## Remove current build outputs (keeps versioned archives)

clean-msdr:    ## Remove the default current generated MSDR project
	rm -rf -- msdr_v3_16bit_cdcfix_gen

clean-adrv9001_zcu102: ## Remove adrv9001_zcu102_gen/
	rm -rf adrv9001_zcu102_gen

clean-lib:     ## Clean the ADI IP libraries
	@for lib in $(LIB_DEPS); do \
	  $(MAKE) --no-print-directory -C $(ADI_HDL)/library/$$lib clean; \
	done

clean-ipcache: ## Drop the shared Vivado IP cache
	rm -rf $(ADI_HDL)/ipcache
