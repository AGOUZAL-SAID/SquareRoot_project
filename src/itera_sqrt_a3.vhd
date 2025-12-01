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

architecture a3 of it_sqrt is 
    type T_state  is (S_WAIT,S_COMP,S_FIN);

    subtype register_R is signed(NBITS+1-1 downto 0);
    type pack_register_R is array (0 to NBITS) of register_R;

    subtype register_Z is unsigned(NBITS-1 downto 0);
    type pack_register_Z is array (0 to NBITS) of register_Z;

    subtype register_D is unsigned(2*NBITS-1 downto 0);
    type pack_register_D is array (0 to NBITS) of register_D;

    
    signal D      : pack_register_D;
    signal Z      : pack_register_Z;
    signal R      : pack_register_R;
    signal state  : T_state;
    signal counter : integer range 0 to NBITS;
    begin
    FSM : process(clk,reset) 
    begin
        if (reset='0') then
            state      <= S_WAIT ; 
            finished <= '0' ;
        elsif (rising_edge(clk)) then
            case( state ) is
                when S_WAIT => if (start = '1') then 
                                state <= S_COMP ;
                                end if ;            
                                counter <= 0;
                when S_COMP =>  counter <= counter + 1;
                                if (counter = NBITS-1) then
                                    state <= S_FIN ;
                                    finished <=  '1' ;
                                end if ;

                
                when S_FIN  =>  if (start = '0') then 
                                    finished <= '0' ;  
                                    state <= S_WAIT;
                               end if ;
                
                when others => null;
            end case ;
        end if ;
    end process ;
    
    COMPUTATION : process(clk,reset) -- sync process
    variable div_sig  : signed (2*NBITS-1 downto 0);
    variable SZ_sig   : signed (NBITS+1-1 downto 0);
    variable div      : unsigned(2*NBITS-1 downto 0);
    variable Z_4      : unsigned(NBITS-1 downto 0);
    variable R_comp   : signed(NBITS+1-1 downto 0);
    begin
        if (reset='0') then
            for i in 0 to NBITS loop
                R(i) <= to_signed(0,NBITS+1);
                D(i) <= to_unsigned(0,2*NBITS);
                Z(i) <= to_unsigned(0,NBITS);
            end loop;
        elsif (rising_edge(clk)) then
            R(0) <= to_signed(0,NBITS+1);
            D(0) <= unsigned(A);
            Z(0) <= to_unsigned(0,NBITS);
            for i in 0 to NBITS-1 loop


                div := shift_right(D(i),2*NBITS-2);
                Z_4 := shift_left(Z(i),2);
                div_sig := signed(div);
                SZ_sig  := signed(resize(Z_4, NBITS+1));


                if (R(i)>=to_signed(0,NBITS+1)) then
                    R_comp := shift_left(R(i),2) + div_sig(NBITS+1-1 downto 0) - SZ_sig - to_signed(1,NBITS+1);
                    R(i+1) <= R_comp;
                else
                    R_comp := shift_left(R(i),2) + div_sig(NBITS+1-1 downto 0) + SZ_sig + to_signed(3,NBITS+1);
                    R(i+1) <= R_comp;
                end if;


                if (R_comp >=to_signed(0,NBITS+1)) then 
                    Z(i+1) <= shift_left(Z(i),1) + to_unsigned(1,NBITS);
                else 
                    Z(i+1) <= shift_left(Z(i),1);
                end if;


                D(i+1)<= shift_left(D(i),2);


            end loop;
        end if ;
    end process;
    result <= std_logic_vector(Z(NBITS));


end a3;