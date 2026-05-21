# Trabalho Final — Mininet

**Alunos:** Gabriel Bissacot Fraguas e Henrique Fonseca

---

## Arquivos do projeto

| Arquivo                        | Descrição                                   |
| ------------------------------ | --------------------------------------------- |
| `topologia_customizada.py`   | Código Python da topologia da Questão 2     |
| `regras_mac.sh`              | Script de regras OpenFlow baseadas em MAC     |
| `trabalho_final_mininet.pdf` | Relatório completo com prints e resultados   |
| `topologia_quest1.pdf`       | Desenho da topologia linear (Questão 1)      |
| `topologia_quest2.pdf`       | Desenho da topologia customizada (Questão 2) |

---

## Dependências

* [Mininet](http://mininet.org/) — emulador de redes SDN
* Open vSwitch (OVS) — instalado junto com o Mininet
* `iperf` — teste de banda
* `tcpdump` — captura de pacotes

Instalar tudo de uma vez (Ubuntu/Debian):

```bash
sudo apt-get install mininet iperf tcpdump -y
```

---

## Questão 1 — Topologia linear com 8 switches

Topologia criada via linha de comando, com MACs padronizados e largura de banda de 20 Mbps:

```bash
sudo mn --topo linear,8 --mac --link tc,bw=20
```

Para os testes iperf com outras larguras de banda, recriar com `bw=30` ou `bw=40`.

---

## Questão 2 — Topologia customizada

### 1. Subir o controlador manual

Em um terminal separado, antes de rodar o Python:

```bash
sudo ovs-testcontroller ptcp: &
```

### 2. Executar a topologia

```bash
sudo python3 topologia_customizada.py
```

### 3. Aplicar as regras MAC (em outro terminal, fora do Mininet)

```bash
sudo bash regras_mac.sh
```

O script apaga as regras existentes, instala regras OpenFlow baseadas em endereço MAC para comunicação entre hosts de switches diferentes, e adiciona uma regra de drop para bloquear tráfego não autorizado.

**Pares permitidos pelas regras:**

* h1 (s2) ↔ h3 (s3)
* h2 (s2) ↔ h4 (s7)
* h3 (s3) ↔ h5 (s7)

---

## Observações

* O relatório completo com todos os prints e resultados está em `trabalho_final_mininet.pdf`.
* As bandas medidas pelo iperf ficam ligeiramente abaixo do limite configurado — esperado pela passagem por 8 switches em série.
* O teste de bloqueio (h1 → h4) retorna 100% de perda, confirmando que as regras MAC funcionam corretamente.
