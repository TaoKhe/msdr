`include "system_infor.vh"

module system_info_wrapper # (
    // These match the AXI defaults from the VHDL file
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 8
) (
    // User Ports

    output cfg_reload_out,
    output gpio_test_out,
    output aurora_rst_out,
    output [31:0] gpio_mask1_ub_out,
    output [31:0] gpio_mask2_ub_out,
    output [31:0] gpio_mask3_ub_out,
    output [31:0] command1_out,
    output [31:0] command2_out,
    output [31:0] command3_out,
    output [31:0] command4_out,
    output [31:0] command5_out,
    output [31:0] tx_command_out,
    
    input  [31:0] tx_card_status_in,
    input  [31:0] aurora_status_in,
    
    // AXI4-Lite Ports
    input  wire                                S_AXI_ACLK,
    input  wire                                S_AXI_ARESETN,
    input  wire [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_AWADDR,
    input  wire [2 : 0]                        S_AXI_AWPROT,
    input  wire                                S_AXI_AWVALID,
    output wire                                S_AXI_AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input  wire                                S_AXI_WVALID,
    output wire                                S_AXI_WREADY,
    output wire [1 : 0]                        S_AXI_BRESP,
    output wire                                S_AXI_BVALID,
    input  wire                                S_AXI_BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,
    input  wire [2 : 0]                        S_AXI_ARPROT,
    input  wire                                S_AXI_ARVALID,
    output wire                                S_AXI_ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_RDATA,
    output wire [1 : 0]                        S_AXI_RRESP,
    output wire                                S_AXI_RVALID,
    input  wire                                S_AXI_RREADY
);

    // Instantiation of the VHDL entity
    // Mapping Verilog Parameters (from .vh) to VHDL Generics 
    system_info #(
        .HW_MAJOR    (HW_MAJOR),    // 16'h0003
        .HW_MINOR    (HW_MINOR),    // 8'h01
        .HW_REVISION (HW_REVISION), // 8'h01
        .RTL_MAJOR   (RTL_MAJOR),   // 16'h0001
        .RTL_MINOR   (RTL_MINOR),   // 8'h03 
        .RTL_REVISION(RTL_REVISION),// 8'h13
        .BUILD_YEAR  (BUILD_YEAR),  // 16'h2025
        .BUILD_MONTH (BUILD_MONTH), // 8'h09
        .BUILD_DATE  (BUILD_DATE),  // 8'h23
        .BUILD_HOUR  (BUILD_HOUR),  // 8'h01
        .BUILD_MIN   (BUILD_MIN),   // 8'h19
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
    ) u_system_ctrl_inst (
        .cfg_reload_out          (cfg_reload_out),
        .gpio_test_out           (gpio_test_out),
        .aurora_rst_out          (aurora_rst_out),
        .gpio_mask1_ub_out       (gpio_mask1_ub_out),
        .gpio_mask2_ub_out       (gpio_mask2_ub_out),
        .gpio_mask3_ub_out       (gpio_mask3_ub_out),
        .command1_out            (command1_out),
        .command2_out            (command2_out),
        .command3_out            (command3_out),
        .command4_out            (command4_out),
        .command5_out            (command5_out),
        .tx_command_out          (tx_command_out),
        .tx_card_status_in       (tx_card_status_in),
        .aurora_status_in        (aurora_status_in),
        .S_AXI_ACLK              (S_AXI_ACLK),
        .S_AXI_ARESETN           (S_AXI_ARESETN),
        .S_AXI_AWADDR            (S_AXI_AWADDR),
        .S_AXI_AWPROT            (S_AXI_AWPROT),
        .S_AXI_AWVALID           (S_AXI_AWVALID),
        .S_AXI_AWREADY           (S_AXI_AWREADY),
        .S_AXI_WDATA             (S_AXI_WDATA),
        .S_AXI_WSTRB             (S_AXI_WSTRB),
        .S_AXI_WVALID            (S_AXI_WVALID),
        .S_AXI_WREADY            (S_AXI_WREADY),
        .S_AXI_BRESP             (S_AXI_BRESP),
        .S_AXI_BVALID            (S_AXI_BVALID),
        .S_AXI_BREADY            (S_AXI_BREADY),
        .S_AXI_ARADDR            (S_AXI_ARADDR),
        .S_AXI_ARPROT            (S_AXI_ARPROT),
        .S_AXI_ARVALID           (S_AXI_ARVALID),
        .S_AXI_ARREADY           (S_AXI_ARREADY),
        .S_AXI_RDATA             (S_AXI_RDATA),
        .S_AXI_RRESP             (S_AXI_RRESP),
        .S_AXI_RVALID            (S_AXI_RVALID),
        .S_AXI_RREADY            (S_AXI_RREADY)
    );

endmodule
