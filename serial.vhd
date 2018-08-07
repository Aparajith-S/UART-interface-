library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--~ library work;
--~ use work.math.all;
--~ use work.print.all;
--~ use work.uart_sim.all;
--~ use work.conditional_select.all;

entity serial is
    port
    (
        clk             :   in  std_logic;
        rst             :   in  std_logic;
        
        rxd             :   in  std_logic;
        txd             :   out std_logic;
        
        -- rx
        rx_req          :   out std_logic;
        rx_data         :   out std_logic_vector(7 downto 0);
        rx_ack          :   in  std_logic;        
        
        -- tx
        tx_req          :   in  std_logic;
        tx_data         :   in  std_logic_vector(7 downto 0);
        tx_ack          :   out std_logic
    );
end entity serial;

architecture IMP of serial is

    component SendCaps is
        port
        (
        	clk		    : in  std_logic;					-- Clock
            res			: in  std_logic;					-- Sync. Reset
            data		: in  std_logic_vector(7 downto 0);	-- Daten
            data_ready	: in  std_logic;					-- Daten bereit
            ser_out		: out std_logic;					-- Serielle Daten
            data_sent	: out std_logic
        );
    end component;
    
    component RecvCaps is
		port
        (
        	clk				: in  std_logic;	--Takt
			res				: in  std_logic;	--Reset
			serial_in		: in  std_logic;	--Serieller Eingang
			parallel_out	: out std_logic_vector(7 downto 0);	--Daten
			int_recv		: out std_logic;	--Daten liegen an -> INT
			int_ack			: in  std_logic  	--SW Acknowlege vom INT
        );
    end component;
    
begin

    sender : SendCaps
            
        port map
            
            (
            
                clk		    => clk,
                res			=> rst,
                data		=> tx_data,
                data_ready	=> tx_req,
                ser_out		=> txd,
                data_sent	=> tx_ack
            
            );
            
    receiver : RecvCaps
            
        port map
            
            (
            
                clk				=> clk,
                res				=> rst,
                serial_in		=> rxd,
                parallel_out	=> rx_data,
                int_recv		=> rx_req,
                int_ack			=> rx_ack
            
            );
    
end architecture IMP;
