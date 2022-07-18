----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2022 02:57:09 PM
-- Design Name: 
-- Module Name: sevenseg4 - funct4
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


--4 seven segment-A3

library IEEE;
use IEEE.std_logic_1164.all;
-- use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sevenseg4 is
port(
    inputs: in std_logic_vector(15 downto 0);
    clock : in std_logic;	--clock 100Mhz
    --, reset
    anodes: out std_logic_vector(3 downto 0);
    sevens: out std_logic_vector(6 downto 0)
    );
end sevenseg4;

--  architecture
architecture funct4 of sevenseg4 is
  signal fours : std_logic_vector(3 downto 0);-- :="0000"
  signal rcounter: std_logic_vector(19 downto 0):= (others => '0');-- refresh counter
  --for creating refresh period of 10.5ms
  signal selector : std_logic_vector(1 downto 0);
begin

--refresh rate range most probably 1ms to 16ms

--for generating timing/refreshing signals
process(clock)
begin
--	if (reset = '1') then 
--    	rcounter <= (others => '0');
	if rising_edge(clock) then
    	rcounter <= rcounter +X"1";
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
        anodes <= "1011";
        fours <= inputs(11 downto 8);
    when "11" =>
        anodes <= "0111";
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

end funct4;
