# jul/22/2023 13:22:28 by RouterOS 7.9.2
# software id = 
#
/interface bridge
add name=Bridge-VLAN-TRUNKs
/interface pppoe-client
add disabled=no interface=ether1 name=pppoe-out1 user=ppp1
add disabled=no interface=ether2 name=pppoe-out2 user=ppp2
/interface vlan
add interface=Bridge-VLAN-TRUNKs name=vlan10 vlan-id=10
add interface=Bridge-VLAN-TRUNKs name=vlan20 vlan-id=20
/disk
set slot1 slot=slot1 type=hardware
/interface list
add name=Bridge-LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=dhcp_pool0 ranges=192.168.88.2-192.168.88.254
add name=dhcp_pool1 ranges=10.10.10.2-10.10.10.254
add name=dhcp_pool2 ranges=10.20.20.2-10.20.20.254
/ip dhcp-server
add address-pool=dhcp_pool0 interface=Bridge-VLAN-TRUNKs lease-time=1d name=\
    dhcp1
add address-pool=dhcp_pool1 interface=vlan10 lease-time=1d name=dhcp2
add address-pool=dhcp_pool2 interface=vlan20 lease-time=1d name=dhcp3
/port
set 0 name=serial0
/routing table
add disabled=no fib name=via-ISP1
add disabled=no fib name=via-ISP2
/interface bridge port
add bridge=Bridge-VLAN-TRUNKs interface=ether5
/interface list member
add interface=Bridge-VLAN-TRUNKs list=Bridge-LAN
add interface=vlan10 list=Bridge-LAN
add interface=vlan20 list=Bridge-LAN
/ip address
add address=192.168.88.1/24 interface=Bridge-VLAN-TRUNKs network=192.168.88.0
add address=10.10.10.1/24 interface=vlan10 network=10.10.10.0
add address=10.20.20.1/24 interface=vlan20 network=10.20.20.0
/ip dhcp-server network
add address=10.10.10.0/24 dns-server=10.10.10.1 gateway=10.10.10.1
add address=10.20.20.0/24 dns-server=10.20.20.1 gateway=10.20.20.1
add address=192.168.88.0/24 dns-server=192.168.88.1 gateway=192.168.88.1
/ip dns
set allow-remote-requests=yes servers=1.1.1.1,1.0.0.1
/ip firewall address-list
add address=192.168.88.0/24 list=LAN
add address=10.10.10.0/24 list=LAN
add address=10.20.20.0/24 list=LAN
/ip firewall mangle
add action=accept chain=prerouting in-interface=pppoe-out1
add action=accept chain=prerouting in-interface=pppoe-out2
add action=accept chain=prerouting dst-address-list=LAN
add action=mark-connection chain=prerouting in-interface-list=Bridge-LAN \
    new-connection-mark=ISP1_Conn passthrough=yes per-connection-classifier=\
    both-addresses:2/0
add action=mark-routing chain=prerouting connection-mark=ISP1_Conn \
    in-interface-list=Bridge-LAN new-routing-mark=via-ISP1 passthrough=no
add action=mark-connection chain=prerouting in-interface-list=Bridge-LAN \
    new-connection-mark=ISP2_Conn passthrough=yes per-connection-classifier=\
    both-addresses:2/1
add action=mark-routing chain=prerouting connection-mark=ISP2_Conn \
    in-interface-list=Bridge-LAN new-routing-mark=via-ISP2 passthrough=no
add action=mark-connection chain=prerouting in-interface=pppoe-out1 \
    new-connection-mark=ISP1_Conn passthrough=yes
add action=mark-routing chain=output connection-mark=ISP1_Conn \
    new-routing-mark=via-ISP1 passthrough=no
add action=mark-connection chain=prerouting in-interface=pppoe-out2 \
    new-connection-mark=ISP2_Conn passthrough=yes
add action=mark-routing chain=output connection-mark=ISP2_Conn \
    new-routing-mark=via-ISP2 passthrough=no
/ip firewall nat
add action=masquerade chain=srcnat out-interface=pppoe-out1
add action=masquerade chain=srcnat out-interface=pppoe-out2
/ip route
add comment=via-ISP1_To_ISP1 disabled=no distance=1 dst-address=0.0.0.0/0 \
    gateway=pppoe-out1 pref-src="" routing-table=via-ISP1 scope=30 \
    suppress-hw-offload=no target-scope=10
add comment=via-ISP2_To_ISP2 disabled=no distance=1 dst-address=0.0.0.0/0 \
    gateway=pppoe-out2 pref-src="" routing-table=via-ISP2 scope=30 \
    suppress-hw-offload=no target-scope=10
add comment="Redirect via-ISP1 To ISP2" disabled=no distance=2 dst-address=\
    0.0.0.0/0 gateway=pppoe-out2 pref-src="" routing-table=via-ISP1 scope=30 \
    suppress-hw-offload=no target-scope=10
add comment="Redirect via-ISP2 To ISP1" disabled=no distance=2 dst-address=\
    0.0.0.0/0 gateway=pppoe-out1 pref-src="" routing-table=via-ISP2 scope=30 \
    suppress-hw-offload=no target-scope=10
add comment=To-ISP1 disabled=no distance=1 dst-address=0.0.0.0/0 gateway=\
    pppoe-out1 pref-src="" routing-table=main scope=30 suppress-hw-offload=no \
    target-scope=10
add comment=To-ISP2 disabled=no distance=2 dst-address=0.0.0.0/0 gateway=\
    pppoe-out2 pref-src="" routing-table=main scope=30 suppress-hw-offload=no \
    target-scope=10
add comment="Netwatch ISP1 (Quad9 DNS)" disabled=no distance=1 dst-address=\
    9.9.9.9/32 gateway=pppoe-out1 pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=no target-scope=10
add comment="Netwatch ISP2 (Google DNS)" disabled=no distance=1 dst-address=\
    8.8.8.8/32 gateway=pppoe-out2 pref-src="" routing-table=main scope=30 \
    suppress-hw-offload=no target-scope=10
/system identity
set name=R1
/system note
set show-at-login=no
/tool netwatch
add comment=ISP1 disabled=no down-script="ip route disable [find comment=To-IS\
    P1]\r\
    \nip route disable [find comment=via-ISP1_To_ISP1]\r\
    \n:log warning \"ISP1 is down\"\r\
    \n/ip firewall connection remove [find]" host=9.9.9.9 http-codes="" \
    interval=10s test-script="" timeout=800ms type=simple up-script="ip route \
    enable [find comment=To-ISP1]\r\
    \nip route enable [find comment=via-ISP1_To_ISP1]\r\
    \n:log warning \"ISP1 is up\""
add comment=ISP2 disabled=no down-script="ip route disable [find comment=To-IS\
    P2]\r\
    \nip route disable [find comment=via-ISP2_To_ISP2]\r\
    \n:log warning \"ISP1 is down\"\r\
    \n/ip firewall connection remove [find]" host=8.8.8.8 http-codes="" \
    interval=10s test-script="" timeout=800ms type=simple up-script="ip route \
    enable [find comment=To-ISP2]\r\
    \nip route enable [find comment=via-ISP2_To_ISP2]\r\
    \n:log warning \"ISP2 is up\""
