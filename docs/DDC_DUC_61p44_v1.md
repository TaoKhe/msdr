# DDC/DUC cho MSDR - profile TX/RX 61,44 MSps

**Phiên bản:** v1  
**Ngày:** 10/11/2026  
**Đối tượng:** T12, ADRV9002, FPGA dùng `axi_adrv9001`, project `msdr_repair_v3_gen`.

## 1. Kết luận thiết kế

Profile radio được người dùng xác nhận có tốc độ TX và RX là **61,44 MSps**.
Đây là 61,44 triệu **cặp I/Q mỗi giây trên mỗi kênh**, không phải tổng số
giá trị I và Q.

- Nếu BBU cũng trao đổi I/Q ở 61,44 MSps: không cần đổi tốc độ mẫu,
  tức DDC/DUC có hệ số 1. Vẫn có thể cần dịch tần hoặc lọc.
- Nếu BBU dùng tốc độ thấp hơn: DDC giảm tốc độ ở RX, DUC tăng tốc độ ở TX.
- Clock bus Aurora không xác định tốc độ mẫu I/Q.
- FIFO đổi miền clock không thay thế bộ lọc đổi tốc độ mẫu.
- V3 chưa bảo đảm bảo toàn mẫu xuyên suốt Aurora ↔ radio. Cần sửa điều tiết
  mẫu trước khi coi đây là đường truyền I/Q hoạt động đúng trên phần cứng.

Tài liệu này mô tả và đề xuất thiết kế; **chưa thêm DDC/DUC vào RTL**.

## 2. Ba loại tốc độ không được nhầm lẫn

| Đại lượng | Ý nghĩa | Giá trị trong trường hợp đang xét |
|---|---|---|
| `Fs` | Tốc độ các cặp I/Q hợp lệ | 61,44 MSps/kênh theo profile |
| DCLK SSI/LVDS | Clock vật lý truyền dữ liệu nối tiếp giữa FPGA và radio | 491,52 MHz nếu LVDS DDR hai lane riêng I/Q, mỗi thành phần 16-bit, không có overhead bổ sung |
| Clock logic song song | Clock xử lý sau SERDES chia 4 | 122,88 MHz nếu DCLK là 491,52 MHz |
| Clock AXI/Aurora | Clock vận chuyển các word dữ liệu đóng gói | Khoảng 161,133 MHz trong báo cáo timing v3 |
| PS PL0/PL1/PL2 | Các clock do PS phát | 100/250/500 MHz trong thiết kế |

### 2.1 Vì sao DCLK có thể bằng 8 × Fs?

Với hai lane LVDS, một lane cho I và một lane cho Q:

```text
Mỗi lane truyền 16 bit cho một mẫu thành phần.
DDR truyền 2 bit mỗi chu kỳ DCLK.
DCLK = 16 / 2 × Fs = 8 × Fs
     = 8 × 61,44 MHz = 491,52 MHz.
```

Sau SERDES 8 bit/lane, clock song song bằng DCLK/4:

```text
Flogic = 491,52 / 4 = 122,88 MHz = 2 × Fs.
```

Trong điều kiện đó, nhịp mẫu trung bình là một cặp I/Q trên hai chu kỳ logic.
Không tự tạo tín hiệu valid bằng cách chia đôi clock: dùng qualifier/yêu cầu
mẫu của core để giữ đúng pha, reset và chế độ hoạt động.

**Giới hạn của phép tính:** profile 61,44 MSps một mình chưa chứng minh toàn bộ
cấu hình SSI. Cần đối chiếu chế độ lane, DDR, độ dài word, nguồn clock và các
thanh ghi runtime. Không áp dụng máy móc tỷ lệ trên cho CMOS hoặc một lane.

### 2.2 Giá trị timing v3 không phải số đo phần cứng

[Báo cáo timing v3](../msdr_repair_v3_gen/repair_timing_final_v3.rpt) đang dùng
constraint RX/TX DCLK 500 MHz, từ đó suy ra clock logic 125 MHz.

Đây là mô hình static timing, không phải bằng chứng radio thực tế đang chạy
500 MHz hoặc phát 125 triệu mẫu hợp lệ mỗi giây.

Nếu cấu hình phần cứng xác nhận DCLK 491,52 MHz thì constraint tương ứng có
chu kỳ khoảng **2,034505 ns**. Sau khi cập nhật phải chạy lại implementation,
timing và kiểm tra clock liên quan. Việc này chưa được thực hiện trong tài liệu.

## 3. DCLK nằm ở cổng nào?

Tên cổng IP được dùng chung cho LVDS và CMOS.

| Cổng kênh 1 trên `axi_adrv9001` | Hướng so với FPGA | Vai trò |
|---|---|---|
| `rx1_dclk_in_p_dclk_in`, `rx1_dclk_in_n_NC` | Vào | Clock đi kèm dữ liệu RX từ radio |
| `tx1_dclk_in_p_dclk_in`, `tx1_dclk_in_n_NC` | Vào | Clock TX do radio đưa sang FPGA |
| `tx1_dclk_out_p_dclk_out`, `tx1_dclk_out_n_NC` | Ra | Clock FPGA đưa sang radio cùng dữ liệu TX |
| `adc_1_clk` | Ra khỏi IP, dùng trong fabric | Clock logic đường RX |
| `dac_1_clk` | Ra khỏi IP, dùng trong fabric | Clock logic đường TX |

Kênh 2 thay `1` bằng `2`.

Trong **LVDS**, hậu tố `_n_NC` vẫn là cực âm của cặp vi sai và cần nối.
`NC` chỉ phản ánh chân không dùng trong chế độ CMOS tương ứng.

**Không nối DDC/DUC trực tiếp vào các cổng DCLK vật lý.** Dùng clock logic
`adc_*_clk`/`dac_*_clk`, kèm valid, enable hoặc request theo giao thức thực tế.

Ở v3, `USE_RX_CLK_FOR_TX1/2 = 2`; clock logic TX được lựa chọn từ miền RX
theo cấu hình IP. Vì thế không được mặc định `dac_1_clk` luôn sinh từ
`tx1_dclk_in_*` chỉ dựa vào tên cổng. Cần xác nhận lựa chọn này phù hợp
cấu hình đồng bộ RX/TX của radio.

## 4. DDC và DUC làm gì?

### DDC - Digital Down Converter

Đường nhận:

```text
ADRV9002 RX → axi_adrv9001 → dịch tần NCO → lọc chống alias
            → giảm mẫu D → đóng gói → Aurora → BBU
```

```text
Fs_BBU = Fs_RX / D
```

Nếu dữ liệu radio đã là complex baseband đúng tâm tần số, có thể bỏ mixer/NCO.
Không được bỏ bộ lọc chống alias khi giảm mẫu chỉ vì dữ liệu đã là I/Q.

### DUC - Digital Up Converter

Đường phát:

```text
BBU → Aurora → giải đóng gói → nội suy L → lọc chống ảnh phổ
    → dịch tần NCO → axi_adrv9001 → ADRV9002 TX
```

```text
Fs_TX = Fs_BBU × L
```

Thứ tự mixer và các tầng lọc có thể thay đổi theo kiến trúc, nhưng tần số NCO
phải được tính theo sample rate tại chính vị trí mixer.

Với NCO có accumulator N bit:

```text
phase_increment = round(f_offset / Fs_NCO × 2^N)
```

NCO phải tiến pha theo **mẫu hợp lệ**, không theo mọi clock fabric nếu valid
có khoảng trống. Dấu dịch tần cần thống nhất theo quy ước complex mixer.

## 5. Chọn hệ số cho profile 61,44 MSps

| Tốc độ I/Q phía BBU, mỗi kênh | DDC RX | DUC TX |
|---:|---:|---:|
| 61,44 MSps | 1 | 1 |
| 30,72 MSps | 2 | 2 |
| 15,36 MSps | 4 | 4 |
| 7,68 MSps | 8 | 8 |
| 3,84 MSps | 16 | 16 |

Ví dụ BBU dùng 15,36 MSps:

```text
RX: 61,44 MSps → DDC /4 → 15,36 MSps → Aurora.
TX: Aurora → 15,36 MSps → DUC ×4 → 61,44 MSps.
```

Các hệ số 2/4/8 phù hợp kiến trúc nhiều tầng half-band. CIC có thể hữu ích
cho hệ số lớn, nhưng cần xử lý gain, bit growth và bù droop.

Không chọn hệ số chỉ từ clock PL 100/250/500 MHz hoặc clock Aurora.
Clock xử lý quyết định khả năng tính toán; valid quyết định tốc độ mẫu.

## 6. Hiện trạng thực tế của v3

Nguồn top-level:
[msdr_fpga_v3.vhd](../src/hdl/top/msdr_fpga_v3.vhd).

### 6.1 Đường RX

- `sample_clk_s` và `clk_375M` thực tế nối tới `adc_1_clk`.
- `Sample_IQin_valid` nối từ `adc_1_valid`.
- Word 64-bit gồm `{I_RX1, Q_RX1, I_RX2, Q_RX2}`, mỗi thành phần 16-bit.
- RX2 đi qua FIFO CDC vào miền RX1.
- Chưa có DDC giữa ADC và framer.

Do đó tên `clk_375M` không có nghĩa clock đang chạy 375 MHz.
Khi ADC không hỗ trợ backpressure, DDC và FIFO sau nó phải nhận được mọi mẫu
hợp lệ; không được dựa vào `ready=0` để dừng radio.

FIFO CDC của RX2 chỉ vượt miền clock, không tự chứng minh hai kênh được căn
chỉnh cùng thời điểm. Hệ thống nhiều kênh cần kiểm tra đồng bộ và sample index.

### 6.2 Đường TX

- `clk_250m_aurora_s` thực tế nối tới `dac_1_clk`, không phải PS PL1 250 MHz.
- Deframer xuất word 32-bit `{I, Q}` theo clock này.
- Deframer có cơ chế giữ/lặp mẫu khi FIFO thiếu và bỏ dữ liệu khi quá đầy.
- Top chọn I/Q rồi đóng gói hai mẫu liên tiếp vào một word 64-bit.
- `dac_unpack` lấy lại hai mẫu, cấp dữ liệu theo từng chu kỳ `dac_1_clk`.
- Đường tùy biến này chưa điều tiết đầy đủ theo nhịp yêu cầu mẫu DAC.

**Hệ quả:** nếu clock logic là 122,88 MHz nhưng radio nhận 61,44 MSps,
không thể coi mọi lần cập nhật word là một mẫu radio được phát.
Việc lặp/bỏ mẫu trong elastic buffer không tương đương nội suy/giảm mẫu có lọc.
Không dùng nó để chuyển tỷ lệ 2:1.

Comment cũ nói 250 MSps trong deframer mô tả giả định cũ, không phải giá trị
được xác nhận của project v3.

## 7. Kiến trúc ghép khối đề xuất

### 7.1 Chế độ giữ nguyên 61,44 MSps ở BBU

```text
RX: ADC data + valid → FIFO/packetizer → Aurora.
TX: Aurora → FIFO I/Q → cấp một mẫu trên mỗi yêu cầu DAC.
```

Không cần bộ lọc đổi tốc độ. Cần sửa flow control để:

1. Mỗi mẫu RX hợp lệ vào framer đúng một lần.
2. Mỗi mẫu TX từ BBU được DAC tiêu thụ đúng một lần.
3. FIFO chỉ pop khi thật sự chuyển giao một mẫu.
4. Reset, startup, link loss và underrun có hành vi rõ ràng.

Đây là chế độ nên xác minh trước khi thêm hệ số đổi tốc độ.

### 7.2 Chế độ BBU 15,36 MSps

```text
RX, miền adc_clk:
  adc_valid → DDC /4 → FIFO CDC → Aurora framer.

TX:
  Aurora deframer → FIFO CDC → DUC ×4 → FIFO đầu ra → DAC request.
```

Trong miền xử lý 122,88 MHz, nhịp trung bình tương ứng:

| Luồng | Mẫu/giây | Trung bình số clock/mẫu |
|---|---:|---:|
| Radio RX/TX | 61,44 M | 2 |
| BBU sau DDC /4, trước DUC ×4 | 15,36 M | 8 |

Đây là quan hệ trung bình, không phải yêu cầu mọi luồng luôn có valid cách đều.
Các khối streaming có thể phát burst; FIFO và handshake phải xử lý được.

### 7.3 Quy tắc handshake

- AXI-Stream chỉ chuyển giao khi `tvalid AND tready = 1`.
- Khi `tvalid=1` và `tready=0`, giữ nguyên dữ liệu và các sideband.
- FIFO CDC không tự chuyển sample rate.
- Phía ADC không dừng được cần đủ throughput và bộ đệm hữu hạn được tính toán.
- Phía DAC phải có dữ liệu đúng hạn; underrun cần flag/counter và chính sách
  rõ ràng như phát zero hoặc giữ mẫu, không âm thầm coi là bình thường.
- Không suy diễn `dac_*_valid`, enable và request có cùng ý nghĩa. Đối chiếu
  chế độ nguồn dữ liệu, thanh ghi datarate và pipeline của ADI trước khi nối.
- Nếu dùng FIR Compiler, cấu hình đúng clock frequency, input sample rate,
  số kênh và cơ chế backpressure; kiểm tra throughput thực tế sau generate.

## 8. Băng thông Aurora

Với I và Q đều 16-bit:

```text
Payload một kênh = Fs × 32 bit.
61,44 MSps × 32 = 1,96608 Gbit/s.
Hai kênh RX = 3,93216 Gbit/s.
```

Với BBU 15,36 MSps:

```text
Một kênh = 0,49152 Gbit/s.
Hai kênh = 0,98304 Gbit/s.
```

Đây chỉ là payload I/Q. Phải cộng overhead frame, metadata, GFP/SA,
clock compensation, idle và encoding đường truyền.
Bus 64-bit ở khoảng 161,133 MHz không có nghĩa toàn bộ băng thông đó luôn
dành được cho mẫu I/Q.

Hai hướng link full-duplex cần tính riêng theo số kênh và lưu lượng thực tế.

## 9. Thiết kế bộ lọc và định dạng số

Trước khi tạo coefficient, xác định:

- Băng thông tín hiệu hữu ích và vùng guard.
- Passband ripple, stopband attenuation và transition bandwidth.
- Mức tín hiệu đầu vào lớn nhất, gain mixer/filter và giới hạn clipping.
- Word length đầu vào/đầu ra, coefficient width, accumulator width.
- Cách làm tròn, saturation và scaling; tránh wrap-around.
- Độ trễ cố định của từng tầng, kể cả FIFO và pipeline.

Với giảm mẫu hệ số D, đầu ra có Nyquist ±Fs_out/2. Bộ lọc phải chặn các
thành phần sẽ alias vào băng thông hữu ích; không giữ tín hiệu vượt giới hạn
này chỉ bằng cách bỏ mẫu.

Với nội suy hệ số L, bộ lọc phải loại ảnh phổ. Kiểm tra chuẩn hóa gain:
chèn zero và lọc có thể làm thay đổi biên độ nếu coefficient không được
chuẩn hóa theo kiến trúc.

Độ trễ DDC/DUC cần phản ánh vào timestamp và thời điểm phát TDD. Không chỉ
kiểm tra phổ đẹp mà bỏ qua sample alignment và thời gian phát.

## 10. Checklist kiểm chứng

### A. Chốt cấu hình radio và clock

- Xác nhận profile thực tế TX/RX 61,44 MSps đã được nạp.
- Đọc chế độ SSI: LVDS, DDR, số lane, độ dài mẫu và nguồn clock TX.
- Đo hoặc đếm RX DCLK, TX DCLK và clock logic.
- Đếm mẫu RX valid và yêu cầu mẫu TX trong khoảng thời gian đã biết.
- Không dùng số đo valid đã bị TDD gate để suy ra active sample rate nếu
  không loại thời gian kênh tắt.

### B. Mô phỏng chức năng

- Dùng ramp/sample index để phát hiện mất, lặp hoặc đảo mẫu.
- Kiểm tra thứ tự I/Q và thứ tự hai mẫu trong word 64-bit.
- Kiểm tra backpressure, reset giữa frame, mất link và FIFO đầy/rỗng.
- Kiểm tra lệch ppm giữa nguồn BBU và radio; quyết định cơ chế đồng bộ clock
  hoặc resampling thích hợp, không dựa vào FIFO để chữa sai lệch kéo dài.
- Với DDC/DUC: chạy tone trong băng, sát mép và ngoài băng; đo alias, ảnh phổ,
  ripple, gain, clipping và latency.

### C. Sau implementation và trên board

- Cập nhật đúng constraint và chạy lại timing/CDC.
- Đảm bảo đủ throughput cho mọi kênh đồng thời.
- Quan sát FIFO level, overflow/underflow và số mẫu bằng ILA/counter.
- Đo phổ và sample rate thực tế trước khi dùng cho RF.

## 11. Các điểm tham chiếu

- [Top-level v3](../src/hdl/top/msdr_fpga_v3.vhd):
  ghép ADC, protocol, FIFO TX và DAC.
- [Aurora protocol](../src/hdl/aurora/aurora_protocol.vhd):
  clock framer và deframer tách riêng.
- [Aurora deframer](../src/hdl/aurora_deframer/aurora_deframer.vhd):
  FIFO và cơ chế elastic buffer.
- [Block design v3](../msdr_repair_v3_gen/msdr.srcs/sources_1/bd/system/system.bd):
  cấu hình LVDS và nguồn clock TX.
- [Constraint LVDS](../src/xdc/msdr_lvds.xdc):
  clock/pin hiện tại.
- [Timing v3](../msdr_repair_v3_gen/repair_timing_final_v3.rpt):
  clock được static timing phân tích.
- [ADI RX link](../src/hdl/library/axi_adrv9001/adrv9001_rx_link.v) và
  [ADI TX datapath](../src/hdl/library/axi_adrv9001/axi_adrv9001_tx.v):
  qualifier mẫu và điều khiển datarate.

Các file ADI được tham chiếu để hiểu giao thức, không sửa core.
Các báo cáo và đường dẫn generated ở trên chỉ tồn tại khi giữ project v3.

## 12. Cấu hình đề xuất ban đầu

**Nếu chưa có yêu cầu giảm băng thông BBU:** bắt đầu với 61,44 MSps xuyên suốt,
DDC/DUC hệ số 1, sửa handshake TX/RX và chứng minh bảo toàn mẫu.

**Nếu BBU yêu cầu 15,36 MSps:** dùng DDC /4 và DUC ×4, sau khi hoàn tất
điều tiết mẫu, đồng bộ clock và xác định đặc tính bộ lọc.

Không tự chọn hệ số 2 chỉ vì clock xử lý bằng 122,88 MHz. Tỷ lệ đó là
quan hệ clock/valid, không tự nó là nhu cầu nội suy hoặc giảm mẫu.
