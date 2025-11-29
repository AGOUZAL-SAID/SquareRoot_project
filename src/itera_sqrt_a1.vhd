library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
use ieee.math_real.all;
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

architecture a1 of it_sqrt is 
    type T_state  is (S_WAIT,S_INT,S_COMP,S_FIN);
    signal state  : T_state;
    signal D      : unsigned (2*NBITS-1 downto 0 );
    signal Z      : unsigned (NBITS-1 downto 0 );
    signal R      : signed (NBITS+1-1 downto 0 );
    signal counter : integer range 0 to NBITS;
    begin
    FSM : process(clk,reset) 
    variable div_sig  : signed (2*NBITS-1 downto 0);
    variable SZ_sig   : signed (NBITS+1-1 downto 0);
    variable div      : unsigned(2*NBITS-1 downto 0);
    variable Z_4      : unsigned(NBITS-1 downto 0);
    variable R_comp   : signed(NBITS+1-1 downto 0);
    begin
        if (reset='0') then
            state      <= S_WAIT ; 
            D <= to_unsigned(0,2*NBITS);
            Z <= to_unsigned(0,NBITS);
            R <= to_signed(0,NBITS+1) ;
            counter <= 0;
        elsif (rising_edge(clk)) then
            case( state ) is
                when S_WAIT => if (start = '1') then 
                                state <= S_INT ;
                                end if ;
                
                when S_INT  =>  state <= S_COMP ;
                                D <= unsigned(A);
                                Z <= to_unsigned(0,NBITS);
                                R <= to_signed(0,NBITS+1);
                                counter <= 0;
                
                when S_COMP =>  div := shift_right(D,2*NBITS-2);
                                Z_4 := shift_left(Z,2);
                                div_sig := signed(div);
                                SZ_sig  := signed(resize(Z_4, NBITS+1));


                                if (R>=to_signed(0,NBITS+1)) then
                                    R_comp := shift_left(R,2) + div_sig(NBITS+1-1 downto 0) - SZ_sig - to_signed(1,NBITS+1);
                                    R <= R_comp;
                                else
                                    R_comp := shift_left(R,2) + div_sig(NBITS+1-1 downto 0) + SZ_sig + to_signed(3,NBITS+1);
                                    R <= R_comp; 
                                end if;
                                
                                
                                if (R_comp >=to_signed(0,NBITS+1)) then 
                                    Z <= shift_left(Z,1) + to_unsigned(1,NBITS);
                                else 
                                    Z <= shift_left(Z,1);
                                end if;


                                D <= shift_left(D,2);
                                counter <= counter + 1;
                                if (counter = NBITS-1) then 
                                    state <= S_FIN ;
                                end if ;
                
                when S_FIN  => finished <=  '1' ;
                               if (start = '0') then 
                                    finished <= '0' ;  
                                    state <= S_WAIT;
                                    finished   <= '0' ;
                               end if ;
                
                when others => null;
            end case ;
        end if ;
    end process ;
    result <= std_logic_vector(Z);


end a1;