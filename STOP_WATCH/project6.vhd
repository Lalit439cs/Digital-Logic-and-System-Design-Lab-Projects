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
 use IEEE.NUMERIC_STD.ALL;
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


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/12/2022 09:23:14 AM
-- Design Name: 
-- Module Name: stopwatch - beh
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


--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;




--A6
--maintaining modularity by using A3 pre-built seven segment display
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity stopwatch is
port(
    clock, reset : in std_logic;	--clock 100Mhz
    anodes: out std_logic_vector(3 downto 0);
    sevens: out std_logic_vector(6 downto 0);
    button1: in std_logic;-- start/ continue
    button2: in std_logic --stop
    );
end stopwatch;

--  architecture
architecture beh of stopwatch is

component sevenseg4 is
port(
    inputs: in std_logic_vector(15 downto 0);
    clock : in std_logic;	--clock 100Mhz
    --, reset
    anodes: out std_logic_vector(3 downto 0);
    sevens: out std_logic_vector(6 downto 0)
    );
end component;

    signal inputs: std_logic_vector(15 downto 0):= (others => '0');
  signal count : integer range 0 to 10000000;
  signal state : std_logic_vector(1 downto 0) := "00";--start state
  signal enable : std_logic := '0';

  signal min : integer RANGE 0 TO 9;
  signal secten : integer RANGE 0 TO 9;
  signal secone : integer RANGE 0 TO 9;
--  signal clk : std_logic;
  signal secbyten : integer RANGE 0 TO 9;

begin
--clk <= clock;
-- seven segmnent display
UUT : sevenseg4 PORT MAP (inputs => inputs, clock => clock, anodes => anodes , sevens => sevens) ;
 


process(clock)
begin

     
    if rising_edge(clock) then
    
    if (button1 = '1') then 
        state <= "01";
        elsif (button2 = '1') then
            state <= "10";
        elsif (reset = '1') then
            state <= "00";
        end if; 
        
       if (reset = '1') then
    
           min <= 0;
           secten <= 0;
           secone <= 0;
           secbyten <= 0;
    --               state <= "00";
    --               enable <= '0';
           count <= 0;
        elsif (enable = '1') then  
            if (count = 10000000 - 1) then
                count <= 0;

                if (secbyten = 9) then 
                    secbyten <= 0;

                    if (secone = 9) then 
                        secone <= 0;

                        if (secten = 5) then
                            secten <= 0;

                            if (min = 9) then
                                min <= 0;
                            else
                                min <= min + 1;
                            end if;
                        else
                            secten <= secten + 1;
                        end if;
                    else
                        secone <= secone + 1;
                    end if;
                else
                    secbyten <= secbyten + 1;
                end if;
            else 
                count <= count + 1;
            end if;
            
        end if;
    end if;
end process;

inputs(3 DOWNTO 0) <= std_logic_vector(to_unsigned(secbyten, 4));
inputs(7 DOWNTO 4)<= std_logic_vector(to_unsigned(secone, 4));
inputs(11 DOWNTO 8)<= std_logic_vector(to_unsigned(secten, 4));
inputs(15 DOWNTO 12) <= std_logic_vector(to_unsigned(min,4));


--states
--process(button1,button2)
--begin
--    if (button1 = '0') then 
--        state <= "01";
--        enable <= '1' ;
--    elsif (button2 = '1') then
--        state <= "10";
--        enable <= '0' ;
--    end if;
--end process;

enable <= '1' when (state = "01") else '0'; 
--states
--process(button1,button2,reset)
--begin
--    if (button1 = '1') then 
--        state <= "01";
--    elsif (button2 = '1') then
--        state <= "10";
--    elsif (reset = '1') then
--        state <= "00";
--    end if;
--end process;

end beh;
