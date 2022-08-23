--A7 code
--Showing Receiver parallel output by 4 seven segment display
--Displaying by 4 seven segment-A3

library IEEE;
use IEEE.std_logic_1164.all;
 use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--m stands for connecting signals of main entity
entity main is
port(
    mi_RX_Serial : in  std_logic;
    clock,reset : in std_logic;	--clock 100Mhz
    anodes: out std_logic_vector(3 downto 0);
    sevens: out std_logic_vector(6 downto 0)
    );
end main;

--  architecture
architecture testbench of main is
--receiver component
component  RX_UART is

  port (
    clock,reset      : in  std_logic;
    RSRX : in  std_logic; -- INPUT RX_Serial 
    RX_DONE     : out std_logic;
   OUT_RX   : out std_logic_vector(7 downto 0)
    );
end component;

  signal fours : std_logic_vector(3 downto 0);-- :="0000"
  signal rcounter: std_logic_vector(19 downto 0):= (others => '0');-- refresh counter
  --for creating refresh period of 10.5ms
  signal selector : std_logic_vector(1 downto 0);
  signal mRX_DONE     : std_logic;
  signal inputs: std_logic_vector(15 downto 0):= (others => '0');
   signal mOUT_RX   : std_logic_vector(7 downto 0); --mo_RX_Byte
begin

--receiver component initiation
RUT : RX_UART PORT MAP (clock,reset,mi_RX_Serial,mRX_DONE,mOUT_RX ) ;

 

--for generating timing/refreshing signals
process(clock)
begin
--	if (reset = '1') then 
--    	rcounter <= (others => '0');
	if rising_edge(clock) then
    	rcounter <= rcounter +X"1";
    	if (reset = '1') then 
    	   inputs(7 downto 0) <= X"00" ;
    	elsif (mRX_DONE = '1') THEN
    	   inputs(7 downto 0) <= mOUT_RX ;
    	   END IF;
    	
	end if;
end process;

--refresh period of 10.5ms
selector <= rcounter (19 downto 18 );-- select signal in below multiplexing logic
    	

--multiplexer for selecting current displaying seven segment display and its 4 bits of a displaying digit 
process(selector)
begin
    case selector is 
    when "00" =>
        anodes <= "1110";
        fours <= inputs(3 downto 0);
    when "01" =>
        anodes <= "1101";
        fours <= inputs(7 downto 4);
    when "10" =>
        anodes <= "1111";
        fours <= inputs(11 downto 8);
    when "11" =>
        anodes <= "1111";
        fours <= inputs(15 downto 12);
     when others => null;
    end case;
end process;



-- seven segment display
with fours select sevens <=
    "1000000" when "0000",--0
    "1111001" when "0001",--1
    "0100100" when "0010",--2
    "0110000" when "0011",--3
    "0011001" when "0100",--4
    "0010010" when "0101",--5
    "0000010" when "0110",--6
    "1111000" when "0111",--7
    "0000000" when "1000",--8
    "0010000" when "1001",--9
    "0100000" when "1010",--A
    "0000011" when "1011",--b
    "1000110" when "1100",--C
    "0100001" when "1101",--d
    "0000110" when "1110",--E
    "0001110" when "1111",--F
    "1111111" when others;

end testbench;


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/18/2022 12:44:32 PM
-- Design Name: 
-- Module Name: RX_UART - rbeh
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


-- This file contains the UART Receiver.  This receiver is able to
-- receive 8 bits of serial data, one start bit, one stop bit,
-- and no parity bit.  When receive is complete RX_DONE will be
-- driven high for one clock cycle.
-- 
-- Set Generic g_CLKS_PER_BIT as follows:
-- g_CLKS_PER_BIT = (Frequency of i_Clk)/(Frequency of UART)
-- 16
--
library IEEE;
use IEEE.std_logic_1164.all;
 use IEEE.NUMERIC_STD.ALL;
 
entity RX_UART is
  port (
    clock,reset       : in  std_logic;
    RSRX : in  std_logic; -- INPUT RX_Serial
    RX_DONE     : out std_logic;
   OUT_RX   : out std_logic_vector(7 downto 0) -- OUTPUT RX_Byte
    );
end RX_UART;
 
 
architecture rbeh of RX_UART is
 
  type rstate is (IDLE, START_BIT, DATA_BITS,
                     STOP_BIT, CLEANUP);
  signal state : rstate := IDLE;
  constant g_CLKS_PER_BIT : integer := 16 ;    -- Needs to be set correctly
 
  signal RX_Data_R : std_logic := '0';
  signal RX_Data   : std_logic := '0';
  signal i_Clk  : std_logic := '0';
  signal ccount : integer range 0 to 651 := 0;
   
  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal RX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
  signal r_RX_DV     : std_logic := '0';
  
--  signal RX_DONE     :  std_logic;
--   signal OUT_RX   : std_logic_vector(7 downto 0); -- 7 sd
   
begin
 
  -- Purpose: Double-register the incoming data.
  -- removes metastabiliy related problems)\
  
  --for generating timing/refreshing signals
process(clock)
begin
--	if (reset = '1') then 
--    	rcounter <= (others => '0');
	if rising_edge(clock) then
    	ccount <= ccount + 1;
    	if (ccount < 325) then 
        	i_Clk <= '0';
          elsif (ccount < 649) then --650-1
          i_Clk <= '1';
          elsif(ccount = 649) then ccount <= 0;
          end if;
          
    
          
	end if;
end process;
  
  p_SAMPLE : process (i_Clk)
  begin

    if rising_edge(i_Clk) then
      RX_Data_R <= RSRX;
      RX_Data   <= RX_Data_R;
    end if;
  end process p_SAMPLE;
   
 
  -- Purpose: Control RX state machine
  p_UART_RX : process (i_Clk,reset)
  begin
  if (reset = '1') then -- check working of reset 
           state <= IDLE;
          
    elsif rising_edge(i_Clk) then
    
    
         
      case state is
 
        when IDLE =>
          r_RX_DV     <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;
 
          if RX_Data = '0' then       --  detecting Start bit
            state <= START_BIT;
          else
            state <= IDLE;
          end if;
 
           
        -- Checking middle of start bit 
        when START_BIT =>
          if r_Clk_Count = (g_CLKS_PER_BIT-1)/2 then
            if RX_Data = '0' then
              r_Clk_Count <= 0;  -- reset counter as middle
              state   <= DATA_BITS;
            else
              state   <= IDLE;
            end if;
          else
            r_Clk_Count <= r_Clk_Count + 1;
            state   <= START_BIT;
          end if;
 
           
        -- to sample serial data ,Wait g_CLKS_PER_BIT-1 clock cycles 
        when DATA_BITS =>
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            state   <= DATA_BITS;
          else
            r_Clk_Count            <= 0;
            RX_Byte(r_Bit_Index) <= RX_Data;
             
            -- Check for sent out all bits or not
            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
              state   <= DATA_BITS;
            else
              r_Bit_Index <= 0;
              state   <= STOP_BIT;
            end if;
          end if;
 
 
        --  Stop bit = 1 Receive Stop bit.  
        when STOP_BIT =>
          -- for Stop bit to finish,Wait g_CLKS_PER_BIT-1 clock cycles 
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            state   <= STOP_BIT;
          else
            r_RX_DV     <= '1';
            r_Clk_Count <= 0;
            state   <= CLEANUP;
          end if;
 
                   
        -- for 1 clock
        when CLEANUP =>
          state <= IDLE;
          r_RX_DV   <= '0';
 
             
        when others =>
          state <= IDLE;
 
      end case;
    end if;
  end process p_UART_RX;
  OUT_RX <= RX_Byte;
  RX_DONE   <= r_RX_DV;
  
   
end rbeh;

