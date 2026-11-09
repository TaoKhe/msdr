# T12 DSP – Kiến Trúc Phần Cứng
> Tài liệu tham chiếu: `T12_DSP_v01.pdf` (44 trang sơ đồ nguyên lý)

---

## Mục Lục
1. [Block Diagram Tổng Quan](#1-block-diagram-tổng-quan)
2. [U_2 – Power Tree](#2-u_2--power-tree)
3. [U_3 – Power Block Chi Tiết](#3-u_3--power-block-chi-tiết)
4. [U_5 – FPGA Block (Zynq UltraScale+)](#4-u_5--fpga-block-zynq-ultrascale)
5. [U_6 – Memory](#5-u_6--memory)
6. [U_7 – Ethernet](#6-u_7--ethernet)
7. [U_8 – RFE Connector](#7-u_8--rfe-connector)
8. [U_9 – BBU Connector](#8-u_9--bbu-connector)
9. [U_10 – RF Front-End](#9-u_10--rf-front-end)
10. [U_11 – Buffer (Level Shifter)](#10-u_11--buffer-level-shifter)
11. [U_13 – TRX (ADRV9002)](#11-u_13--trx-adrv9002)
12. [U_15 – Debug (FT2232H)](#12-u_15--debug-ft2232h)
13. [Kết Nối Liên Khối](#13-kết-nối-liên-khối)
14. [Danh Sách IC Chính](#14-danh-sách-ic-chính)
15. [Power Rails Tổng Hợp](#15-power-rails-tổng-hợp)

---

## 1. Block Diagram Tổng Quan

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          T12 DSP BOARD – TOP LEVEL                              │
│                                                                                 │
│  ┌──────────────┐   FLASH-IF / DDR4-IF     ┌──────────────────┐                 │
│  │  U_6 Memory  │◄────────────────────────►│                  │                 │
│  │  - DDR4 SDRAM│                          │   U_5 FPGA Block │                 │
│  │  - QSPI Flash│                          │  XCZU15EG-2FFVB  │                 │
│  └──────────────┘                          │     1156I        │                 │
│                                            │  (Zynq UltraScale│                 │
│  ┌──────────────┐   ADRV_SPI/CSb           │      MPSoC)      │                 │
│  │  U_13 TRX    │◄────────────────────────►│                  │                 │
│  │  ADRV9002    │   ADRV_RX/TX_DATA        │                  │                 │
│  │  (2T2R RF    │   ADRV_CTRL              │                  │                 │
│  │   Transceiver│   ADRV_CLK_OUT ─────────►│ FPGA_SYSCLK      │                 │
│  └──────┬───────┘                          │                  │                 │
│         │ TX1/TX2/RX1/RX2/ORX1             │                  │◄── PMBUS        │
│         ▼                                  │                  │◄── I2C          │
│  ┌──────────────┐   RFE_CTRL               │                  │                 │
│  │  U_10 RF     │◄────────────────────────►│                  │                 │
│  │  Front-End   │   HB/LB TFT_SPI          │                  │                 │
│  │  (LB + HB)   │   TX/RX/ORX DSA_SPI      │                  │                 │
│  └──────┬───────┘                          │                  │                 │
│         │ J3~J9 (SMA)                      │                  │                 │
│                                            │                  │                 │
│  ┌──────────────┐   ETH (RGMII)            │                  │                 │
│  │  U_7 Ethernet│◄────────────────────────►│                  │                 │
│  │  KSZ9131RNXI │   PHY_RST/MDIO           │                  │                 │
│  └──────────────┘                          │                  │                 │
│                                            │                  │                 │
│  ┌──────────────┐   UART0 / JTAG           │                  │                 │
│  │  U_15 Debug  │◄────────────────────────►│                  │                 │
│  │  FT2232H     │   USB ↔ UART/JTAG        │                  │                 │
│  └──────────────┘                          │                  │                 │
│                                            │                  │                 │
│  ┌──────────────┐   BBU_GPIO / AURORA      │                  │                 │
│  │  U_9 BBU     │◄────────────────────────►│  GTH SerDes      │                 │
│  │  Connector   │   Aurora (L1/L2 Tx/Rx)   │  (128/129/130    │                 │
│  │  (J2)        │   +28V_UNFILTERED IN     │   228/229/230)   │                 │
│  └──────────────┘                          └──────────────────┘                 │
│                                                                                 │
│  ┌──────────────┐   PMBUS / I2C                                                 │
│  │  U_3 Power   │────────────────────────────────────────────────────────────►  │
│  │  Block       │   PWR_STT / WDI / WDT_EN                                      │
│  │  UCD90160    │   PS_PROG_B / PS_SRST / PS_POR                                │
│  └──────────────┘                                                               │
│                                                                                 │
│  ┌──────────────┐   3V3 Level Shift                                             │
│  │  U_11 Buffer │   RFSW_CTRL / GB_BYP_CTRL                                     │
│  │  SN74LVC8T245│   (1.8V FPGA → 3.3V RF)                                       │
│  └──────────────┘                                                               │
│                                                                                 │
│  ┌──────────────┐   RFE_CTRL (30-pin)                                           │
│  │  U_8 RFE     │◄──────────────────────── FPGA                                 │
│  │  Connector   │   RFSW_CTRL1~4 / LBF_CTRL1~5                                  │
│  │  (J6)        │   HB/LB_TRX_CTRL / LNA_BYP / TRX_SPI                          │
│  └──────────────┘                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. U_2 – Power Tree

```
                    +28V_UNFILTERED (J11 – Power Connector)
                            │
                            ▼
              ┌─────────────────────────┐
              │  U_3.1 PWR_EMI_PROTECT  │  IC: LTC4365 (OVP/UVP/Reverse)
              │  + TVS (SMBJ24CA)       │  Bảo vệ ngõ vào 8A / 30V
              └────────────┬────────────┘
                           │
                    +12V_VIN ──────────────────────────────────────────────────────┐
                           │                                                       │
              ┌────────────▼────────────┐                                          │
              │  U_3.2 PWR_SEQ_MON      │  IC: UCD90160 (Power Sequencer)          │
              │  Power Sequencing &     │  16-rail monitor, PMBUS, GPIO            │
              │  Monitoring             │  WDI / WDT_EN / PWR_STT / FLASH_RST      │
              └────────────┬────────────┘                                          │
                           │ CLKOUT (chuỗi enable)                                 │
          ┌────────────────┼──────────────────────────────────┐                    │
          │                │                │                 │                    │
          ▼                ▼                ▼                 ▼                    │
   ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐             │
   │ PWR_P01     │  │ PWR_P02     │  │ PWR_P03      │  │ PWR_P04     │             │
   │ R01:+0V85   │  │ R04:+0V9    │  │ R09:+1V2     │  │ R12:+2V5    │             │
   │ _VCCINT     │  │ _VMGTAVCC   │  │ _DDR4_VDD    │  │ _DDR4_VPP   │             │
   │ R02:+1V8    │  │ R05:+1V8    │  │              │  │ R13:+0V6    │             │
   │ _VCCAUX     │  │ _VMGTVCCAUX │  │              │  │ _DDR4_VTT   │             │
   │ R03:+3V3    │  │             │  │              │  │             │             │
   │ _VCCO       │  │             │  │              │  │             │             │
   └─────────────┘  └─────────────┘  └──────────────┘  └─────────────┘             │
                                                                                   │
          ┌────────────────────────────────────────────────────────────────────────┘
          │
          ▼
   ┌─────────────┐
   │ PWR_P05     │  R17: +1V8_ADRV
   │ (ADRV PWR)  │  R18: +1V_VDIG_ADRV
   │             │  R19: +1V3_ADRV
   └─────────────┘

   ┌─────────────┐
   │ PWR_P06     │  +3V3_UTILS / +3V6_UTILS / +5V3_UTILS
   │ (Utils PWR) │  +5V / +3V3_RF / +5V_TX_RF / +5V_RX_RF
   └─────────────┘
```

---

## 3. U_3 – Power Block Chi Tiết

### 3.1 Chuỗi Power Rails FPGA (Zynq UltraScale+)

| Rail | Điện áp | Dùng cho |
|------|---------|----------|
| `+0V85_VCCINT` | 0.85 V | PL Core (VCCINT) |
| `+0V85_VPS_MGTRAVCC` | 0.85 V | PS MGT RAVCC |
| `+0V9_VMGTAVCC` | 0.9 V | GTH Analog VCC |
| `+1V2_VCC_PSPLL` | 1.2 V | PS PLL |
| `+1V2_VMGTAVTT` | 1.2 V | GTH Termination |
| `+1V8_VCCAUX` | 1.8 V | PL Aux (VCCAUX) |
| `+1V8_VMGTVCCAUX` | 1.8 V | GTH Aux |
| `+1V8_VCC_PSDDR_PLL` | 1.8 V | PS DDR PLL |
| `+3V3_VCCO` | 3.3 V | PL I/O Banks |

### 3.2 Power Rails DDR4

| Rail | Điện áp | Dùng cho |
|------|---------|----------|
| `+1V2_DDR4_VDD` | 1.2 V | DDR4 Core |
| `+2V5_DDR4_VPP` | 2.5 V | DDR4 Activating |
| `+0V6_DDR4_VTT` | 0.6 V | DDR4 Termination |
| `+0V6_DDR4_VTTREF` | 0.6 V | DDR4 Vref |

### 3.3 Power Rails ADRV9002

| Rail | Điện áp | Dùng cho |
|------|---------|----------|
| `+1V8_ADRV` | 1.8 V | ADRV Digital I/O |
| `+1V_ADRV` / `+1V_ADRV_VDIG` | 1.0 V | ADRV Digital Core |
| `+1V3_ADRV` | 1.3 V | ADRV Analog |
| `+1V3_ADRV_VANA1/2` | 1.3 V | Analog Supply 1/2 |
| `+1V3_ADRV_VDDA` | 1.3 V | Analog VDD |
| `+1V3_ADRV_VCONV` | 1.3 V | Converter Supply |
| `+1V3_ADRV_VCLKSYN` | 1.3 V | Clock Synthesizer |
| `+1V3_ADRV_VRFSYN1/2` | 1.3 V | RF Synthesizer 1/2 |
| `+1V8_ADRV_VDIGIO` | 1.8 V | Digital GPIO |
| `+1V8_ADRV_DIG` | 1.8 V | Digital |
| `+1V8_DCTCXO` | 1.8 V | TCXO/DCXO |

---

## 4. U_5 – FPGA Block (Zynq UltraScale+)

**IC:** `XCZU15EG-2FFVB1156I` (Xilinx Zynq UltraScale+ MPSoC)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    XCZU15EG-2FFVB1156I (1156-ball BGA)                       │
│                                                                              │
│  ┌─────────────────────────────┐   ┌─────────────────────────────────────┐   │
│  │     Processing System (PS)  │   │      Programmable Logic (PL)        │   │
│  │                             │   │                                     │   │
│  │  ┌──────────┐               │   │  ┌─────────────────────────────┐    │   │
│  │  │ ARM A53  │               │   │  │  HP Banks (High Performance)│    │   │
│  │  │ Quad Core│               │   │  │  → DDR4 Interface           │    │   │
│  │  └──────────┘               │   │  └─────────────────────────────┘    │   │
│  │  ┌──────────┐               │   │                                     │   │
│  │  │ ARM R5F  │               │   │  ┌─────────────────────────────┐    │   │
│  │  │ Dual Core│               │   │  │  HD Banks (High Density)    │    │   │
│  │  └──────────┘               │   │  │  → ADRV9002 LVDS Data       │    │   │
│  │                             │   │  └─────────────────────────────┘    │   │
│  │  PS Interfaces:             │   │                                     │   │
│  │  - PS_UART0 (Debug)         │   │  ┌─────────────────────────────┐    │   │
│  │  - PS_JTAG                  │   │  │  GTH Transceivers           │    │   │
│  │  - PS_PROG_B/SRST/POR       │   │  │  Bank 128/129/130           │    │   │
│  │  - MIO → Ethernet MDIO      │   │  │  Bank 228/229/230           │    │   │
│  │                             │   │  │  → Aurora (BBU J2)          │    │   │
│  │                             │   │  │  → Ethernet SGMII (J8)      │    │   │
│  └─────────────────────────────┘   └─────────────────────────────────────┘   │
│                                                                              │
│  Clocks:                                                                     │
│  - FPGA_SYSCLK ← ADRV_CLK_OUT (từ ADRV9002)                                  │
│  - FPGA_GTHREFCLK_P/N → GTH Reference Clock                                  │
│  - DCOSC_SPI → External DCXO/TCXO                                            │
└──────────────────────────────────────────────────────────────────────────────┘

Kết nối ra ngoài:
  FPGA ──FLASH-IF (QSPI)──► MT25QL01G (QSPI Flash 1Gb)
  FPGA ──DDR4-IF──────────► MT40A512M16LY (DDR4 8Gb)
  FPGA ──ADRV_SPI/LVDS────► ADRV9002 (TRX)
  FPGA ──RGMII────────────► KSZ9131RNXI (Ethernet PHY)
  FPGA ──GTH SerDes────────► J2 BBU Connector (Aurora)
  FPGA ──UART/JTAG─────────► FT2232H (USB Debug)
  FPGA ──RFE_CTRL──────────► J6 RFE Connector
  FPGA ──GPIO──────────────► J2 BBU GPIO (10MHz ref, UART)
```

---

## 5. U_6 – Memory

### 5.1 DDR4 SDRAM

```
┌──────────────────────────────────────────────────────┐
│  IC: MT40A512M16LY-062E IT:E (Micron)                │
│  Dung lượng: 512M × 16bit = 8Gb                      │
│  Tốc độ: DDR4-3200 (062E = 3.2 Gbps)                 │
│                                                      │
│  Interface:                                          │
│  - DQ[15:0]  – 16-bit Data Bus                       │
│  - A[14:0]   – Address Bus                           │
│  - BA[1:0]   – Bank Address                          │
│  - BG[1:0]   – Bank Group                            │
│  - CK_P/N    – Differential Clock                    │
│  - CKE       – Clock Enable                          │
│  - CS_N      – Chip Select                           │
│  - ODT       – On-Die Termination                    │
│  - DM/DBI    – Data Mask                             │
│  - DQS_P/N   – Data Strobe                           │
│                                                      │
│  Power: +1V2_DDR4_VDD / +2V5_DDR4_VPP                │
│         +0V6_DDR4_VTT / +0V6_DDR4_VTTREF             │
└──────────────────────────────────────────────────────┘
```

### 5.2 QSPI Flash

```
┌──────────────────────────────────────────────────────┐
│  IC: MT25QL01GBBB8ESF-0AAT TR (Micron)               │
│  Dung lượng: 1Gb (128MB) QSPI NOR Flash              │
│                                                      │
│  Interface:                                          │
│  - FLASH-IF (QSPI x4)                                │
│  - FLASH_RST (từ UCD90160 Power Sequencer)           │
│                                                      │
│  Power: +3V3_FLASH                                   │
└──────────────────────────────────────────────────────┘
```

---

## 6. U_7 – Ethernet

```
┌──────────────────────────────────────────────────────┐
│  IC: KSZ9131RNXI (Microchip)                         │
│  Gigabit Ethernet PHY                                │
│                                                      │
│  Interface với FPGA:                                 │
│  ┌──────────────────────────────────────────────┐    │
│  │  RGMII (Reduced Gigabit MII)                 │    │
│  │  ETH_D0_P/N ~ ETH_D3_P/N (4 lane LVDS)       │    │
│  │  PHY_MDIO  – Management Data I/O             │    │
│  │  PHY_RST   – Reset                           │    │
│  └──────────────────────────────────────────────┘    │ 
│                                                      │
│  Interface ra ngoài:                                 │
│  ┌──────────────────────────────────────────────┐    │
│  │  J8 – Ethernet Connector                     │    │
│  │  (CONN_19S141-40ML5)                         │    │
│  │  ETH_D0~D3 P/N + USB_VBUS/P/N                │    │
│  └──────────────────────────────────────────────┘    │
│                                                      │
│  Power: +1V2_PHY / +3V3_VCCO                         │
└──────────────────────────────────────────────────────┘
```

---

## 7. U_8 – RFE Connector

```
┌──────────────────────────────────────────────────────────────────┐
│  J6 – RFE Connector (CONN_HLE-115-02-G-DV-BE-LC-K-TR, 30-pin)    │
│                                                                  │
│  Tín hiệu điều khiển từ FPGA → RF Front-End Board:               │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  RF Switch Control                                       │    │
│  │  RFSW_CTRL1 / RFSW_CTRL2 / RFSW_CTRL3 / RFSW_CTRL4       │    │
│  ├──────────────────────────────────────────────────────────┤    │
│  │  Low-Band Filter Control                                 │    │
│  │  LBF_CTRL1 / LBF_CTRL2 / LBF_CTRL3 / LBF_CTRL4 / LBF5    │    │
│  ├──────────────────────────────────────────────────────────┤    │
│  │  LNA Bypass                                              │    │
│  │  HB_LNA_BYP / LB_LNA_BYP                                 │    │
│  ├──────────────────────────────────────────────────────────┤    │
│  │  TRX Control                                             │    │
│  │  HB_TRX_CTRL / LB_TRX_CTRL                               │    │
│  ├──────────────────────────────────────────────────────────┤    │
│  │  TRX SPI (3-wire)                                        │    │
│  │  TRX_SCLK / TRX_MOSI / TRX_MISO                          │    │
│  └──────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
```

---

## 8. U_9 – BBU Connector

```
┌──────────────────────────────────────────────────────────────────┐
│  J2 – BBU Connector (CONN_VSM-04-10-120-50-02-G, 4×10 = 40 pin)  │
│  Kết nối với BBU (Baseband Unit)                                 │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  Power                                                   │    │
│  │  +28V_UNFILTERED (nhiều pin)                             │    │
│  │  GND                                                     │    │
│  ├──────────────────────────────────────────────────────────┤    │
│  │  Aurora High-Speed Serial (GTH)                          │    │
│  │  Aurora_L1_Tx_P/N  (FPGA → BBU)                          │    │
│  │  Aurora_L1_Rx_P/N  (BBU → FPGA)                          │    │
│  │  Aurora_L2_Tx_P/N  (FPGA → BBU)                          │    │
│  │  Aurora_L2_Rx_P/N  (BBU → FPGA)                          │    │
│  ├──────────────────────────────────────────────────────────┤    │
│  │  GPIO                                                    │    │
│  │  GPIO_0 (GPIO_0)                                         │    │
│  │  GPIO_1 (10 MHz Reference Clock)                         │    │
│  │  GPIO_2 (UART RX)                                        │    │
│  │  GPIO_3 (UART TX)                                        │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                  │
│  TVS Protection: D1213A-04V-7 (4-line TVS cho GPIO)              │
│  Series Resistors: 30Ω (R40~R43) cho GPIO lines                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 9. U_10 – RF Front-End

### 9.1 Sơ Đồ Tổng Quan RF Path

```
                         ┌─────────────────────────────────────────────────────┐
                         │              RF FRONT-END (U_10)                    │
                         │                                                     │
  ADRV9002               │   TX PATH                                           │
  ──TX1──────────────────┼──► [U_10.1 DSA] ──► [FILTER] ──► [U_10.2 SW] ──►    │
  ──TX2──────────────────┼──► [U_10.1 DSA] ──► [FILTER] ──► [U_10.2 SW] ──►    │
                         │                                                     │
  ADRV9002               │   RX PATH                                           │
  ◄─RX1──────────────────┼──◄ [FILTER] ◄── [U_10.2 SW] ◄── [U_10.7 AMP1] ◄─    │
  ◄─RX2──────────────────┼──◄ [FILTER] ◄── [U_10.2 SW] ◄──                     │
                         │                                                     │
  ADRV9002               │   ORX PATH (Observation RX)                         │
  ◄─ORX1─────────────────┼──◄ [U_10.1 DSA] ◄── ORX_IN (J3 SMA)                 │
                         │                                                     │
                         │   RF CONNECTORS (SMA)                               │
                         │   J3: ORX_IN      J4: TRX_RX_LB                     │
                         │   J5: TRX_RX_HB   J7: TRX_TX_LB                     │
                         │   J9: TRX_TX_HB   J1: RX_TEST_OUT                   │
                         └─────────────────────────────────────────────────────┘
```

### 9.2 Chi Tiết Các Khối RF

#### U_10.1 – RF DSA (Digital Step Attenuator)
```
┌─────────────────────────────────────────────────────┐
│  IC: RFSA3713 (Qorvo)                               │
│  6-bit DSA, 0~31.5 dB, 0.5 dB step                  │
│  Tần số: DC ~ 4 GHz                                 │
│                                                     │
│  Có 3 instance:                                     │
│  - TX DSA  (SPI: TX_DSA_SPI)                        │
│  - RX DSA  (SPI: RX_DSA_SPI)                        │
│  - ORX DSA (SPI: ORX_DSA_SPI)                       │
│                                                     │
│  Power: +3V3_RF                                     │
└─────────────────────────────────────────────────────┘
```

#### U_10.2 – RF SPDT Switch
```
┌─────────────────────────────────────────────────────┐
│  IC: HMC197BE (Analog Devices)                      │
│  SPDT RF Switch                                     │
│  Tần số: DC ~ 3 GHz                                 │
│                                                     │
│  Điều khiển: TFT_CTRL (A/B) từ FPGA qua Buffer      │
│  Nhiều instance cho LB/HB switching                 │
│                                                     │
│  Ports: RFC (common), RF1, RF2                      │
└─────────────────────────────────────────────────────┘
```

#### U_10.3 – RF Tunable Filter (Low-Band)
```
┌─────────────────────────────────────────────────────┐
│  IC: ADMV8052 (Analog Devices)                      │
│  Tunable Bandpass Filter                            │
│  Tần số: 2 ~ 6 GHz (Low Band)                       │
│                                                     │
│  SPI: LB_TFT_SPI (CSb: LB_TFT_CSb1/2)               │
│  Reset: LB_TFT_RESET                                │
│  BYP: GB_LB_BYP_CTRL (Gain Block Bypass)            │
│  Power: +3V3_RF_FILTER / -2V5_RF                    │
└─────────────────────────────────────────────────────┘
```

#### U_10.4 – RF Tunable Filter (High-Band 1)
```
┌─────────────────────────────────────────────────────┐
│  IC: ADMV8526 (Analog Devices)                      │
│  Tunable Bandpass Filter                            │
│  Tần số: High Band                                  │
│                                                     │
│  SPI: HB_TFT_SPI (CSb: HB_TFT_CSb2)                 │
│  Reset: HB_TFT_RESET                                │
│  Power: +3V3_RF_FILTER / -2V5_RF                    │
└─────────────────────────────────────────────────────┘
```

#### U_10.5 – RF Tunable Filter (High-Band 2)
```
┌─────────────────────────────────────────────────────┐
│  IC: ADMV8513 (Analog Devices)                      │
│  Tunable Bandpass Filter                            │
│  Tần số: High Band                                  │
│                                                     │
│  SPI: HB_TFT_SPI (CSb: HB_TFT_CSb1)                 │
│  Reset: HB_TFT_RESET                                │
│  Power: +3V3_RF_FILTER / -2V5_RF                    │
└─────────────────────────────────────────────────────┘
```

#### U_10.6 – RF Tunable Filter (High-Band 3/4)
```
┌─────────────────────────────────────────────────────┐
│  IC: ADMV8052 (Analog Devices) – instance HB        │
│  SPI: HB_TFT_SPI (CSb: HB_TFT_CSb3/4)               │
└─────────────────────────────────────────────────────┘
```

#### U_10.7 – RF Amplifier 1 (RX LNA)
```
┌─────────────────────────────────────────────────────┐
│  IC: MAAM-011252 (MACOM)                            │
│  Low Noise Amplifier (LNA)                          │
│  Tần số: 0.5 ~ 6 GHz                                │
│                                                     │
│  EN: GB_LB_BYP_CTRL / GB1_HB_BYP_CTRL               │
│  (Bypass control cho Gain Block)                    │
│  Power: +5V_RX_RF                                   │
└─────────────────────────────────────────────────────┘
```

#### U_10.8 – RF Amplifier 2 (TX Driver)
```
┌─────────────────────────────────────────────────────┐
│  IC: MAAM-011305 (MACOM)                            │
│  Driver Amplifier                                   │
│  Tần số: 0.5 ~ 6 GHz                                │
│                                                     │
│  EN: TX_GB_CTRL1 / TX_GB_CTRL2 / TX_GB_CTRL3        │
│  Power: +5V_TX_RF                                   │
└─────────────────────────────────────────────────────┘
```

#### U_10.9 – RF Amplifier 3 (RX LNA High-Band)
```
┌─────────────────────────────────────────────────────┐
│  IC: TSS2-53LNB+ (Mini-Circuits)                    │
│  LNA, 0.5 ~ 6 GHz                                   │
│                                                     │
│  2 instance: GB1_HB / GB2_HB                        │
│  EN: GB1_HB_BYP_CTRL / GB2_HB_BYP_CTRL              │
│  Power: +5V_RX_RF                                   │
└─────────────────────────────────────────────────────┘
```

### 9.3 RF Signal Flow Chi Tiết

```
TX PATH (Low-Band):
  ADRV9002_TX1 ──► [DSA RFSA3713] ──► [FILTER LFCN-2750D+] ──► [SW HMC197BE]
                                                                     │
                   TBFT_TX_LB ◄──────────────────────────────────────┘
                       │
                       ▼
                  [AMP MAAM-011305] ──► GB_TX_LB ──► [SW HMC197BE] ──► J7 TRX_TX_LB

TX PATH (High-Band):
  ADRV9002_TX2 ──► [DSA RFSA3713] ──► [FILTER LFCN-2750D+] ──► [SW HMC197BE]
                                                                     │
                   TBFT_TX_HB ◄──────────────────────────────────────┘
                       │
                       ▼
                  [AMP MAAM-011305] ──► GB_TX_HB ──► [SW HMC197BE] ──► J9 TRX_TX_HB

RX PATH (Low-Band):
  J4 TRX_RX_LB ──► [SW HMC197BE] ──► GB_RX_LB
                                         │
                   [AMP MAAM-011252] ◄───┘
                         │
                         ▼
                   [TFT ADMV8052] ──► [SW HMC197BE] ──► ADRV9002_RX1

RX PATH (High-Band):
  J5 TRX_RX_HB ──► [SW HMC197BE] ──► GB_RX_HB
                                        │
                   [AMP TSS2-53LNB+] ◄──┘
                         │
                         ▼
                   [TFT ADMV8513/8526] ──► [SW HMC197BE] ──► ADRV9002_RX2

ORX PATH:
  J3 ORX_IN ──► [DSA RFSA3713] ──► ADRV9002_ORX1
```

---

## 10. U_11 – Buffer (Level Shifter)

```
┌──────────────────────────────────────────────────────────────────┐
│  IC: SN74LVC8T245RHLR (Texas Instruments)                        │
│  8-bit Bidirectional Voltage Level Translator                    │
│  VCCA: 1.8V (FPGA side) → VCCB: 3.3V (RF side)                   │
│                                                                  │
│  4 instance (U34, U36, U38, U41):                                │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  U34: TFT_CTRL5~8 (A/B) + SW13/14_CTRL (A/B)             │    │
│  │       + GB2_HB_BYP_CTRL                                  │    │
│  ├──────────────────────────────────────────────────────────┤    │
│  │  U36: GB1/2_HB_BYP_CTRL + TFT_CTRL7/8 (A/B)              │    │
│  │       + SW15/16_CTRL (A/B)                               │    │
│  ├──────────────────────────────────────────────────────────┤    │
│  │  U38: TFT_CTRL4 (A/B) + SW14_CTRL (A/B)                  │    │
│  ├──────────────────────────────────────────────────────────┤    │
│  │  U41: TFT_CTRL1~3 (A/B)                                  │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                  │
│  Output signals (_3V3):                                          │
│  GB1_HB_BYP_CTRL_3V3 / GB2_HB_BYP_CTRL_3V3                       │
│  RFSW_CTRL_3V3 / TFT_CTRL1~8_A/B_3V3                             │
│  SW13~16_CTRL_A/B_3V3                                            │
└──────────────────────────────────────────────────────────────────┘
```

---

## 11. U_13 – TRX (ADRV9002)

**IC:** `ADRV9002BBCZ` (Analog Devices)  
2T2R Wideband RF Transceiver, 30 MHz ~ 6 GHz

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         ADRV9002BBCZ                                     │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────── ─┐    │
│  │  TX Paths                                                        │    │
│  │  TX1: ADRV_TX1_P/N ──────────────────────────────► RF Front-End  │    │
│  │  TX2: ADRV_TX2_P/N ──────────────────────────────► RF Front-End  │    │
│  │                                                                  │    │
│  │  LVDS Data Interface (từ FPGA):                                  │    │
│  │  TX1: IDATA_IN_P/N, QDATA_IN_P/N, STROBE_IN_P/N, DCLK_IN_P/N     │    │
│  │  TX2: IDATA_IN_P/N, QDATA_IN_P/N, STROBE_IN_P/N, DCLK_IN_P/N     │    │
│  ├───────────────────────────────────────────────────────────────── ┤    │
│  │  RX Paths                                                        │    │
│  │  RX1: ADRV_RX1A_P/N ◄──────────────────────────── RF Front-End   │    │
│  │  RX2: ADRV_RX2A_P/N ◄──────────────────────────── RF Front-End   │    │
│  │                                                                  │    │
│  │  LVDS Data Interface (tới FPGA):                                 │    │
│  │  RX1: IDATA_OUT_P/N, QDATA_OUT_P/N, STROBE_OUT_P/N, DCLK_OUT     │    │
│  │  RX2: IDATA_OUT_P/N, QDATA_OUT_P/N, STROBE_OUT_P/N, DCLK_OUT     │    │
│  ├──────────────────────────────────────────────────────────────── ─┤    │
│  │  Control Interface                                               │    │
│  │  SPI:    ADRV_SPI (SCLK, MOSI, MISO) + ADRV_CSb                  │    │
│  │  GPIO:   DGPIO_0~11 (Digital GPIO)                               │    │
│  │          AGPIO_0~11 (Analog GPIO)                                │    │
│  │          AUXADC_0~3                                              │    │
│  │  Enable: ADRV_EN_TX1 / ADRV_EN_TX2                               │    │
│  │          ADRV_EN_RX1 / ADRV_EN_RX2                               │    │
│  │  Reset:  RESETB                                                  │    │
│  │  IRQ:    ADRV_GP_INT                                             │    │
│  ├────────────────────────────────────────────────────────────── ───┤    │
│  │  Clock                                                           │    │
│  │  ADRV_CLK_OUT ──────────────────────────────────► FPGA_SYSCLK    │    │
│  │  DEV_CLK_IN ◄──────────────────────────────────── DCOSC          │    │
│  │  DCOSC_SPI (SPI điều khiển DCXO)                                 │    │
│  ├─────────────────────────────────────────────────────────────── ──┤    │
│  │  Power (Sheet 13.2)                                              │    │
│  │  VDIGIO: +1V8_ADRV_VDIGIO                                        │    │
│  │  VDIG:   +1V_ADRV_VDIG                                           │    │
│  │  VANA1:  +1V3_ADRV_VANA1 / +1V8_ADRV_VANA1                       │    │
│  │  VANA2:  +1V3_ADRV_VANA2 / +1V8_ADRV_VANA2                       │    │
│  │  VDDA:   +1V3_ADRV_VDDA / +1V8_ADRV_VDDA                         │    │
│  │  VCONV:  +1V3_ADRV_VCONV / +1V8_ADRV_VCONV                       │    │
│  │  VCLKSYN:+1V3_ADRV_VCLKSYN / VCLKVCO                             │    │
│  │  VRFSYN: +1V3_ADRV_VRFSYN1/2 / VRFVCO1/2                         │    │
│  │  VLO:    +1V3_ADRV_VRX1LO/VRX2LO/VTX1LO/VTX2LO                   │    │
│  └────────────────────────────────────────────────────────────── ───┘    │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## 12. U_15 – Debug (FT2232H)

```
┌─────────────────────────────────────────────────────────────────┐
│  IC: FT2232H-56Q-TRAY (FTDI)                                    │
│  Dual High-Speed USB ↔ Serial/JTAG Bridge                       │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Channel A – JTAG                                        │   │
│  │  USB ↔ PS_JTAG_TCK/TDI/TDO/TMS                           │   │
│  │  (Lập trình / Debug FPGA qua USB)                        │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  Channel B – UART                                        │   │
│  │  USB ↔ PS_UART0_RX/TX                                    │   │
│  │  (Console debug qua USB)                                 │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  USB Interface                                           │   │
│  │  USB_VBUS / USB_P / USB_N → J8 Connector                 │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  EEPROM: 93LC56BT-E/SN (U4)                              │   │
│  │  Lưu cấu hình VID/PID FT2232H                            │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  Crystal: ECS-120-12-33Q-JES-TR (Y2)                     │   │
│  │  12 MHz reference clock                                  │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  Power                                                   │   │
│  │  VCORE: +1V8_VCORE (LDO TPS7A2018)                       │   │
│  │  VPHY:  +3V3_FT2232                                      │   │
│  │  VPLL:  +3V3_FT2232                                      │   │
│  │  VCCIO: +3V3_FT2232                                      │   │
│  │  USB VBUS: +5V_VBUS → LDO TPS7A2033 → +3V3_FT2232        │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 13. Kết Nối Liên Khối

### 13.1 SPI Bus Map

| SPI Bus | Master | Slave | Tín hiệu |
|---------|--------|-------|----------|
| `ADRV_SPI` | FPGA | ADRV9002 | SCLK, MOSI, MISO, CSb |
| `DCOSC_SPI` | PS SPI1 (EMIO) | DCXO | SCLK, MOSI, MISO, CSb |
| `TX_DSA_SPI` | AXI GPIO | RFSA3713 (TX) | SI, CLK, LE; software bit-banged |
| `RX_DSA_SPI` | AXI GPIO | RFSA3713 (RX) | SI, CLK, LE; software bit-banged |
| `ORX_DSA_SPI` | AXI GPIO | RFSA3713 (ORX) | SI, CLK, LE; software bit-banged |
| `LB_TFT_SPI` | FPGA | ADMV8052 | SCLK, SDI, SDO, CSb1/CSb2; SFL separate |
| `HB_TFT_SPI` | FPGA | ADMV8513/8526 | SCLK, SDI, SDO, CSb1..CSb4; SFL separate |

#### SPI controllers and FPGA pin assignment

Two independent AXI Quad SPI master IPs in the PL serve the separate low-band
and high-band buses. PS SPI0 remains connected to ADRV9002. PS SPI1 EMIO is
connected to the DCXO (`DCOSC_SPI`): SCLK AB4, MOSI V4, MISO AC4, CSb V3.
The DCXO controller uses the PS SPI1 peripheral at `0xFF050000`. Both TFT cores use
standard SPI, 8-bit transfers, 16-deep FIFOs, and a 16:1 SCK clock ratio.
CPOL/CPHA must be selected in software after checking each device's datasheet.
The 16:1 ratio is a conservative starting point (6.25 MHz from the current
100 MHz PL clock), not confirmation of the filter's maximum clock. Their
AXI-Lite base addresses are `0x81210000` for LB and `0x81220000` for HB.

| AXI Quad SPI net | Schematic net | FPGA package pin | Direction at FPGA |
|------------------|---------------|------------------|-------------------|
| `lb_tft_sclk` | `LB_TFT_SCLK` | J14 | Output |
| `lb_tft_mosi` | `LB_TFT_SDI` | G14 | Output |
| `lb_tft_miso` | `LB_TFT_SDO` | J15 | Input |
| `lb_tft_csn[0]` | `LB_TFT_CSb1` | J12 | Active-low output |
| `lb_tft_csn[1]` | `LB_TFT_CSb2` | G13 | Active-low output |
| `hb_tft_sclk` | `HB_TFT_SCLK` | C21 | Output |
| `hb_tft_mosi` | `HB_TFT_SDI` | D21 | Output |
| `hb_tft_miso` | `HB_TFT_SDO` | A22 | Input |
| `hb_tft_csn[0]` | `HB_TFT_CSb1` | G18 | Active-low output |
| `hb_tft_csn[1]` | `HB_TFT_CSb2` | E20 | Active-low output |
| `hb_tft_csn[2]` | `HB_TFT_CSb3` | C22 | Active-low output |
| `hb_tft_csn[3]` | `HB_TFT_CSb4` | G19 | Active-low output |

#### Auxiliary AXI GPIO and FPGA pin assignment

The auxiliary AXI GPIO occupies `0x81230000`. It has 17 tri-state-capable
signals; all are high-Z after reset until software configures their direction.
Bit 0 is the least-significant bit of the GPIO data/direction registers.

| AXI GPIO bit | Schematic net | FPGA port | Package pin |
|---:|---|---|---|
| 0 | `TX_DSA_SI` | `tx_dsa_si` | C18 |
| 1 | `TX_DSA_CLK` | `tx_dsa_clk` | A17 |
| 2 | `TX_DSA_LE` | `tx_dsa_le` | B18 |
| 3 | `RX_DSA_SI` | `rx_dsa_si` | D17 |
| 4 | `RX_DSA_CLK` | `rx_dsa_clk` | F18 |
| 5 | `RX_DSA_LE` | `rx_dsa_le` | E17 |
| 6 | `ORX_DSA_SI` | `orx_dsa_si` | J16 |
| 7 | `ORX_DSA_CLK` | `orx_dsa_clk` | G15 |
| 8 | `ORX_DSA_LE` | `orx_dsa_le` | H16 |
| 9 | `BBU_GPIO_1` (10 MHz) | `bbu_gpio_1` | AH14 |
| 10 | `BBU_GPIO_2` (UART RX) | `bbu_gpio_2` | AF15 |
| 11 | `BBU_GPIO_3` (UART TX) | `bbu_gpio_3` | AG15 |
| 12 | `TRX_SCLK` | `trx_sclk` | AJ14 |
| 13 | `TRX_MOSI` | `trx_mosi` | AK14 |
| 14 | `TRX_MISO` | `trx_miso` | AF13 |
| 15 | `LB_TFT_SFL` | `lb_tft_sfl` | G16 |
| 16 | `HB_TFT_SFL` | `hb_tft_sfl` | D20 |

The DSA signal groups are available as GPIO for software-driven serial
transactions. The BBU and SFL pins are also direction-configurable. The
schematic does not show a chip-select net for the `TRX_*` signals on J6, so
these three pins are exposed as GPIO and no complete SPI chip-select interface
is implied. Confirm the SFL meaning and direction and the BBU GPIO electrical
roles against the peripheral/connector requirements before enabling their
outputs.

### 13.2 Clock Distribution

```
  DCXO/TCXO
      │
      ▼ DEV_CLK_IN
  ADRV9002 ──── ADRV_CLK_OUT ────► FPGA_SYSCLK (PL)
      │
      └── Internal PLL → TX/RX LO generation

  External GTHREFCLK ──────────────► FPGA GTH Banks (128~230)
                                      → Aurora (BBU)
                                      → Ethernet SGMII
```

### 13.3 LVDS Data Interface (FPGA ↔ ADRV9002)

```
FPGA (PL HD Banks)                    ADRV9002
─────────────────────────────────────────────────────
ADRV_TX1_IDATA_IN_P/N    ──────────► TX1 I Data
ADRV_TX1_QDATA_IN_P/N    ──────────► TX1 Q Data
ADRV_TX1_STROBE_IN_P/N   ──────────► TX1 Strobe
ADRV_TX1_DCLK_IN_P/N     ──────────► TX1 Data Clock
ADRV_TX1_DCLK_OUT_P/N    ◄────────── TX1 Clock Out

ADRV_TX2_IDATA_IN_P/N    ──────────► TX2 I Data
ADRV_TX2_QDATA_IN_P/N    ──────────► TX2 Q Data
ADRV_TX2_STROBE_IN_P/N   ──────────► TX2 Strobe
ADRV_TX2_DCLK_IN_P/N     ──────────► TX2 Data Clock

ADRV_RX1_IDATA_OUT_P/N   ◄────────── RX1 I Data
ADRV_RX1_QDATA_OUT_P/N   ◄────────── RX1 Q Data
ADRV_RX1_STROBE_OUT_P/N  ◄────────── RX1 Strobe
ADRV_RX1_DCLK_OUT_P/N    ◄────────── RX1 Clock Out

ADRV_RX2_IDATA_OUT_P/N   ◄────────── RX2 I Data
ADRV_RX2_QDATA_OUT_P/N   ◄────────── RX2 Q Data
ADRV_RX2_STROBE_OUT_P/N  ◄────────── RX2 Strobe
ADRV_RX2_DCLK_OUT_P/N    ◄────────── RX2 Clock Out
```

### 13.4 GTH SerDes (Aurora – BBU)

```
FPGA GTH Bank 128/129/130/228/229/230
  MGTHTXP/N[0~3]_128 ──────────────────────► Aurora L1/L2 Tx → J2 BBU
  MGTHRXP/N[0~3]_128 ◄────────────────────── Aurora L1/L2 Rx ← J2 BBU
```

---

## 14. Danh Sách IC Chính

| Ref | IC | Chức năng | Nhà sản xuất |
|-----|----|-----------|--------------|
| U150 | `XCZU15EG-2FFVB1156I` | Zynq UltraScale+ MPSoC | Xilinx/AMD |
| U170 | `ADRV9002BBCZ` | 2T2R RF Transceiver 30MHz~6GHz | Analog Devices |
| U200 | `MT40A512M16LY-062E` | DDR4 SDRAM 8Gb | Micron |
| U250 | `MT25QL01GBBB8ESF` | QSPI NOR Flash 1Gb | Micron |
| U30 | `UCD90160ARGCT` | 16-Rail Power Sequencer/Monitor | Texas Instruments |
| U2 | `LTC4365ITS8` | OVP/UVP/Reverse Protection | Analog Devices |
| U160 | `FT2232H-56Q` | Dual USB↔UART/JTAG Bridge | FTDI |
| U4 | `93LC56BT-E/SN` | 2Kb Serial EEPROM | Microchip |
| U1 | `TPS7A2033PDBVR` | 200mA LDO +3V3 | Texas Instruments |
| — | `TPS7A2018PDBVR` | 200mA LDO +1V8 | Texas Instruments |
| — | `KSZ9131RNXI` | Gigabit Ethernet PHY | Microchip |
| U21 | `ADMV8052` | Tunable BPF (LB) | Analog Devices |
| U26 | `ADMV8513` | Tunable BPF (HB) | Analog Devices |
| U29 | `ADMV8526` | Tunable BPF (HB) | Analog Devices |
| U39 | `RFSA3713` | 6-bit DSA 0~31.5dB | Qorvo |
| U30 | `HMC197BE` | SPDT RF Switch | Analog Devices |
| U32/40 | `MAAM-011252/305` | RF Amplifier (LNA/Driver) | MACOM |
| U33 | `TSS2-53LNB+` | LNA 0.5~6GHz | Mini-Circuits |
| U27 | `FILTER_LFCN-2750D+` | Low-Pass Filter 2750MHz | Mini-Circuits |
| U34/36/38/41 | `SN74LVC8T245RHLR` | 8-bit Level Shifter 1.8V↔3.3V | Texas Instruments |
| — | `LM27761DSGR` | Charge Pump -2.5V | Texas Instruments |
| — | `NCP59744MN1ADJTBG` | LDO Regulator | ON Semiconductor |
| — | `REF3112AQDBZRQ1` | Voltage Reference 1.25V | Texas Instruments |
| — | `TPS51200DRCR` | DDR VTT Regulator | Texas Instruments |

---

## 15. Power Rails Tổng Hợp

```
+28V_UNFILTERED (J11 / J2 BBU)
    │
    ▼
LTC4365 (OVP/UVP)
    │
    ▼
+12V_VIN
    │
    ├──► +12V_UTILS ──► DC/DC ──► +5V3_UTILS
    │                          ──► +3V6_UTILS
    │                          ──► +3V3_UTILS
    │                          ──► +5V
    │
    └──► UCD90160 Power Sequencer
              │
              ├──► +0V85_VCCINT        (FPGA PL Core)
              ├──► +0V85_VPS_MGTRAVCC  (PS MGT)
              ├──► +0V9_VMGTAVCC       (GTH Analog)
              ├──► +1V2_VCC_PSPLL      (PS PLL)
              ├──► +1V2_VMGTAVTT       (GTH Term)
              ├──► +1V8_VCCAUX         (PL Aux)
              ├──► +1V8_VMGTVCCAUX     (GTH Aux)
              ├──► +3V3_VCCO           (PL I/O)
              │
              ├──► +1V2_DDR4_VDD       (DDR4 Core)
              ├──► +2V5_DDR4_VPP       (DDR4 Activate)
              ├──► +0V6_DDR4_VTT       (DDR4 Term)
              │
              ├──► +1V_ADRV            (ADRV9002 Digital Core)
              ├──► +1V3_ADRV           (ADRV9002 Analog)
              ├──► +1V8_ADRV           (ADRV9002 Digital I/O)
              ├──► +1V8_DCTCXO         (DCXO)
              │
              ├──► +3V3_RF             (RF Control ICs)
              ├──► +3V3_RF_FILTER      (TFT ICs)
              ├──► -2V5_RF             (TFT Negative Supply, LM27761)
              ├──► +5V_TX_RF           (TX Amplifiers)
              └──► +5V_RX_RF           (RX Amplifiers/LNAs)
```

---

## Ghi Chú

| Ký hiệu | Ý nghĩa |
|---------|---------|
| LB | Low Band |
| HB | High Band |
| TFT | Tunable Filter |
| DSA | Digital Step Attenuator |
| TRX | Transceiver (TX+RX path) |
| ORX | Observation RX |
| GB | Gain Block |
| BYP | Bypass |
| BBU | Baseband Unit |
| RFE | RF Front-End |
| SPDT | Single-Pole Double-Throw (RF Switch) |
| LVDS | Low Voltage Differential Signaling |
| GTH | Gigabit Transceiver High-speed (Xilinx) |
| Aurora | Xilinx high-speed serial protocol |
| PMBUS | Power Management Bus |
| OVP/UVP | Over/Under Voltage Protection |

---
*Tài liệu được tổng hợp từ T12_DSP_v01.pdf – 44 sheets schematic*
