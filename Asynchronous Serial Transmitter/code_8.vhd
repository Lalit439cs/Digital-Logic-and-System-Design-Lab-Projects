--A8 code
--Showing Receiver parallel output by 4 seven segment display
--connecting the parallel
-- output of the receiver (designed in the previous assignment) to the parallel input of the 
-- transmitter to form a loop
--Displaying by 4 seven segment-A3
--main module
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
    sevens: out std_logic_vector(6 downto 0);
      MTX_SERIAL : OUT std_logic
    );
end main;

--  architecture
architecture testbench of main is
--receiver component
component  RX_UART is

    port (
        i_Clk,reset      : in  std_logic;
        RSRX : in  std_logic; -- INPUT RX_Serial 
        RX_DONE     : out std_logic;
       OUT_RX   : out std_logic_vector(7 downto 0)
        );
end component;

component TX_UART is
  port (
    i_Clk       : in  std_logic;
    TX_DV     : in  std_logic;
    TX_BYTE   : in  std_logic_vector(7 downto 0); 
    TX_ACTIVE : out std_logic;
    TX_SERIAL : out std_logic;
    TX_DONE   : out std_logic
    );
end component;

  signal fours : std_logic_vector(3 downto 0);-- :="0000"
  signal rcounter: std_logic_vector(19 downto 0):= (others => '0');-- refresh counter
  --for creating refresh period of 10.5ms
  signal selector : std_logic_vector(1 downto 0);
  signal mo_RX_DV     : std_logic;
  signal inputs: std_logic_vector(15 downto 0):= (others => '0');
   signal mo_RX_Byte   : std_logic_vector(7 downto 0); --mo_RX_Byte
   signal i_Clk  : std_logic := '0';
   signal ccount : integer range 0 to 651 := 0;
--   SIGNAL I_TX_DV : STD_LOGIC;
--   SIGNAL I_TX_BYTE   : std_logic_vector(7 downto 0);
SIGNAL MTX_ACTIVE :  std_logic;
    SIGNAL MTX_DONE   :  std_logic;
   
   
begin

--receiver component initiation
RUT : RX_UART PORT MAP (i_Clk,reset,mi_RX_Serial,mo_RX_DV,mo_RX_Byte ) ;

--transmitter component initiation
TUT : TX_UART PORT MAP (i_Clk,mo_RX_DV,mo_RX_Byte,MTX_ACTIVE,MTX_SERIAL,MTX_DONE);

--for generating 16 * baud rate clock
process(clock)
begin
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

--for generating timing/refreshing signals
process(clock)
begin
--	if (reset = '1') then 
--    	rcounter <= (others => '0');
	if rising_edge(clock) then
    	rcounter <= rcounter +X"1";
    	if (reset = '1') then 
    	   inputs(7 downto 0) <= X"00" ;
    	elsif (mo_RX_DV = '1') THEN
    	   inputs(7 downto 0) <= mo_RX_Byte ;
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
-- 1
library IEEE;
use IEEE.std_logic_1164.all;
 use IEEE.NUMERIC_STD.ALL;
 
entity RX_UART is
  port (
    i_Clk,reset       : in  std_logic;
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
--   signal i_Clk  : std_logic := '0';
--   signal ccount : integer range 0 to 651 := 0;
   
  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal RX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
  signal r_RX_DV     : std_logic := '0';
  
--  signal RX_DONE     :  std_logic;
--   signal OUT_RX   : std_logic_vector(7 downto 0); -- 7 sd
   
begin
 
  -- Purpose: Double-register the incoming data.
  -- removes metastabiliy related problems)\
  
  
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
  if (reset = '1') then -- check working of reset ,otherwise in process list
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



----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/19/2022 04:56:37 PM
-- Design Name: 
-- Module Name: TX_UART - tbeh
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity TX_UART is
  port (
    i_Clk       : in  std_logic;
    TX_DV     : in  std_logic;
    TX_BYTE   : in  std_logic_vector(7 downto 0);
    TX_ACTIVE : out std_logic;
    TX_SERIAL : out std_logic;
    TX_DONE   : out std_logic
    );
end TX_UART;
 
 
architecture tbeh of TX_UART is
 
  type tstate is (IDLE, START_BIT, DATA_BITS,
                     STOP_BIT, CLEANUP);
                     
  signal state_t : tstate := IDLE;
  constant g_CLKS_PER_BIT : integer := 16 ;    -- Needs to be set correctly
 
  signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
  signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
  signal r_TX_Data   : std_logic_vector(7 downto 0) := (others => '0');
  signal r_TX_Done   : std_logic := '0';
   
begin
 
   
  p_TX_UART : process (i_Clk)
  begin
    if rising_edge(i_Clk) then
         
      case state_t is
 
        when IDLE =>
          TX_ACTIVE <= '0';
          TX_SERIAL <= '1';         -- Drive Line High for Idle
          r_TX_Done   <= '0';
          r_Clk_Count <= 0;
          r_Bit_Index <= 0;
 
          if TX_DV = '1' then
            r_TX_Data <= TX_BYTE;
            state_t <= START_BIT;
          else
            state_t <= IDLE;
          end if;
 
           
        -- Send out Start Bit. Start bit = 0
        when START_BIT =>
          TX_ACTIVE <= '1';
          TX_SERIAL <= '0';
 
          -- Wait g_CLKS_PER_BIT-1 clock cycles for start bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            state_t   <= START_BIT;
          else
            r_Clk_Count <= 0;
            state_t   <= DATA_BITS;
          end if;
 
           
        -- Wait g_CLKS_PER_BIT-1 clock cycles for data bits to finish          
        when DATA_BITS =>
          TX_SERIAL <= r_TX_Data(r_Bit_Index);
           
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            state_t   <= DATA_BITS;
          else
            r_Clk_Count <= 0;
             
            -- Check if we have sent out all bits
            if r_Bit_Index < 7 then
              r_Bit_Index <= r_Bit_Index + 1;
              state_t   <= DATA_BITS;
            else
              r_Bit_Index <= 0;
              state_t   <= STOP_BIT;
            end if;
          end if;
 
 
        -- Send out Stop bit.  Stop bit = 1
        when STOP_BIT =>
          TX_SERIAL <= '1';
 
          -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if r_Clk_Count < g_CLKS_PER_BIT-1 then
            r_Clk_Count <= r_Clk_Count + 1;
            state_t   <= STOP_BIT;
          else
            r_TX_Done   <= '1';
            r_Clk_Count <= 0;
            state_t   <= CLEANUP;
          end if;
 
                   
        -- Stay here 1 clock
        when CLEANUP =>
          TX_ACTIVE <= '0';
          r_TX_Done   <= '1';
          state_t   <= IDLE;
           
             
        when others =>
          state_t <= IDLE;
 
      end case;
    end if;
  end process p_TX_UART;
 
  TX_DONE <= r_TX_Done;
   
end tbeh;
--fine
