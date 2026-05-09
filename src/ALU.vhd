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
        
        
        signal w_carryi, w_carryo, w_overflow: std_logic; 
        signal w_flags : std_logic_vector(3 downto 0);
        signal  w_inverse_reg2, w_addsub, w_addres, w_subres, w_andres, w_orres, w_result: std_logic_vector(7 downto 0);
       

begin

      w_addsub <= (not i_B) when i_op = "001" else i_b;
        
      
      adder : ripple_adder port map(
        A => i_A,
        B => w_addsub,
        Cin => '0',
        S => w_addres,
        Cout => w_carryo
        );

        
o_result <= w_addres when i_op = "000" else
            w_addres when i_op = "001" else
            (i_a and i_b) when i_op = "010" else
            (i_a or i_b) when i_op = "011" else w_addres;
      --with i_op select
        --w_overflow <= ((not w_result(7)) and w_reg1(7) and w_reg2(7)) or (w_result(7) and (not w_reg1(7)) and (not w_reg2(7))) when "000",
                   
      
        o_flags(3) <= '1' when w_addres(7) = '1' else '0';
        O_flags(2) <= '1' when w_addres = "00000000" else '0';
        o_flags(1) <= not(i_op(1)) and (w_carryo);
        o_flags(0) <= (not(i_A(7) xor i_op(0) xor i_b(7)) and (w_addres(7) xor i_a(7)) and not(i_op(1)));
      --(w_result(7) and (not w_reg1(7)) and (not w_reg2(7))); 
end Behavioral;
