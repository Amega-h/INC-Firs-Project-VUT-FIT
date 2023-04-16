-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Bogdan Shaposhnik (xshapo04@vutbr.cz)

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(
   CLK      :   in std_logic;
   RST      :   in std_logic;
   DIN      :   in std_logic;
   DOUT     :   out std_logic_vector(7 downto 0);
   DOUT_VLD :   out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
   signal  cnt1    :   std_logic_vector(4 downto 0);
   signal  cnt2    :   std_logic_vector(3 downto 0);
   signal  vld     :   std_logic;
   signal  rx_en   :   std_logic;
   signal  cnt_en  :   std_logic;
begin
   FSM: entity work.UART_FSM(behavioral)
   port map(
      CLK           =>  CLK,
      RST           =>  RST,
      DIN           =>  DIN,
      CNT1          =>  cnt1,
      CNT2          =>  cnt2,
      DOUT_VLD      =>  vld,
      CNT_EN        =>  cnt_en,
      RX_EN         =>  rx_en
   );

   DOUT_VLD <= vld;


   p_cnt1: process(CLK, RST, cnt_en, rx_en) begin
         if (RST = '1' or cnt_en = '0') then
                  cnt1 <= "00000";
         elsif rising_edge(CLK) then
                  if (cnt1(4) = '1' and rx_en = '1') then
                        cnt1 <= "00001";
                           else
                        cnt1 <= cnt1 + 1;
                  end if;
         end if;
   end process p_cnt1;

   p_cnt2: process(CLK, RST, rx_en) begin
         if (RST = '1' or rx_en = '0') then
                  cnt2 <= "0000";
         elsif rising_edge(CLK) then
                  if (cnt1(4) = '1' and rx_en = '1') then
                        cnt2 <= cnt2 + 1;
                  end if;
         end if;
   end process p_cnt2;

   p_demultiplexer: process(CLK, RST, cnt2, rx_en, DIN) begin
      if (RST = '1') then
         DOUT <= "00000000";
      elsif rising_edge(CLK) then
         if (cnt1(4) = '1' and rx_en = '1') then
            case cnt2 is
               when "0000" => DOUT(0) <= DIN;
               when "0001" => DOUT(1) <= DIN;
               when "0010" => DOUT(2) <= DIN;
               when "0011" => DOUT(3) <= DIN;
               when "0100" => DOUT(4) <= DIN;
               when "0101" => DOUT(5) <= DIN;
               when "0110" => DOUT(6) <= DIN;
               when "0111" => DOUT(7) <= DIN;
               when others => null;
            end case;
         end if;
      end if;
   end process p_demultiplexer;
   
end architecture behavioral;