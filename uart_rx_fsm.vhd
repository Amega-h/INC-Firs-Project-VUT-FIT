-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Bogdan Shaposhnik (xshapo04@vutbr.cz)

library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK        : in std_logic;
   RST        : in std_logic;
   DIN        : in std_logic;
   CNT1       : in std_logic_vector(4 downto 0);
   CNT2       : in std_logic_vector(3 downto 0);
   CNT_EN     : out std_logic;
   RX_EN      : out std_logic;
   DOUT_VLD : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
    type condition is (waiting, start_bit_wait, reading_bits, stop_bit_wait, confirmation);
    signal pr_condition : condition := waiting;
 begin
    RX_EN <= '1' when pr_condition = reading_bits 
        else '0';
    CNT_EN <= '0' when (pr_condition = waiting or pr_condition = confirmation) 
         else '1';
    DOUT_VLD <= '1' when pr_condition = confirmation 
           else '0';
    process(CLK, RST) begin
       if rising_edge(CLK) then
          if RST = '1' then
             pr_condition <= waiting;
          else 
             case pr_condition is
                when waiting => if DIN = '0' then
                                         pr_condition <= start_bit_wait;
                                      end if;
                when start_bit_wait => if CNT1 = "11000" then
                                         pr_condition <= reading_bits;
                                      end if;
                when reading_bits => if CNT2 = "1000" then
                                         pr_condition <= stop_bit_wait;
                                      end if;
                when stop_bit_wait => if (CNT1 = "10000" and DIN = '1') then
                                         pr_condition <= confirmation;
                                      end if;
                when confirmation => pr_condition <= waiting;
                when others => pr_condition <= waiting;
             end case;
          end if;
       end if;
    end process;
end behavioral;