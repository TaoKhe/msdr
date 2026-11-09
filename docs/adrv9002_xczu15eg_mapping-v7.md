# Bản đồ kết nối ADRV9002 và FPGA XCZU15EG (v7)

**Bảng Thống Kê Kết Nối ADRV9002 với FPGA XCZU15EG**

### 1. Bảng thống kê dữ liệu High-Speed LVDS (Swapped Bank Config)

| Tên cổng trong HDL | Hướng | Chân FPGA XCZU15EG | Tên Net trên Sơ đồ mạch | Chuẩn IO | Chân Chip ADRV9002 | Tên chân gốc ADRV9002 | Mô tả |
| :--- | :--- | :---: | :--- | :--- | :---: | :--- | :--- |
| **rx1_dclk_in_p** | Input | **T8** | ADRV_RX1_DCLK_OUT_P | LVDS | **M11** | RX1_DCLK_OUT+ | Clock ngõ vào của RX1 (Bank 67) |
| **rx1_dclk_in_n** | Input | **R8** | ADRV_RX1_DCLK_OUT_N | LVDS | **M12** | RX1_DCLK_OUT- | Clock ngõ vào của RX1 (Bank 67) |
| **rx1_strobe_in_p** | Input | **R10** | ADRV_RX1_STROBE_OUT_P | LVDS | **N2** | RX1_STROBE_OUT+ | Strobe ngõ vào của RX1 (Bank 67) |
| **rx1_strobe_in_n** | Input | **R9** | ADRV_RX1_STROBE_OUT_N | LVDS | **N1** | RX1_STROBE_OUT- | Strobe ngõ vào của RX1 (Bank 67) |
| **rx1_idata_in_p** | Input | **T7** | ADRV_RX1_IDATA_OUT_P | LVDS | **M2** | RX1_IDATA_OUT+ | I-Data ngõ vào của RX1 (Bank 67) |
| **rx1_idata_in_n** | Input | **T6** | ADRV_RX1_IDATA_OUT_N | LVDS | **M1** | RX1_IDATA_OUT- | I-Data ngõ vào của RX1 (Bank 67) |
| **rx1_qdata_in_p** | Input | **U9** | ADRV_RX1_QDATA_OUT_P | LVDS | **N4** | RX1_QDATA_OUT+ | Q-Data ngõ vào của RX1 (Bank 67) |
| **rx1_qdata_in_n** | Input | **U8** | ADRV_RX1_QDATA_OUT_N | LVDS | **N3** | RX1_QDATA_OUT- | Q-Data ngõ vào của RX1 (Bank 67) |
| | | | | | | | |
| **rx2_dclk_in_p** | Input | **Y2** | ADRV_RX2_DCLK_OUT_P | LVDS | **M11** | RX2_DCLK_OUT+ | Clock ngõ vào của RX2 (Bank 66) |
| **rx2_dclk_in_n** | Input | **Y1** | ADRV_RX2_DCLK_OUT_N | LVDS | **M12** | RX2_DCLK_OUT- | Clock ngõ vào của RX2 (Bank 66) |
| **rx2_strobe_in_p** | Input | **AA2** | ADRV_RX2_STROBE_OUT_P | LVDS | **N13** | RX2_STROBE_OUT+ | Strobe ngõ vào của RX2 (Bank 66) |
| **rx2_strobe_in_n** | Input | **AA1** | ADRV_RX2_STROBE_OUT_N | LVDS | **N14** | RX2_STROBE_OUT- | Strobe ngõ vào của RX2 (Bank 66) |
| **rx2_idata_in_p** | Input | **AB3** | ADRV_RX2_IDATA_OUT_P | LVDS | **M13** | RX2_IDATA_OUT+ | I-Data ngõ vào của RX2 (Bank 66) |
| **rx2_idata_in_n** | Input | **AC3** | ADRV_RX2_IDATA_OUT_N | LVDS | **M14** | RX2_IDATA_OUT- | I-Data ngõ vào của RX2 (Bank 66) |
| **rx2_qdata_in_p** | Input | **AC2** | ADRV_RX2_QDATA_OUT_P | LVDS | **N11** | RX2_QDATA_OUT+ | Q-Data ngõ vào của RX2 (Bank 66) |
| **rx2_qdata_in_n** | Input | **AC1** | ADRV_RX2_QDATA_OUT_N | LVDS | **N12** | RX2_QDATA_OUT- | Q-Data ngõ vào của RX2 (Bank 66) |
| | | | | | | | |
| **tx1_dclk_in_p** | Output | **T13** | ADRV_TX1_DCLK_IN_P | LVDS | **N5** | TX1_DCLK_IN+ | Clock ngõ vào TX của TX1 (Bank 67) |
| **tx1_dclk_in_n** | Output | **R13** | ADRV_TX1_DCLK_IN_N | LVDS | **N6** | TX1_DCLK_IN- | Clock ngõ vào TX của TX1 (Bank 67) |
| **tx1_strobe_out_p** | Output | **W12** | ADRV_TX1_STROBE_IN_P | LVDS | **P2** | TX1_STROBE_IN+ | Strobe ngõ vào TX của TX1 (Bank 67) |
| **tx1_strobe_out_n** | Output | **W11** | ADRV_TX1_STROBE_IN_N | LVDS | **P3** | TX1_STROBE_IN- | Strobe ngõ vào TX của TX1 (Bank 67) |
| **tx1_idata_out_p** | Output | **L15** | ADRV_TX1_IDATA_IN_P | LVDS | **P6** | TX1_IDATA_IN+ | I-Data ngõ vào TX của TX1 (Bank 67) |
| **tx1_idata_out_n** | Output | **K15** | ADRV_TX1_IDATA_IN_N | LVDS | **P7** | TX1_IDATA_IN- | I-Data ngõ vào TX của TX1 (Bank 67) |
| **tx1_qdata_out_p** | Output | **L13** | ADRV_TX1_QDATA_IN_P | LVDS | **P5** | TX1_QDATA_IN+ | Q-Data ngõ vào TX của TX1 (Bank 67) |
| **tx1_qdata_out_n** | Output | **K13** | ADRV_TX1_QDATA_IN_N | LVDS | **P4** | TX1_QDATA_IN- | Q-Data ngõ vào TX của TX1 (Bank 67) |
| **tx1_dclk_out_p** | Input | **U10** | ADRV_TX1_DCLK_OUT_P | LVDS | **M5** | DGPIO_15 / TX1_DCLK_OUT+ | Feedback Clock của TX1 (Bank 67) |
| **tx1_dclk_out_n** | Input | **T10** | ADRV_TX1_DCLK_OUT_N | LVDS | **M6** | DGPIO_14 / TX1_DCLK_OUT- | Feedback Clock của TX1 (Bank 67) |
| | | | | | | | |
| **tx2_dclk_in_p** | Output | **Y10** | ADRV_TX2_DCLK_IN_P | LVDS | **N10** | TX2_DCLK_IN+ | Clock ngõ vào TX của TX2 (Bank 66) |
| **tx2_dclk_in_n** | Output | **Y9** | ADRV_TX2_DCLK_IN_N | LVDS | **N9** | TX2_DCLK_IN- | Clock ngõ vào TX của TX2 (Bank 66) |
| **tx2_strobe_out_p** | Output | **Y12** | ADRV_TX2_STROBE_IN_P | LVDS | **P13** | TX2_STROBE_IN+ | Strobe ngõ vào TX của TX2 (Bank 66) |
| **tx2_strobe_out_n** | Output | **AA12** | ADRV_TX2_STROBE_IN_N | LVDS | **P12** | TX2_STROBE_IN- | Strobe ngõ vào TX của TX2 (Bank 66) |
| **tx2_idata_out_p** | Output | **AB9** | ADRV_TX2_IDATA_IN_P | LVDS | **P9** | TX2_IDATA_IN+ | I-Data ngõ vào TX của TX2 (Bank 66) |
| **tx2_idata_out_n** | Output | **AC9** | ADRV_TX2_IDATA_IN_N | LVDS | **P8** | TX2_IDATA_IN- | I-Data ngõ vào TX của TX2 (Bank 66) |
| **tx2_qdata_out_p** | Output | **AA11** | ADRV_TX2_QDATA_IN_P | LVDS | **P10** | TX2_QDATA_IN+ | Q-Data ngõ vào TX của TX2 (Bank 66) |
| **tx2_qdata_out_n** | Output | **AA10** | ADRV_TX2_QDATA_IN_N | LVDS | **P11** | TX2_QDATA_IN- | Q-Data ngõ vào TX của TX2 (Bank 66) |
| **tx2_dclk_out_p** | Input | **AA7** | ADRV_TX2_DCLK_OUT_P | LVDS | **M10** | DGPIO_13 / TX2_DCLK_OUT+ | Feedback Clock của TX2 (Bank 66) |
| **tx2_dclk_out_n** | Input | **AA6** | ADRV_TX2_DCLK_OUT_N | LVDS | **M9** | DGPIO_12 / TX2_DCLK_OUT- | Feedback Clock của TX2 (Bank 66) |


### 2. Bảng thống kê SPI, Reset và các tín hiệu Enables (LVCMOS18)

| Tên cổng trong HDL | Hướng | Chân FPGA XCZU15EG | Tên Net trên Sơ đồ mạch | Chuẩn IO | Chân Chip ADRV9002 | Tên chân gốc ADRV9002 |
| :--- | :--- | :---: | :--- | :--- | :---: | :--- |
| **spi_clk** | Output | **L10** | ADRV_SPI_CLK | LVCMOS18 | **K1** | SPI_CLK |
| **spi_dio** | Bidirectional | **M10** | ADRV_SPI_DIO | LVCMOS18 | **K2** | SPI_DIO |
| **spi_do** | Input | **P9** | ADRV_SPI_DO | LVCMOS18 | **L2** | SPI_DO |
| **spi_en** | Output | **P10** | ADRV_SPI_EN | LVCMOS18 | **L1** | SPI_EN |
| **rx1_enable** | Output | **N11** | ADRV_EN_RX1 | LVCMOS18 | **K12** | RX1_ENABLE |
| **rx2_enable** | Output | **P11** | ADRV_EN_RX2 | LVCMOS18 | **K3** | RX2_ENABLE |
| **tx1_enable** | Output | **M14** | ADRV_EN_TX1 | LVCMOS18 | **L12** | TX1_ENABLE |
| **tx2_enable** | Output | **M15** | ADRV_EN_TX2 | LVCMOS18 | **L3** | TX2_ENABLE |
| **reset_trx** | Output | **N8** | ADRV_RESET | LVCMOS18 | **K13** | RESETB |
| **mode** | Output | **L15** | ADRV_DGPIO_11 (MODE) | LVCMOS18 | **L13** | MODE / DGPIO_11 |


### 3. Bảng thống kê hệ thống dgpio_0 đến dgpio_11 và các ngõ ngắt / trạng thái phụ

| Tên cổng trong HDL | Hướng | Chân FPGA XCZU15EG | Chuẩn IO | Bank FPGA | Mô tả |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **dgpio_0** | Bidirectional | **U5** | LVCMOS18 | Bank 66 | Đường GPIO số 0 dùng cho ADRV9002 |
| **dgpio_1** | Bidirectional | **U4** | LVCMOS18 | Bank 66 | Đường GPIO số 1 dùng cho ADRV9002 |
| **dgpio_2** | Bidirectional | **V4** | LVCMOS18 | Bank 66 | Đường GPIO số 2 dùng cho ADRV9002 |
| **dgpio_3** | Bidirectional | **V3** | LVCMOS18 | Bank 66 | Đường GPIO số 3 dùng cho ADRV9002 |
| **dgpio_4** | Bidirectional | **AB4** | LVCMOS18 | Bank 66 | Đường GPIO số 4 dùng cho ADRV9002 |
| **dgpio_5** | Bidirectional | **AC4** | LVCMOS18 | Bank 66 | Đường GPIO số 5 dùng cho ADRV9002 |
| **dgpio_6** | Bidirectional | **K16** | LVCMOS18 | Bank 67 | Đường GPIO số 6 dùng cho ADRV9002 |
| **dgpio_7** | Bidirectional | **L16** | LVCMOS18 | Bank 67 | Đường GPIO số 7 dùng cho ADRV9002 |
| **dgpio_8** | Bidirectional | **K14** | LVCMOS18 | Bank 67 | Đường GPIO số 8 dùng cho ADRV9002 |
| **dgpio_9** | Bidirectional | **K10** | LVCMOS18 | Bank 67 | Đường GPIO số 9 dùng cho ADRV9002 |
| **dgpio_10** | Bidirectional | **W5** | LVCMOS18 | Bank 66 | Đường GPIO số 10 dùng cho ADRV9002 |
| **dgpio_11** | Bidirectional | **L15** | LVCMOS18 | Bank 67 | Đường GPIO số 11 dùng cho ADRV9002 (MODE) |
| **gp_int** | Input | **N9** | LVCMOS18 | Bank 67 | Tín hiệu ngắt đa dụng từ chip ADRV9002 |
| **sm_fan_tach** | Input | **E13** | LVCMOS18 | Bank 49 | Đo tốc độ quạt làm mát trên bo mạch (Thực tế nối vào Bank 49 trên Schematic) |
| **vadj_err** | Input | **D12** | LVCMOS18 | Bank 49 | Cảnh báo lỗi điện áp điều chỉnh VADJ_FMC (Thực tế nối vào Bank 49 trên Schematic) |
| **platform_status** | Input | **E12** | LVCMOS18 | Bank 49 | Trạng thái hoạt động của nền tảng (Thực tế nối vào Bank 49 trên Schematic) |
| **tdd_sync** | Output | **F13** | LVCMOS18 | Bank 49 | Đồng bộ hóa phân chia thời gian TDD Sync (Thực tế nối vào Bank 49 trên Schematic) |


### 4. Bảng thống kê Clocks và Đồng bộ hóa Hệ thống (System Clocks & Sync)

| Tên cổng trong HDL | Hướng | Chân FPGA XCZU15EG | Chuẩn IO | Bank FPGA | Mô tả |
| :--- | :--- | :---: | :--- | :--- | :--- |
| **dev_clk_in** | Input | **W9** | LVCMOS18 | Bank 66 | Xung nhịp thiết bị chính ngõ vào (Tên Net: `FPGA_SYSCLK`) |
| **dev_mcs_fpga_out_p** | Output | **Y4** | LVDS | Bank 66 | Tín hiệu đồng bộ đa chip MCS ngõ ra (+) (Tên Net: `ADRV_MCS_OUT_P`) |
| **dev_mcs_fpga_out_n** | Output | **Y3** | LVDS | Bank 66 | Tín hiệu đồng bộ đa chip MCS ngõ ra (-) (Tên Net: `ADRV_MCS_OUT_N`) |
| **fpga_mcs_in_p** | Input | **P12** | LVDS | Bank 67 | Tín hiệu MCS đồng bộ ngõ vào (+) (Tên Net: `FPGA_MCS_IN_P`) |
| **fpga_mcs_in_n** | Input | **N12** | LVDS | Bank 67 | Tín hiệu MCS đồng bộ ngõ vào (-) (Tên Net: `FPGA_MCS_IN_N`) |
| **fpga_ref_clk_p** | Input | **V9** | LVDS | Bank 67 | Xung nhịp tham chiếu từ ADRV9002 sang FPGA (+) (Tín hiệu Single-ended `ADRV_CLK_OUT` nối vào chân `V9`) |
| **fpga_ref_clk_n** | Input | **—** | LVDS | Bank 67 | Xung nhịp tham chiếu từ ADRV9002 sang FPGA (-) (Không sử dụng do tín hiệu là Single-ended) |
