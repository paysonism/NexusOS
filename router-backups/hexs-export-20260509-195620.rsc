# 2026-05-09 19:56:22 by RouterOS 7.18.2
# software id = E2CU-5NFF
#
# model = E60iUGS
# serial number = HJP0ATWP1KX
/interface bridge
add admin-mac=04:F4:1C:29:A8:11 arp=reply-only auto-mac=no comment=defconf \
    dhcp-snooping=yes name=bridge
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/ip firewall layer7-protocol
add name=YouTube-L7 regexp="(youtube\\.com|googlevideo\\.com|ytimg\\.com|youtu\
    \\.be|yt\\.be|ggpht\\.com|youtube-nocookie\\.com|youtubei\\.googleapis\\.c\
    om|youtube\\.googleapis\\.com|gvt1\\.com|gvt2\\.com|yt3\\.ggpht\\.com|vide\
    o\\.google\\.com|music\\.youtube\\.com|tv\\.youtube\\.com)"
add name=Instagram-L7 regexp="(instagram\\.com|cdninstagram\\.com|fbcdn\\.net|\
    graph\\.instagram\\.com|i\\.instagram\\.com|lookaside\\.instagram\\.com|th\
    reads\\.net|l\\.instagram\\.com)"
add name=sky-l7 regexp="(sky\\.(com|co\\.uk|de|it|es)|nowtv\\.com|skygo\\.co\\\
    .uk|skysports\\.com|skynews\\.com|skycinema|sky-cdn|skyott)"
add name=ssh-tunnel-l7 regexp="SSH-[12]\\.[0-9]"
add name=softether-l7 regexp=SEVPN|SE.VPN
add name=openvpn-l7 regexp=AEAD|OpenVPN
add name=trojan-proto regexp="^[0-9a-f]{56}\\x0d\\x0a"
add name=https-connect regexp="^CONNECT [^ ]+ HTTP/1\\.[01]"
add name=non-tls-on-443 regexp="^[^\\x16\\xc0-\\xff]"
add name=sni-microsoft regexp="(microsoft\\.com|outlook\\.com|azure\\.com|live\
    \\.com|windows\\.com|office\\.com|hotmail\\.com|bing\\.com|skype\\.com)"
add name=sni-cloudflare regexp="(cloudflare\\.com|cdn\\.cloudflare\\.net)"
add name=sni-google regexp="(google\\.com|googleapis\\.com|googlevideo\\.com|g\
    static\\.com|youtube\\.com)"
add name=sni-apple regexp="(apple\\.com|icloud\\.com)"
add name=vless-tls-uuid regexp=\
    "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"
add name=reality-handshake regexp=\
    "^\\x16\\x03[\\x01\\x03]..\\x01...\\x03\\x03"
add name=bittorrent regexp="^(\\x13bittorrent protocol|d1:ad2:id20:|GET /scrap\
    e\\\?info_hash=|GET /announce\\\?info_hash=)"
add name=stratum-mining regexp=\
    "\"method\":\\s\?\"mining\\.(subscribe|authorize|submit|notify)\""
add name=ws-suspect-paths regexp="(GET /(ray|v2ray|vmess|vless|trojan|proxy|tu\
    nnel|wss\?|ws|api|gateway|relay|edge|node|conn|link|pipe|stream|sub|cdn|cf\
    |worker)([/\?][^ ]*)\? HTTP/1\\\\.[01]|Upgrade:[ \\\\t]*websocket|Sec-WebS\
    ocket-Key:|workers\\\\.dev|pages\\\\.dev)"
add name=trojan-go regexp="^[0-9a-f]{56}"
add name=doh-sni regexp="(cloudflare-dns\\.com|dns\\.cloudflare\\.com|dns\\.go\
    ogle|dns\\.quad9\\.net|doh\\.opendns\\.com|dns\\.adguard|dns\\.adguard-dns\
    \\.com|dns\\.nextdns\\.io|controld\\.com|dns0\\.eu|mullvad-dns\\.com|dns\\\
    .mullvad\\.net|doh\\.cleanbrowsing\\.org|doh\\.dns\\.sb|dns\\.dnshome\\.de\
    )"
add name=proton-vpn-auth-main regexp=protonvpn
add name=proton-vpn-auth-api regexp=api.protonvpn.ch
add name=proton-vpn-auth-me regexp=vpn-api.proton.me
add name=proton-account-host regexp=account.proton.me
add name=proton-api-host regexp=api.proton.me
/ip pool
add name=default-dhcp ranges=192.168.88.10-192.168.88.254
/ip dhcp-server
add add-arp=yes address-pool=default-dhcp interface=bridge name=defconf
/queue type
add kind=pcq name=pcq-ul-2m pcq-classifier=\
    src-address,dst-address,src-port,dst-port pcq-rate=2M
add kind=pcq name=pcq-dl-2m pcq-classifier=\
    src-address,dst-address,src-port,dst-port pcq-rate=2M
/queue simple
add max-limit=1G/1G name=per-client-2mbps queue=pcq-ul-2m/pcq-dl-2m target=\
    192.168.88.0/24
/system logging action
set 0 memory-lines=5000
/disk settings
set auto-media-interface=bridge auto-media-sharing=yes auto-smb-sharing=yes
/interface bridge filter
add action=drop chain=forward comment=\
    "BRIDGE: Drop rogue DHCP server replies" dst-port=68 ip-protocol=udp log=\
    yes log-prefix=ROGUE-DHCP: mac-protocol=ip src-port=67
add action=accept chain=forward comment="BRIDGE: Allow ARP from desktop" \
    mac-protocol=arp src-mac-address=00:E0:4C:62:04:C2/FF:FF:FF:FF:FF:FF
add action=accept chain=forward comment="BRIDGE: Allow ARP from router" \
    mac-protocol=arp src-mac-address=04:F4:1C:29:A8:11/FF:FF:FF:FF:FF:FF
add action=log chain=forward comment="BRIDGE: Log unknown-source ARP" \
    log-prefix=UNKNOWN-ARP: mac-protocol=arp
add action=drop chain=forward comment="BRIDGE: Anti IP-spoof for desktop" \
    log=yes log-prefix=IPSPOOF: mac-protocol=ip src-address=192.168.88.254/32 \
    src-mac-address=!00:E0:4C:62:04:C2/FF:FF:FF:FF:FF:FF
add action=drop chain=forward comment=\
    "BRIDGE: Drop IPv6 from non-router (anti rogue RA/NDP)" log=yes \
    log-prefix=ROGUE-V6: mac-protocol=ipv6 src-mac-address=\
    !04:F4:1C:29:A8:11/FF:FF:FF:FF:FF:FF
/interface bridge port
add bridge=bridge comment=defconf interface=ether2
add bridge=bridge comment=defconf interface=ether3
add bridge=bridge comment=defconf interface=ether4
add bridge=bridge comment=defconf interface=ether5
add bridge=bridge comment=defconf interface=sfp1
/interface bridge settings
# ipv6 *accept router advertisements* configuration has changed, please restart device to apply settings
set allow-fast-path=no use-ip-firewall=yes use-ip-firewall-for-vlan=yes
/ip neighbor discovery-settings
# ipv6 *accept router advertisements* configuration has changed, please restart device to apply settings
set discover-interface-list=LAN
/ipv6 settings
# ipv6 *accept router advertisements* configuration has changed, please restart device to apply settings
set accept-router-advertisements=no disable-ipv6=yes forward=no
/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=ether1 list=WAN
/ip address
add address=192.168.88.1/24 comment=defconf interface=bridge network=\
    192.168.88.0
/ip arp
add address=192.168.88.254 comment="static: desktop" interface=bridge \
    mac-address=00:E0:4C:62:04:C2
/ip dhcp-client
add comment=defconf interface=ether1
/ip dhcp-server network
add address=192.168.88.0/24 comment=defconf dns-server=192.168.88.1 gateway=\
    192.168.88.1
/ip dns
set allow-remote-requests=yes cache-size=4096KiB servers=1.1.1.1,8.8.8.8
/ip dns static
add address=192.168.88.1 comment=defconf name=router.lan type=A
add name=youtube.com type=NXDOMAIN
add name=*.youtube.com type=NXDOMAIN
add name=googlevideo.com type=NXDOMAIN
add name=*.googlevideo.com type=NXDOMAIN
add name=youtu.be type=NXDOMAIN
add name=ytimg.com type=NXDOMAIN
add name=*.ytimg.com type=NXDOMAIN
add name=yt3.ggpht.com type=NXDOMAIN
add name=instagram.com type=NXDOMAIN
add name=*.instagram.com type=NXDOMAIN
add name=cdninstagram.com type=NXDOMAIN
add name=*.cdninstagram.com type=NXDOMAIN
add address=127.0.0.1 regexp=".*\\.sky\\.com\$" ttl=1m type=A
add address=127.0.0.1 regexp=".*\\.sky\\.co\\.uk\$" ttl=1m type=A
add address=127.0.0.1 regexp=".*\\.nowtv\\.com\$" ttl=1m type=A
add address=127.0.0.1 regexp=".*\\.skygo\\.co\\.uk\$" ttl=1m type=A
add address=127.0.0.1 regexp=".*\\.skysports\\.com\$" ttl=1m type=A
add address=127.0.0.1 regexp=".*\\.skynews\\.com\$" ttl=1m type=A
add address=127.0.0.1 regexp=".*\\.skycinema\\.co\\.uk\$" ttl=1m type=A
add address=127.0.0.1 regexp=".*\\.sky-cdn\\.com\$" ttl=1m type=A
add address=127.0.0.1 regexp=".*\\.skyott\\.com\$" ttl=1m type=A
add name=yt.be type=NXDOMAIN
add name=ggpht.com type=NXDOMAIN
add name=*.ggpht.com type=NXDOMAIN
add name=youtube-nocookie.com type=NXDOMAIN
add name=*.youtube-nocookie.com type=NXDOMAIN
add name=youtubei.googleapis.com type=NXDOMAIN
add name=youtube.googleapis.com type=NXDOMAIN
add name=gvt1.com type=NXDOMAIN
add name=*.gvt1.com type=NXDOMAIN
add name=gvt2.com type=NXDOMAIN
add name=*.gvt2.com type=NXDOMAIN
add name=threads.net type=NXDOMAIN
add name=*.threads.net type=NXDOMAIN
add name=fbcdn.net type=NXDOMAIN
add name=*.fbcdn.net type=NXDOMAIN
add name=hotspotshield.com type=NXDOMAIN
add name=*.hotspotshield.com type=NXDOMAIN
add name=hsssapi.com type=NXDOMAIN
add name=*.hsssapi.com type=NXDOMAIN
add name=anchorfree.com type=NXDOMAIN
add name=*.anchorfree.com type=NXDOMAIN
add name=nortonvpn.com type=NXDOMAIN
add name=*.nortonvpn.com type=NXDOMAIN
add name=protonvpn.com type=NXDOMAIN
add name=*.protonvpn.com type=NXDOMAIN
add name=browsec.com type=NXDOMAIN
add name=*.browsec.com type=NXDOMAIN
add name=zenmate.com type=NXDOMAIN
add name=*.zenmate.com type=NXDOMAIN
add name=tunnelbear.com type=NXDOMAIN
add name=*.tunnelbear.com type=NXDOMAIN
add name=windscribe.com type=NXDOMAIN
add name=*.windscribe.com type=NXDOMAIN
add name=cyberghostvpn.com type=NXDOMAIN
add name=*.cyberghostvpn.com type=NXDOMAIN
add name=ipvanish.com type=NXDOMAIN
add name=*.ipvanish.com type=NXDOMAIN
add name=hidemyass.com type=NXDOMAIN
add name=*.hidemyass.com type=NXDOMAIN
add name=hide.me type=NXDOMAIN
add name=*.hide.me type=NXDOMAIN
add name=opera-proxy.net type=NXDOMAIN
add name=*.opera-proxy.net type=NXDOMAIN
add name=warp.cloudflare.com type=NXDOMAIN
add name=cloudflareclient.com type=NXDOMAIN
add comment="DoH lock" name=cloudflare-dns.com type=NXDOMAIN
add comment="DoH lock" name=dns.cloudflare.com type=NXDOMAIN
add comment="DoH lock" name=dns.google type=NXDOMAIN
add comment="DoH lock" name=dns.quad9.net type=NXDOMAIN
add comment="DoH lock" name=doh.opendns.com type=NXDOMAIN
add comment="DoH lock" name=dns.adguard.com type=NXDOMAIN
add comment="DoH lock" name=dns.adguard-dns.com type=NXDOMAIN
add comment="DoH lock" name=dns.nextdns.io type=NXDOMAIN
add comment="DoH lock" name=doh.controld.com type=NXDOMAIN
add comment="DoH lock" name=dns0.eu type=NXDOMAIN
add comment="DoH lock" name=dns.mullvad.net type=NXDOMAIN
add comment="DoH lock" name=doh.cleanbrowsing.org type=NXDOMAIN
add comment="DoH lock" name=doh.dns.sb type=NXDOMAIN
add comment="DoH lock" name=mozilla.cloudflare-dns.com type=NXDOMAIN
add comment="DoH lock" name=chrome.cloudflare-dns.com type=NXDOMAIN
add address=192.0.2.1 comment="ENF: Proton VPN auth DNS sinkhole" name=\
    protonvpn.com ttl=1h type=A
add address=192.0.2.1 comment="ENF: Proton VPN auth DNS sinkhole" name=\
    www.protonvpn.com ttl=1h type=A
add address=192.0.2.1 comment="ENF: Proton VPN auth DNS sinkhole" name=\
    api.protonvpn.ch ttl=1h type=A
add address=192.0.2.1 comment="ENF: Proton VPN auth DNS sinkhole" name=\
    vpn-api.proton.me ttl=1h type=A
add address=192.0.2.1 comment="ENF: Proton VPN auth DNS sinkhole" name=\
    protonstatus.com ttl=1h type=A
add address=192.0.2.1 comment="ENF: Proton VPN auth DNS sinkhole" name=\
    account.proton.me ttl=1h type=A
add address=192.0.2.1 comment="ENF: Proton VPN auth DNS sinkhole" name=\
    api.proton.me ttl=1h type=A
/ip firewall address-list
add address=sky.com comment=Sky list=block-sky
add address=sky.co.uk list=block-sky
add address=nowtv.com list=block-sky
add address=skygo.co.uk list=block-sky
add address=skysports.com list=block-sky
add address=skynews.com list=block-sky
add address=skycinema.co.uk list=block-sky
add address=skyott.com list=block-sky
add address=sky-cdn.com list=block-sky
add address=193.114.200.0/21 comment="BSkyB ASN5607 range 1" list=block-sky
add address=5.104.64.0/21 comment="BSkyB ASN5607 range 2" list=block-sky
add address=31.205.32.0/19 comment="BSkyB ASN5607 range 3" list=block-sky
add address=74.125.0.0/16 comment="Google/YouTube video" list=block-youtube
add address=173.194.0.0/16 comment=Google/YouTube list=block-youtube
add address=216.58.192.0/19 comment=Google/YouTube list=block-youtube
add address=172.217.0.0/16 comment=Google/YouTube list=block-youtube
add address=142.250.0.0/15 comment=Google/YouTube list=block-youtube
add address=youtube.com list=block-youtube
add address=googlevideo.com list=block-youtube
add address=ytimg.com list=block-youtube
add address=ggpht.com list=block-youtube
add address=gvt1.com list=block-youtube
add address=gvt2.com list=block-youtube
add address=157.240.0.0/16 comment="Meta primary" list=block-instagram
add address=31.13.24.0/21 comment=Meta list=block-instagram
add address=31.13.64.0/18 comment=Meta list=block-instagram
add address=66.220.144.0/20 comment=Meta list=block-instagram
add address=69.63.176.0/20 comment=Meta list=block-instagram
add address=69.171.224.0/19 comment=Meta list=block-instagram
add address=74.119.76.0/22 comment=Meta list=block-instagram
add address=179.60.192.0/22 comment=Meta list=block-instagram
add address=185.60.216.0/22 comment=Meta list=block-instagram
add address=204.15.20.0/22 comment=Meta list=block-instagram
add address=instagram.com list=block-instagram
add address=cdninstagram.com list=block-instagram
add address=fbcdn.net list=block-instagram
add address=threads.net list=block-instagram
add address=193.138.218.0/24 comment=Mullvad list=vpn-providers
add address=185.213.154.0/23 comment=Mullvad list=vpn-providers
add address=146.70.0.0/16 comment=Mullvad list=vpn-providers
add address=185.159.156.0/22 comment=ProtonVPN list=vpn-providers
add address=185.107.56.0/22 comment=ProtonVPN list=vpn-providers
add address=37.19.198.0/23 comment=NordVPN list=vpn-providers
add address=103.86.96.0/22 comment=NordVPN list=vpn-providers
add address=194.165.16.0/23 comment=NordVPN list=vpn-providers
add address=89.187.160.0/19 comment=ExpressVPN list=vpn-providers
add address=217.138.192.0/21 comment=ExpressVPN list=vpn-providers
add address=109.201.133.0/24 comment=ExpressVPN list=vpn-providers
add address=5.180.62.0/23 comment=Surfshark list=vpn-providers
add address=185.230.124.0/22 comment=Surfshark list=vpn-providers
add address=45.87.212.0/22 comment=PIA list=vpn-providers
add address=209.222.0.0/18 comment=PIA list=vpn-providers
add address=5.2.77.0/24 comment=ProtonVPN list=vpn-providers
add address=212.102.50.0/23 comment=ProtonVPN list=vpn-providers
add address=193.19.108.0/24 comment=ProtonVPN list=vpn-providers
add address=185.133.188.0/22 comment=ProtonVPN list=vpn-providers
add address=protonvpn.com comment="ProtonVPN domain" list=vpn-providers
add address=45.57.0.0/17 comment="Hotspot Shield/Norton" list=vpn-providers
add address=72.52.65.0/24 comment="Hotspot Shield" list=vpn-providers
add address=209.197.25.0/24 comment="Hotspot Shield" list=vpn-providers
add address=104.223.64.0/19 comment="Norton/Aura VPN" list=vpn-providers
add address=hotspotshield.com comment="Hotspot Shield" list=vpn-providers
add address=hsssapi.com comment="Hotspot Shield API" list=vpn-providers
add address=anchorfree.com comment="Hotspot Shield/Aura" list=vpn-providers
add address=nortonvpn.com comment="Norton VPN" list=vpn-providers
add address=162.159.192.0/24 comment="Cloudflare WARP" list=vpn-providers
add address=162.159.193.0/24 comment="Cloudflare WARP" list=vpn-providers
add address=162.159.195.0/24 comment="Cloudflare WARP" list=vpn-providers
add address=188.114.96.0/23 comment="Cloudflare WARP" list=vpn-providers
add address=1.1.1.1 comment="Cloudflare DoH" list=block-doh
add address=1.0.0.1 comment="Cloudflare DoH" list=block-doh
add address=8.8.8.8 comment="Google DoH" list=block-doh
add address=8.8.4.4 comment="Google DoH" list=block-doh
add address=9.9.9.9 comment="Quad9 DoH" list=block-doh
add address=149.112.112.112 comment="Quad9 DoH" list=block-doh
add address=45.90.28.0/23 comment="NextDNS DoH" list=block-doh
add address=45.90.30.0/23 comment="NextDNS DoH" list=block-doh
add address=94.140.14.14 comment="AdGuard DoH" list=block-doh
add address=94.140.15.15 comment="AdGuard DoH" list=block-doh
add address=browsec.com comment="Browsec extension" list=vpn-providers
add address=zenmate.com comment="ZenMate extension" list=vpn-providers
add address=tunnelbear.com comment=TunnelBear list=vpn-providers
add address=cyberghostvpn.com comment=CyberGhost list=vpn-providers
add address=ipvanish.com comment=IPVanish list=vpn-providers
add address=hidemyass.com comment=HideMyAss list=vpn-providers
add address=windscribe.com comment=Windscribe list=vpn-providers
add address=hide.me comment="hide.me VPN" list=vpn-providers
add address=opera-proxy.net comment="Opera VPN proxy" list=vpn-providers
add address=13.64.0.0/11 comment=cdn list=sni-legit-microsoft
add address=13.96.0.0/13 comment=cdn list=sni-legit-microsoft
add address=13.104.0.0/14 comment=cdn list=sni-legit-microsoft
add address=20.0.0.0/8 comment=cdn list=sni-legit-microsoft
add address=40.64.0.0/10 comment=cdn list=sni-legit-microsoft
add address=40.74.0.0/15 comment=cdn list=sni-legit-microsoft
add address=40.76.0.0/14 comment=cdn list=sni-legit-microsoft
add address=40.96.0.0/12 comment=cdn list=sni-legit-microsoft
add address=40.112.0.0/13 comment=cdn list=sni-legit-microsoft
add address=40.120.0.0/14 comment=cdn list=sni-legit-microsoft
add address=52.96.0.0/12 comment=cdn list=sni-legit-microsoft
add address=52.112.0.0/14 comment=cdn list=sni-legit-microsoft
add address=52.120.0.0/14 comment=cdn list=sni-legit-microsoft
add address=52.128.0.0/9 comment=cdn list=sni-legit-microsoft
add address=52.224.0.0/11 comment=cdn list=sni-legit-microsoft
add address=104.40.0.0/13 comment=cdn list=sni-legit-microsoft
add address=104.146.0.0/15 comment=cdn list=sni-legit-microsoft
add address=137.116.0.0/15 comment=cdn list=sni-legit-microsoft
add address=157.54.0.0/15 comment=cdn list=sni-legit-microsoft
add address=168.61.0.0/16 comment=cdn list=sni-legit-microsoft
add address=168.62.0.0/15 comment=cdn list=sni-legit-microsoft
add address=103.21.244.0/22 comment=cdn list=sni-legit-cloudflare
add address=103.22.200.0/22 comment=cdn list=sni-legit-cloudflare
add address=103.31.4.0/22 comment=cdn list=sni-legit-cloudflare
add address=104.16.0.0/13 comment=cdn list=sni-legit-cloudflare
add address=104.24.0.0/14 comment=cdn list=sni-legit-cloudflare
add address=108.162.192.0/18 comment=cdn list=sni-legit-cloudflare
add address=131.0.72.0/22 comment=cdn list=sni-legit-cloudflare
add address=141.101.64.0/18 comment=cdn list=sni-legit-cloudflare
add address=162.158.0.0/15 comment=cdn list=sni-legit-cloudflare
add address=172.64.0.0/13 comment=cdn list=sni-legit-cloudflare
add address=173.245.48.0/20 comment=cdn list=sni-legit-cloudflare
add address=188.114.96.0/20 comment=cdn list=sni-legit-cloudflare
add address=190.93.240.0/20 comment=cdn list=sni-legit-cloudflare
add address=197.234.240.0/22 comment=cdn list=sni-legit-cloudflare
add address=198.41.128.0/17 comment=cdn list=sni-legit-cloudflare
add address=8.8.4.0/24 comment=cdn list=sni-legit-google
add address=8.8.8.0/24 comment=cdn list=sni-legit-google
add address=34.0.0.0/9 comment=cdn list=sni-legit-google
add address=34.128.0.0/10 comment=cdn list=sni-legit-google
add address=35.184.0.0/13 comment=cdn list=sni-legit-google
add address=35.192.0.0/14 comment=cdn list=sni-legit-google
add address=64.233.160.0/19 comment=cdn list=sni-legit-google
add address=66.249.64.0/19 comment=cdn list=sni-legit-google
add address=74.125.0.0/16 comment=cdn list=sni-legit-google
add address=104.128.0.0/10 comment=cdn list=sni-legit-google
add address=104.154.0.0/15 comment=cdn list=sni-legit-google
add address=104.196.0.0/14 comment=cdn list=sni-legit-google
add address=108.177.0.0/17 comment=cdn list=sni-legit-google
add address=130.211.0.0/22 comment=cdn list=sni-legit-google
add address=142.250.0.0/15 comment=cdn list=sni-legit-google
add address=172.217.0.0/16 comment=cdn list=sni-legit-google
add address=172.253.0.0/16 comment=cdn list=sni-legit-google
add address=173.194.0.0/16 comment=cdn list=sni-legit-google
add address=192.178.0.0/15 comment=cdn list=sni-legit-google
add address=209.85.128.0/17 comment=cdn list=sni-legit-google
add address=216.239.32.0/19 comment=cdn list=sni-legit-google
add address=17.0.0.0/8 comment=cdn list=sni-legit-apple
add address=3.0.0.0/9 comment=cdn list=sni-legit-amazon
add address=13.32.0.0/12 comment=cdn list=sni-legit-amazon
add address=13.48.0.0/12 comment=cdn list=sni-legit-amazon
add address=13.224.0.0/14 comment=cdn list=sni-legit-amazon
add address=13.248.0.0/14 comment=cdn list=sni-legit-amazon
add address=18.64.0.0/10 comment=cdn list=sni-legit-amazon
add address=52.0.0.0/11 comment=cdn list=sni-legit-amazon
add address=52.84.0.0/15 comment=cdn list=sni-legit-amazon
add address=54.64.0.0/11 comment=cdn list=sni-legit-amazon
add address=54.144.0.0/12 comment=cdn list=sni-legit-amazon
add address=54.176.0.0/12 comment=cdn list=sni-legit-amazon
add address=54.192.0.0/12 comment=cdn list=sni-legit-amazon
add address=99.77.0.0/16 comment=cdn list=sni-legit-amazon
add address=204.246.164.0/22 comment=cdn list=sni-legit-amazon
add address=151.101.0.0/16 comment="Fastly Whitelist (Speedtest)" list=\
    witnessed-dns-ips
add address=8.8.8.8 comment="Google DNS" list=witnessed-dns-ips
add address=23.192.0.0/11 comment="Akamai (Speedtest CDN)" list=\
    witnessed-dns-ips
add address=8.8.8.8 comment="Google DoH" list=doh-servers
add address=1.1.1.1 comment="Cloudflare DoH" list=doh-servers
add address=9.9.9.9 comment="Quad9 DoH" list=doh-servers
add address=172.217.0.0/16 comment="Permanent Whitelist: Google" list=\
    witnessed-dns-ips
add address=142.250.0.0/15 comment="Permanent Whitelist: Google" list=\
    witnessed-dns-ips
add address=104.16.0.0/12 comment="Permanent Whitelist: Cloudflare" list=\
    witnessed-dns-ips
add address=anthropic.com comment="Anthropic whitelist" list=claude-whitelist
add address=api.anthropic.com comment="Anthropic whitelist" list=\
    claude-whitelist
add address=claude.ai comment="Anthropic whitelist" list=claude-whitelist
add address=console.anthropic.com comment="Anthropic whitelist" list=\
    claude-whitelist
add address=statsig.anthropic.com comment="Anthropic whitelist" list=\
    claude-whitelist
add address=sentry.io comment="Anthropic whitelist" list=claude-whitelist
add address=o4505012666007552.ingest.sentry.io comment="Anthropic whitelist" \
    list=claude-whitelist
add address=statsig.com comment="Anthropic whitelist" list=claude-whitelist
add address=featuregates.org comment="Anthropic whitelist" list=\
    claude-whitelist
add address=events.statsigapi.net comment="Anthropic whitelist" list=\
    claude-whitelist
add address=cloudflare.com comment="Anthropic whitelist" list=\
    claude-whitelist
add address=cdn.cloudflare.net comment="Anthropic whitelist" list=\
    claude-whitelist
add address=github.com comment="Anthropic whitelist" list=claude-whitelist
add address=api.github.com comment="Anthropic whitelist" list=\
    claude-whitelist
add address=objects.githubusercontent.com comment="Anthropic whitelist" list=\
    claude-whitelist
add address=raw.githubusercontent.com comment="Anthropic whitelist" list=\
    claude-whitelist
add address=160.79.104.0/23 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=162.159.140.0/24 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=173.245.48.0/20 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=103.21.244.0/22 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=103.22.200.0/22 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=103.31.4.0/22 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=141.101.64.0/18 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=108.162.192.0/18 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=190.93.240.0/20 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=188.114.96.0/20 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=197.234.240.0/22 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=198.41.128.0/17 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=162.158.0.0/15 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=104.16.0.0/13 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=172.64.0.0/13 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=131.0.72.0/22 comment="Cloudflare range (Anthropic frontend)" \
    list=claude-whitelist
add address=194.242.2.2 comment="Mullvad DNS" list=block-doh
add address=194.242.2.3 comment="Mullvad DNS adblock" list=block-doh
add address=194.242.2.4 comment="Mullvad DNS family" list=block-doh
add address=194.242.2.9 comment="Mullvad DNS extended" list=block-doh
add address=76.76.2.0/24 comment=ControlD list=block-doh
add address=76.76.10.0/24 comment=ControlD list=block-doh
add address=193.110.81.0/24 comment=dns0.eu list=block-doh
add address=185.253.5.0/24 comment=dns0.eu list=block-doh
add address=208.67.222.222 comment=OpenDNS list=block-doh
add address=208.67.220.220 comment=OpenDNS list=block-doh
add address=8.26.56.26 comment=Comodo list=block-doh
add address=8.20.247.20 comment=Comodo list=block-doh
add address=185.228.168.0/24 comment=CleanBrowsing list=block-doh
add address=185.228.169.0/24 comment=CleanBrowsing list=block-doh
add address=64.6.64.6 comment=Verisign list=block-doh
add address=64.6.65.6 comment=Verisign list=block-doh
add address=192.178.0.0/15 comment="Google/YouTube observed direct-IP bypass" \
    list=block-youtube
/ip firewall filter
add action=drop chain=forward comment="LOW-TRUST: src penalty 1h" disabled=\
    yes log=yes log-prefix=LOW-TRUST-SRC src-address-list=low-trust
add action=drop chain=forward comment="LOW-TRUST: dst penalty 1h" disabled=\
    yes dst-address-list=low-trust log=yes log-prefix=LOW-TRUST-DST
add action=drop chain=forward comment="ENF: drop traffic to banned dst" \
    disabled=yes dst-address-list=bad-dst log=yes log-prefix=BAD-DST
add action=drop chain=forward comment="ENF: src banned (3+ strikes/5min)" \
    disabled=yes log=yes log-prefix=LOW-TRUST-DROP src-address-list=low-trust
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment="ENF: ban dst on proxy-candidate >500KB" \
    connection-bytes=500000-0 connection-mark=proxy-candidate disabled=yes \
    dst-port=443 log=yes log-prefix=PROXY-MARK-DST protocol=tcp
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment="ENF: ban dst on proxy-suspect-1 >500KB" \
    connection-bytes=500000-0 connection-mark=proxy-suspect-1 disabled=yes \
    dst-port=443 log=yes log-prefix=PROXY-MARK-DST protocol=tcp
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment="ENF: ban dst on proxy-suspect-2 >500KB" \
    connection-bytes=500000-0 connection-mark=proxy-suspect-2 disabled=yes \
    dst-port=443 log=yes log-prefix=PROXY-MARK-DST protocol=tcp
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment="ENF: ban dst on proxy-suspect-3 >500KB" \
    connection-bytes=500000-0 connection-mark=proxy-suspect-3 disabled=yes \
    dst-port=443 log=yes log-prefix=PROXY-MARK-DST protocol=tcp
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment="ENF: ban dst on long-lived >500KB" \
    connection-bytes=500000-0 connection-mark=long-lived disabled=yes \
    dst-port=443 log=yes log-prefix=PROXY-MARK-DST protocol=tcp
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment=\
    "ENF: any TCP/443 >10MB sustained -> ban dst (CF-Workers/WS heuristic)" \
    connection-bytes=10000000-0 connection-state=established disabled=yes \
    dst-port=443 log=yes log-prefix=SUSTAIN-10MB protocol=tcp
add action=accept chain=forward comment=\
    "WHITELIST: Claude/Anthropic outbound" dst-address-list=claude-whitelist
add action=accept chain=forward comment="WHITELIST: Claude/Anthropic inbound" \
    src-address-list=claude-whitelist
add action=reject chain=forward comment=\
    "DROP: Zero-Survival Ghost Tunnel (TCP)" disabled=yes dst-address-list=\
    !witnessed-dns-ips dst-port=443 protocol=tcp reject-with=tcp-reset
add action=drop chain=forward comment=\
    "DROP: Zero-Survival Ghost Tunnel (UDP)" disabled=yes dst-address-list=\
    !witnessed-dns-ips dst-port=443 protocol=udp
add action=drop chain=forward comment="DROP: Detected VPN Tunnels" \
    dst-address-list=vpn-detected
add action=drop chain=forward comment="Block YouTube by IP outbound" \
    dst-address-list=block-youtube log=yes log-prefix="YT-IP-OUT "
add action=drop chain=forward comment="Block YouTube DPI" layer7-protocol=\
    YouTube-L7 log=yes log-prefix="YT-DPI "
add action=drop chain=forward comment="Block YouTube by IP inbound" log=yes \
    log-prefix="YT-IP-IN " src-address-list=block-youtube
add action=drop chain=forward comment="Block Instagram DPI" layer7-protocol=\
    Instagram-L7
add action=drop chain=forward comment="Block YouTube QUIC/HTTP3" \
    dst-address-list=block-youtube dst-port=443 log=yes log-prefix="YT-QUIC " \
    protocol=udp
add action=drop chain=forward comment="Block Instagram by IP outbound" \
    dst-address-list=block-instagram log-prefix=IG-IP:
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="Block Instagram by IP inbound" \
    src-address-list=block-instagram
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=drop chain=forward comment="Block Instagram QUIC/HTTP3" \
    dst-address-list=block-instagram dst-port=443 protocol=udp
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=drop chain=forward comment="Block IKEv1/v2 UDP 500" dst-port=500 \
    protocol=udp
add action=drop chain=input comment="Block YouTube L7 input" layer7-protocol=\
    YouTube-L7
add action=drop chain=forward comment="Block IKE NAT-T UDP 4500" dst-port=\
    4500 protocol=udp
add action=accept chain=input comment=\
    "defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=drop chain=input comment="Block IKE to router" dst-port=500 \
    protocol=udp
add action=drop chain=input comment="Block Instagram L7 input" \
    layer7-protocol=Instagram-L7
add action=drop chain=input comment="Block IKE NAT-T to router" dst-port=4500 \
    protocol=udp
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    in-interface-list=!LAN
add action=drop chain=forward comment="Block Sky IP outbound (pre-fasttrack)" \
    disabled=yes dst-address-list=block-sky
add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    ipsec-policy=in,ipsec
add action=drop chain=forward comment="Block Sky IP inbound (pre-fasttrack)" \
    disabled=yes src-address-list=block-sky
add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    ipsec-policy=out,ipsec
add action=drop chain=forward comment="Block Sky QUIC pre-fasttrack" \
    disabled=yes dst-address-list=block-sky dst-port=443 protocol=udp
add action=fasttrack-connection chain=forward comment=\
    "SMART Fasttrack: Only Offload Witnessed traffic" connection-state=\
    established,related disabled=yes dst-address-list="" hw-offload=yes
add action=fasttrack-connection chain=forward comment=\
    "SMART Fasttrack: Only Offload Witnessed traffic" connection-bytes=\
    20000-0 connection-mark=!proxy-candidate connection-state=\
    established,related disabled=yes dst-address-list="" hw-offload=yes
add action=reject chain=forward comment=\
    "ENF: reject Proton VPN auth/control SNI" dst-port=443 layer7-protocol=\
    proton-vpn-auth-main log=yes log-prefix=PROTON-AUTH-SNI protocol=tcp \
    reject-with=tcp-reset src-address=192.168.88.0/24
add action=reject chain=forward comment="ENF: reject Proton VPN API SNI" \
    dst-port=443 layer7-protocol=proton-vpn-auth-api log=yes log-prefix=\
    PROTON-AUTH-API protocol=tcp reject-with=tcp-reset src-address=\
    192.168.88.0/24
add action=reject chain=forward comment="ENF: reject Proton VPN vpn-api SNI" \
    dst-port=443 layer7-protocol=proton-vpn-auth-me log=yes log-prefix=\
    PROTON-AUTH-ME protocol=tcp reject-with=tcp-reset src-address=\
    192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF: reject Proton VPN auth/control HTTP host" dst-port=80 \
    layer7-protocol=proton-vpn-auth-main log=yes log-prefix=PROTON-AUTH-HTTP \
    protocol=tcp reject-with=tcp-reset src-address=192.168.88.0/24
add action=reject chain=forward comment="ENF: reject Proton account auth SNI" \
    dst-port=443 layer7-protocol=proton-account-host log=yes log-prefix=\
    PROTON-ACCOUNT protocol=tcp reject-with=tcp-reset src-address=\
    192.168.88.0/24
add action=reject chain=forward comment="ENF: reject Proton API auth SNI" \
    dst-port=443 layer7-protocol=proton-api-host log=yes log-prefix=\
    PROTON-API protocol=tcp reject-with=tcp-reset src-address=192.168.88.0/24
add action=jump chain=forward comment="VERDICT: new TCP/443 from LAN" \
    connection-state=new dst-port=443 in-interface-list=LAN jump-target=\
    trust-verdict protocol=tcp
add action=jump chain=forward comment="VERDICT: new UDP/443 from LAN" \
    connection-state=new dst-port=443 in-interface-list=LAN jump-target=\
    trust-verdict protocol=udp
add action=jump chain=forward comment="VERDICT-WIDE: new TCP from LAN" \
    connection-state=new dst-address=!192.168.0.0/16 in-interface-list=LAN \
    jump-target=trust-verdict protocol=tcp
add action=jump chain=forward comment=\
    "VERDICT-WIDE: new UDP from LAN (excl DNS/NTP/mDNS/DHCP)" \
    connection-state=new dst-address=!192.168.0.0/16 dst-port=\
    !53,123,5353,67,68 in-interface-list=LAN jump-target=trust-verdict \
    protocol=udp
add action=reject chain=forward comment=\
    "ENF: reject plaintext WebSocket proxy/VPN handshake" layer7-protocol=\
    ws-suspect-paths log=yes log-prefix=WS-REJECT protocol=tcp reject-with=\
    tcp-reset src-address=192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF: kill behavior-marked WS/TLS tunnel" connection-bytes=500000-0 \
    connection-mark=proxy-suspect-2 dst-port=443 log=yes log-prefix=\
    WS-TUNNEL-KILL protocol=tcp reject-with=tcp-reset src-address=\
    192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF: kill high-confidence WS/TLS tunnel" connection-bytes=500000-0 \
    connection-mark=proxy-suspect-3 dst-port=443 log=yes log-prefix=\
    WS-TUNNEL-KILL protocol=tcp reject-with=tcp-reset src-address=\
    192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF: kill sustained single TCP/443 tunnel" connection-bytes=20000000-0 \
    connection-state=established dst-port=443 log=yes log-prefix=SUSTAIN-KILL \
    protocol=tcp reject-with=tcp-reset src-address=192.168.88.0/24
add action=reject chain=forward comment="ENF: block WS VPN alt TCP port 4472" \
    dst-port=4472 log=yes log-prefix=WS-4472-KILL protocol=tcp reject-with=\
    tcp-reset src-address=192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF: reject new/active proxy-suspect-2 TCP443 tunnel" connection-mark=\
    proxy-suspect-2 disabled=yes dst-port=443 log=yes log-prefix=\
    PROXY-S2-KILL protocol=tcp reject-with=tcp-reset src-address=\
    192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF: reject new/active proxy-suspect-3 TCP443 tunnel" connection-mark=\
    proxy-suspect-3 disabled=yes dst-port=443 log=yes log-prefix=\
    PROXY-S3-KILL protocol=tcp reject-with=tcp-reset src-address=\
    192.168.88.0/24
add action=reject chain=forward comment="ENF: block WS VPN alt TCP port 4458" \
    dst-port=4458 log=yes log-prefix=WS-4458-KILL protocol=tcp reject-with=\
    tcp-reset src-address=192.168.88.0/24
add action=accept chain=forward comment=\
    "ENF2: allow Steam/Valve before suspect kill" dst-address-list=\
    steam-valve-whitelist dst-port=443,27015-27050 protocol=tcp src-address=\
    192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF2: reject non-TLS proxy payload on TCP443" dst-port=443 \
    layer7-protocol=non-tls-on-443 log=yes log-prefix=ENF2-NON-TLS protocol=\
    tcp reject-with=tcp-reset src-address=192.168.88.0/24
add action=accept chain=forward comment=\
    "ENF3: allow backend-validated normal HTTPS" disabled=yes \
    dst-address-list=web-validated dst-port=443 protocol=tcp src-address=\
    192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF2: kill proxy-suspect-2 TCP443 immediately" connection-mark=\
    proxy-suspect-2 dst-port=443 log=yes log-prefix=ENF2-S2-KILL protocol=tcp \
    reject-with=tcp-reset src-address=192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF2: kill proxy-suspect-3 TCP443 immediately" connection-mark=\
    proxy-suspect-3 dst-port=443 log=yes log-prefix=ENF2-S3-KILL protocol=tcp \
    reject-with=tcp-reset src-address=192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF2: block Xray proxy TCP ports 8080/8443" dst-port=8080,8443 log=yes \
    log-prefix=ENF2-X-TCP1 protocol=tcp reject-with=tcp-reset src-address=\
    192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF2: block Xray Cloudflare TLS alt TCP ports" dst-port=2083,2087,2096 \
    log=yes log-prefix=ENF2-X-TCP2 protocol=tcp reject-with=tcp-reset \
    src-address=192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF2: block Xray Cloudflare extra TCP ports" dst-port=\
    2052,2053,2082,2086,2095 log=yes log-prefix=ENF2-X-TCP3 protocol=tcp \
    reject-with=tcp-reset src-address=192.168.88.0/24
add action=drop chain=forward comment=\
    "ENF2: block Hysteria/Xray UDP 443/4443/8443" dst-port=443,4443,8443 log=\
    yes log-prefix=ENF2-HY2-U1 protocol=udp src-address=192.168.88.0/24
add action=drop chain=forward comment=\
    "ENF2: block Hysteria/Xray Cloudflare UDP ports" dst-port=\
    2053,2083,2087,2096 log=yes log-prefix=ENF2-HY2-U2 protocol=udp \
    src-address=192.168.88.0/24
add action=drop chain=forward comment=\
    "ENF2: block Shadowsocks common TCP ports" dst-port=8388,8389,8380 log=\
    yes log-prefix=ENF2-SS-TCP protocol=tcp src-address=192.168.88.0/24
add action=drop chain=forward comment=\
    "ENF2: block Shadowsocks common UDP ports" dst-port=8388,8389,8380 log=\
    yes log-prefix=ENF2-SS-UDP protocol=udp src-address=192.168.88.0/24
add action=reject chain=forward comment=\
    "ENF2: reject Xray VMess VLESS WebSocket handshakes" layer7-protocol=\
    ws-suspect-paths log=yes log-prefix=ENF2-WS protocol=tcp reject-with=\
    tcp-reset src-address=192.168.88.0/24
add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment="PROTO: Block IPIP tunnel" log=yes \
    log-prefix=IPIP: protocol=ipencap
add action=drop chain=forward comment="PROTO: Block 6in4" log=yes log-prefix=\
    6IN4: protocol=ipv6-encap
add action=drop chain=forward comment="PROTO: Block Teredo IPv6 tunnel" \
    dst-port=3544 log=yes log-prefix=TEREDO: protocol=udp
add action=drop chain=forward comment="PROTO: Block SCTP" log=yes log-prefix=\
    SCTP: protocol=sctp
add action=drop chain=forward comment="PROTO: Block DCCP" log=yes log-prefix=\
    DCCP: protocol=dccp
add action=drop chain=forward comment="PROTO: Block EGP" protocol=egp
add action=drop chain=forward comment="PROTO: Block OSPF transit" protocol=\
    ospf
add action=drop chain=forward comment="PROTO: Block PIM" protocol=pim
add action=drop chain=forward comment="PROTO: Block VRRP" protocol=vrrp
add action=drop chain=forward comment="PROTO: Block ETHERIP" protocol=etherip
add action=drop chain=forward comment="PROTO: Block DoQ DNS-over-QUIC" \
    dst-port=784,8853 log=yes log-prefix=DOQ: protocol=udp
add action=drop chain=forward comment="PROTO: Block external mDNS" dst-port=\
    5353 protocol=udp src-address=!192.168.88.0/24
add action=add-dst-to-address-list address-list=reality-suspect \
    address-list-timeout=1h chain=forward comment=\
    "DETECT: TLS-in-TLS XRAY pattern" connection-bytes=500-2000 dst-port=443 \
    layer7-protocol=reality-handshake log=yes log-prefix=TLS-IN-TLS: \
    protocol=tcp
add action=drop chain=forward comment="DROP: confirmed XRAY/Reality dst" \
    dst-address-list=reality-suspect log=yes log-prefix=REALITY-CONFIRMED:
add action=add-dst-to-address-list address-list=udp-tunnel-suspect \
    address-list-timeout=30m chain=forward comment=\
    "DETECT: Sustained UDP high port (XRAY/Hysteria)" connection-bytes=\
    500000-0 connection-state=established dst-port=1024-52999 log=yes \
    log-prefix=UDP-HP protocol=udp
add action=add-dst-to-address-list address-list=udp-tunnel-suspect \
    address-list-timeout=30m chain=forward connection-bytes=500000-0 \
    connection-state=established dst-port=53001-65535 log=yes log-prefix=\
    UDP-HP2 protocol=udp
add action=add-src-to-address-list address-list=p2p-users \
    address-list-timeout=1d chain=forward comment=\
    "DETECT: BitTorrent activity" layer7-protocol=bittorrent log=yes \
    log-prefix=BT:
add action=add-src-to-address-list address-list=p2p-users \
    address-list-timeout=1d chain=forward comment="DETECT: BT default ports" \
    dst-port=6881-6889 protocol=tcp
add action=drop chain=forward comment="BLOCK: Cryptomining stratum" \
    layer7-protocol=stratum-mining log=yes log-prefix=MINER:
add action=add-dst-to-address-list address-list=mining-pools \
    address-list-timeout=1w chain=forward comment=\
    "DETECT: stratum-typical ports" dst-port=\
    3333,4444,7777,8888,14444,9999,1314 log=yes log-prefix=MINER-PORT: \
    protocol=tcp
add action=drop chain=forward comment=\
    "BLOCK: Direct SMTP25 outbound (spam/exfil)" dst-port=25 log=yes \
    log-prefix=SMTP25: protocol=tcp src-address=192.168.88.0/24
add action=add-dst-to-address-list address-list=sip-endpoints \
    address-list-timeout=1d chain=forward comment="MONITOR: SIP" dst-port=\
    5060,5061 protocol=udp
add action=add-src-to-address-list address-list=irc-users \
    address-list-timeout=1d chain=forward comment="MONITOR: IRC" dst-port=\
    6660-6669,6697,7000 log=yes log-prefix=IRC: protocol=tcp
add action=drop chain=forward comment="BLOCK: Telnet outbound" dst-port=23 \
    log=yes log-prefix=TELNET: protocol=tcp src-address=192.168.88.0/24
add action=add-dst-to-address-list address-list=rdp-targets \
    address-list-timeout=1d chain=forward comment="MONITOR: RDP outbound" \
    dst-port=3389 log=yes log-prefix=RDP: protocol=tcp src-address=\
    192.168.88.0/24
add action=drop chain=forward comment="BLOCK: SMB outbound (NTLM-relay risk)" \
    dst-port=445,139 log=yes log-prefix=SMB: protocol=tcp src-address=\
    192.168.88.0/24
add action=add-dst-to-address-list address-list=inv-web-http \
    address-list-timeout=6h chain=forward comment="INV: web-http" dst-port=80 \
    protocol=tcp src-address=192.168.88.0/24
add action=add-dst-to-address-list address-list=inv-web-https \
    address-list-timeout=6h chain=forward comment="INV: web-https" dst-port=\
    443 protocol=tcp src-address=192.168.88.0/24
add action=add-dst-to-address-list address-list=inv-web-quic \
    address-list-timeout=6h chain=forward comment="INV: web-quic" dst-port=\
    443 protocol=udp src-address=192.168.88.0/24
add action=add-dst-to-address-list address-list=inv-ssh-out \
    address-list-timeout=6h chain=forward comment="INV: ssh-out" dst-port=22 \
    protocol=tcp src-address=192.168.88.0/24
add action=add-dst-to-address-list address-list=inv-proxy \
    address-list-timeout=6h chain=forward comment="INV: proxy" dst-port=8080 \
    protocol=tcp src-address=192.168.88.0/24
add action=add-dst-to-address-list address-list=inv-alt-https \
    address-list-timeout=6h chain=forward comment="INV: alt-https" dst-port=\
    8443 protocol=tcp src-address=192.168.88.0/24
add action=add-dst-to-address-list address-list=inv-ntp address-list-timeout=\
    6h chain=forward comment="INV: ntp" dst-port=123 protocol=udp \
    src-address=192.168.88.0/24
add action=add-dst-to-address-list address-list=inv-smtp-sub \
    address-list-timeout=6h chain=forward comment="INV: smtp-sub" dst-port=\
    587 protocol=tcp src-address=192.168.88.0/24
add action=add-dst-to-address-list address-list=inv-smtp-tls \
    address-list-timeout=6h chain=forward comment="INV: smtp-tls" dst-port=\
    465 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=input comment="ICMP: drop timestamp request (recon)" \
    icmp-options=13:0 protocol=icmp
add action=drop chain=input comment="ICMP: drop address-mask request (recon)" \
    icmp-options=17:0 protocol=icmp
add action=drop chain=forward comment="ICMP: drop redirect (MITM vector)" \
    icmp-options=5:0-3 log=yes log-prefix=ICMP-REDIR: protocol=icmp
add action=add-dst-to-address-list address-list=reality-suspect \
    address-list-timeout=6h chain=forward comment=\
    "DETECT: XRAY/proxy WebSocket paths" layer7-protocol=ws-suspect-paths \
    log=yes log-prefix=WS-XRAY: protocol=tcp
add action=drop chain=forward comment=\
    "DNS-LOCK: drop any UDP/53 not to router" dst-address=!192.168.88.1 \
    dst-port=53 log=yes log-prefix=DNS-BYPASS: protocol=udp src-address=\
    192.168.88.0/24
add action=reject chain=forward comment=\
    "DNS-LOCK: RST any TCP/53 not to router" dst-address=!192.168.88.1 \
    dst-port=53 log=yes log-prefix=DNS-BYPASS-TCP: protocol=tcp reject-with=\
    tcp-reset src-address=192.168.88.0/24
add action=reject chain=forward comment="DNS-LOCK: RST DoH SNI handshake" \
    dst-port=443 layer7-protocol=doh-sni log=yes log-prefix=DOH-SNI: \
    protocol=tcp reject-with=tcp-reset
add action=drop chain=forward comment=\
    "defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN
add action=drop chain=forward comment="Block Sky L7/DPI all-packets" \
    disabled=yes layer7-protocol=sky-l7 log-prefix=SKY-DPI:
add action=drop chain=input comment="Block Sky L7 input all-packets" \
    disabled=yes layer7-protocol=sky-l7
add action=drop chain=forward comment="Block Sky by IP outbound" disabled=yes \
    dst-address-list=block-sky log-prefix=SKY-IP:
add action=drop chain=forward comment="Block Sky by IP inbound" disabled=yes \
    src-address-list=block-sky
add action=drop chain=forward comment="Block Sky Go TCP 4740" disabled=yes \
    dst-port=4740 protocol=tcp
add action=drop chain=forward comment="Block Sky Go UDP 4740" disabled=yes \
    dst-port=4740 protocol=udp
add action=drop chain=forward comment="Block Sky QUIC/HTTP3" disabled=yes \
    dst-address-list=block-sky dst-port=443 protocol=udp
add action=drop chain=forward comment="DROP: Live VPN blocklist" \
    dst-address-list=vpn-detected log=yes log-prefix=VPN-LIVE-DROP
add action=drop chain=forward comment="DROP: Live VPN blocklist inbound" \
    src-address-list=vpn-detected
add action=drop chain=forward comment="Block VPN provider IPs" disabled=yes \
    dst-address-list=vpn-providers log=yes log-prefix=VPN-PROVIDER
add action=drop chain=forward comment="Block VPN provider IPs inbound" \
    disabled=yes src-address-list=vpn-providers
add action=accept chain=forward comment=\
    "Eero - block WireGuard detect from tagging Eero IP" dst-address=\
    192.168.88.254
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment=\
    "DETECT WireGuard UDP 51820" dst-port=51820 log=yes log-prefix=WG-PORT \
    protocol=udp
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment="DETECT WireGuard return" \
    log=yes log-prefix=WG-RET protocol=udp src-port=51820
add action=drop chain=forward comment="Block WireGuard alt ports" dst-port=\
    51821-51830 protocol=udp
add action=drop chain=forward comment="Block WireGuard Mullvad 13231" \
    dst-port=13231 protocol=udp
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment=\
    "DETECT WireGuard handshake init 176b" log=yes log-prefix=WG-INIT \
    packet-size=176 protocol=udp
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment=\
    "DETECT WireGuard handshake resp 120b" log=yes log-prefix=WG-RESP \
    packet-size=120 protocol=udp
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment=\
    "DETECT WireGuard cookie 92b" log=yes log-prefix=WG-COOKIE packet-size=92 \
    protocol=udp
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment="DETECT OpenVPN UDP 1194" \
    dst-port=1194 log=yes log-prefix=OVPN-UDP protocol=udp
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment="DETECT OpenVPN TCP 1194" \
    dst-port=1194 log=yes log-prefix=OVPN-TCP protocol=tcp
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment="DETECT OpenVPN L7" \
    layer7-protocol=openvpn-l7 log=yes log-prefix=OVPN-L7
add action=drop chain=forward comment="Block IPsec ESP proto 50" protocol=\
    ipsec-esp
add action=drop chain=forward comment="Block IPsec AH proto 51" protocol=\
    ipsec-ah
add action=drop chain=forward comment="Block PPTP TCP 1723" dst-port=1723 \
    protocol=tcp
add action=drop chain=forward comment="Block GRE tunnels" protocol=gre
add action=drop chain=forward comment="Block L2TP UDP 1701" dst-port=1701 \
    protocol=udp
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment=\
    "DETECT SSH tunnel any port" layer7-protocol=ssh-tunnel-l7 log=yes \
    log-prefix=SSH-DETECT
add action=drop chain=forward comment="Block SSH" dst-port=22 protocol=tcp
add action=drop chain=input comment="Block SSH L7 to router" layer7-protocol=\
    ssh-tunnel-l7
add action=drop chain=forward comment="Block SoftEther 5555" dst-port=5555 \
    protocol=tcp
add action=drop chain=forward comment="Block SoftEther 992" dst-port=992 \
    protocol=tcp
add action=drop chain=forward comment="Block SoftEther L7" layer7-protocol=\
    softether-l7
add action=drop chain=forward comment="Block Tor 9001" dst-port=9001 \
    protocol=tcp
add action=drop chain=forward comment="Block Tor 9030" dst-port=9030 \
    protocol=tcp
add action=drop chain=forward comment="Block Tor 9050" dst-port=9050 \
    protocol=tcp
add action=drop chain=forward comment="Block Tor 9051" dst-port=9051 \
    protocol=tcp
add action=drop chain=forward comment="Block Shadowsocks TCP 8388" dst-port=\
    8388 protocol=tcp
add action=drop chain=forward comment="Block Shadowsocks UDP 8388" dst-port=\
    8388 protocol=udp
add action=drop chain=forward comment="Block Cloudflare WARP UDP 2408" \
    dst-port=2408 protocol=udp
add action=drop chain=forward comment="Block Cloudflare WARP UDP 2408 return" \
    protocol=udp src-port=2408
add action=drop chain=forward comment="Block Cloudflare WARP TCP 2408" \
    dst-port=2408 protocol=tcp
add action=reject chain=forward comment=\
    "Block DoH TCP 443 to known resolvers" disabled=yes dst-address-list=\
    block-doh dst-port=443 log=yes log-prefix=DOH-BLOCK protocol=tcp \
    reject-with=tcp-reset
add action=drop chain=forward comment=\
    "Block DoH UDP 443 (QUIC) to known resolvers" disabled=yes \
    dst-address-list=block-doh dst-port=443 protocol=udp
add action=drop chain=forward comment="Block DNS-over-TLS port 853 globally" \
    dst-port=853 protocol=tcp
add action=drop chain=forward comment="Block DNS-over-TLS UDP 853" dst-port=\
    853 protocol=udp
add action=drop chain=forward comment=\
    "Block QUIC UDP 443 globally (VPN bypass prevention)" disabled=yes \
    dst-port=443 log-prefix=QUIC-GLOBAL: protocol=udp
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment="DETECT: Trojan protocol" \
    dst-port=443,80,8443 layer7-protocol=trojan-proto log=yes log-prefix=\
    TROJAN protocol=tcp
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment=\
    "DETECT: HTTPS CONNECT tunnel NaiveProxy" layer7-protocol=https-connect \
    log=yes log-prefix=NAIVEPROXY
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment=\
    "DETECT: Non-TLS on TCP/443 Shadowsocks" dst-port=443 layer7-protocol=\
    non-tls-on-443 log=yes log-prefix=NON-TLS-443 protocol=tcp
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment=\
    "DETECT: Hysteria2 custom UDP sustained >1MB" connection-bytes=1000000-0 \
    dst-port=!53,123,500,4500,5353,1900 log=yes log-prefix=HYSTERIA2 \
    protocol=udp
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment=\
    "PENALTY: DETECT: SNI=Microsoft to non-MS IP (Reality/XRAY)" \
    dst-address-list=!sni-legit-microsoft dst-port=443 layer7-protocol=\
    sni-microsoft log=yes log-prefix=SNI-VIOLATION protocol=tcp
add action=drop chain=forward comment=\
    "DETECT: SNI=Microsoft to non-MS IP (Reality/XRAY)" dst-address-list=\
    !sni-legit-microsoft dst-port=443 layer7-protocol=sni-microsoft log=yes \
    log-prefix=REALITY-DROP: protocol=tcp
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment=\
    "PENALTY: DETECT: SNI=Cloudflare to non-CF IP (Reality/XRAY)" \
    dst-address-list=!sni-legit-cloudflare dst-port=443 layer7-protocol=\
    sni-cloudflare log=yes log-prefix=SNI-VIOLATION protocol=tcp
add action=drop chain=forward comment=\
    "DETECT: SNI=Cloudflare to non-CF IP (Reality/XRAY)" dst-address-list=\
    !sni-legit-cloudflare dst-port=443 layer7-protocol=sni-cloudflare log=yes \
    log-prefix=REALITY-DROP: protocol=tcp
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment=\
    "PENALTY: DETECT: SNI=Google to non-Google IP (Reality/XRAY)" \
    dst-address-list=!sni-legit-google dst-port=443 layer7-protocol=\
    sni-google log=yes log-prefix=SNI-VIOLATION protocol=tcp
add action=drop chain=forward comment=\
    "DETECT: SNI=Google to non-Google IP (Reality/XRAY)" dst-address-list=\
    !sni-legit-google dst-port=443 layer7-protocol=sni-google log=yes \
    log-prefix=REALITY-DROP: protocol=tcp
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment=\
    "PENALTY: DETECT: SNI=Apple to non-Apple IP (Reality/XRAY)" \
    dst-address-list=!sni-legit-apple dst-port=443 layer7-protocol=sni-apple \
    log=yes log-prefix=SNI-VIOLATION protocol=tcp
add action=drop chain=forward comment=\
    "DETECT: SNI=Apple to non-Apple IP (Reality/XRAY)" dst-address-list=\
    !sni-legit-apple dst-port=443 layer7-protocol=sni-apple log=yes \
    log-prefix=REALITY-DROP: protocol=tcp
add action=drop chain=forward comment=\
    "DROP: Xray/VLESS TLS Fragmentation bypass" connection-bytes=0-1000 \
    dst-port=443 packet-size=0-200 protocol=tcp tcp-flags=psh,ack
add action=jump chain=forward comment=\
    "JUMP: Check for sustained TCP proxy tunnel" connection-bytes=5000000-0 \
    connection-mark=long-lived dst-port=443 jump-target=tls-tunnel-check \
    protocol=tcp
add action=accept chain=tls-tunnel-check dst-address-list=sni-legit-microsoft
add action=accept chain=tls-tunnel-check dst-address-list=\
    sni-legit-cloudflare
add action=accept chain=tls-tunnel-check dst-address-list=sni-legit-google
add action=accept chain=tls-tunnel-check dst-address-list=sni-legit-apple
add action=accept chain=tls-tunnel-check dst-address-list=sni-legit-amazon
add action=add-src-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=tls-tunnel-check comment=\
    "DETECT: Anti-Reality/Stealth" log-prefix=REALITY-DETECT:
add action=add-dst-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=tls-tunnel-check comment=\
    "DETECT: Anti-Reality/Stealth DST"
add action=drop chain=tls-tunnel-check
add action=add-src-to-address-list address-list=vpn-detected \
    address-list-timeout=1d chain=forward comment=\
    "DETECT: Sustained proxy protocol tunnel" connection-bytes=2000000-0 \
    connection-mark=proxy-candidate dst-port=443 log=yes log-prefix=\
    ANTI-VPN-DROP protocol=tcp
add action=add-src-to-address-list address-list=vpn-detected \
    address-list-timeout=1h chain=forward comment=\
    "DETECT: Ghost TCP Proxy (No DNS See)" connection-bytes=1000000-0 \
    disabled=yes dst-address-list=!witnessed-dns-ips dst-port=443 protocol=\
    tcp
add action=add-src-to-address-list address-list=vpn-detected \
    address-list-timeout=1h chain=forward comment=\
    "DETECT: Ghost UDP Proxy (No DNS See)" connection-bytes=100000-0 \
    disabled=yes dst-address-list=!witnessed-dns-ips dst-port=443 protocol=\
    udp
add action=return chain=trust-verdict comment="TRUST: DNS witnessed" \
    dst-address-list=dns-witnessed
add action=return chain=trust-verdict comment="TRUST: multi-client" \
    dst-address-list=multi-client-trusted
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment="PENALTY: WS-tunnel paths/Upgrade hdr" disabled=\
    yes layer7-protocol=ws-suspect-paths log=yes log-prefix=WS-VPN-PENALTY \
    protocol=tcp
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=forward comment=\
    "PENALTY: sustained single TLS flow >20MB (CF-Workers/WS VPN heuristic)" \
    connection-bytes=5000000-0 connection-state=established disabled=yes \
    dst-port=443 log=yes log-prefix=TUNNEL-SHAPE-DST protocol=tcp
add action=add-src-to-address-list address-list=low-trust \
    address-list-timeout=1h chain=forward comment=\
    "PENALTY: src talked to vpn-detected dst" disabled=yes dst-address-list=\
    vpn-detected log=yes log-prefix=VPN-PENALTY-SRC
add action=add-dst-to-address-list address-list=bad-dst address-list-timeout=\
    1h chain=trust-verdict comment="ENF: ban ghost dst 1h" disabled=yes log=\
    yes log-prefix=GHOST-BAN-DST
add action=add-src-to-address-list address-list=ghost-strikes \
    address-list-timeout=5m chain=trust-verdict comment=\
    "ENF: count strikes per src" log-prefix=GHOST-STRIKE
add action=drop chain=trust-verdict comment="ENF: drop ghost connection" \
    disabled=yes log=yes log-prefix=GHOST-DROP
/ip firewall mangle
add action=accept chain=forward comment="WHITELIST: skip mangle for Claude" \
    dst-address-list=claude-whitelist
add action=add-dst-to-address-list address-list=icmp-seen \
    address-list-timeout=10m chain=prerouting comment=\
    "ICMP-RECON: capture true target" dst-address=!192.168.88.0/24 \
    icmp-options=8:0 protocol=icmp src-address=192.168.88.0/24
add action=mark-connection chain=forward comment=\
    "MANGLE: Mark new LAN connections" connection-state=new \
    new-connection-mark=lan-new src-address=192.168.88.0/24
add action=mark-connection chain=forward comment=\
    "MANGLE: Tag long-lived high-data" connection-bytes=1000000-0 \
    connection-mark=lan-new connection-state=established new-connection-mark=\
    long-lived
add action=mark-connection chain=forward comment="MANGLE: Tag outbound UDP" \
    connection-state=new new-connection-mark=udp-suspect protocol=udp \
    src-address=192.168.88.0/24
add action=mark-connection chain=forward comment=\
    "MANGLE: Track TLS connections" connection-state=new dst-port=443 \
    new-connection-mark=tls-track protocol=tcp src-address=192.168.88.0/24
add action=mark-connection chain=forward comment=\
    "MANGLE: Tag high-throughput >10MB" connection-bytes=10000000-0 \
    connection-state=established new-connection-mark=high-throughput \
    src-address=192.168.88.0/24
add action=mark-packet chain=forward comment=\
    "MANGLE: Mark VPN-detected packets" new-packet-mark=vpn-flagged \
    src-address-list=vpn-detected
add action=add-src-to-address-list address-list=conn-rate-track \
    address-list-timeout=1m chain=forward comment=\
    "MANGLE: Track connection rate" connection-state=new src-address=\
    192.168.88.0/24
add action=add-dst-to-address-list address-list=tls-new-ips \
    address-list-timeout=1m chain=forward comment=\
    "DETECT: Track recent TLS target" connection-state=new dst-port=443 \
    protocol=tcp src-address=192.168.88.0/24
add action=mark-connection chain=forward connection-state=new \
    dst-address-list=!sni-legit-microsoft dst-port=443 new-connection-mark=\
    proxy-candidate-1 protocol=tcp
add action=mark-connection chain=forward connection-mark=proxy-candidate-1 \
    dst-address-list=!sni-legit-cloudflare new-connection-mark=\
    proxy-candidate-2
add action=mark-connection chain=forward connection-mark=proxy-candidate-2 \
    dst-address-list=!sni-legit-google new-connection-mark=proxy-candidate-3
add action=mark-connection chain=forward connection-mark=proxy-candidate-3 \
    dst-address-list=!sni-legit-apple new-connection-mark=proxy-candidate
add action=mark-connection chain=forward comment="PROXY_SUSPECT: Step 1" \
    connection-state=new dst-address-list=!sni-legit-google dst-port=443 \
    new-connection-mark=proxy-suspect-1 protocol=tcp
add action=mark-connection chain=forward connection-mark=proxy-suspect-1 \
    dst-address-list=!sni-legit-microsoft new-connection-mark=proxy-suspect-2
/ip firewall nat
add action=redirect chain=dstnat comment="MITM: Force Local DNS (Internal)" \
    disabled=yes dst-port=53 protocol=udp to-ports=53
add action=masquerade chain=srcnat comment="NAT: Masquerade WAN" \
    ipsec-policy=out,none out-interface-list=WAN
add action=dst-nat chain=dstnat comment="NAT: ICMP middleman" dst-address=\
    !192.168.88.0/24 dst-address-list=!icmp-allowed icmp-options=8:0 \
    protocol=icmp src-address=192.168.88.0/24 to-addresses=192.168.88.1
add action=redirect chain=dstnat comment="NAT: Force DNS UDP" dst-port=53 \
    protocol=udp src-address=192.168.88.0/24 to-ports=53
add action=redirect chain=dstnat comment="NAT: Force DNS TCP" dst-port=53 \
    protocol=tcp src-address=192.168.88.0/24 to-ports=53
/ip firewall raw
add action=drop chain=prerouting comment="RAW: Drop XMAS packets" log=yes \
    log-prefix=RAW-XMAS: protocol=tcp tcp-flags=fin,syn,rst,psh,ack,urg
add action=drop chain=prerouting comment="RAW: Drop NULL packets" log=yes \
    log-prefix=RAW-NULL: protocol=tcp tcp-flags=!fin,!syn,!rst,!psh,!ack,!urg
add action=drop chain=prerouting comment="RAW: Drop SYN+FIN" log=yes \
    log-prefix=RAW-SYNFIN: protocol=tcp tcp-flags=fin,syn
add action=drop chain=prerouting comment="RAW: Drop SYN+RST" log=yes \
    log-prefix=RAW-SYNRST: protocol=tcp tcp-flags=syn,rst
add action=drop chain=prerouting comment="RAW: Drop FIN+RST" log=yes \
    log-prefix=RAW-FINRST: protocol=tcp tcp-flags=fin,rst
add action=drop chain=prerouting comment="RAW: Drop FIN without ACK" \
    protocol=tcp tcp-flags=fin,!ack
add action=drop chain=prerouting comment="RAW: Drop URG without ACK" \
    protocol=tcp tcp-flags=urg,!ack
add action=drop chain=prerouting comment="RAW: Drop PSH without ACK" \
    protocol=tcp tcp-flags=psh,!ack
add action=drop chain=prerouting comment="RAW: Drop TCP fragments" fragment=\
    yes log=yes log-prefix=RAW-TCPFRAG: protocol=tcp
add action=drop chain=prerouting comment="RAW: Drop UDP fragments" fragment=\
    yes log=yes log-prefix=RAW-UDPFRAG: protocol=udp
add action=drop chain=prerouting comment="RAW: Drop ICMP fragments" fragment=\
    yes log=yes log-prefix=RAW-ICMPFRAG: protocol=icmp
add action=drop chain=prerouting comment="RAW: Drop bogon sources on WAN" \
    in-interface=ether1 log=yes log-prefix=RAW-BOGON: src-address-list=bogons
add action=drop chain=prerouting comment="RAW: Drop SYN flood" in-interface=\
    ether1 log=yes log-prefix=RAW-SYNFLOOD: protocol=tcp src-address-list=\
    syn-flood tcp-flags=syn
add action=drop chain=prerouting comment="RAW: Drop UDP flood" in-interface=\
    ether1 log=yes log-prefix=RAW-UDPFLOOD: protocol=udp src-address-list=\
    udp-flood
add action=drop chain=prerouting comment="RAW: Drop ICMP flood" in-interface=\
    ether1 log=yes log-prefix=RAW-ICMPFLOOD: protocol=icmp src-address-list=\
    icmp-flood
add action=add-src-to-address-list address-list=port-scanners \
    address-list-timeout=1d chain=prerouting comment=\
    "RAW: Detect port scanners" in-interface=ether1 log=yes log-prefix=\
    RAW-PORTSCAN: protocol=tcp psd=21,3s,3,1
add action=drop chain=prerouting comment="RAW: Drop port scanners" \
    in-interface=ether1 src-address-list=port-scanners
add action=notrack chain=prerouting comment="RAW: Notrack ICMP prerouting" \
    disabled=yes protocol=icmp
add action=notrack chain=output comment="RAW: Notrack ICMP output" disabled=\
    yes protocol=icmp
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www address=192.168.88.0/24
set ssh address=192.168.88.0/24
set api address=192.168.88.0/24
set winbox address=192.168.88.0/24
set api-ssl disabled=yes
/ip traffic-flow
set cache-entries=32k enabled=yes
/ipv6 firewall address-list
add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="defconf: lo" list=bad_ipv6
add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: discard only " list=bad_ipv6
add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6
/ipv6 firewall filter
add action=drop chain=forward comment="DROP: Detected VPN Tunnels IPv6" \
    dst-address-list=vpn-detected
add action=add-src-to-address-list address-list=vpn-detected \
    address-list-timeout=1h chain=forward comment=\
    "DETECT: IPv6 Ghost TCP Proxy" connection-bytes=200000-0 disabled=yes \
    dst-address-list=!witnessed-dns-ips dst-port=443 protocol=tcp
add action=reject chain=forward comment="DROP: Zero-Survival Ghost IPv6" \
    disabled=yes dst-address-list=!witnessed-dns-ips dst-port=443 protocol=\
    tcp reject-with=tcp-reset
add action=drop chain=forward comment="DROP: Zero-Survival Ghost IPv6 UDP" \
    disabled=yes dst-address-list=!witnessed-dns-ips dst-port=443 protocol=\
    udp
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" \
    dst-port=33434-33534 protocol=udp
add action=accept chain=input comment=\
    "defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=\
    udp src-address=fe80::/10
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 \
    protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=input comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
add action=fasttrack-connection chain=forward comment="defconf: fasttrack6" \
    connection-state=established,related
add action=accept chain=forward comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment=\
    "defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" \
    hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=\
    icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=\
    500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=\
    ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=\
    ipsec-esp
add action=accept chain=forward comment=\
    "defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment=\
    "defconf: drop everything else not coming from LAN" in-interface-list=\
    !LAN
/system clock
set time-zone-name=Europe/London
/system logging
add topics=firewall
add topics=firewall
/system note
set show-at-login=no
/system scheduler
add interval=1h name=vpn-list-cleanup on-event=\
    "/ip firewall address-list remove [find list=vpn-detected dynamic=yes]" \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2026-03-12 start-time=18:42:12
add comment=vpndet disabled=yes interval=1d name=vpndet-blocklist-update \
    on-event="/import file-name=vpndet-dc-fetch.rsc" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2026-03-29 start-time=04:17:00
add disabled=yes interval=1s name=VPNDetect-DNS-Sched on-event=VPNDetect-DNS \
    policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2026-03-30 start-time=13:48:51
add interval=30s name=icmp-recon-sched on-event=\
    "/system script run icmp-recon" policy=read,write,test start-date=\
    2026-05-09 start-time=12:17:07
add interval=1h name=doh-resolver-sched on-event=\
    "/system script run doh-resolver" policy=read,write,test start-date=\
    2026-05-09 start-time=15:25:53
add interval=1m name=trust-list-refresh on-event="/system script run populate-\
    dns-witnessed; /system script run populate-multi-client-trusted" policy=\
    read,write,test start-date=2026-05-09 start-time=16:00:28
add interval=30s name=admin-unban-sched on-event=\
    "/system script run admin-unban" policy=read,write,test start-date=\
    2026-05-09 start-time=16:27:13
add interval=1m name=strike-escalate-sched on-event=\
    "/system script run strike-escalate" policy=read,write,test start-date=\
    2026-05-09 start-time=16:27:13
add disabled=yes interval=5m name=web-validate-candidates on-event=\
    "/system script run web-validate-candidates" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-time=startup
/system script
add dont-require-permissions=no name=icmp-recon owner=admin policy=\
    read,write,test source=":foreach e in=[/ip firewall address-list find list\
    =icmp-seen] do={\
    \n  :local ip [/ip firewall address-list get \$e address]\
    \n  :do {\
    \n    :local r [/ping address=\$ip count=3 interval=200ms]\
    \n    :if (\$r >= 2) do={\
    \n      :if ([:len [/ip firewall address-list find list=icmp-allowed addre\
    ss=\$ip]] = 0) do={\
    \n        /ip firewall address-list add list=icmp-allowed address=\$ip tim\
    eout=10m comment=\"auto-allowed\"\
    \n        :log info (\"ICMP-RECON allowed: \" . \$ip)\
    \n      } else={\
    \n        /ip firewall address-list set [find list=icmp-allowed address=\$\
    ip] timeout=10m\
    \n      }\
    \n    }\
    \n  } on-error={}\
    \n  /ip firewall address-list remove \$e\
    \n}\
    \n:foreach e in=[/ip firewall address-list find list=icmp-allowed] do={\
    \n  :local ip [/ip firewall address-list get \$e address]\
    \n  :do {\
    \n    :local r [/ping address=\$ip count=3 interval=200ms]\
    \n    :if (\$r < 2) do={\
    \n      /ip firewall address-list remove \$e\
    \n      :log info (\"ICMP-RECON demoted: \" . \$ip)\
    \n    } else={\
    \n      /ip firewall address-list set \$e timeout=10m\
    \n    }\
    \n  } on-error={}\
    \n}"
add dont-require-permissions=no name=safety-rollback owner=admin policy=\
    read,write,policy,test source=":global rollbackCmd\
    \n:if ([:typeof \$rollbackCmd] = \"nothing\") do={ :log info \"no rollback\
    \_set\" } else={\
    \n  :log warning \"AUTO-ROLLBACK firing\"\
    \n  [:parse \$rollbackCmd]\
    \n  :set rollbackCmd\
    \n}"
add dont-require-permissions=no name=doh-resolver owner=admin policy=\
    read,write,test source=":local hosts {\"cloudflare-dns.com\";\"dns.cloudfl\
    are.com\";\"dns.google\";\"dns.quad9.net\";\"doh.opendns.com\";\"dns.adgua\
    rd.com\";\"dns.adguard-dns.com\";\"dns.nextdns.io\";\"doh.controld.com\";\
    \"dns0.eu\";\"dns.mullvad.net\";\"doh.cleanbrowsing.org\";\"doh.dns.sb\"}\
    \n:foreach h in=\$hosts do={\
    \n  :do {\
    \n    :local ip [:resolve \$h]\
    \n    :if ([:len [/ip firewall address-list find list=block-doh address=\$\
    ip]] = 0) do={\
    \n      /ip firewall address-list add list=block-doh address=\$ip comment=\
    (\"auto: \" . \$h) timeout=2d\
    \n      :log info (\"DOH-AUTO: \" . \$h . \" -> \" . \$ip)\
    \n    }\
    \n  } on-error={}\
    \n}"
add dont-require-permissions=no name=populate-dns-witnessed owner=admin \
    policy=read,write,test source=":foreach c in=[/ip dns cache find where typ\
    e=\"A\"] do={\
    \n  :do {\
    \n    :local ip [/ip dns cache get \$c data]\
    \n    :if ([:len [/ip firewall address-list find where list=dns-witnessed \
    and address=\$ip]] = 0) do={\
    \n      /ip firewall address-list add list=dns-witnessed address=\$ip time\
    out=1h comment=\"auto-dns\"\
    \n    } else={\
    \n      /ip firewall address-list set [/ip firewall address-list find wher\
    e list=dns-witnessed and address=\$ip] timeout=1h\
    \n    }\
    \n  } on-error={}\
    \n}"
add dont-require-permissions=no name=populate-multi-client-trusted owner=\
    admin policy=read,write,test source=":local dsts [:toarray \"\"]\
    \n:foreach c in=[/ip firewall connection find protocol=tcp] do={\
    \n  :do {\
    \n    :local da [/ip firewall connection get \$c dst-address]\
    \n    :local pd [:find \$da \":\"]\
    \n    :if (\$pd > 0) do={\
    \n      :local port [:pick \$da (\$pd + 1) [:len \$da]]\
    \n      :if (\$port = \"443\") do={\
    \n        :local dip [:pick \$da 0 \$pd]\
    \n        :if ([:typeof (\$dsts->\$dip)] = \"nothing\") do={ :set (\$dsts-\
    >\$dip) \"\" }\
    \n      }\
    \n    }\
    \n  } on-error={}\
    \n}\
    \n:foreach dip,_ in=\$dsts do={\
    \n  :do {\
    \n    :local srcs [:toarray \"\"]\
    \n    :foreach c in=[/ip firewall connection find protocol=tcp] do={\
    \n      :local da [/ip firewall connection get \$c dst-address]\
    \n      :local sa [/ip firewall connection get \$c src-address]\
    \n      :local pd [:find \$da \":\"]\
    \n      :local ps [:find \$sa \":\"]\
    \n      :if (\$pd > 0 && \$ps > 0) do={\
    \n        :local dipx [:pick \$da 0 \$pd]\
    \n        :local port [:pick \$da (\$pd + 1) [:len \$da]]\
    \n        :if (\$dipx = \$dip && \$port = \"443\") do={\
    \n          :local sip [:pick \$sa 0 \$ps]\
    \n          :set (\$srcs->\$sip) \"1\"\
    \n        }\
    \n      }\
    \n    }\
    \n    :local cnt 0\
    \n    :foreach _,_ in=\$srcs do={ :set cnt (\$cnt + 1) }\
    \n    :if (\$cnt >= 2) do={\
    \n      :if ([:len [/ip firewall address-list find list=multi-client-trust\
    ed address=\$dip]] = 0) do={\
    \n        /ip firewall address-list add list=multi-client-trusted address=\
    \$dip timeout=7d comment=\"auto-multi\"\
    \n      } else={\
    \n        /ip firewall address-list set [/ip firewall address-list find li\
    st=multi-client-trusted address=\$dip] timeout=7d\
    \n      }\
    \n    }\
    \n  } on-error={}\
    \n}"
add dont-require-permissions=no name=admin-unban owner=admin policy=\
    read,write,test source=":foreach e in=[/ip firewall address-list find wher\
    e list=low-trust and address=\"192.168.88.254\"] do={\
    \n  /ip firewall address-list remove \$e\
    \n  :log warning \"ADMIN-PROTECT: removed 192.168.88.254 from low-trust\"\
    \n}"
add dont-require-permissions=no name=strike-escalate owner=admin policy=\
    read,write,test source=":foreach src in=[/ip firewall address-list find wh\
    ere list=ghost-strikes] do={\
    \n  :do {\
    \n    :local addr [/ip firewall address-list get \$src address]\
    \n    :if (\$addr != \"192.168.88.254\") do={\
    \n      :local cnt [:len [/ip firewall address-list find where list=ghost-\
    strikes and address=\$addr]]\
    \n      :if (\$cnt >= 3) do={\
    \n        :if ([:len [/ip firewall address-list find where list=low-trust \
    and address=\$addr]] = 0) do={\
    \n          /ip firewall address-list add list=low-trust address=\$addr ti\
    meout=15m comment=\"auto-strike-escalation\"\
    \n          :log warning (\"STRIKE-ESCALATE: \" . \$addr . \" banned 15m\"\
    )\
    \n        }\
    \n      }\
    \n    }\
    \n  } on-error={}\
    \n}"
add dont-require-permissions=no name=web-validate-candidates owner=admin \
    policy=read,write,test source=":foreach i in=[/ip firewall address-list fi\
    nd where list=\"tls-new-ips\"] do={ :local a [/ip firewall address-list ge\
    t \$i address]; :if ([:len \$a] > 0) do={ :do { /tool fetch url=(\"http://\
    \" . \$a . \"/\") output=none; /ip firewall address-list remove [find list\
    =\"web-validated\" address=\$a]; /ip firewall address-list add list=\"web-\
    validated\" address=\$a timeout=1h comment=(\"auto web validated http \" .\
    \_[/system clock get time]) } on-error={ :do { /tool fetch url=(\"https://\
    \" . \$a . \"/\") output=none check-certificate=no; /ip firewall address-l\
    ist remove [find list=\"web-validated\" address=\$a]; /ip firewall address\
    -list add list=\"web-validated\" address=\$a timeout=1h comment=(\"auto we\
    b validated https \" . [/system clock get time]) } on-error={} } } }"
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
