// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2024.1 (lin64) Build 5076996 Wed May 22 18:36:09 MDT 2024
// Date        : Mon Nov  9 13:13:34 2026
// Host        : server01 running 64-bit Ubuntu 22.04.5 LTS
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ Adder_32_sim_netlist.v
// Design      : Adder_32
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xczu15eg-ffvb1156-2-i
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "Adder_32,c_addsub_v12_0_18,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_addsub_v12_0_18,Vivado 2024.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (A,
    B,
    CLK,
    S);
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [31:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 b_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME b_intf, LAYERED_METADATA undef" *) input [31:0]B;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF s_intf:c_out_intf:sinit_intf:sset_intf:bypass_intf:c_in_intf:add_intf:b_intf:a_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 s_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME s_intf, LAYERED_METADATA undef" *) output [31:0]S;

  wire [31:0]A;
  wire [31:0]B;
  wire CLK;
  wire [31:0]S;
  wire NLW_U0_C_OUT_UNCONNECTED;

  (* C_ADD_MODE = "0" *) 
  (* C_AINIT_VAL = "0" *) 
  (* C_A_TYPE = "1" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_BORROW_LOW = "1" *) 
  (* C_BYPASS_LOW = "0" *) 
  (* C_B_CONSTANT = "0" *) 
  (* C_B_TYPE = "1" *) 
  (* C_B_VALUE = "00000000000000000000000000000000" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_CE_OVERRIDES_BYPASS = "1" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_BYPASS = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_C_IN = "0" *) 
  (* C_HAS_C_OUT = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "1" *) 
  (* C_LATENCY = "1" *) 
  (* C_OUT_WIDTH = "32" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "zynquplus" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_addsub_v12_0_18 U0
       (.A(A),
        .ADD(1'b1),
        .B(B),
        .BYPASS(1'b0),
        .CE(1'b1),
        .CLK(CLK),
        .C_IN(1'b0),
        .C_OUT(NLW_U0_C_OUT_UNCONNECTED),
        .S(S),
        .SCLR(1'b0),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2024.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
j+cisgNr51kboBzSEDMqVtItc+GjGUiMNF0E04YxNeYXTtpqczXoHl7p3pBX3lPxGHPUBdZ6oYbA
uFzQSoAOvv3ANxN24NJ35g39Gushnh3bAhkIaggJwqirNk8uvbFei0Q37GZcy7DTONZHx9iSsnwg
43qcv84+v1Oqg1QlkK0=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
LvmfIuwVQiUSvu/SWE90Ii3gBrSlLLUK62Pe9Uo5lexkMeDgQfulU0pV4/6bexfxf29XSUIZb3c9
av2fcRcp1ZeyqEnW0ei/HP4UoYfgCSzAUmuehTopxqUP3M4kX2/ETc0gdNuIi6qDHquW7YY9QQGa
g5MTm81zI19+yvQdowrY7g+W1mLrHRcb8Ho+qe0uZMYO9K9DLpwNlhtSf0qufVmJGM+5COEyqb1U
lL+nfwveqOc0IWRRpPS42kC7OR6BTARi5c6dKCQl/a9fojTU0hW9itdcCGK5DL1CuzhnLB3Cw1Lc
UIHvmiN+LslcbwXadjp0wvd8yuh6HziY0Vfxsw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
sxpYAYC9AO3d/Qq5Dz0dcOejYw99+MiH0W395D6tyIroWG9T14T6E7ryw+s/by4tx97NytW6qUN3
NXZVsmgnxSKTeXfcn+ZXRsWNPcQGtCaIdh8TbBiHtUeZecWXJ0/iGORapfLQxNbHmGtiSkN1eYCn
C7QZMw6qZPNfuNyivRg=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
E/GNyTiOpevKZa3+bbpJb0kDvoBk/eMnN/JT+ul7JFDogMwn8CpOobzq4ORZE40PqtaeX8shZ2Io
cJi8jjFyYeWd2nZtLZo0heKqX3v/pdf8QoQbxat3X7qE+EWjBbCn/ZFGg9zTrFFxwaHk42COVzlL
0j+PRabCWynZ5ILjyTP47frcmCN/iRKt0d+pvi/GA4UjFDtb6+9p1niifgkhCn1MkMBg8U/Y5knN
CVQ7z+g5SrUo/3bEiUXLkpBhMSliuE96gVp/dhIEh9H7jm8yTGyk0JzdtVTLaZLa+Lip0djJZLpb
UppZLdmVomSIk5FAqXrXZx6cyoWBJHtDlyJZkA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
hg0hZUmrq09eMOjEntvd+gf7Zd2U4BwDY1Jz7gQri0LZtchGB8Z8SRY7YjUyWlUFux+gzbhxtgxE
uXob+ZiD1GlC8r4A2zRmOzuSIMz5UnEhy5TMjR+8A23FUgB5H14Nk+8/ui0Zs/CqU3Odf3BBWOAg
zxnOh70mcUhtPTAIZ+EcN+1Ujtdp78bNTd2IQJcFIhDRt35kHTIgOpo8oDPU8cUgKH6HYVq0sF+B
1yu+k9PCMZikA3k51SJhEW/Qc39FpYPT9CKN0WwelzSM6CD2GrcLMAt1oh2PsLi9Pfz1zzfj+mED
XS3V2CvLYBAA5I2Zn5G1DKrCLW1s3QCGdjLFcQ==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2023_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ZihOD8xT0OXV+vYQgVKC2OgNYw1KaLnWHAc+JKheEAvf+yg1M7C7urUi93p572HyJs7Y4xmmO7jH
ND7Tv3yag5/ovBwWsoZpyr5RiGqozyxd59WCmh1IY/4VIOP7O8XrKDP4OGGR4Yrc69eGX7icFD/q
q1Yri9lFsLwghmgnG5/5LI0ZMQuooogdTmG+J2E0ZDBWfT/UmG0W92Ul8I3gfcKlKOiouwG5y4Jp
nBDOfD0ITqlCH9MMIsDa+elFeLXvv2KVvemlQ6QmFkF7trsIsF7QEhsAEKVsCYQTNVAGTL0GQsfh
sg3wRbAMH9DIJaQxk+17Z2Yacz0Veyzzwk9ehw==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
HY3h60x+HFg/eOgHTI4UVm9DtPW6wqUKca7u8NGVkEwgcMgpHEWwLglcdrxdQNjcwm8OHot4ETKF
WKbgVoX+iDWvtyepO4qxoxeWXH2F1fmkO5TcCS5lfsbj510UC680iv6lj8Cyu8iiRTaXR/o4FoM0
fC0fK1I3vPhOTQ5CR3OgRKAFDdX+d/qZ444LSpBM+tvjaaKR1BRRMkaGxO58SlkZRhBySU0nhAQy
dLhrkimMDrmmj/sej98ps6eMFspr8+5pUYJg+vWp++Sm0zHT5N6L1+n+oCGTjgEAgNvxvIgPv6O6
O614qs4bb0unrlrWFTLtb8eoiQe9RHpwGopwlw==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
UwlS0UvncccxxkW4NnEPYSb0LG5K+diX5o0hrXyga8q/gD9ab0W8hccMe2HgIOrJ0coq4cXubRll
ZpfwAORkvZtLjLAkjJkvmwum68290Kk65/t/Zns9LY543if5KVhDzDg632T/2/g+S4iACupycWXY
cZ6s39/F2p//kX1YHKh6qPf3qkoP25aHoXQhlWkBAIGe3uIyPYPXstbeMaMeWMmKTh0rnBbtpr8y
0Qg1S5j9DIzW9sNl57338zbHnQbUbJzw5eAHPIYReJLbGLoFizMzbCeVUf9qQcME/zhozlHMqIYN
Mafo4cDvvsMIs8ppl+EWkfmPwMyBiDor8XdnJwhL6PXvmC52OK25D9SarDCqe+sqUKRPLYOzZm9s
mRp4pTSLWqKlA4Kmt9Om1GAjesqP6fBmfP1NGnjIrnslWz4gi45DlpUHMRKmIlfMjMLoDcxkJyie
bdt0EiJv3tUHW+hzM1osET2y5r7UP2tXX1I0KcbPrsM8mAjAbCi8yC8b

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
X0dvE3L7dLQCMLonwloQgw5itpWmwVthmLjXvNCwkkUnrWRnIFGWcVV+7J059QS+MH4TlngLY35K
jozGLlOeR74+bBTejoxLYWg2EOfziRkOnWV2uSeOTEyEL+LD9sSATD6G+de3w3tolkltsugp6Asm
4+ouB1syLSHEJDe3i6xdrhgn2gjStQgaIBrGx67K6P9M/ZpIE3tJpGwQpXAQW6mcrqXnyP8s9OOR
lKGNPgaQFWDxxHZY806A4MaHpWk9o7ni2o+CNUO1IEpPDpNcX5kMGjPY2d5U2F21JssOrE9gdyeA
WYmROE1TZ0h61Y5QNSuC42zh2bxl5RnU9Yw9kA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
oIVzpSluI7daBxkOk2gHCozBGlbxG53WoEhOzUaurQiUeJP9/arWOJWk+fvz3PNZhGKqhMT34Elf
4CE16vrKhBto+aiBjmbTGqgpcZuAov0ThKrdb5D2RErj9L03MzOMQdBEb2OGyWHIaVcOR12TL/Pc
ppZorRLXpXsMO6OiQvQgS6gBpPLmoJ/4mFQU2y7Gq4fQ1w0mBb5WD4aOFS27kco9sWZg134eJyHh
g3WophY4AK3S6VNrjwfZ8V2EHcWlysmTyQhS/i6nISRdlQIyBBenPXI1qC3X2elRwJJ1rDBw4tSk
FPpZVv+Pg6wD1lxgePFMJlGymPGte/sHafK1og==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
flfR64NYycLIyauxCLn1wC38i1K4/yOEiIIS/pzPw5b4T8AQasCEhfXccXWd7XYD8tVTgjkiZlil
BY/FskgSGdAPW60ru4A65EEa7ULY+aPS1CSMAW6nANPgjVXgGu5AsFKiDjSfY+ibvvFHUmJ8Zmez
wEdjdaf1uPn8gwW70f2+rXV6O5zQnCdBG+tQ5cUZMYqSxcdKZEcd7uFDN1+GqykP0vqNVRZMAmZE
umrRSJg1a1YyLdwwKiD+UbAJWJ0KQNS+4RQTCOHtz8/EK1t1YnoCf5KBTTe57whtj0S+rfOK5HaB
upEqngWyR+h+SKSvfYHRQkIHJPKSCB9buGG6MQ==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 2688)
`pragma protect data_block
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
kGuAvdFQ8d/1
`pragma protect end_protected
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2024.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
j+cisgNr51kboBzSEDMqVtItc+GjGUiMNF0E04YxNeYXTtpqczXoHl7p3pBX3lPxGHPUBdZ6oYbA
uFzQSoAOvv3ANxN24NJ35g39Gushnh3bAhkIaggJwqirNk8uvbFei0Q37GZcy7DTONZHx9iSsnwg
43qcv84+v1Oqg1QlkK0=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
LvmfIuwVQiUSvu/SWE90Ii3gBrSlLLUK62Pe9Uo5lexkMeDgQfulU0pV4/6bexfxf29XSUIZb3c9
av2fcRcp1ZeyqEnW0ei/HP4UoYfgCSzAUmuehTopxqUP3M4kX2/ETc0gdNuIi6qDHquW7YY9QQGa
g5MTm81zI19+yvQdowrY7g+W1mLrHRcb8Ho+qe0uZMYO9K9DLpwNlhtSf0qufVmJGM+5COEyqb1U
lL+nfwveqOc0IWRRpPS42kC7OR6BTARi5c6dKCQl/a9fojTU0hW9itdcCGK5DL1CuzhnLB3Cw1Lc
UIHvmiN+LslcbwXadjp0wvd8yuh6HziY0Vfxsw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
sxpYAYC9AO3d/Qq5Dz0dcOejYw99+MiH0W395D6tyIroWG9T14T6E7ryw+s/by4tx97NytW6qUN3
NXZVsmgnxSKTeXfcn+ZXRsWNPcQGtCaIdh8TbBiHtUeZecWXJ0/iGORapfLQxNbHmGtiSkN1eYCn
C7QZMw6qZPNfuNyivRg=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
E/GNyTiOpevKZa3+bbpJb0kDvoBk/eMnN/JT+ul7JFDogMwn8CpOobzq4ORZE40PqtaeX8shZ2Io
cJi8jjFyYeWd2nZtLZo0heKqX3v/pdf8QoQbxat3X7qE+EWjBbCn/ZFGg9zTrFFxwaHk42COVzlL
0j+PRabCWynZ5ILjyTP47frcmCN/iRKt0d+pvi/GA4UjFDtb6+9p1niifgkhCn1MkMBg8U/Y5knN
CVQ7z+g5SrUo/3bEiUXLkpBhMSliuE96gVp/dhIEh9H7jm8yTGyk0JzdtVTLaZLa+Lip0djJZLpb
UppZLdmVomSIk5FAqXrXZx6cyoWBJHtDlyJZkA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
hg0hZUmrq09eMOjEntvd+gf7Zd2U4BwDY1Jz7gQri0LZtchGB8Z8SRY7YjUyWlUFux+gzbhxtgxE
uXob+ZiD1GlC8r4A2zRmOzuSIMz5UnEhy5TMjR+8A23FUgB5H14Nk+8/ui0Zs/CqU3Odf3BBWOAg
zxnOh70mcUhtPTAIZ+EcN+1Ujtdp78bNTd2IQJcFIhDRt35kHTIgOpo8oDPU8cUgKH6HYVq0sF+B
1yu+k9PCMZikA3k51SJhEW/Qc39FpYPT9CKN0WwelzSM6CD2GrcLMAt1oh2PsLi9Pfz1zzfj+mED
XS3V2CvLYBAA5I2Zn5G1DKrCLW1s3QCGdjLFcQ==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2023_11", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ZihOD8xT0OXV+vYQgVKC2OgNYw1KaLnWHAc+JKheEAvf+yg1M7C7urUi93p572HyJs7Y4xmmO7jH
ND7Tv3yag5/ovBwWsoZpyr5RiGqozyxd59WCmh1IY/4VIOP7O8XrKDP4OGGR4Yrc69eGX7icFD/q
q1Yri9lFsLwghmgnG5/5LI0ZMQuooogdTmG+J2E0ZDBWfT/UmG0W92Ul8I3gfcKlKOiouwG5y4Jp
nBDOfD0ITqlCH9MMIsDa+elFeLXvv2KVvemlQ6QmFkF7trsIsF7QEhsAEKVsCYQTNVAGTL0GQsfh
sg3wRbAMH9DIJaQxk+17Z2Yacz0Veyzzwk9ehw==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
HY3h60x+HFg/eOgHTI4UVm9DtPW6wqUKca7u8NGVkEwgcMgpHEWwLglcdrxdQNjcwm8OHot4ETKF
WKbgVoX+iDWvtyepO4qxoxeWXH2F1fmkO5TcCS5lfsbj510UC680iv6lj8Cyu8iiRTaXR/o4FoM0
fC0fK1I3vPhOTQ5CR3OgRKAFDdX+d/qZ444LSpBM+tvjaaKR1BRRMkaGxO58SlkZRhBySU0nhAQy
dLhrkimMDrmmj/sej98ps6eMFspr8+5pUYJg+vWp++Sm0zHT5N6L1+n+oCGTjgEAgNvxvIgPv6O6
O614qs4bb0unrlrWFTLtb8eoiQe9RHpwGopwlw==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
UwlS0UvncccxxkW4NnEPYSb0LG5K+diX5o0hrXyga8q/gD9ab0W8hccMe2HgIOrJ0coq4cXubRll
ZpfwAORkvZtLjLAkjJkvmwum68290Kk65/t/Zns9LY543if5KVhDzDg632T/2/g+S4iACupycWXY
cZ6s39/F2p//kX1YHKh6qPf3qkoP25aHoXQhlWkBAIGe3uIyPYPXstbeMaMeWMmKTh0rnBbtpr8y
0Qg1S5j9DIzW9sNl57338zbHnQbUbJzw5eAHPIYReJLbGLoFizMzbCeVUf9qQcME/zhozlHMqIYN
Mafo4cDvvsMIs8ppl+EWkfmPwMyBiDor8XdnJwhL6PXvmC52OK25D9SarDCqe+sqUKRPLYOzZm9s
mRp4pTSLWqKlA4Kmt9Om1GAjesqP6fBmfP1NGnjIrnslWz4gi45DlpUHMRKmIlfMjMLoDcxkJyie
bdt0EiJv3tUHW+hzM1osET2y5r7UP2tXX1I0KcbPrsM8mAjAbCi8yC8b

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
X0dvE3L7dLQCMLonwloQgw5itpWmwVthmLjXvNCwkkUnrWRnIFGWcVV+7J059QS+MH4TlngLY35K
jozGLlOeR74+bBTejoxLYWg2EOfziRkOnWV2uSeOTEyEL+LD9sSATD6G+de3w3tolkltsugp6Asm
4+ouB1syLSHEJDe3i6xdrhgn2gjStQgaIBrGx67K6P9M/ZpIE3tJpGwQpXAQW6mcrqXnyP8s9OOR
lKGNPgaQFWDxxHZY806A4MaHpWk9o7ni2o+CNUO1IEpPDpNcX5kMGjPY2d5U2F21JssOrE9gdyeA
WYmROE1TZ0h61Y5QNSuC42zh2bxl5RnU9Yw9kA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
oIVzpSluI7daBxkOk2gHCozBGlbxG53WoEhOzUaurQiUeJP9/arWOJWk+fvz3PNZhGKqhMT34Elf
4CE16vrKhBto+aiBjmbTGqgpcZuAov0ThKrdb5D2RErj9L03MzOMQdBEb2OGyWHIaVcOR12TL/Pc
ppZorRLXpXsMO6OiQvQgS6gBpPLmoJ/4mFQU2y7Gq4fQ1w0mBb5WD4aOFS27kco9sWZg134eJyHh
g3WophY4AK3S6VNrjwfZ8V2EHcWlysmTyQhS/i6nISRdlQIyBBenPXI1qC3X2elRwJJ1rDBw4tSk
FPpZVv+Pg6wD1lxgePFMJlGymPGte/sHafK1og==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
flfR64NYycLIyauxCLn1wC38i1K4/yOEiIIS/pzPw5b4T8AQasCEhfXccXWd7XYD8tVTgjkiZlil
BY/FskgSGdAPW60ru4A65EEa7ULY+aPS1CSMAW6nANPgjVXgGu5AsFKiDjSfY+ibvvFHUmJ8Zmez
wEdjdaf1uPn8gwW70f2+rXV6O5zQnCdBG+tQ5cUZMYqSxcdKZEcd7uFDN1+GqykP0vqNVRZMAmZE
umrRSJg1a1YyLdwwKiD+UbAJWJ0KQNS+4RQTCOHtz8/EK1t1YnoCf5KBTTe57whtj0S+rfOK5HaB
upEqngWyR+h+SKSvfYHRQkIHJPKSCB9buGG6MQ==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 12000)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
