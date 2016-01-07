------------------------------------------------------------
-- Author(s) : Fabien Marteau <fabien.marteau@armadeus.com>
-- Creation Date : 01/11/2014
------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

Entity button_deb is
    generic (
        clk_freq : natural := 95_000;    -- clk frequency in kHz
        debounce_per_ms : natural := 20  -- debounce period in ms
    );
    port (
        -- sync design
        clk : in std_logic;
        rst : in std_logic;
        -- in-out
        button_in : in std_logic;
        button_valid : out std_logic
    );
end entity;

Architecture button_deb_1 of button_deb is
    signal edge : std_logic := '0';
    signal debounced : std_logic;

    signal button_in_s : std_logic := '0';
    signal button_hold : std_logic := '0';

    signal button_valid_s : std_logic := '0';
    CONSTANT MAX_COUNT : natural := ((debounce_per_ms * clk_freq)) + 1;
    signal count : natural range 0 to MAX_COUNT := (MAX_COUNT - 1);
begin

    -- synchronize button_in
    sync_button_p : process(clk, rst)
        variable button_in_old : std_logic;
    begin
        if rst = '1' then
            button_in_s <= '0';
            button_in_old := '0';
        elsif rising_edge(clk) then
            button_in_s <= button_in_old;
            button_in_old := button_in;
        end if;
    end process sync_button_p;

    -- detecting edge.
    edge_pc: process(clk, rst)
        variable button_in_edge_old : std_logic := '0';
    begin
        if (rst = '1') then
            button_in_edge_old :=  '0';
        elsif rising_edge(clk) then
            edge <= button_in_s xor button_in_edge_old;
            button_in_edge_old :=  button_in_s;
        end if;
    end process edge_pc;

    -- counter
    count_p : process(clk, rst)
    begin
        if rst = '1' then
            count <= (MAX_COUNT - 1);
        elsif rising_edge(clk) then
            if count < MAX_COUNT then
                count <= count + 1;
            elsif edge = '1' then
                count <= 0;
            end if;
        end if;
    end process count_p;

    -- button sig debounced
    debounced <= edge when count = MAX_COUNT else '0';

    -- button commute
    commute_p : process(clk, rst)
    begin
        if rst = '1' then
            button_hold <= '0';
            button_valid_s <= '0';
        elsif rising_edge(clk) then
            if (debounced = '1') and (edge = '1') then
                button_hold <=  not button_hold;
            else
                button_hold <=  button_hold;
            end if;
            if debounced = '1' and button_hold = '0' then
                button_valid_s <= not button_valid_s;
            end if;
        end if;
    end process commute_p;

    button_valid <= button_valid_s;

end Architecture button_deb_1;
