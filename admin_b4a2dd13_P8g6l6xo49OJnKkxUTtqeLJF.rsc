# 2026-05-10 18:05:38 by RouterOS 7.18.2
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
add name=wireguard-native regexp="^[\\x01-\\x04]"
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
add disabled=yes max-limit=1G/1G name=per-client-2mbps queue=\
    pcq-ul-2m/pcq-dl-2m target=192.168.88.0/24
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
add bridge=bridge comment=\
    "ANALYZER PORT - disabled from LAN; mirror off by default" disabled=yes \
    interface=ether3
add bridge=bridge comment=defconf interface=ether4
add bridge=bridge comment=defconf interface=ether5
add bridge=bridge comment=defconf interface=sfp1
/ip neighbor discovery-settings
set discover-interface-list=LAN
/ipv6 settings
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
add disabled=yes name=yt3.ggpht.com type=NXDOMAIN
add name=instagram.com type=NXDOMAIN
add name=*.instagram.com type=NXDOMAIN
add name=cdninstagram.com type=NXDOMAIN
add name=*.cdninstagram.com type=NXDOMAIN
add address=127.0.0.1 disabled=yes regexp=".*\\.sky\\.com\$" ttl=1m type=A
add address=127.0.0.1 disabled=yes regexp=".*\\.sky\\.co\\.uk\$" ttl=1m type=\
    A
add address=127.0.0.1 disabled=yes regexp=".*\\.nowtv\\.com\$" ttl=1m type=A
add address=127.0.0.1 disabled=yes regexp=".*\\.skygo\\.co\\.uk\$" ttl=1m \
    type=A
add address=127.0.0.1 disabled=yes regexp=".*\\.skysports\\.com\$" ttl=1m \
    type=A
add address=127.0.0.1 disabled=yes regexp=".*\\.skynews\\.com\$" ttl=1m type=\
    A
add address=127.0.0.1 disabled=yes regexp=".*\\.skycinema\\.co\\.uk\$" ttl=1m \
    type=A
add address=127.0.0.1 disabled=yes regexp=".*\\.sky-cdn\\.com\$" ttl=1m type=\
    A
add address=127.0.0.1 disabled=yes regexp=".*\\.skyott\\.com\$" ttl=1m type=A
add name=yt.be type=NXDOMAIN
add disabled=yes name=ggpht.com type=NXDOMAIN
add disabled=yes name=*.ggpht.com type=NXDOMAIN
add name=youtube-nocookie.com type=NXDOMAIN
add name=*.youtube-nocookie.com type=NXDOMAIN
add name=youtubei.googleapis.com type=NXDOMAIN
add name=youtube.googleapis.com type=NXDOMAIN
add disabled=yes name=gvt1.com type=NXDOMAIN
add disabled=yes name=*.gvt1.com type=NXDOMAIN
add disabled=yes name=gvt2.com type=NXDOMAIN
add disabled=yes name=*.gvt2.com type=NXDOMAIN
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
add comment="XVERIFY: block Cloudflare Workers public suffix" name=\
    workers.dev type=NXDOMAIN
add comment="XVERIFY: block Cloudflare Workers public suffix" name=\
    *.workers.dev type=NXDOMAIN
add comment="XVERIFY: block Cloudflare Pages public suffix" name=pages.dev \
    type=NXDOMAIN
add comment="XVERIFY: block Cloudflare Pages public suffix" name=*.pages.dev \
    type=NXDOMAIN
add comment="XVERIFY: block Cloudflare tunnel public suffix" name=\
    trycloudflare.com type=NXDOMAIN
add comment="XVERIFY: block Cloudflare tunnel public suffix" name=\
    *.trycloudflare.com type=NXDOMAIN
add address-list=fullspeed-allow comment="fullspeed: Fast.com (fast.com)" \
    forward-to=1.1.1.1 name=fast.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Fast.com (*.fast.com)" \
    forward-to=1.1.1.1 name=*.fast.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Netflix/Fast dependencies (netflix.com)" forward-to=1.1.1.1 \
    name=netflix.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Netflix/Fast dependencies (*.netflix.com)" forward-to=1.1.1.1 \
    name=*.netflix.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Ookla Speedtest (speedtest.net)" forward-to=1.1.1.1 name=\
    speedtest.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Ookla Speedtest (*.speedtest.net)" forward-to=1.1.1.1 name=\
    *.speedtest.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Ookla test servers (ooklaserver.net)" forward-to=1.1.1.1 \
    name=ooklaserver.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Ookla test servers (*.ooklaserver.net)" forward-to=1.1.1.1 \
    name=*.ooklaserver.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Steam (steampowered.com)" forward-to=1.1.1.1 name=\
    steampowered.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Steam (*.steampowered.com)" forward-to=1.1.1.1 name=\
    *.steampowered.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Steam content (steamcontent.com)" forward-to=1.1.1.1 name=\
    steamcontent.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Steam content (*.steamcontent.com)" forward-to=1.1.1.1 name=\
    *.steamcontent.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Steam static (steamstatic.com)" forward-to=1.1.1.1 name=\
    steamstatic.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Steam static (*.steamstatic.com)" forward-to=1.1.1.1 name=\
    *.steamstatic.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Steam servers (steamserver.net)" forward-to=1.1.1.1 name=\
    steamserver.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Steam servers (*.steamserver.net)" forward-to=1.1.1.1 name=\
    *.steamserver.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: CDN downloads (akamaihd.net)" forward-to=1.1.1.1 name=\
    akamaihd.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: CDN downloads (*.akamaihd.net)" forward-to=1.1.1.1 name=\
    *.akamaihd.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Epic Games (epicgames.com)" forward-to=1.1.1.1 name=\
    epicgames.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Epic Games (*.epicgames.com)" forward-to=1.1.1.1 name=\
    *.epicgames.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Epic/Unreal (unrealengine.com)" forward-to=1.1.1.1 name=\
    unrealengine.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Epic/Unreal (*.unrealengine.com)" forward-to=1.1.1.1 name=\
    *.unrealengine.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Xbox Live (xboxlive.com)" forward-to=1.1.1.1 name=\
    xboxlive.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Xbox Live (*.xboxlive.com)" forward-to=1.1.1.1 name=\
    *.xboxlive.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Xbox services (xboxservices.com)" forward-to=1.1.1.1 name=\
    xboxservices.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Xbox services (*.xboxservices.com)" forward-to=1.1.1.1 name=\
    *.xboxservices.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: PlayStation Network (playstation.net)" forward-to=1.1.1.1 \
    name=playstation.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: PlayStation Network (*.playstation.net)" forward-to=1.1.1.1 \
    name=*.playstation.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: PlayStation (playstation.com)" forward-to=1.1.1.1 name=\
    playstation.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: PlayStation (*.playstation.com)" forward-to=1.1.1.1 name=\
    *.playstation.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Nintendo (nintendo.net)" \
    forward-to=1.1.1.1 name=nintendo.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Nintendo (*.nintendo.net)" forward-to=1.1.1.1 name=\
    *.nintendo.net type=FWD
add address-list=fullspeed-allow comment="fullspeed: Battle.net (battle.net)" \
    forward-to=1.1.1.1 name=battle.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Battle.net (*.battle.net)" forward-to=1.1.1.1 name=\
    *.battle.net type=FWD
add address-list=fullspeed-allow comment="fullspeed: Blizzard (blizzard.com)" \
    forward-to=1.1.1.1 name=blizzard.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Blizzard (*.blizzard.com)" forward-to=1.1.1.1 name=\
    *.blizzard.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Blizzard CDN (blzstatic.cn)" forward-to=1.1.1.1 name=\
    blzstatic.cn type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Blizzard CDN (*.blzstatic.cn)" forward-to=1.1.1.1 name=\
    *.blzstatic.cn type=FWD
add address-list=fullspeed-allow comment="fullspeed: EA (ea.com)" forward-to=\
    1.1.1.1 name=ea.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: EA (*.ea.com)" \
    forward-to=1.1.1.1 name=*.ea.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Origin (origin.com)" \
    forward-to=1.1.1.1 name=origin.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Origin (*.origin.com)" \
    forward-to=1.1.1.1 name=*.origin.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Riot (riotgames.com)" \
    forward-to=1.1.1.1 name=riotgames.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Riot (*.riotgames.com)" \
    forward-to=1.1.1.1 name=*.riotgames.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Riot/PVP (pvp.net)" \
    forward-to=1.1.1.1 name=pvp.net type=FWD
add address-list=fullspeed-allow comment="fullspeed: Riot/PVP (*.pvp.net)" \
    forward-to=1.1.1.1 name=*.pvp.net type=FWD
add address-list=fullspeed-allow comment="fullspeed: Ubisoft (ubisoft.com)" \
    forward-to=1.1.1.1 name=ubisoft.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Ubisoft (*.ubisoft.com)" \
    forward-to=1.1.1.1 name=*.ubisoft.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Ubisoft (ubi.com)" \
    forward-to=1.1.1.1 name=ubi.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Ubisoft (*.ubi.com)" \
    forward-to=1.1.1.1 name=*.ubi.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Rockstar (rockstargames.com)" forward-to=1.1.1.1 name=\
    rockstargames.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Rockstar (*.rockstargames.com)" forward-to=1.1.1.1 name=\
    *.rockstargames.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Minecraft (minecraft.net)" forward-to=1.1.1.1 name=\
    minecraft.net type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Minecraft (*.minecraft.net)" forward-to=1.1.1.1 name=\
    *.minecraft.net type=FWD
add address-list=fullspeed-allow comment="fullspeed: Mojang (mojang.com)" \
    forward-to=1.1.1.1 name=mojang.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Mojang (*.mojang.com)" \
    forward-to=1.1.1.1 name=*.mojang.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Microsoft Store/Xbox delivery (delivery.mp.microsoft.com)" \
    forward-to=1.1.1.1 name=delivery.mp.microsoft.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Microsoft Store/Xbox delivery (*.delivery.mp.microsoft.com)" \
    forward-to=1.1.1.1 name=*.delivery.mp.microsoft.com type=FWD
add address-list=fullspeed-allow comment=\
    "fullspeed: Microsoft Store/Xbox delivery (dl.delivery.mp.microsoft.com)" \
    forward-to=1.1.1.1 name=dl.delivery.mp.microsoft.com type=FWD
add address-list=fullspeed-allow comment="fullspeed: Microsoft Store/Xbox deli\
    very (*.dl.delivery.mp.microsoft.com)" forward-to=1.1.1.1 name=\
    *.dl.delivery.mp.microsoft.com type=FWD
add address-list=dns-witnessed comment=\
    "XVERIFY: witness all forwarded DNS answers" forward-to=1.1.1.1 regexp=.* \
    type=FWD
add address-list=dns-witnessed forward-to=1.1.1.1 regexp=\
    ".*\\.ooklaserver\\.net" type=FWD
add address-list=dns-witnessed forward-to=1.1.1.1 regexp=".*\\.ookla\\.com" \
    type=FWD
add address-list=dns-witnessed forward-to=1.1.1.1 regexp=\
    ".*\\.ziffstatic\\.com" type=FWD
/ip firewall address-list
add address=sky.com comment=Sky disabled=yes list=block-sky
add address=sky.co.uk disabled=yes list=block-sky
add address=nowtv.com disabled=yes list=block-sky
add address=skygo.co.uk disabled=yes list=block-sky
add address=skysports.com disabled=yes list=block-sky
add address=skynews.com disabled=yes list=block-sky
add address=skycinema.co.uk disabled=yes list=block-sky
add address=skyott.com disabled=yes list=block-sky
add address=sky-cdn.com disabled=yes list=block-sky
add address=193.114.200.0/21 comment="BSkyB ASN5607 range 1" disabled=yes \
    list=block-sky
add address=5.104.64.0/21 comment="BSkyB ASN5607 range 2" disabled=yes list=\
    block-sky
add address=31.205.32.0/19 comment="BSkyB ASN5607 range 3" disabled=yes list=\
    block-sky
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
add address=fast.com comment="normal-web: Fast.com" list=normal-web-allow
add address=api.fast.com comment="normal-web: Fast.com API" list=\
    normal-web-allow
add address=netflix.com comment="normal-web: Netflix/Fast dependency" list=\
    normal-web-allow
add address=www.netflix.com comment="normal-web: Netflix/Fast dependency" \
    list=normal-web-allow
add address=128.116.0.0/16 list=sni-legit-speedtest
add address=172.187.0.0/16 list=sni-legit-speedtest
add address=151.101.0.0/16 list=sni-legit-web
add address=199.232.0.0/16 comment="Whitelisted Fastly" list=dns-witnessed
add address=78.147.40.59 comment=\
    "VLESS Reality endpoint observed during speedtest bypass" list=\
    blocked-proxy
add address=duel.com comment="normal-web: duel.com" list=normal-web-allow
add address=roulette.duel.com comment="normal-web: roulette.duel.com" list=\
    normal-web-allow
add address=avatars.duel.com comment="normal-web: avatars.duel.com" list=\
    normal-web-allow
add address=16.170.177.121 comment=\
    "observed Sweden TCP443 VPN/proxy endpoint from eero" list=vpn-providers
add address=13.49.212.214 comment=\
    "observed Sweden TCP443 VPN/proxy endpoint from eero" list=vpn-providers
add address=17.252.14.210 comment=apple-game-service-observed list=\
    game-udp-allow-observed
add address=20.201.209.2 comment=xbox-teredo-observed list=\
    game-udp-allow-observed
add address=170.23.236.148 comment=fortnite-observed list=\
    game-udp-allow-observed
add address=170.23.236.180 comment=fortnite-observed list=\
    game-udp-allow-observed
add address=170.23.236.140 comment=fortnite-observed list=\
    game-udp-allow-observed
add address=170.23.178.180 comment=fortnite-observed list=\
    game-udp-allow-observed
add address=149.50.216.0/24 comment=\
    "observed stealth TCP443 VPN endpoints 149.50.216.193/.195" list=\
    vpn-providers
add address=13.107.64.0/18 comment="Microsoft Teams media" list=\
    teams-media-allow
add address=52.112.0.0/14 comment="Microsoft Teams media" list=\
    teams-media-allow
add address=3.7.35.0/25 comment="Zoom meeting media" list=zoom-media-allow
add address=3.21.137.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=3.22.11.0/24 comment="Zoom meeting media" list=zoom-media-allow
add address=3.25.41.128/25 comment="Zoom meeting media" list=zoom-media-allow
add address=3.25.42.0/25 comment="Zoom meeting media" list=zoom-media-allow
add address=3.80.20.128/25 comment="Zoom meeting media" list=zoom-media-allow
add address=3.101.32.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=3.101.52.0/25 comment="Zoom meeting media" list=zoom-media-allow
add address=3.104.34.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=3.120.121.0/25 comment="Zoom meeting media" list=zoom-media-allow
add address=3.127.194.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=3.208.72.0/25 comment="Zoom meeting media" list=zoom-media-allow
add address=3.211.241.0/25 comment="Zoom meeting media" list=zoom-media-allow
add address=3.235.69.0/25 comment="Zoom meeting media" list=zoom-media-allow
add address=3.235.82.0/23 comment="Zoom meeting media" list=zoom-media-allow
add address=3.235.71.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=3.235.72.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=3.235.73.0/25 comment="Zoom meeting media" list=zoom-media-allow
add address=3.235.96.0/23 comment="Zoom meeting media" list=zoom-media-allow
add address=4.34.125.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=4.35.64.128/25 comment="Zoom meeting media" list=zoom-media-allow
add address=8.5.128.0/23 comment="Zoom meeting media" list=zoom-media-allow
add address=13.52.6.128/25 comment="Zoom meeting media" list=zoom-media-allow
add address=13.52.146.0/25 comment="Zoom meeting media" list=zoom-media-allow
add address=13.114.106.166 comment="Zoom meeting media" list=zoom-media-allow
add address=18.205.93.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=50.239.202.0/23 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=50.239.204.0/24 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=52.61.100.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=52.81.151.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=52.197.97.21 comment="Zoom meeting media" list=zoom-media-allow
add address=52.202.62.192/26 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=52.215.168.0/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=64.69.74.0/24 comment="Zoom meeting media" list=zoom-media-allow
add address=64.125.62.0/24 comment="Zoom meeting media" list=zoom-media-allow
add address=64.211.144.0/24 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=65.39.152.0/24 comment="Zoom meeting media" list=zoom-media-allow
add address=69.174.57.0/24 comment="Zoom meeting media" list=zoom-media-allow
add address=69.174.108.0/22 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=99.79.20.0/25 comment="Zoom meeting media" list=zoom-media-allow
add address=103.122.166.0/23 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=109.94.160.0/22 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=109.244.18.0/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=109.244.19.0/24 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=115.110.154.192/26 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=115.114.56.192/26 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=115.114.115.0/26 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=115.114.131.0/26 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=120.29.148.0/24 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=147.124.96.0/19 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=160.1.56.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=161.199.136.0/22 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=162.12.232.0/22 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=162.255.36.0/22 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=165.254.88.0/23 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=173.231.80.0/20 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=192.204.12.0/22 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=202.177.207.128/27 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=202.177.213.96/27 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=204.80.104.0/21 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=204.141.28.0/22 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=207.226.132.0/24 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=209.9.211.0/24 comment="Zoom meeting media" list=zoom-media-allow
add address=209.9.215.0/24 comment="Zoom meeting media" list=zoom-media-allow
add address=210.57.55.0/24 comment="Zoom meeting media" list=zoom-media-allow
add address=213.19.144.0/24 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=213.19.153.0/24 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=213.244.140.0/24 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=221.122.88.64/27 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=221.122.88.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=221.122.89.128/25 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=221.123.139.192/27 comment="Zoom meeting media" list=\
    zoom-media-allow
add address=169.150.208.0/24 comment=\
    "observed WireGuard TCP/stealth TCP endpoint 169.150.208.187" list=\
    vpn-providers
add address=62.93.166.0/24 comment=\
    "observed WireGuard TCP/UDP VPN endpoints 62.93.166.121/.122" list=\
    vpn-providers
/ip firewall filter
add action=drop chain=forward comment="Drop native WireGuard UDP" disabled=\
    yes layer7-protocol=wireguard-native log=yes log-prefix="WG-DROP " \
    protocol=udp
add action=accept chain=input comment=INPUT-00-ACCEPT-EST-REL \
    connection-state=established,related,untracked
add action=drop chain=input comment=INPUT-01-DROP-INVALID connection-state=\
    invalid
add action=accept chain=input comment=INPUT-02-ACCEPT-LAN-ROUTER-SERVICES \
    in-interface-list=LAN
add action=accept chain=input comment=INPUT-03-ACCEPT-WAN-DHCP-CLIENT \
    dst-port=68 in-interface-list=WAN protocol=udp src-port=67
add action=accept chain=input comment=INPUT-04-ACCEPT-ICMP-RATE limit=\
    5,10:packet protocol=icmp
add action=drop chain=input comment=INPUT-99-DROP-WAN-TO-ROUTER \
    in-interface-list=WAN
add action=drop chain=input comment="Drop native WireGuard UDP to router" \
    disabled=yes layer7-protocol=wireguard-native log=yes log-prefix=\
    "WG-IN-DROP " protocol=udp
add action=drop chain=output comment="Drop native WireGuard UDP from router" \
    disabled=yes layer7-protocol=wireguard-native log=yes log-prefix=\
    "WG-OUT-DROP " protocol=udp
add action=drop chain=forward comment=12-DROP-VPN-UDP-500-IKE \
    connection-state=established,related,new dst-port=500 protocol=udp \
    src-address=192.168.88.0/24
add action=drop chain=forward comment=12-DROP-VPN-UDP-4500-IPSEC-NAT-T \
    connection-state=established,related,new dst-port=4500 protocol=udp \
    src-address=192.168.88.0/24
add action=drop chain=forward comment=12-DROP-VPN-UDP-1701-L2TP \
    connection-state=established,related,new dst-port=1701 protocol=udp \
    src-address=192.168.88.0/24
add action=drop chain=forward comment=12-DROP-VPN-TCP-1723-PPTP \
    connection-state=established,related,new dst-port=1723 protocol=tcp \
    src-address=192.168.88.0/24
add action=drop chain=forward comment=12-DROP-VPN-TCP-1194-OPENVPN \
    connection-state=established,related,new dst-port=1194 protocol=tcp \
    src-address=192.168.88.0/24
add action=drop chain=forward comment=12-DROP-VPN-UDP-1194-OPENVPN \
    connection-state=established,related,new dst-port=1194 protocol=udp \
    src-address=192.168.88.0/24
add action=drop chain=forward comment=12-DROP-VPN-UDP-51820-WIREGUARD \
    connection-state=established,related,new dst-port=51820 protocol=udp \
    src-address=192.168.88.0/24
add action=drop chain=forward comment=12-DROP-UDP-443-QUIC-VPN-BYPASS \
    connection-state=established,related,new dst-port=443 protocol=udp \
    src-address=192.168.88.0/24
add action=drop chain=forward comment=WG-DPI-SIZE-IN-60-192.168.88.253 \
    disabled=yes dst-address=192.168.88.253 packet-size=60 protocol=udp
add action=drop chain=forward comment=WG-DPI-SIZE-IN-92-192.168.88.253 \
    disabled=yes dst-address=192.168.88.253 packet-size=92 protocol=udp
add action=drop chain=forward comment=WG-DPI-SIZE-IN-120-192.168.88.253 \
    disabled=yes dst-address=192.168.88.253 packet-size=120 protocol=udp
add action=drop chain=forward comment=WG-DPI-SIZE-IN-176-192.168.88.253 \
    disabled=yes dst-address=192.168.88.253 packet-size=176 protocol=udp
add action=accept chain=forward comment=ZOOM-ALLOW-UDP-192.168.88.253 \
    disabled=yes dst-address-list=zoom-media-allow dst-port=\
    3478,3479,8801-8810 protocol=udp src-address=192.168.88.253
add action=drop chain=forward comment=WG-DPI-SIZE-OUT-60-192.168.88.253 \
    disabled=yes packet-size=60 protocol=udp src-address=192.168.88.253
add action=drop chain=forward comment=WG-DPI-SIZE-OUT-92-192.168.88.253 \
    disabled=yes packet-size=92 protocol=udp src-address=192.168.88.253
add action=drop chain=forward comment=WG-DPI-SIZE-OUT-120-192.168.88.253 \
    disabled=yes packet-size=120 protocol=udp src-address=192.168.88.253
add action=drop chain=forward comment=WG-DPI-SIZE-OUT-176-192.168.88.253 \
    disabled=yes packet-size=176 protocol=udp src-address=192.168.88.253
add action=drop chain=forward comment=13B-DROP-STEALTH-VPN-149.50.216.0-24 \
    connection-state=established,related,new disabled=yes dst-address=\
    149.50.216.0/24 src-address=192.168.88.253
add action=drop chain=forward comment=10-DROP-VPN-PROVIDERS-TCP \
    connection-state=established,related,new disabled=yes dst-address-list=\
    vpn-providers protocol=tcp
add action=drop chain=forward comment=11-DROP-VPN-PROVIDERS-UDP \
    connection-state=established,related,new disabled=yes dst-address-list=\
    vpn-providers protocol=udp
add action=passthrough chain=forward comment=\
    MONITOR-TLS443-SNI-PRESENT-192.168.88.253 dst-port=443 protocol=tcp \
    src-address=192.168.88.253 tls-host=*
add action=drop chain=forward comment=\
    CLIENT-DROP-TCP443-NO-SNI-AFTER-512K-192.168.88.253 connection-bytes=\
    524288-0 connection-mark=tls-pending dst-port=443 protocol=tcp \
    src-address=192.168.88.253
add action=drop chain=forward comment=\
    CLIENT-DROP-LARGE-TCP443-TUNNEL-192.168.88.253 connection-bytes=\
    25000000-0 dst-port=443 protocol=tcp src-address=192.168.88.253
add action=accept chain=forward comment=FORTNITE-ALLOW-TCP-192.168.88.253 \
    dst-port=80,443,5222 protocol=tcp src-address=192.168.88.253
add action=accept chain=forward comment=\
    ROCKET-LEAGUE-ALLOW-TCP-192.168.88.253 dst-port=80,443 protocol=tcp \
    src-address=192.168.88.253
add action=accept chain=forward comment=\
    CLIENT-ALLOW-TCP-5223-APNS-192.168.88.253 dst-port=5223 protocol=tcp \
    src-address=192.168.88.253
add action=accept chain=forward comment=\
    CLIENT-ALLOW-TCP-8883-MQTT-192.168.88.253 dst-port=8883 protocol=tcp \
    src-address=192.168.88.253
add action=drop chain=forward comment=\
    CLIENT-DROP-HIGH-TCP-VPN-TUNNELS-192.168.88.253 dst-port=1024-65535 \
    protocol=tcp src-address=192.168.88.253
add action=accept chain=forward comment=FORTNITE-ALLOW-UDP-192.168.88.253 \
    dst-port=3478,3479,5060,5062,6250,12000-65000 protocol=udp src-address=\
    192.168.88.253
add action=accept chain=forward comment=\
    ROCKET-LEAGUE-ALLOW-UDP-192.168.88.253 dst-port=7000-9000 protocol=udp \
    src-address=192.168.88.253
add action=accept chain=forward comment=TEAMS-ALLOW-UDP-192.168.88.253 \
    dst-address-list=teams-media-allow dst-port=3478-3481 protocol=udp \
    src-address=192.168.88.253
add action=accept chain=forward comment=ZOOM-ALLOW-UDP-STUN-192.168.88.253 \
    dst-address-list=zoom-media-allow dst-port=3478-3479 protocol=udp \
    src-address=192.168.88.253
add action=accept chain=forward comment=ZOOM-ALLOW-UDP-MEDIA-192.168.88.253 \
    dst-address-list=zoom-media-allow dst-port=8801-8810 protocol=udp \
    src-address=192.168.88.253
add action=drop chain=forward comment=13-DROP-LAN-UDP-88-WIREGUARD-BYPASS \
    connection-state=established,related,new dst-port=88 log-prefix=\
    "UDP88-WG-DROP " protocol=udp src-address=192.168.88.0/24
add action=drop chain=forward comment=\
    14-DEFAULT-DENY-UDP-192.168.88.253-NONALLOW connection-state=\
    established,related,new protocol=udp src-address=192.168.88.253
add action=fasttrack-connection chain=forward comment=\
    01-FASTTRACK-TRUSTED-FLOWS connection-mark=accelerate-me \
    connection-state=established,related disabled=yes dst-address-list=\
    !vpn-providers hw-offload=yes
add action=drop chain=forward comment=09-DROP-INV-PROXY-FORWARD \
    connection-state=established,related,new disabled=yes dst-address-list=\
    inv-proxy src-address=192.168.88.0/24
add action=drop chain=forward comment=08-DROP-VLESS-TCP-433-FORWARD \
    connection-state=established,related,new dst-port=433 protocol=tcp \
    src-address=192.168.88.0/24
add action=drop chain=forward comment=08-DROP-VLESS-UDP-433-FORWARD \
    connection-state=established,related,new dst-port=433 protocol=udp \
    src-address=192.168.88.0/24
add action=drop chain=forward comment=07-DROP-BLOCKED-PROXY-FORWARD \
    connection-state=established,related,new disabled=yes dst-address-list=\
    blocked-proxy src-address=192.168.88.0/24
add action=drop chain=forward comment=06-DROP-TLS-SNI-proton dst-port=443 \
    protocol=tcp src-address=192.168.88.0/24 tls-host=*proton*
add action=drop chain=forward comment=06-DROP-TLS-SNI-protonvpn dst-port=443 \
    protocol=tcp src-address=192.168.88.0/24 tls-host=*protonvpn*
add action=drop chain=forward comment=06-DROP-TLS-SNI-proton-me dst-port=443 \
    protocol=tcp src-address=192.168.88.0/24 tls-host=*proton.me*
add action=drop chain=forward comment=06-DROP-TLS-SNI-protonvpn-net dst-port=\
    443 protocol=tcp src-address=192.168.88.0/24 tls-host=*protonvpn.net*
add action=drop chain=forward comment=06-DROP-TLS-SNI-protonvpn-ch dst-port=\
    443 protocol=tcp src-address=192.168.88.0/24 tls-host=*protonvpn.ch*
add action=accept chain=forward comment=04E-ALLOW-NORMAL-WEB-TLS \
    connection-state=established,related,new dst-address-list=\
    normal-web-allow dst-port=443 protocol=tcp src-address=192.168.88.0/24
add action=accept chain=forward comment=05-ALLOW-ROUTER-VALIDATED-TLS \
    connection-state=established,related,new dst-address-list=\
    tls-router-validated dst-port=443 protocol=tcp src-address=\
    192.168.88.0/24
add action=add-dst-to-address-list address-list=tls-no-dns-candidates \
    address-list-timeout=10m chain=forward comment=05A-QUEUE-NODNS-TLS \
    connection-state=new dst-address-list=!dns-witnessed dst-port=443 \
    protocol=tcp src-address=192.168.88.0/24
add action=drop chain=forward comment=05B-DROP-NODNS-TLS connection-state=new \
    dst-address-list=!dns-witnessed dst-port=443 protocol=tcp src-address=\
    192.168.88.0/24
add action=accept chain=forward comment=02-ACCEPT-ESTABLISHED \
    connection-state=established,related,untracked
add action=drop chain=forward comment=03-DROP-INVALID connection-state=\
    invalid
add action=drop chain=forward comment=04-BLOCK-HTTP-TUNNELS connection-bytes=\
    500000-0 dst-port=80 protocol=tcp
/ip firewall mangle
add action=mark-connection chain=forward comment=DETECT-TRUSTED-FASTTRACK-TCP \
    connection-mark=no-mark connection-rate=20M-1G connection-state=\
    established dst-address-list=fullspeed-allow new-connection-mark=\
    accelerate-me protocol=tcp
add action=mark-connection chain=forward comment=\
    FORTNITE-MARK-TCP-192.168.88.253 connection-mark=no-mark \
    connection-state=established,related,new dst-port=80,5222 \
    new-connection-mark=accelerate-me protocol=tcp src-address=192.168.88.253
add action=mark-connection chain=forward comment=\
    FORTNITE-MARK-UDP-192.168.88.253 connection-mark=no-mark \
    connection-state=established,related,new dst-port=\
    3478,3479,5060,5062,6250,12000-65000 new-connection-mark=accelerate-me \
    protocol=udp src-address=192.168.88.253
add action=mark-connection chain=forward comment=DETECT-TRUSTED-FASTTRACK-UDP \
    connection-mark=no-mark connection-rate=20M-1G connection-state=\
    established dst-address-list=fullspeed-allow new-connection-mark=\
    accelerate-me protocol=udp
add action=mark-connection chain=forward comment=\
    MARK-TCP443-PENDING-192.168.88.253 connection-state=new dst-port=443 \
    new-connection-mark=tls-pending protocol=tcp src-address=192.168.88.253
add action=mark-connection chain=forward comment=\
    MARK-TCP443-SNI-PRESENT-192.168.88.253 dst-port=443 new-connection-mark=\
    tls-sni-present protocol=tcp src-address=192.168.88.253 tls-host=*
/ip firewall nat
add action=redirect chain=dstnat comment=FORCE-DNS-REDIRECT dst-port=53 \
    protocol=udp to-ports=53
add action=redirect chain=dstnat comment=FORCE-DNS-REDIRECT dst-port=53 \
    protocol=tcp to-ports=53
add action=redirect chain=dstnat comment=FORCE-DNS-FOR-WITNESS dst-port=53 \
    protocol=udp to-ports=53
add action=redirect chain=dstnat comment=FORCE-DNS-FOR-WITNESS dst-port=53 \
    protocol=tcp to-ports=53
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
add action=redirect chain=dstnat comment=FORCE-NTP-REDIRECT-LAN dst-port=123 \
    protocol=udp src-address=192.168.88.0/24 to-ports=123
/ip firewall raw
add action=drop chain=prerouting comment=BLOCK-VMESS-80 content=/vmess-ws \
    dst-port=80 protocol=tcp
add action=drop chain=prerouting comment=BLOCK-WS-UPGRADE content=\
    "Upgrade: websocket" dst-port=80 protocol=tcp
add action=drop chain=prerouting comment=BLOCK-WS-RESPONSE content=\
    "101 Switching Protocols" protocol=tcp src-port=80
add action=drop chain=prerouting comment=DROP-VPN-PROVIDERS-RAW disabled=yes \
    dst-address-list=vpn-providers src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-1194-RAW disabled=yes \
    dst-port=1194 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-1701-RAW disabled=yes \
    dst-port=1701 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-1723-RAW disabled=yes \
    dst-port=1723 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-500-RAW disabled=yes \
    dst-port=500 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-4500-RAW disabled=yes \
    dst-port=4500 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-51820-RAW disabled=yes \
    dst-port=51820 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-51821-RAW disabled=yes \
    dst-port=51821 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-8388-RAW disabled=yes \
    dst-port=8388 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-8389-RAW disabled=yes \
    dst-port=8389 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-1080-RAW disabled=yes \
    dst-port=1080 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-1081-RAW disabled=yes \
    dst-port=1081 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-1088-RAW disabled=yes \
    dst-port=1088 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-8443-RAW disabled=yes \
    dst-port=8443 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-8888-RAW disabled=yes \
    dst-port=8888 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-2082-RAW disabled=yes \
    dst-port=2082 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-2083-RAW disabled=yes \
    dst-port=2083 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-2086-RAW disabled=yes \
    dst-port=2086 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-2087-RAW disabled=yes \
    dst-port=2087 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-2095-RAW disabled=yes \
    dst-port=2095 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-2096-RAW disabled=yes \
    dst-port=2096 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-TCP-8880-RAW disabled=yes \
    dst-port=8880 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-500-RAW disabled=yes \
    dst-port=500 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-4500-RAW disabled=yes \
    dst-port=4500 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-1194-RAW disabled=yes \
    dst-port=1194 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-1701-RAW disabled=yes \
    dst-port=1701 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-51820-RAW disabled=yes \
    dst-port=51820 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-51821-RAW disabled=yes \
    dst-port=51821 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-8388-RAW disabled=yes \
    dst-port=8388 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-8389-RAW disabled=yes \
    dst-port=8389 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-1080-RAW disabled=yes \
    dst-port=1080 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-1081-RAW disabled=yes \
    dst-port=1081 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-1088-RAW disabled=yes \
    dst-port=1088 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-2408-RAW disabled=yes \
    dst-port=2408 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-8443-RAW disabled=yes \
    dst-port=8443 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VPN-UDP-8888-RAW disabled=yes \
    dst-port=8888 protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-INV-PROXY-RAW disabled=yes \
    dst-address-list=inv-proxy src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VLESS-TCP-433-RAW dst-port=433 \
    protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-VLESS-UDP-433-RAW dst-port=433 \
    protocol=udp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-BLOCKED-PROXY-RAW disabled=yes \
    dst-address-list=blocked-proxy src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-TLS-CONTENT-proton content=\
    proton dst-port=443 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-TLS-CONTENT-protonvpn content=\
    protonvpn dst-port=443 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-TLS-CONTENT-proton-me content=\
    proton.me dst-port=443 protocol=tcp src-address=192.168.88.0/24
add action=drop chain=prerouting comment=DROP-TLS-CONTENT-protonvpn-ch \
    content=protonvpn.ch dst-port=443 protocol=tcp src-address=\
    192.168.88.0/24
add action=drop chain=prerouting comment=DROP-TLS-CONTENT-protonvpn-net \
    content=protonvpn.net dst-port=443 protocol=tcp src-address=\
    192.168.88.0/24
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www address=192.168.88.0/24 disabled=yes
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
/system ntp client
set enabled=yes
/system ntp server
set enabled=yes use-local-clock=yes
/system ntp client servers
add address=162.159.200.1
add address=162.159.200.123
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
add interval=1m name=trust-list-refresh on-event=\
    "/system script run populate-dns-witnessed" policy=read,write,test \
    start-date=2026-05-09 start-time=16:00:28
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
add disabled=yes interval=5s name=proxy-blocklist-sync-sched on-event=\
    "/system script run proxy-blocklist-sync" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2026-05-09 start-time=22:22:10
add interval=10s name=tls-router-validate-sched on-event=\
    "/system script run tls-router-validate" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=2026-05-09 start-time=22:28:25
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
add dont-require-permissions=no name=proxy-blocklist-sync owner=admin policy=\
    read,write,test source=":foreach e in=[/ip firewall address-list find wher\
    e list=\"inv-proxy\"] do={\
    \n  :local ip [/ip firewall address-list get \$e address]\
    \n  :if ([:len [/ip firewall address-list find where list=\"normal-web-all\
    ow\" and address=\$ip]] = 0 && [:len [/ip firewall address-list find where\
    \_list=\"fullspeed-allow\" and address=\$ip]] = 0) do={\
    \n    :if ([:len [/ip firewall address-list find where list=\"blocked-prox\
    y\" and address=\$ip]] = 0) do={\
    \n      /ip firewall address-list add list=\"blocked-proxy\" address=\$ip \
    timeout=1d comment=\"auto from inv-proxy\"\
    \n      :log warning (\"PROXY-BLOCK: \" . \$ip)\
    \n    }\
    \n  }\
    \n}"
add dont-require-permissions=no name=tls-router-validate owner=admin policy=\
    read,write,test source=":foreach e in=[/ip firewall address-list find wher\
    e list=\"tls-no-dns-candidates\"] do={\
    \n  :local ip [/ip firewall address-list get \$e address]\
    \n  :if ([:len [/ip firewall address-list find where list=\"dns-witnessed\
    \" and address=\$ip]] > 0) do={\
    \n    /ip firewall address-list remove \$e\
    \n  } else={\
    \n    :if ([:len [/ip firewall address-list find where list=\"tls-router-v\
    alidated\" and address=\$ip]] = 0) do={\
    \n      :do {\
    \n        /tool fetch url=(\"https://\" . \$ip . \"/\") output=none check-\
    certificate=no duration=3s\
    \n        /ip firewall address-list add list=\"tls-router-validated\" addr\
    ess=\$ip timeout=1h comment=\"router https probe ok\"\
    \n        /ip firewall address-list remove \$e\
    \n        :log info (\"TLS-VALIDATED: \" . \$ip)\
    \n      } on-error={\
    \n        :log warning (\"TLS-BLOCKED-NO-VALIDATION: \" . \$ip)\
    \n      }\
    \n    }\
    \n  }\
    \n}"
add comment="ether3 passive analyzer mirror control" \
    dont-require-permissions=no name=MIRROR-ETHER3-OFF owner=admin policy=\
    read,write,test source="/interface ethernet switch set switch1 mirror-sour\
    ce=none mirror-target=none; /interface bridge port disable [find interface\
    =ether3]; /log info \"ether3 analyzer mirror OFF\""
add comment="ether3 passive analyzer mirror control" \
    dont-require-permissions=no name=MIRROR-ETHER3-ON-ETHER2 owner=admin \
    policy=read,write,test source="/interface bridge port disable [find interf\
    ace=ether3]; /interface ethernet switch set switch1 mirror-source=ether2 m\
    irror-target=ether3; /log warning \"ether3 analyzer mirror ON source ether\
    2\""
add comment="ether3 passive analyzer mirror control" \
    dont-require-permissions=no name=MIRROR-ETHER3-ON-ETHER4 owner=admin \
    policy=read,write,test source="/interface bridge port disable [find interf\
    ace=ether3]; /interface ethernet switch set switch1 mirror-source=ether4 m\
    irror-target=ether3; /log warning \"ether3 analyzer mirror ON source ether\
    4\""
add comment="ether3 passive analyzer mirror control" \
    dont-require-permissions=no name=MIRROR-ETHER3-ON-ETHER5 owner=admin \
    policy=read,write,test source="/interface bridge port disable [find interf\
    ace=ether3]; /interface ethernet switch set switch1 mirror-source=ether5 m\
    irror-target=ether3; /log warning \"ether3 analyzer mirror ON source ether\
    5\""
/tool bandwidth-server
set enabled=no
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
/tool sniffer
set memory-limit=4096KiB
