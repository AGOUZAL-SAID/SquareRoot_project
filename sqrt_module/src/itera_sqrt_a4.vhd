library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
entity it_sqrt is
    generic(NBITS : integer := 32) ;
    port (
        reset   : in std_logic                             ;
        clk     : in std_logic                             ;
        start   : in std_logic                             ;
        A       : in std_logic_vector (2*NBITS-1 downto 0 );
        result  : out std_logic_vector (NBITS-1 downto 0 ) ;
        finished: out std_logic                            
        );
end entity ;

architecture a4 of it_sqrt is 
    type T_state  is (S_WAIT,S_COMP1,S_COMP2,S_FIN);
    signal state   : T_state;
    signal D       : unsigned (2*NBITS-1 downto 0 );
    signal Z       : unsigned (NBITS-1 downto 0 );
    signal R       : signed (NBITS+1-1 downto 0 );
    signal E1      : signed (NBITS downto 0);
    signal E2      : signed (NBITS downto 0);
    signal sub     :  std_logic;
    signal RES     : std_logic_vector (NBITS downto 0);
    signal result_sig  : unsigned (NBITS-1 downto 0 );
    signal counter : integer range 0 to NBITS;
    component alu is 
        generic(NBITS : integer := 32);
        port (
            E1   : in  std_logic_vector (NBITS downto 0);
            E2   : in  std_logic_vector (NBITS downto 0);
            sub  : in std_logic;
            RES  : out std_logic_vector (NBITS downto 0)
        );
    end component;
    begin

    add_sub : alu   
        generic map (NBITS =>NBITS)
        port map (
            E1  => std_logic_vector(E1),
            E2  => std_logic_vector(E2),
            sub => sub,
            RES => RES
        );
    FSM : process(clk,reset) 
		variable attache2 : std_logic;
            
        begin
            if (reset='0') then
                state      <= S_WAIT ; 
                D       <= to_unsigned(0,2*NBITS);
                Z       <= to_unsigned(0,NBITS);
                R       <= to_signed(0,NBITS+1) ;
                result_sig <= to_unsigned(0,NBITS);
                counter <= 0;
                finished <=  '0' ;      
            elsif (rising_edge(clk)) then
            case( state ) is
            
                when S_WAIT =>  if (start = '1') then 
                                state <= S_COMP1 ;
                                end if ;
								D <= unsigned(A);
								counter <= 0;
								
                                
            
                when S_COMP1 => 
                                R <= signed(RES);
                                if (signed(RES)>=to_signed(0,NBITS+1)) then -- equivalent to just Z(NBITS-2 downto 0 & not(RES(NBITS)
                                    attache2  :=  '1' ;
                                else
                                    attache2  := '0';
                                end if;
                                Z  <= Z(NBITS-2 downto 0) & attache2 ;
                                D <= D(2*NBITS-3 downto 0) & b"00";
                                counter <= counter + 1;
                                if (counter = NBITS-1) then 
                                    state <= S_FIN ;
                                    finished <=  '1' ;
                                    result_sig <= Z;
                                else 
                                    state <= S_COMP1;
                                end if;
                when S_FIN   => 
                                Z <= to_unsigned(0,NBITS);
                                R <= to_signed(0,NBITS+1) ;
                                if (start = '0') then 
                                    finished <= '0' ;  
                                    state <= S_WAIT;
                               end if ;
                when others => null;
            end case ;
            end if ;
    end process;
    result <= std_logic_vector(result_sig);
    alu_process : process( R,D,Z )
    variable attache : unsigned(0 downto 0);
    begin
        E1 <= R(NBITS+1-1-2 downto 0) & signed(D(2*NBITS-1 downto 2*NBITS-2));
		  sub <= not(std_logic(R(NBITS)));
        E2 <= signed(b"0" & Z(NBITS-3 downto 0) & R(NBITS) & b"1");
    end process ; -- alu
end a4;