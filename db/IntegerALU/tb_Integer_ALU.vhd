library ieee;
use ieee.std_logic_1164.all;

-- Testbench de estímulo simples para a ALU de Inteiros
entity tb_Integer_ALU is
end entity tb_Integer_ALU;

architecture test of tb_Integer_ALU is

    -- 1. Declarar o Componente que vamos testar (a UUT)
    component Integer_ALU
        port (
            A       : in  std_logic_vector(31 downto 0);
            B       : in  std_logic_vector(31 downto 0);
            ALU_Sel : in  std_logic_vector(3 downto 0);
            R       : out std_logic_vector(31 downto 0);
            Zero    : out std_logic
        );
    end component;

    -- 2. Sinais internos do testbench para conectar na UUT
    signal s_A       : std_logic_vector(31 downto 0) := (others => '0');
    signal s_B       : std_logic_vector(31 downto 0) := (others => '0');
    signal s_ALU_Sel : std_logic_vector(3 downto 0)  := "0000";
    signal s_R       : std_logic_vector(31 downto 0);
    signal s_Zero    : std_logic;

    -- Constante para definir o "passo" da simulação
    constant STEP_TIME : time := 10 ns;

begin

    -- 3. Instanciar a UUT
    u_uut: Integer_ALU
        port map (
            A       => s_A,
            B       => s_B,
            ALU_Sel => s_ALU_Sel,
            R       => s_R,
            Zero    => s_Zero
        );

    -- 4. Processo de Estímulo (Verifique os resultados no Waveform)
    stim_proc: process
    begin
        report "Iniciando simulacao (Integer_ALU)..." severity note;
        
        -- Teste 1: "0000" (AND)
        s_A       <= x"FFFF0000";
        s_B       <= x"00FFFF00";
        s_ALU_Sel <= "0000";
        wait for STEP_TIME;
        -- Valor esperado: R = x"00FF0000", Zero = '0'

        -- Teste 2: "0001" (OR)
        s_A       <= x"FFFF0000";
        s_B       <= x"00FFFF00";
        s_ALU_Sel <= "0001";
        wait for STEP_TIME;
        -- Valor esperado: R = x"FFFFFF00", Zero = '0'

        -- Teste 3: "0010" (ADD) - Simples (5 + 10)
        s_A       <= x"00000005";
        s_B       <= x"0000000A";
        s_ALU_Sel <= "0010";
        wait for STEP_TIME;
        -- Valor esperado: R = x"0000000F" (15), Zero = '0'
            
        -- Teste 4: "0010" (ADD) - Com negativo (5 + (-10))
        s_A       <= x"00000005";
        s_B       <= x"FFFFFFF6";
        s_ALU_Sel <= "0010";
        wait for STEP_TIME;
        -- Valor esperado: R = x"FFFFFFFB" (-5), Zero = '0'

        -- Teste 5: "0110" (SUB) - Resultado Zero (10 - 10)
        s_A       <= x"0000000A";
        s_B       <= x"0000000A";
        s_ALU_Sel <= "0110";
        wait for STEP_TIME;
        -- Valor esperado: R = x"00000000", Zero = '1'

        -- Teste 6: "0111" (SLT) - True (-10 < 5)
        s_A       <= x"FFFFFFF6";
        s_B       <= x"00000005";
        s_ALU_Sel <= "0111";
        wait for STEP_TIME;
        -- Valor esperado: R = x"00000001", Zero = '0'
            
        -- Teste 7: "0111" (SLT) - False (5 >= -10)
        s_A       <= x"00000005";
        s_B       <= x"FFFFFFF6";
        s_ALU_Sel <= "0111";
        wait for STEP_TIME;
        -- Valor esperado: R = x"00000000", Zero = '1'
            
        -- Teste 8: "1100" (NOR)
        s_A       <= x"F0F0F0F0";
        s_B       <= x"0F0F0F0F";
        s_ALU_Sel <= "1100";
        wait for STEP_TIME;
        -- Valor esperado: R = x"00000000", Zero = '1'

        -- Fim da simulação
        report "Simulacao (Integer_ALU) concluida." severity note;
        wait; -- Pára a simulação
        
    end process stim_proc;

end architecture test;