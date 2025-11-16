# Identificacao do grupo:  A21
#
# Membros [istID, primeiro + ultimo nome]
# 1. ist1114049, Marta Mendes
# 2. ist1114456, Joana Oliveira
# 3. is1114497, Margarida Guedes
$
# ===========================================================
# Descricao da ISA Implementada
#
# == Formato das Instrucoes ==
# Cada instrução tem 8 bits, divididos em dois campos:
# - opcode: 2 bits (bits [7:6])
# - imediato: 6 bits (bits [5:0])
# Esta divisão permite até 4 instruções distintas e operandos de 6 bits.
# Para utilizarmos as 5 instruções no nosso projeto utilizamos outro bit de controlo o bit 5, sendo que as sem                                            # imediato usam os bits [5:0] a 0.
# Para as intruções utilizamos os seguintes opcodes:
# 	li: 00
# 	addi: 01
# 	subbi: 10
#	abs:   11 (e bit 5 = 0)
#	relu:  11 (e bit 5 = 1)
#
# == Sumario dos Estagios do Pipeline==
# Devido ao processador seguir uma arquitetura simples, não implementámos estágios de pipelining, pois seria mais # dispendioso criar novos registos, no entanto tem 4 estágios principais bem definidos:
# 1. Fetch: 
#	O contador de programa fornece o endereço à ROM e obtém a instrução (8 bits).
# 2. Decode: 
#	Um distribuidor separa os 8 bits, outro que une os [7:6] em opcode e outro que une os [5:0] em
#	imediato. O decoder recebe opcode e gera os sinais de controlo.
# 3. Execute:
#	A ALU executa a operação com base no alu_op e nos valores de R1 e do imediato (via MUX). Para as             # 	instruções com opcode de função unária (como abs/relu), o bit 5 do imediato é usado como seletor de um       #	MUX, este bit foi atribuído na ROM com que escolhe entre executar abs (quando bit 5 = 0) ou relu 
#	(quando bit 5 = 1). Isso permite distinguir as duas operações com o mesmo opcode.
# 4. Write-back: 
#	O resultado da ALU é carregado no registrador R1, se o sinal load_R1 estiver ativo.

# == Sinais de Controlo ==
# alu_op[7:6]: Seleciona a operação que a ALU deve realizar.
#     00 = li, 01 = addi, 10 = subi, 11 = abs/relu (MUX seleciona com base no bit 5)
# mux_sel: Controla o MUX da entrada B da ALU (0 = zero, 1 = imediato).
#     Por exemplo, li/addi/subi usam o imediato; abs/relu usam apenas R1.
# load_R1: Ativa a escrita no registrador R1.
#     Está ativo em todas as instruções.
#
# ===========================================================
# Requisitos do enunciado que nao estao corretamente implementados:
# (indicar um por linha, ou responder "nenhum")
# -nenhum
#
# ===========================================================
# Top-3 das otimizacoes que a vossa solucao incorpora:
# (maximo 140 caracteres por cada otimizacao)
#
# 1.
#
# 2.
#
# 3.
#
# ===========================================================