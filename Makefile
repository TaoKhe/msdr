.DEFAULT_GOAL := all

.PHONY: all msdr clean

all:
	$(MAKE) -C scripts

msdr clean:
	$(MAKE) -C scripts $@
