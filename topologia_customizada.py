#!/usr/bin/env python3
"""
Trabalho Final Mininet - Questão 2
Topologia customizada:
        s1
      / | \
    s2  s3  s7
   / \   |  / | \
  h1  h2 h3 h4 h5 h6

Uso: sudo python3 topologia_customizada.py
"""

from mininet.net import Mininet
from mininet.node import Controller, RemoteController, OVSSwitch
from mininet.cli import CLI
from mininet.log import setLogLevel, info
from mininet.link import TCLink


def criarTopologia():
    """Cria a topologia customizada com controlador manual (RemoteController)."""

    # Controlador manual (externo) - deve estar rodando antes de iniciar
    # Para subir o controlador: execute em outro terminal:
    #   sudo ovs-testcontroller ptcp: &
    # OU use o controlador padrão do Mininet (descomente a linha abaixo)
    net = Mininet(controller=RemoteController, switch=OVSSwitch, link=TCLink)

    info('*** Adicionando controlador remoto\n')
    c0 = net.addController('c0', controller=RemoteController,
                           ip='127.0.0.1', port=6653)

    info('*** Adicionando switches\n')
    s1 = net.addSwitch('s1', dpid='0000000000000001')
    s2 = net.addSwitch('s2', dpid='0000000000000002')
    s3 = net.addSwitch('s3', dpid='0000000000000003')
    s7 = net.addSwitch('s7', dpid='0000000000000007')

    info('*** Adicionando hosts com MACs padronizados\n')
    h1 = net.addHost('h1', mac='00:00:00:00:00:01', ip='10.0.0.1/8')
    h2 = net.addHost('h2', mac='00:00:00:00:00:02', ip='10.0.0.2/8')
    h3 = net.addHost('h3', mac='00:00:00:00:00:03', ip='10.0.0.3/8')
    h4 = net.addHost('h4', mac='00:00:00:00:00:04', ip='10.0.0.4/8')
    h5 = net.addHost('h5', mac='00:00:00:00:00:05', ip='10.0.0.5/8')
    h6 = net.addHost('h6', mac='00:00:00:00:00:06', ip='10.0.0.6/8')

    info('*** Criando links (s1 -> s2, s3, s7)\n')
    # Switch raiz s1 conectado a s2, s3 e s7
    net.addLink(s1, s2)
    net.addLink(s1, s3)
    net.addLink(s1, s7)

    info('*** Criando links hosts -> switches\n')
    # s2 -> h1, h2
    net.addLink(s2, h1)
    net.addLink(s2, h2)
    # s3 -> h3
    net.addLink(s3, h3)
    # s7 -> h4, h5, h6
    net.addLink(s7, h4)
    net.addLink(s7, h5)
    net.addLink(s7, h6)

    info('*** Iniciando rede\n')
    net.start()

    info('\n*** Rede iniciada com sucesso!\n')
    info('*** Para inspecionar: net, dump, nodes, links\n')
    info('*** Para ver MACs dos hosts: h1 ifconfig, h2 ifconfig, ...\n')
    info('*** Para ver portas dos switches: s1 ovs-ofctl show s1\n')
    info('\n')
    info('=== COMANDOS ÚTEIS PARA O RELATÓRIO ===\n')
    info('net              -> interfaces e links\n')
    info('dump             -> info completa de todos os nós\n')
    info('nodes            -> lista de nós\n')
    info('h1 ifconfig      -> IP/MAC do host h1\n')
    info('s1 ovs-ofctl show s1  -> portas do switch s1\n')
    info('pingall          -> ping entre todos os hosts\n')
    info('h1 ping h4       -> ping entre hosts de switches diferentes\n')
    info('==========================================\n\n')

    CLI(net)

    info('*** Parando rede\n')
    net.stop()


if __name__ == '__main__':
    setLogLevel('info')
    criarTopologia()
