library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--~ library work;
--~ use work.math.all;
--~ use work.print.all;
--~ use work.uart_sim.all;
--~ use work.conditional_select.all;

entity nexys_seven_segment is
    port
    (
        clk         :   in  std_logic;
        rst         :   in  std_logic;
        
        -- data
        data_in     :   in  std_logic_vector(11 downto 0);
        minus       :   in  std_logic;
            
        -- engine nr
        button      :   in  std_logic;
        switch      :   in  std_logic_vector(2 downto 0);
        
        -- output pins
        seg_out     :   out std_logic_vector(7 downto 0);
        an_out      :   out std_logic_vector(3 downto 0)
    );
end entity nexys_seven_segment;

architecture IMP of nexys_seven_segment is

    ------------------------------
    -- constants
    ------------------------------
    
    constant SEG_0          : std_logic_vector(6 downto 0) := "1000000";
    constant SEG_1          : std_logic_vector(6 downto 0) := "1111001";
    constant SEG_2          : std_logic_vector(6 downto 0) := "0100100";
    constant SEG_3          : std_logic_vector(6 downto 0) := "0110000";
    constant SEG_4          : std_logic_vector(6 downto 0) := "0011001";
    constant SEG_5          : std_logic_vector(6 downto 0) := "0010010";
    constant SEG_6          : std_logic_vector(6 downto 0) := "0000010";
    constant SEG_7          : std_logic_vector(6 downto 0) := "1111000";
    constant SEG_8          : std_logic_vector(6 downto 0) := "0000000";
    constant SEG_9          : std_logic_vector(6 downto 0) := "0010000";
    constant SEG_A          : std_logic_vector(6 downto 0) := "0001000";
    constant SEG_B          : std_logic_vector(6 downto 0) := "0000011";
    constant SEG_C          : std_logic_vector(6 downto 0) := "1000110";
    constant SEG_D          : std_logic_vector(6 downto 0) := "0100001";
    constant SEG_E          : std_logic_vector(6 downto 0) := "0000110";
    constant SEG_F          : std_logic_vector(6 downto 0) := "0001110";
        
    constant SEG_r          : std_logic_vector(6 downto 0) := "0101111";
    constant SEG_o          : std_logic_vector(6 downto 0) := "0100011";
    constant SEG_u          : std_logic_vector(6 downto 0) := "0111111";
    constant SEG_off        : std_logic_vector(6 downto 0) := "1111111";
    
    constant seven_error    : std_logic_vector(27 downto 0) := SEG_E & SEG_r & SEG_r & SEG_o;
    
    ------------------------------
    -- signals
    ------------------------------
    
    signal seven_segment    : std_logic_vector(20 downto 0);
    
begin

    P_SEG : process (data_in)
    begin
    
        if button = '1' then
        
            ------------------------------
            -- show engine nr
            ------------------------------
        
            seven_segment(20 downto 14) <= SEG_off;
            seven_segment( 6 downto  0) <= SEG_off;
            case (switch) is
                when "000"  => seven_segment(13 downto 7) <= SEG_1;
                when "001"  => seven_segment(13 downto 7) <= SEG_2;
                when "010"  => seven_segment(13 downto 7) <= SEG_3;
                when "011"  => seven_segment(13 downto 7) <= SEG_4;
                when "100"  => seven_segment(13 downto 7) <= SEG_5;
                when "101"  => seven_segment(13 downto 7) <= SEG_6;
                when "110"  => seven_segment(13 downto 7) <= SEG_7;
                when "111"  => seven_segment(13 downto 7) <= SEG_8;
                when others => seven_segment(13 downto 7) <= SEG_0;
            end case;
            
        elsif unsigned(switch) > 5 then
        
            ------------------------------
            -- show "---" when engine Nr too high
            ------------------------------
            
            seven_segment(20 downto 14) <= SEG_u;
            seven_segment(13 downto  7) <= SEG_u;
            seven_segment( 6 downto  0) <= SEG_u;
            
        else

            ------------------------------
            -- show engine state
            ------------------------------
            
            for I in 2 downto 0 loop
                case unsigned(data_in((I+1)*4-1 downto I*4)) is
                    when x"0"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_0;
                    when x"1"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_1;
                    when x"2"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_2;
                    when x"3"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_3;
                    when x"4"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_4;
                    when x"5"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_5;
                    when x"6"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_6;
                    when x"7"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_7;
                    when x"8"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_8;
                    when x"9"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_9;
                    when x"a"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_A;
                    when x"b"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_B;
                    when x"c"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_C;
                    when x"d"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_D;
                    when x"e"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_E;
                    when x"f"   => seven_segment((I+1)*7-1 downto I*7) <= SEG_F;
                    when others => seven_segment((I+1)*7-1 downto I*7) <= (others => '0');
                end case;
            end loop;

        end if;

    end process;
    
    P_DISPLAY : process (clk, rst)
        variable seg_count : integer range 0 to 3;              -- seg number
        variable time_count  : integer range 0 to 2_000 - 1;    -- 2 ms delay between switch
    begin
        if rst = '1' then
            seg_count := 0;
            time_count := 0;
            
            seg_out <= '1' & SEG_u;
            an_out <= (others => '0');
        else
            if rising_edge(clk) then
            
                if time_count < 2_000 - 1 then
                    
                    -- inc delay timer
                    time_count := time_count + 1;
                    
                    -- enable current
                    an_out <= (others => '1');
                    an_out(seg_count) <= '0';
                    
                    -- output
                    if seg_count = 3 then
                        if minus = '1' and button = '0' then
                            seg_out <= '1' & SEG_u;
                        else
                            seg_out <= '1' & SEG_off;
                        end if;
                    else
                        seg_out <= '1' & seven_segment((seg_count+1)*7-1 downto seg_count*7);
                    end if;
                    
                else
                
                    -- reset delay timer
                    time_count := 0;
                    
                    -- inc seg number
                    if seg_count < 3 then
                        seg_count := seg_count + 1;
                    else
                        seg_count := 0;
                    end if;
                    
                end if;
            
            end if;
        end if;
    end process;
    
end architecture IMP;
