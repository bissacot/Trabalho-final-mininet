#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# MACs dos hosts (atribuídos pelo --mac ou pelo código Python):
#   h1 -> 00:00:00:00:00:01  (switch s2)
#   h2 -> 00:00:00:00:00:02  (switch s2)
#   h3 -> 00:00:00:00:00:03  (switch s3)
#   h4 -> 00:00:00:00:00:04  (switch s7)
#   h5 -> 00:00:00:00:00:05  (switch s7)
#   h6 -> 00:00:00:00:00:06  (switch s7)

echo "=== PASSO 1: Apagar TODAS as regras existentes ==="
sudo ovs-ofctl del-flows s1
sudo ovs-ofctl del-flows s2
sudo ovs-ofctl del-flows s3
sudo ovs-ofctl del-flows s7
echo "Regras apagadas."

echo ""
echo "=== PASSO 2: Verificar portas de cada switch ==="
echo "--- s1 ---"
sudo ovs-ofctl show s1
echo "--- s2 ---"
sudo ovs-ofctl show s2
echo "--- s3 ---"
sudo ovs-ofctl show s3
echo "--- s7 ---"
sudo ovs-ofctl show s7

# ============================================================
# MAPEAMENTO DE PORTAS (baseado na topologia Python):
#   s2: porta 1=s1, porta 2=h1, porta 3=h2
#   s3: porta 1=s1, porta 2=h3
#   s7: porta 1=s1, porta 2=h4, porta 3=h5, porta 4=h6
#   s1: porta 1=s2, porta 2=s3, porta 3=s7

echo ""
echo "=== Instalando regras para permitir tráfego ARP ==="
sudo ovs-ofctl add-flow s1 "priority=50,dl_type=0x0806,actions=flood"
sudo ovs-ofctl add-flow s2 "priority=50,dl_type=0x0806,actions=flood"
sudo ovs-ofctl add-flow s3 "priority=50,dl_type=0x0806,actions=flood"
sudo ovs-ofctl add-flow s7 "priority=50,dl_type=0x0806,actions=flood"

echo ""
echo "=== PASSO 3: Instalar regras baseadas em MAC ==="

# --- Regras no switch s2 ---
# h1 (00:00:00:00:00:01) envia para h3 (00:00:00:00:00:03) - por s1
sudo ovs-ofctl add-flow s2 \
  "priority=100,dl_src=00:00:00:00:00:01,dl_dst=00:00:00:00:00:03,actions=output:1"
# h3 responde para h1
sudo ovs-ofctl add-flow s2 \
  "priority=100,dl_src=00:00:00:00:00:03,dl_dst=00:00:00:00:00:01,actions=output:2"

# h2 (00:00:00:00:00:02) envia para h4 (00:00:00:00:00:04) - por s1
sudo ovs-ofctl add-flow s2 \
  "priority=100,dl_src=00:00:00:00:00:02,dl_dst=00:00:00:00:00:04,actions=output:1"
# h4 responde para h2
sudo ovs-ofctl add-flow s2 \
  "priority=100,dl_src=00:00:00:00:00:04,dl_dst=00:00:00:00:00:02,actions=output:3"

# --- Regras no switch s3 ---
# h3 (00:00:00:00:00:03) envia para h1 (00:00:00:00:00:01) - por s1
sudo ovs-ofctl add-flow s3 \
  "priority=100,dl_src=00:00:00:00:00:03,dl_dst=00:00:00:00:00:01,actions=output:1"
# h1 chega em s3 indo para h3
sudo ovs-ofctl add-flow s3 \
  "priority=100,dl_src=00:00:00:00:00:01,dl_dst=00:00:00:00:00:03,actions=output:2"

# h3 (00:00:00:00:00:03) envia para h5 (00:00:00:00:00:05) - por s1
sudo ovs-ofctl add-flow s3 \
  "priority=100,dl_src=00:00:00:00:00:03,dl_dst=00:00:00:00:00:05,actions=output:1"
# h5 responde para h3
sudo ovs-ofctl add-flow s3 \
  "priority=100,dl_src=00:00:00:00:00:05,dl_dst=00:00:00:00:00:03,actions=output:2"

# --- Regras no switch s7 ---
# h4 (00:00:00:00:00:04) envia para h2 - por s1
sudo ovs-ofctl add-flow s7 \
  "priority=100,dl_src=00:00:00:00:00:04,dl_dst=00:00:00:00:00:02,actions=output:1"
# h2 chega em s7 indo para h4
sudo ovs-ofctl add-flow s7 \
  "priority=100,dl_src=00:00:00:00:00:02,dl_dst=00:00:00:00:00:04,actions=output:2"

# h5 (00:00:00:00:00:05) envia para h3 - por s1
sudo ovs-ofctl add-flow s7 \
  "priority=100,dl_src=00:00:00:00:00:05,dl_dst=00:00:00:00:00:03,actions=output:1"
# h3 chega em s7 indo para h5
sudo ovs-ofctl add-flow s7 \
  "priority=100,dl_src=00:00:00:00:00:03,dl_dst=00:00:00:00:00:05,actions=output:3"

# --- Regras no switch s1 (core) ---
# s1 encaminha baseado no MAC de destino para a porta correta
# Destinos em s2 (h1, h2) -> porta 1
sudo ovs-ofctl add-flow s1 \
  "priority=100,dl_dst=00:00:00:00:00:01,actions=output:1"
sudo ovs-ofctl add-flow s1 \
  "priority=100,dl_dst=00:00:00:00:00:02,actions=output:1"
# Destinos em s3 (h3) -> porta 2
sudo ovs-ofctl add-flow s1 \
  "priority=100,dl_dst=00:00:00:00:00:03,actions=output:2"
# Destinos em s7 (h4, h5, h6) -> porta 3
sudo ovs-ofctl add-flow s1 \
  "priority=100,dl_dst=00:00:00:00:00:04,actions=output:3"
sudo ovs-ofctl add-flow s1 \
  "priority=100,dl_dst=00:00:00:00:00:05,actions=output:3"
sudo ovs-ofctl add-flow s1 \
  "priority=100,dl_dst=00:00:00:00:00:06,actions=output:3"

echo ""
echo "=== PASSO 4: Verificar regras instaladas ==="
echo "--- Flows em s1 ---"
sudo ovs-ofctl dump-flows s1
echo "--- Flows em s2 ---"
sudo ovs-ofctl dump-flows s2
echo "--- Flows em s3 ---"
sudo ovs-ofctl dump-flows s3
echo "--- Flows em s7 ---"
sudo ovs-ofctl dump-flows s7

echo ""
echo "=== PASSO 5: Testar conectividade entre switches diferentes ==="
echo "Para testar dentro do Mininet CLI:"
echo "  mininet> h1 ping -c 3 h3"
echo "  mininet> h2 ping -c 3 h4"
echo "  mininet> h3 ping -c 3 h5"
echo "  mininet> h1 ping -c 3 h5"


