--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
    
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
component ALU is
    port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end component ALU;

component twos_comp is
    port (
            i_bin: in std_logic_vector(7 downto 0);
            o_sign: out std_logic;
            o_hund: out std_logic_vector(3 downto 0);
            o_tens: out std_logic_vector(3 downto 0);
            o_ones: out std_logic_vector(3 downto 0)
        );
end component twos_comp;

component TDM4 is
	generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
    Port ( i_clk		: in  STD_LOGIC;
           i_reset		: in  STD_LOGIC; -- asynchronous
           i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
		   o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
	);
end component TDM4;


component clock_divider is
    generic ( constant k_DIV : natural := 2	); -- How many clk cycles until slow clock toggles
											   -- Effectively, you divide the clk double this 
											   -- number (e.g., k_DIV := 2 --> clock divider of 4)
	port ( 	i_clk    : in std_logic;
			i_reset  : in std_logic;		   -- asynchronous
			o_clk    : out std_logic		   -- divided (slow) clock
	);
    end component clock_divider;
    
    
component sevenseg_decoder is
    Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
end component sevenseg_decoder;


component controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end component controller_fsm;

component button_debounce is
	Port(	clk: in  STD_LOGIC;
			reset : in  STD_LOGIC;
			button: in STD_LOGIC;
			action: out STD_LOGIC);
end component button_debounce;


--signals--

signal w_i_clock,w_o_clock, w_reset, w_adv,w_btnc: std_logic;
signal w_cycle_out, w_flags, w_D0, w_D1, w_D2, w_D3, w_anode, w_disp_in: std_logic_vector(3 downto 0);
signal w_op_in: std_logic_vector(2 downto 0);
signal w_disp_out, w_checksign: std_logic_vector(6 downto 0);
signal w_reg_in, w_reg1_out, w_reg2_out, w_ALU_out, w_mux_out: std_logic_vector(7 downto 0);

begin
	-- PORT MAPS ----------------------------------------
clkdiv_inst: clock_divider 		--instantiation of clock_divider to take 
        generic map ( k_DIV => 100000) -- 4 Hz clock from 100 MHz
        port map (						  
            i_clk   => w_i_clock,
            i_reset => w_reset,
            o_clk   => w_o_clock
        );  

button_bounce: button_debounce 
	port map(
	     clk => w_i_clock,
	     reset => w_reset,
	     button => w_btnc,
	     action => w_adv
	     );
	     
controller : controller_fsm
    port map(
        i_reset => w_reset,
        i_adv => w_adv,
        o_cycle => w_cycle_out
        );
        
 math_part : ALU
    port map(
         i_A => w_reg1_out,
         i_B => w_reg2_out,
         i_op =>  w_op_in ,
         o_result => w_ALU_out,
         O_flags => w_flags
        );
        
  twos_fixer : twos_comp    
        port map(  
            i_bin  => w_mux_out,
            o_sign => w_D3(0),
            o_hund => w_D2,
            o_tens => w_D1,
            o_ones => w_D0    
        );
        
TDM : TDM4   
    port map(
       i_clk => w_o_clock,
       i_reset => w_reset,
       i_D3 => w_D3,
       i_D2 => w_D2,
       i_D1 => w_D1,
       i_D0 => w_D0,
       o_data => w_disp_in,
       o_sel => w_anode
       );
       
 display : sevenseg_decoder 
    port map(
           i_hex => w_disp_in,
           o_seg_n => w_checksign
           );
           
	-- CONCURRENT STATEMENTS ----------------------------
	w_D3(3 downto 1) <= "000";
	
	
	
	--register logic--
	registers : process(w_i_clock)
	begin
	if rising_edge(w_i_clock) then
	if (w_cycle_out = "0001") then
	   w_reg1_out <= "00000000";
	   w_reg2_out <= "00000000";
	   w_mux_out <= "00000000";
	elsif (w_cycle_out = "0010") then
	   w_reg1_out <= w_reg_in;
	   w_mux_out <= w_reg_in;
	elsif (w_cycle_out = "0100") then               
	   w_reg2_out <= w_reg_in;
	   w_mux_out <= w_reg2_out;
	 elsif (w_cycle_out = "1000") then	            
	      w_mux_out <= w_ALU_out;	      
	 end if;
	 end if;
	 end process registers;  
	 
	 
	--blank disp 4
	seg <= "0111111" when (w_anode = "0111" and w_D3(0) = '1') else
           "1111111" when (w_anode = "0111" and w_D3(0) = '0') else 
            w_checksign;
    led(15 downto 12) <= w_flags when w_cycle_out = "1000" else
                         "0000";
                         
    w_reset	<= btnU;
    w_i_clock <= clk;
    w_btnC <= btnC;
	w_op_in <= sw(2 downto 0);
	an(3 downto 0) <= w_anode;
	w_reg_in <= sw(7 downto 0);
	led(3 downto 0) <= w_cycle_out;

	
end top_basys3_arch;
