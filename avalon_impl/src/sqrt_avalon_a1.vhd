library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;
entity sqrt_avalon is
    generic(NBITS : integer := 16) ;
    port (
        reset              : in std_logic                             ;
        clk                : in std_logic                             ;
        start              : in std_logic                             ;
        finished           : out std_logic;
        read_address       : in std_logic_vector (2*NBITS-1 downto 0 );
        write_address      : in std_logic_vector (2*NBITS-1 downto 0 );
        -- avalon signals 
        write_av           : out std_logic;
        read_av            : out std_logic;
        read_data_valid_av : in  std_logic ;
        wait_request_av    : in  std_logic;
        address_av         : out std_logic_vector (2*NBITS-1 downto 0);
        write_data_av      : out  std_logic_vector (2*NBITS-1 downto 0);
        read_data_av       : in  std_logic_vector (2*NBITS-1 downto 0)

        -- busrt_count :   out  std_logic_vector (2*NBITS-1 downto 0)
        );
end entity ;

architecture a1 of sqrt_avalon is 
    component it_sqrt is
    generic (
        NBITS : integer := 32
    );
    port (
        reset    : in  std_logic;
        clk      : in  std_logic;
        start    : in  std_logic;
        A        : in  std_logic_vector(2*NBITS-1 downto 0);
        result   : out std_logic_vector(NBITS-1 downto 0);
        finished : out std_logic    
    );
    end component;

    signal A          : std_logic_vector (2*NBITS-1 downto 0);
    signal post_start : std_logic ;
    signal pre_finished : std_logic ;
    signal write_av_sig : std_logic ;
    signal read_av_sig : std_logic ;

begin
    UUT : entity work.it_sqrt(a1) 
    generic map(NBITS =>NBITS)
    port map (
        reset   => reset,
        clk     => clk,
        start   => post_start,
        A       => A,
        result  => write_data_av,
        finished=> pre_finished
    );
    
    write_av <= write_av_sig ; 
    read_av  <= read_av_sig  ; 
    
    AVALON_READ : process(clk,reset) 
    begin
        if (reset='0') then
            A <= (others => '0' );
            read_av_sig <= '0' ;
        elsif (rising_edge(clk)) then
            if (start = '1' or wait_request_av = '1') then 
                read_av_sig <= '1';
            else 
                read_av_sig <= '0';
            end if;
            if (read_data_valid_av = '1') then 
                post_start <= '1' ;
                A <= read_data_av ;
            end if;
        end if;
    end process;


    AVALON_WRITE : process(clk,reset) 
    begin
        if (reset='0') then
            write_av_sig <= '0';
        elsif (rising_edge(clk)) then
            if (pre_finished = '1' or wait_request_av = '1') then
                write_av_sig <= '1';
            else
                write_av_sig <= '0';
                finished <= '1';
            end if;
            if (start = '0') then
                finished <= '0';
            end if;
        end if;
    end process;
    
    AVALON_ADDRESS : process(write_av_sig,read_av_sig) 
    begin
        address_av <= read_address;
        if (write_av_sig = '1') then 
            address_av <= write_address;
        end if ;
        if (read_av_sig ='1') then 
            address_av <= read_address;
        end if ;
    end process;
end a1;