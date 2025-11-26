library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
entity newton is
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

architecture a1 of newton is 
type T_state  is (S_WAIT,S_INT,S_COMP,S_FIN);
signal state      : T_state;
signal X_reg      : unsigned (2*NBITS-1 downto 0 );
begin
    FSM : process(clk,reset) 
    variable X_Next : unsigned (2*NBITS downto 0);
    variable div    : unsigned (2*NBITS-1 downto 0);
    begin
        if (reset='0') then
            state      <= S_WAIT ; 
            X_reg      <= to_unsigned(0,2*NBITS);
        elsif (rising_edge(clk)) then
            case( state ) is
                when S_WAIT => if (start = '1') then 
                                state <= S_INT ;
                                end if ;
                when S_INT  => if unsigned(A) > x"00000000FFFFFFFF" then
                                     X_reg <= x"00000000FFFFFFFF";
                                 else
                                    X_reg <= unsigned(A);
                                end if;    
                               state <= S_COMP ;
                when S_COMP => div := unsigned(A)/X_reg; 
                               X_Next := (resize(X_reg,2*NBITS + 1) + resize(div,2*NBITS + 1)) / 2;
                               if (X_reg <= X_Next(2*NBITS-1 downto 0)) then
                                    state <= S_FIN ; 
                               else
                               X_reg <= X_Next(2*NBITS-1 downto 0);
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
    result <= std_logic_vector(X_reg(NBITS-1 downto 0));

end a1 ;