----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

component ripple_adder is 
        port(
            A : in STD_LOGIC_VECTOR (7 downto 0);
            B : in STD_LOGIC_VECTOR (7 downto 0);
            Cin : in STD_LOGIC;
            S : out STD_LOGIC_VECTOR (7 downto 0);
            Cout : out STD_LOGIC
            );
        end component ripple_adder;
        
        
        signal w_carryi, w_carryosub, w_carryoadd: std_logic; 
        signal w_flags : std_logic_vector(3 downto 0);
        signal w_reg1, w_reg2, w_inverse_reg2, w_addres, w_subres, w_andres, w_orres, w_result: std_logic_vector(7 downto 0);
       

begin
      
      w_reg1 <= i_A;
      w_reg2 <= i_B;
      w_inverse_reg2 <= not(w_reg2);
        
      
      adder : ripple_adder port map(
        A => w_reg1,
        B => w_reg2,
        Cin => '0',
        S => w_addres,
        Cout => w_carryoadd
        );
        
      subtractor : ripple_adder port map(
        A => w_reg1,
        B => w_inverse_reg2,
        Cin => '1',
        S => w_subres,
        Cout => w_carryosub
        );
        
        
        w_andres <= w_reg1 AND w_reg2;
	    w_orres <= w_reg1 or w_reg2;
	      
        
      with i_op select
       w_result <= w_addres when "000",
                   w_subres when "001",     
                   w_andres when "010",
                   w_orres  when "011",        
                  "00000000" when others;
  
        
                   
        o_result <= w_result;
      
        o_flags(3) <= '1' when w_result(7) = '1' else '0';
       -- O_flags(2) <= '1' when w_result = "00000000" else '0';
        o_flags(1) <= '1' when ((w_carryoadd = '1' and i_op = "000") or (w_carryosub = '1' and i_op = "001")) else
                       '0';
        --o_flags(0) <= ((not w_result(7)) and w_reg1(7) and w_reg2(7)) or (w_result(7) and (not w_reg1(7)) and (not w_reg2(7))) when i_op = "000" else '0';
      
      
end Behavioral;
