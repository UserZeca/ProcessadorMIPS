library ieee;
use ieee.std_logic_1164.all;

-- Testbench simples para a Memória de Dados (RAM)
entity tb_Data_Memory is
end entity tb_Data_Memory;

architecture test of tb_Data_Memory is

    -- 1. Declarar o Componente que vamos testar (a UUT)
    component Data_Memory
        port (
            Clk         : in  std_logic;
            MemWrite    : in  std_logic;
            MemRead     : in  std_logic;
            Address     : in  std_logic_vector(31 downto 0);
            DataIn      : in  std_logic_vector(31 downto 0);
            DataOut     : out std_logic_vector(31 downto 0)
        );
    end component;

    -- 2. Sinais internos do testbench
    signal s_Clk       : std_logic := '0';
    signal s_MemWrite  : std_logic := '0';
    signal s_MemRead   : std_logic := '0';
    signal s_Address   : std_logic_vector(31 downto 0) := (others => '0');
    signal s_DataIn    : std_logic_vector(31 downto 0) := (others => '0');
    signal s_DataOut   : std_logic_vector(31 downto 0);

    -- Constantes do Clock
    constant CLK_PERIOD : time := 10 ns;
    constant CLK_HALF   : time := CLK_PERIOD / 2;

begin

    -- 3. Instanciar a UUT
    u_uut: Data_Memory
        port map (
            Clk         => s_Clk,
            MemWrite    => s_MemWrite,
            MemRead     => s_MemRead,
            Address     => s_Address,
            DataIn      => s_DataIn,
            DataOut     => s_DataOut
        );

    -- 4. Processo Gerador de Clock
    --    Este processo roda para sempre, gerando '0', '1', '0', '1'...
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
        report "Iniciando simulacao (Data_Memory)..." severity note;
        
        -- Estado inicial (espera o primeiro ciclo de clock)
        wait for CLK_PERIOD;

        -- Teste 1: ESCREVER o valor AAAA no Endereço 10 (Hex)
        -- Simula a instrução: sw $t0, 16($zero)
        report "Teste 1: Escrevendo x""AAAAAAAA"" no endereco x""00000010""..." severity note;
        s_MemWrite <= '1';
        s_MemRead  <= '0';
        s_Address  <= x"00000010"; -- Endereço 16 (decimal)
        s_DataIn   <= x"AAAAAAAA";
        wait for CLK_PERIOD; -- A escrita acontece na borda de subida do clock
        
        -- Coloca os sinais em 'Idle' (nenhuma operação)
        s_MemWrite <= '0';
        s_MemRead  <= '0';
        s_DataIn   <= (others => 'X'); -- 'Don't care'
        wait for CLK_PERIOD;

        -- Teste 2: LER do Endereço 10 (Hex)
        -- Simula a instrução: lw $t1, 16($zero)
        report "Teste 2: Lendo do endereco x""00000010""..." severity note;
        s_MemWrite <= '0';
        s_MemRead  <= '1';
        s_Address  <= x"00000010";
        wait for CLK_PERIOD;
        -- Valor esperado em s_DataOut: x"AAAAAAAA"
        
        -- Teste 3: ESCREVER o valor BBBB no Endereço 24 (Hex)
        report "Teste 3: Escrevendo x""BBBBBBBB"" no endereco x""00000024""..." severity note;
        s_MemWrite <= '1';
        s_MemRead  <= '0';
        s_Address  <= x"00000024"; -- Endereço 36 (decimal)
        s_DataIn   <= x"BBBBBBBB";
        wait for CLK_PERIOD;

        -- Teste 4: LER do Endereço 24 (Hex)
        report "Teste 4: Lendo do endereco x""00000024""..." severity note;
        s_MemWrite <= '0';
        s_MemRead  <= '1';
        s_Address  <= x"00000024";
        wait for CLK_PERIOD;
        -- Valor esperado em s_DataOut: x"BBBBBBBB"

        -- Teste 5: LER do Endereço 10 (Hex) DE NOVO
        report "Teste 5: Lendo do endereco x""00000010"" novamente (verificacao)..." severity note;
        s_MemWrite <= '0';
        s_MemRead  <= '1';
        s_Address  <= x"00000010";
        wait for CLK_PERIOD;
        -- Valor esperado em s_DataOut: x"AAAAAAAA" (deve ser o valor antigo)
        
        -- Fim da simulação
        report "Simulacao (Data_Memory) concluida." severity note;
        wait;
        
    end process stim_proc;

end architecture test;