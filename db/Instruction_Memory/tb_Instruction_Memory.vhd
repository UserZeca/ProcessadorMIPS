library ieee;
use ieee.std_logic_1164.all;

-- Testbench simples para a Memória de Instrução (ROM)
entity tb_Instruction_Memory is
end entity tb_Instruction_Memory;

architecture test of tb_Instruction_Memory is

    -- 1. Declarar o Componente que vamos testar (a UUT)
    component Instruction_Memory
        port (
            Address     : in  std_logic_vector(31 downto 0);
            Instruction : out std_logic_vector(31 downto 0)
        );
    end component;

    -- 2. Sinais internos do testbench
    signal s_Address     : std_logic_vector(31 downto 0) := (others => '0');
    signal s_Instruction : std_logic_vector(31 downto 0);

    -- Constante para definir o "passo" da simulação
    constant STEP_TIME : time := 10 ns;

begin

    -- 3. Instanciar a UUT
    u_uut: Instruction_Memory
        port map (
            Address     => s_Address,
            Instruction => s_Instruction
        );

    -- 4. Processo de Estímulo (Simulando o PC)
    stim_proc: process
    begin
        report "Iniciando simulacao (Instruction_Memory)..." severity note;
        
        -- Apenas esperamos um pouco para a memória inicializar (ler o .mem)
        wait for 5 ns; 

        -- Pedir Endereço 0 (Instrução 1)
        s_Address <= x"00000000";
        wait for STEP_TIME;
        -- Valor esperado em s_Instruction: x"20080005"

        -- Pedir Endereço 4 (Instrução 2)
        s_Address <= x"00000004";
        wait for STEP_TIME;
        -- Valor esperado em s_Instruction: x"2009000A"

        -- Pedir Endereço 8 (Instrução 3)
        s_Address <= x"00000008";
        wait for STEP_TIME;
        -- Valor esperado em s_Instruction: x"01095020"
            
        -- Pedir Endereço 12 (Instrução 4)
        s_Address <= x"0000000C";
        wait for STEP_TIME;
        -- Valor esperado em s_Instruction: x"AC0A0000"
            
        -- Fim da simulação
        report "Simulacao (Instruction_Memory) concluida." severity note;
        wait;
        
    end process stim_proc;

end architecture test;