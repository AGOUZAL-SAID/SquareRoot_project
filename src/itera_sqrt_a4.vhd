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
        begin
            if (reset='0') then
                state      <= S_WAIT ; 
                D       <= to_unsigned(0,2*NBITS);
                Z       <= to_unsigned(0,NBITS);
                R       <= to_signed(0,NBITS+1) ;
                counter <= 0;
                E1      <=  to_signed(0,NBITS+1);   
                E2      <=  to_signed(0,NBITS+1);   
                sub     <=   '0';
                finished <=  '0' ;      
            elsif (rising_edge(clk)) then
            case( state ) is
            
                when S_WAIT =>  state <= S_COMP1;
                                D <= unsigned(A);
                                Z <= to_unsigned(0,NBITS);
                                R <= to_signed(0,NBITS+1) ;
                                counter <= 0;
            
                when S_COMP1 => 
                                state <= S_COMP2;
                                if (R>=to_signed(0,NBITS+1)) then
                                    sub <= '1';
                                    E1 <=R(NBITS+1-1-2 downto 0) & signed(D(2*NBITS-1 downto 2*NBITS-2));  
                                    E2 <= signed(b"0" & Z(NBITS-3 downto 0) & b"01");
                                else 
                                    sub <= '0';
                                    E1 <= R(NBITS+1-1-2 downto 0) & signed(D(2*NBITS-1 downto 2*NBITS-2));
                                    E2 <= resize(signed(Z(NBITS-3 downto 0) & b"11"),NBITS+1);
                                end if ;

                when S_COMP2 => R <= signed(RES);
                                if (signed(RES)>=to_signed(0,NBITS+1)) then 
                                    Z  <= Z(NBITS-2 downto 0) & '1' ;
                                else
                                    Z  <= Z(NBITS-2 downto 0) & '0';
                                end if;
                                D <= D(2*NBITS-3 downto 0) & b"00";
                                counter <= counter + 1;
                                if (counter = NBITS-1) then 
                                    state <= S_FIN ;
                                    finished <=  '1' ;
                                else 
                                    state <= S_COMP1;
                                end if;
                when S_FIN   => 
                                if (start = '0') then 
                                    finished <= '0' ;  
                                    state <= S_WAIT;
                               end if ;
                when others => null;
            end case ;
            end if ;
    end process;
    result <= std_logic_vector(Z);
end a4;