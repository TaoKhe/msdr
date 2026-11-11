# Convenience entry point: locate the repository root and load the vendored
# ADI HDL environment from src/hdl.
set msdr_root [file normalize [file join [file dirname [info script]] ..]]
source [file join $msdr_root src hdl scripts adi_env.tcl]
