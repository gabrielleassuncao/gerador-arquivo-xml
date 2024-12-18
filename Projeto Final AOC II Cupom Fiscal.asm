#Nome: Gabrielle do Carmo Assuncao

.data

nome:       .asciiz "Nome do cliente: "              # Mensagem para nome do cliente
data:       .asciiz "Data da compra: "               # Mensagem para data da compra
itens:      .asciiz "Itens comprados (digite 'fim' para terminar): " # Mensagem para itens comprados
total:      .asciiz "Valor total da compra: "       # Mensagem para valor total da compra
pagamento:  .asciiz "Forma de pagamento: "           # Mensagem para forma de pagamento
arquivo:    .asciiz "CupomFiscal.xml"


buffer:     .space 256  # Buffer para armazenar entradas (nome, data, total, etc.)
item_buffer: .space 256 # Buffer para armazenar itens

# Estrutura do XML
abertura:   .asciiz "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
cupom:      .asciiz "<cupom_fiscal>\n"
nome_abertura:   .asciiz "<nome>"
nome_fechamento: .asciiz "</nome>\n"
data_abertura:   .asciiz "<data>"
data_fechamento: .asciiz "</data>\n"
itens_abertura:  .asciiz "<itens>\n"
itens_fechamento:.asciiz "</itens>\n"
item_abertura:  .asciiz "<item>\n"
item_fechamento:.asciiz "</item>\n"
total_abertura:  .asciiz "<total>"
total_fechamento:.asciiz "</total>\n"
pagamento_abertura: .asciiz "<modo>"
pagamento_fechamento:.asciiz "</modo>\n"
cupom_fechamento: .asciiz "</cupom_fiscal>\n"

.text
.globl main

main:
    # Abre o arquivo para escrita
    li   $v0, 13       # Chamada de sistema para abrir arquivo
    la   $a0, arquivo  # Caminho do arquivo
    li   $a1, 1        # Modo de abertura para escrita
    li   $a2, 0        # Modo ignorado
    syscall            # Abre o arquivo e armazena o descritor em $v0
    move $s6, $v0      # Guarda o descritor do arquivo em $s6
    
    # Escreve o cabeçalho XML
    li   $v0, 15          # Chamada de sistema 15 (escrever no arquivo)
    move $a0, $s6         # Descritor do arquivo
    la   $a1, abertura    # Cabeçalho XML
    li   $a2, 41          # Tamanho da string "<?xml version="1.0" encoding="UTF-8"?>\n"
    syscall               # Escreve no arquivo

    # Escreve a tag <cupom_fiscal>
    li   $v0, 15          # Chamada de sistema 15 (escrever no arquivo)
    move $a0, $s6         # Descritor do arquivo
    la   $a1, cupom       # Tag <cupom_fiscal>
    li   $a2, 15          # Tamanho da string "<cupom_fiscal>\n"
    syscall               # Escreve no arquivo
    
    # Insere o nome do cliente
    li $v0, 4           # syscall para exibir mensagem
    la $a0, nome         # Exibe a mensagem "Nome do cliente: "
    syscall
    li $v0, 8           # syscall para ler string
    la $a0, buffer      # Buffer para armazenar o nome do cliente
    li $a1, 100         # Tamanho máximo da string
    syscall
    move $s0, $a0       # Guarda o endereço do buffer com o nome em $s0
    
    # Escreve o nome do cliente no XML
    li   $v0, 15        # syscall para escrever no arquivo
    move $a0, $s6       # Descritor do arquivo
    la   $a1, nome_abertura  # Tag <nome>
    li   $a2, 6         # Tamanho da string "<nome>"
    syscall             # Escreve a ta,g <nome>
    
    li   $v0, 15        # Escreve o nome do cliente no arquivo
    move $a0, $s6
    la   $a1, buffer
    li   $a2, 100
    syscall             # Escreve o nome no arquivo
    
    li   $v0, 15        # Escreve a tag </nome>
    move $a0, $s6
    la   $a1, nome_fechamento
    li   $a2, 9
    syscall             # Escreve a tag </nome>
    
    # Insere a data
    li $v0, 4           # syscall para exibir mensagem
    la $a0, data         # Exibe a mensagem "Data da compra: "
    syscall
    li $v0, 8           # syscall para ler string
    la $a0, buffer      # Buffer para armazenar a data
    li $a1, 100         # Tamanho máximo da string
    syscall
    move $s1, $a0       # Guarda o endereço do buffer com a data em $s1
    
    # Escreve a tag <data> e a data no arquivo
    li   $v0, 15        # syscall para escrever no arquivo
    move $a0, $s6       # Descritor do arquivo
    la   $a1, data_abertura  # Tag <data>
    li   $a2, 6         # Tamanho da string "<data>"
    syscall             # Escreve a tag <data>
    
    li   $v0, 15        # Escreve a data no arquivo
    move $a0, $s6
    la   $a1, buffer
    li   $a2, 100
    syscall             # Escreve a data no arquivo
    
    li   $v0, 15        # Escreve a tag </data>
    move $a0, $s6
    la   $a1, data_fechamento
    li   $a2, 9
    syscall             # Escreve a tag </data>

    # Insere os itens 
    li   $v0, 15        # syscall para escrever no arquivo
    move $a0, $s6       # Descritor do arquivo
    la   $a1, itens_abertura  # Tag <itens>
    li   $a2, 8         # Tamanho da string "<itens>\n"
    syscall             # Escreve a tag <itens>

    # Loop para inserir itens um a um
    item_loop:
        li $v0, 4           # syscall para exibir mensagem
        la $a0, itens        # Exibe a mensagem "Itens comprados"
        syscall
        li $v0, 8           # syscall para ler string
        la $a0, item_buffer # Buffer para armazenar o item
        li $a1, 100         # Tamanho máximo da string
        syscall
        # Verifica se o usuário digitou "fim"
        la $t0, item_buffer  # Endereço do buffer do item
        li $t1, 102          # Código ASCII para 'f'
        lb $t2, 0($t0)       # Lê o primeiro caractere
        beq $t2, $t1, fim     # Se for 'f', termina o loop
        
        # Escreve a tag <item> antes do nome do item
        li   $v0, 15        # Escreve a tag <item>
        move $a0, $s6
        la   $a1, item_abertura
        li   $a2, 7         # Tamanho da string "<item>\n"
        syscall             # Escreve a tag <item>

        # Escreve o item no arquivo
        li   $v0, 15        # Escreve o item no arquivo
        move $a0, $s6
        la   $a1, item_buffer
        li   $a2, 100
        syscall             # Escreve o item no arquivo
        
        # Escreve a tag </item> após o ,,,,,,,,,,,,,,,,nome do item
        li   $v0, 15        # Escreve a tag </item>
        move $a0, $s6
        la   $a1, item_fechamento
        li   $a2, 8         # Tamanho da string "</item>\n"
        syscall             # Escreve a tag </item>
        
        j item_loop         # Repete o loop

    fim:
        # Escreve a tag de fechamento </itens>
        li   $v0, 15        # Escreve a tag </itens>
        move $a0, $s6
        la   $a1, itens_fechamento
        li   $a2, 9         # Tamanho da string "</itens>"
        syscall             # Escreve a tag </itens>

    # Insere o valor total
    li $v0, 4           # syscall para exibir mensagem
    la $a0, total        # Exibe a mensagem "Valor total da compra: "
    syscall
    li $v0, 8           # syscall para ler string
    la $a0, buffer       # Buffer para armazenar o total
    li $a1, 100          # Tamanho máximo da string
    syscall
    move $s2, $a0        # Guarda o endereço do buffer com o total em $s2
    
    # Escreve o total no arquivo
    li   $v0, 15         # syscall para escrever no arquivo
    move $a0, $s6
    la   $a1, total_abertura
    li   $a2, 7
    syscall              # Escreve a tag <total>
    
    li   $v0, 15         # Escreve o total no arquivo
    move $a0, $s6
    la   $a1, buffer
    li   $a2, 100
    syscall              # Escreve o total no arquivo
    
    li   $v0, 15         # Escreve a tag </total>
    move $a0, $s6
    la   $a1, total_fechamento
    li   $a2, 9
    syscall              # Escreve a tag </total>

    # Insere a forma de pagamento
    li $v0, 4           # syscall para exibir mensagem
    la $a0, pagamento     # Exibe a mensagem "Forma de pagamento: "
    syscall
    li $v0, 8           # syscall para ler string
    la $a0, buffer       # Buffer para armazenar a forma de pagamento
    li $a1, 100          # Tamanho máximo da string
    syscall
    move $s3, $a0        # Guarda o endereço do buffer com o pagamento em $s3

    # Escreve a forma de pagamento no arquivo
    li   $v0, 15         # syscall para escrever no arquivo
    move $a0, $s6
    la   $a1, pagamento_abertura
    li   $a2, 7
    syscall              # Escreve a tag <modo>
    
    li   $v0, 15         # Escreve a forma de pagamento no arquivo
    move $a0, $s6
    la   $a1, buffer
    li   $a2, 100
    syscall              # Escreve a forma de pagamento no arquivo
    
    li   $v0, 15         # Escreve a tag </modo>
    move $a0, $s6
    la   $a1, pagamento_fechamento
    li   $a2, 9
    syscall              # Escreve a tag </modo>

    # Escreve a tag de fechamento </cupom_fiscal>
    li   $v0, 15         # Escreve a tag </cupom_fiscal>
    move $a0, $s6
    la   $a1, cupom_fechamento
    li   $a2, 16
    syscall              # Escreve a tag </cupom_fiscal>
    
    # Fecha o arquivo
    li   $v0, 16         # Chamada de sistema para fechar arquivo
    move $a0, $s6        # Descritor do arquivo
    syscall              # Fecha o arquivo

    # Fim do programa
    li   $v0, 10         # Chamada de sistema para terminar o programa
    syscall
