library ieee;
use ieee.std_logic_1164.all;

-- Testbench simples para o Program Counter (PC)
entity tb_Program_Counter is
end entity tb_Program_Counter;

architecture test of tb_Program_Counter is

    -- 1. Declarar o Componente que vamos testar (a UUT)
    component Program_Counter
        port (
            Clk         : in  std_logic;
            Rst         : in  std_logic;
            Branch_Addr : in  std_logic_vector(31 downto 0);
            PC_Sel      : in  std_logic; 
            PC_Out      : out std_logic_vector(31 downto 0)
        );
    end component;

    -- 2. Sinais internos do testbench
    signal s_Clk         : std_logic := '0';
    signal s_Rst         : std_logic := '0';
    signal s_Branch_Addr : std_logic_vector(31 downto 0) := (others => '0');
    signal s_PC_Sel      : std_logic := '0';
    signal s_PC_Out      : std_logic_vector(31 downto 0);

    -- Constantes do Clock
    constant CLK_PERIOD : time := 10 ns;
    constant CLK_HALF   : time := CLK_PERIOD / 2;

begin

    -- 3. Instanciar a UUT
    u_uut: Program_Counter
        port map (
            Clk         => s_Clk,
            Rst         => s_Rst,
            Branch_Addr => s_Branch_Addr,
            PC_Sel      => s_PC_Sel,
            PC_Out      => s_PC_Out
        );

    -- 4. Processo Gerador de Clock
    clk_proc: process
    begin
        loop
            s_Clk <= '0';
            wait for CLK_HALF;
            s_Clk <= '1';
            wait for CLK_HALF;
        end loop;
    end process;
    
    -- 5. Processo de Estímulo (Simulando o CPU)
    stim_proc: process
    begin
        report "Iniciando simulacao (Program_Counter)..." severity note;
        
        -- Teste 1: RESET
        -- Ativamos o Reset por um ciclo
        s_Rst <= '1';
        wait for CLK_PERIOD;
        -- Valor esperado em s_PC_Out: x"00000000" (resetado)
        
        -- Teste 2: INCREMENTO (PC + 4)
        -- Soltamos o Reset. PC_Sel = '0' (padrão)
        s_Rst <= '0';
        wait for CLK_PERIOD;
        -- Valor esperado em s_PC_Out: x"00000004"
        
        -- Teste 3: INCREMENTO (PC + 4)
        wait for CLK_PERIOD;
        -- Valor esperado em s_PC_Out: x"00000008"

        -- Teste 4: INCREMENTO (PC + 4)
        wait for CLK_PERIOD;
        -- Valor esperado em s_PC_Out: x"0000000C"
        
        -- Teste 5: DESVIO (BRANCH)
        -- Ativamos PC_Sel e fornecemos um endereço de desvio
        report "Teste 5: Forcando desvio..." severity note;
        s_PC_Sel      <= '1';
        s_Branch_Addr <= x"00000040"; -- Endereço de desvio (64 decimal)
        wait for CLK_PERIOD;
        -- Valor esperado em s_PC_Out: x"00000040" (carregou o novo endereço)

        -- Teste 6: INCREMENTO (PC + 4) após desvio
        -- Voltamos ao modo de incremento normal
        s_PC_Sel      <= '0';
        s_Branch_Addr <= (others => 'X'); -- 'Don't care'
        wait for CLK_PERIOD;
        -- Valor esperado em s_PC_Out: x"00000044" (incrementou a partir do desvio)

        -- Fim da simulação
        report "Simulacao (Program_Counter) concluida." severity note;
        wait;
        
    end process stim_proc;

end architecture test;