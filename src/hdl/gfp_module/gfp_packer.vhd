----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/28/2025 03:35:56 AM
-- Design Name: 
-- Module Name: gfp_packer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gfp_packer is
 Port (
    gfp_clk_in                  : in std_logic;
    gfp_rstn_in                 : in std_logic;
    gfp_sink_data_in            : in std_logic_vector(7 downto 0);
    gfp_sink_valid_in           : in std_logic;
    gfp_sink_ready_out          : out std_logic;
    gfp_sink_last_in            : in std_logic;
    
    gfp_source_data_out        : out std_logic_vector(7 downto 0);
    gfp_source_valid_out       : out std_logic;
    gfp_source_ready_in        : in std_logic;
    gfp_source_last_out        : out std_logic
 );
end gfp_packer;

architecture Behavioral of gfp_packer is
    signal gfp_sink_edge_valid : std_logic; 
    signal gfp_sink_edge_valid_delay : std_logic; 
    signal gfp_sink_edge_valid_delay1 : std_logic; 
    signal gfp_sink_edge_valid_delay2 : std_logic; 
    signal gfp_sink_valid_delay : std_logic;
    signal gfp_sink_valid_delay1 : std_logic;
    signal gfp_sink_valid_delay2 : std_logic;
    signal gfp_sink_valid_delay3 : std_logic;
    signal gfp_sink_last_delay : std_logic;
    signal crg_reg : std_logic_vector(7 downto 0); 

begin
    gfp_sink_ready_out <= gfp_source_ready_in;
    process(gfp_clk_in)
    begin
        if(gfp_clk_in'event and gfp_clk_in = '1') then
            if(gfp_rstn_in = '0')then
                gfp_sink_edge_valid <= '0';
                gfp_sink_valid_delay <= '0';

            else
                if(gfp_sink_edge_valid = '1') then
                    gfp_sink_valid_delay    <= gfp_sink_valid_in;
                    gfp_sink_last_delay     <= gfp_sink_last_in;
                    gfp_sink_valid_delay1   <= gfp_sink_valid_delay;
                    gfp_sink_valid_delay2   <= gfp_sink_valid_delay1;
                    gfp_sink_valid_delay3   <= gfp_sink_valid_delay2;
                else
                    gfp_sink_valid_delay    <= '0';
                    gfp_sink_last_delay     <= '0';
                    gfp_sink_valid_delay1   <= '0';
                    gfp_sink_valid_delay2   <= '0';
                    gfp_sink_valid_delay3   <= '0';
                end if;
                if(gfp_sink_edge_valid = '0') then
                    if(gfp_sink_valid_in = '1') and (gfp_sink_data_in = x"4e") and (gfp_source_ready_in = '1') then
                        gfp_sink_edge_valid <= '1';
                        gfp_source_last_out  <= '0' ; 
                    end if;
                elsif(gfp_sink_last_delay = '1')then
                    gfp_sink_edge_valid <= '0';
                end if;
                if(gfp_source_ready_in = '1') then
                    if(gfp_sink_valid_in = '1') then
                        gfp_source_data_out <= gfp_sink_data_in;
                        gfp_source_valid_out <= '1';
                        gfp_sink_edge_valid_delay    <= gfp_sink_edge_valid;
                        gfp_sink_edge_valid_delay1    <= gfp_sink_edge_valid_delay;
                        gfp_sink_edge_valid_delay2    <= gfp_sink_edge_valid_delay1;
                    elsif(gfp_sink_last_delay = '1') and (gfp_sink_valid_delay = '1')then
                        gfp_source_data_out <= crg_reg;
                        gfp_source_last_out  <= '1' ;            
                    elsif(gfp_source_last_out = '1')then
                        gfp_source_valid_out     <= '0';
                        gfp_source_last_out      <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;

-- CRC polynomial coefficients: x^8 + x^2 + x + 1
--                              0x7 (hex)
-- CRC width:                   8 bits
-- CRC shift direction:         left (big endian)
-- Input word width:            8 bits

    crc_cal_proc: process(gfp_clk_in)
    begin
        if(gfp_clk_in'event and gfp_clk_in = '1') then
            if(gfp_rstn_in = '0') or (gfp_sink_valid_delay2 = '0') then
                crg_reg <= (others => '0'); 
            else
                if(gfp_sink_valid_in = '1') and (gfp_sink_valid_in = '1') and (gfp_source_ready_in = '1') and (gfp_sink_edge_valid_delay2 = '1') then
                    crg_reg(0) <= crg_reg(0) xor crg_reg(6) xor crg_reg(7) xor gfp_sink_data_in(0) xor gfp_sink_data_in(6) xor gfp_sink_data_in(7);
                    crg_reg(1) <= crg_reg(0) xor crg_reg(1) xor crg_reg(6) xor gfp_sink_data_in(0) xor gfp_sink_data_in(1) xor gfp_sink_data_in(6);
                    crg_reg(2) <= crg_reg(0) xor crg_reg(1) xor crg_reg(2) xor crg_reg(6) xor gfp_sink_data_in(0) xor gfp_sink_data_in(1) xor gfp_sink_data_in(2) xor gfp_sink_data_in(6);
                    crg_reg(3) <= crg_reg(1) xor crg_reg(2) xor crg_reg(3) xor crg_reg(7) xor gfp_sink_data_in(1) xor gfp_sink_data_in(2) xor gfp_sink_data_in(3) xor gfp_sink_data_in(7);
                    crg_reg(4) <= crg_reg(2) xor crg_reg(3) xor crg_reg(4) xor gfp_sink_data_in(2) xor gfp_sink_data_in(3) xor gfp_sink_data_in(4);
                    crg_reg(5) <= crg_reg(3) xor crg_reg(4) xor crg_reg(5) xor gfp_sink_data_in(3) xor gfp_sink_data_in(4) xor gfp_sink_data_in(5);
                    crg_reg(6) <= crg_reg(4) xor crg_reg(5) xor crg_reg(6) xor gfp_sink_data_in(4) xor gfp_sink_data_in(5) xor gfp_sink_data_in(6);
                    crg_reg(7) <= crg_reg(5) xor crg_reg(6) xor crg_reg(7) xor gfp_sink_data_in(5) xor gfp_sink_data_in(6) xor gfp_sink_data_in(7);
                end if;
            end if;
        end if;
    end process;


end Behavioral;
