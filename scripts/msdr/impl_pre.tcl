# Never hide genuine multiple-driver or unconstrained-I/O violations.
foreach check {MDRV-1 NSTD-1 UCIO-1} {
  reset_property SEVERITY [get_drc_checks $check]
}
