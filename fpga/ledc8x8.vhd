library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.ALL; 

entity ledc8x8 is
port ( 
   SMCLK : in std_logic;
   RESET : in std_logic;

   ROW : out std_logic_vector(7 downto 0);
   LED : out std_logic_vector(7 downto 0)
);
end ledc8x8;

architecture main of ledc8x8 is
   signal char_select   : std_logic := '0';
   signal next_row_req  : std_logic := '0';
   signal sig_row       : std_logic_vector(7 downto 0) := "00000001";
   signal x          : integer range 0 to 7 := 0;
   signal cnt_1hz    : integer range 0 to 3686400 := 0;
   signal cnt_256    : std_logic_vector(7 downto 0) := (others => '0');
   
   type t_char is array (0 to 7) of  std_logic_vector (7 downto 0);
   constant char_j: t_char := (  0 => "11100001",
                                 1 => "11110011",
                                 2 => "11110011",
                                 3 => "11110011",
                                 4 => "11110011",
                                 5 => "10010011",
                                 6 => "10010011",
                                 7 => "11000111");

   constant char_k: t_char := (  0 => "10011001",
                                 1 => "10010011",
                                 2 => "10000111",
                                 3 => "10001111",
                                 4 => "10001111",
                                 5 => "10000111",
                                 6 => "10010011",
                                 7 => "10011001");
  
begin
   clk_div: process(SMCLK, RESET)
   begin
      if (RESET = '1') then
         cnt_256 <= (others => '0');
         cnt_1hz <= 0;

      elsif (SMCLK'event and SMCLK = '1') then
         if (cnt_1hz = 3686400) then
            cnt_1hz <= 0;
            char_select <= not char_select;
         else
            cnt_1hz <= cnt_1hz + 1;
         end if;

         if (cnt_256 = "11111111") then
            cnt_256 <= (others => '0');
            next_row_req <= '1';
         else
            cnt_256 <= cnt_256 + 1;
            next_row_req <= '0';
         end if;
      end if;
   end process clk_div;

   row_incrementator: process(SMCLK)
   begin
      if (SMCLK'event and SMCLK = '1') then
         if (next_row_req = '1') then
            if (x = 7) then
               x <= 0;
            else
               x <= x + 1;
            end if;
         end if;
      end if;
   end process row_incrementator;

   row_rotator: process(SMCLK)
   begin
      if (SMCLK'event and SMCLK = '1') then
        if (next_row_req = '1') then
            sig_row <= sig_row(6 downto 0) & sig_row(7);
        end if;
      end if;
   end process row_rotator;
   
   char_selector : process (char_select, cnt_256)
   begin
         if (char_select = '1') then
            LED <= char_k(x);
         else
            LED <= char_j(x);
         end if;
   end process char_selector;

   ROW <= sig_row;
end main;
