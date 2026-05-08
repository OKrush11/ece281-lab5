----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is

    type out_state is (clear,reg1,reg2,combo);
    signal w_current, w_next, w_reset: out_state;
    
begin
    
    w_next <= clear when w_current = combo and i_adv = '1' else
              out_state'succ(w_current) when i_adv = '1' else
              w_current;
            
    with w_current select
        o_cycle <= "0001" when clear,
                   "0010" when reg1,
                   "0100" when reg2,
                   "1000" when combo,
                   "0000" when others;       
     
            
    state_register : process(i_adv, i_reset)
	begin
           if i_reset = '1' then
               w_current <= clear;
           elsif rising_edge(i_adv) then 
                case w_current is 
                when clear => w_current <= reg1;
                when reg1  => w_current <= reg2;
                when reg2  => w_current <= combo;
                when combo => w_current <= clear; 
                when others => w_current <= clear;
            end case;
           
        end if;
	end process state_register;
    
    
    
 
    
end FSM;
