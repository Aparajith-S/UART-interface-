library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--~ library work;
--~ use work.math.all;
--~ use work.print.all;
--~ use work.uart_sim.all;
--~ use work.conditional_select.all;

entity microblaze_top is
    Port
    ( 
        clk     : in  std_logic;                    -- 100 MHz
        rst     : in  std_logic;                    -- Button
        button  : in  std_logic;                    -- Button
        txd     : out std_logic;                    -- UART Tx
        rxd     : in  std_logic;                    -- UART Rx
        seg     : out std_logic_vector(7 downto 0); -- Seven Segment Data
        an      : out std_logic_vector(3 downto 0); -- Seven Segment Addr/En
        switch  : in  std_logic_vector(2 downto 0); -- Seven Segment Select
        led     : out std_logic_vector(7 downto 0)  -- LED for RxData
    );
end microblaze_top;

architecture Behavioral of microblaze_top is

    ------------------------------
    -- Components
    ------------------------------

    -- processor
    component microblaze_mcs is
        port
        (
            Clk             : in std_logic;
            Reset           : in std_logic;
            GPO1            : out std_logic_vector(12 downto 0);
            GPO2            : out std_logic_vector(8 downto 0);
            GPO3            : out std_logic_vector(0 downto 0);
            GPI1            : in std_logic_vector(2 downto 0);
            GPI1_Interrupt  : out std_logic;
            GPI2            : in std_logic_vector(7 downto 0);
            GPI2_Interrupt  : out std_logic;
            INTC_Interrupt  : in std_logic_vector(1 downto 0);
            INTC_IRQ        : out std_logic
        );
    end component;
    
    -- seven segment display
    component nexys_seven_segment is
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
    end component;
    
    -- serial interface
    component serial is
        port
        (
            clk         :   in  std_logic;
            rst         :   in  std_logic;
            
            rxd         :   in  std_logic;
            txd         :   out std_logic;
            
            -- rx
            rx_req      :   out std_logic;
            rx_data     :   out std_logic_vector(7 downto 0);
            rx_ack      :   in  std_logic;        
            
            -- tx
            tx_req      :   in  std_logic;
            tx_data     :   in  std_logic_vector(7 downto 0);
            tx_ack      :   out std_logic
        );
    end component;
    
    ------------------------------
    -- Signals
    ------------------------------
    
    -- interrupt controller
    signal interrupt_vector     : std_logic_vector(1 downto 0);
    signal interrupt_irq        : std_logic;
    signal interrupt_rx_req     : std_logic;
    signal interrupt_tx_ack     : std_logic;
    
    -- gpi/gpo
    signal gpi_rx_data          : std_logic_vector(7 downto 0);
    signal gpo_seven_segment    : std_logic_vector(12 downto 0);
    signal gpo_tx_data          : std_logic_vector(8 downto 0);
    signal gpo_rx_ack           : std_logic_vector(0 downto 0);
    
    -- other
    signal undefined            : std_logic;
    
begin

    ------------------------------
    -- Processor
    ------------------------------

    mcs_0 : microblaze_mcs
            
        port map
            
            (
            
                Clk             => clk,
                Reset           => rst,
                GPO1            => gpo_seven_segment,
                GPO2            => gpo_tx_data,
                GPO3            => gpo_rx_ack,
                GPI1            => switch,
                GPI1_Interrupt  => open,
                GPI2            => gpi_rx_data,
                GPI2_Interrupt  => open,
                INTC_Interrupt  => interrupt_tx_ack & interrupt_rx_req,
                INTC_IRQ        => open
            
            );
            
    
    
    ------------------------------
    -- Seven Segment Display
    ------------------------------
    
    seven_segment_0 : nexys_seven_segment
            
        port map
            
            (
            
                clk         => clk,
                rst         => rst,
                
                -- data
                data_in     => gpo_seven_segment(11 downto 0),
                minus       => gpo_seven_segment(12),
                
                -- other
                button      => button,
                switch      => switch,
                                
                -- output pins
                seg_out     => seg,
                an_out      => an
            
            );

    
    
    ------------------------------
    -- Serial Interface
    ------------------------------

    serial_0 : serial
            
        port map
            
            (
            
                clk             => clk,
                rst             => rst,
                
                rxd             => rxd,
                txd             => txd,
                
                -- rx
                rx_req          => interrupt_rx_req,
                rx_data         => gpi_rx_data,
                rx_ack          => gpo_rx_ack(0),
                
                -- tx
                tx_req          => gpo_tx_data(8),
                tx_data         => gpo_tx_data(7 downto 0),
                tx_ack          => interrupt_tx_ack
            
            );
            
    ------------------------------
    -- LED
    ------------------------------
    
    P_LED : process (clk, rst, interrupt_rx_req)
    begin
        if rst = '1' then
            led <= (others => '0');
        else
            if rising_edge(clk) then
                if interrupt_rx_req = '1' then
                    led <= gpi_rx_data;
                end if;
            end if;
        end if;
    end process;

    

end Behavioral;

