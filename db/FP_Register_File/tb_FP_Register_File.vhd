library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench simples para o Banco de Registradores de Ponto Flutuante
entity tb_FP_Register_File is
end entity tb_FP_Register_File;

architecture test of tb_FP_Register_File is

    -- 1. Declarar o Componente que vamos testar (a UUT)
    component FP_Register_File
        port (
            Clk         : in  std_logic;
            Rst         : in  std_logic;
            Write_Enable: in  std_logic;
            Read_Addr_1 : in  std_logic_vector(4 downto 0);
            Read_Addr_2 : in  std_logic_vector(4 downto 0);
            Data_Out_1  : out std_logic_vector(31 downto 0);
            Data_Out_2  : out std_logic_vector(31 downto 0);
            Write_Addr  : in  std_logic_vector(4 downto 0);
            Data_In     : in  std_logic_vector(31 downto 0)
        );
    end component;

    -- 2. Sinais internos do testbench
    signal s_Clk         : std_logic := '0';
    signal s_Rst         : std_logic := '0';
    signal s_Write_Enable: std_logic := '0';
    signal s_Read_Addr_1 : std_logic_vector(4 downto 0) := (others => '0');
    signal s_Read_Addr_2 : std_logic_vector(4 downto 0) := (others => '0');
    signal s_Data_Out_1  : std_logic_vector(31 downto 0);
    signal s_Data_Out_2  : std_logic_vector(31 downto 0);
    signal s_Write_Addr  : std_logic_vector(4 downto 0) := (others => '0');
    signal s_Data_In     : std_logic_vector(31 downto 0) := (others => '0');

    -- Constantes do Clock
    constant CLK_PERIOD : time := 10 ns;
    constant CLK_HALF   : time := CLK_PERIOD / 2;

begin

    -- 3. Instanciar a UUT
    u_uut: FP_Register_File
        port map (
            Clk          => s_Clk,
            Rst          => s_Rst,
            Write_Enable => s_Write_Enable,
            Read_Addr_1  => s_Read_Addr_1,
            Read_Addr_2  => s_Read_Addr_2,
            Data_Out_1   => s_Data_Out_1,
            Data_Out_2   => s_Data_Out_2,
            Write_Addr   => s_Write_Addr,
            Data_In      => s_Data_In
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
    
    -- 5. Processo de Estímulo
    stim_proc: process
    begin
        report "Iniciando simulacao (FP_Register_File)..." severity note;
        
        -- Teste 1: RESET
        -- Ativamos o Reset por um ciclo para limpar os registradores
        s_Rst <= '1';
        wait for CLK_PERIOD;
        s_Rst <= '0';
        -- Valor esperado: Todos os registradores internos = 0
        
        -- Teste 2: ESCREVER no registrador $f5
        report "Teste 2: Escrevendo AAAA no reg $f5..." severity note;
        s_Write_Enable <= '1';
        s_Write_Addr   <= "00101"; -- Endereço 5
        s_Data_In      <= x"AAAAAAAA";
        wait for CLK_PERIOD; -- A escrita acontece na borda de subida

        -- Teste 3: LER do registrador $f5 (nas duas portas)
        report "Teste 3: Lendo do reg $f5..." severity note;
        s_Write_Enable <= '0';
        s_Read_Addr_1  <= "00101"; -- Ler do reg 5
        s_Read_Addr_2  <= "00101"; -- Ler do reg 5
        wait for CLK_PERIOD;
        -- Valor esperado: s_Data_Out_1 = x"AAAAAAAA"
        -- Valor esperado: s_Data_Out_2 = x"AAAAAAAA"
        
        -- Teste 4: ESCREVER no reg $f10, LENDO $f5
        report "Teste 4: Escrevendo BBBB no reg $f10, lendo $f5..." severity note;
        s_Write_Enable <= '1';
        s_Write_Addr   <= "01010"; -- Endereço 10
        s_Data_In      <= x"BBBBBBBB";
        s_Read_Addr_1  <= "00101"; -- Ler do reg 5
        s_Read_Addr_2  <= "00000"; -- Ler do reg 0
        wait for CLK_PERIOD;
        -- Valor esperado: s_Data_Out_1 = x"AAAAAAAA" (leitura assíncrona)
        -- Valor esperado: s_Data_Out_2 = x"00000000" (do reset)

        -- Teste 5: LER $f5 e $f10 (verificar a escrita anterior)
        report "Teste 5: Lendo $f5 e $f10..." severity note;
        s_Write_Enable <= '0';
        s_Read_Addr_1  <= "00101"; -- Ler do reg 5
        s_Read_Addr_2  <= "01010"; -- Ler do reg 10
        wait for CLK_PERIOD;
        -- Valor esperado: s_Data_Out_1 = x"AAAAAAAA"
        -- Valor esperado: s_Data_Out_2 = x"BBBBBBBB"

        -- Fim da simulação
        report "Simulacao (FP_Register_File) concluida." severity note;
        wait;
        
    end process stim_proc;

end architecture test;