#!/bin/ash

echo "#====================================================================================================#"
echo "# edit this script and change the values below before running.                                       #"
echo "# more on this script:                                                                               #"
echo "https://openwrt.org/docs/guide-user/services/vpn/wireguard/automated#a_named_peers_with_ids          #"
echo "# https://github.com/amnezia-vpn/amneziawg-linux-kernel-module?tab=readme-ov-file#configuration      #"
echo "# Jc — 1 ≤ Jc ≤ 128; recommended range is from 4 to 12 inclusive                                     #"
echo "# Jmin — Jmax > Jmin < 1280*; recommended value is 8                                                 #"
echo "# Jmax — Jmin < Jmax ≤ 1280*; recommended value is 80                                                #"
echo "# S1 — S1 ≤ 1132* (1280* - 148 = 1132); S1 + 56 ≠ S2; recommended range is from 15 to 150 inclusive  #"
echo "# S2 — S2 ≤ 1188* (1280* - 92 = 1188); recommended range is from 15 to 150 inclusive                 #"
echo "# H1/H2/H3/H4 — must be unique among each other; recommended range is from 5 to 2147483647 inclusive #"
echo "# * Assuming a basic internet connection with an MTU value of 1280.                                  #"
echo "#====================================================================================================#"
sleep 4

export JC="0"
export JMIN="0"
export JMAX="0"
export S1="0"
export S2="0"
export S3="0"
export S4="0"
export H1="0"
export H2="0"
export H3="0"
export H4="0"
export I1="0"
export I2="0"
export I3="0"
export I4="0"
export I5="0"

clear
echo "======================================"
echo "|     Automated AmneziaWG Script     |"
echo "|        Named Peers with IDs        |"
echo "======================================"
# Define Variables
echo -n "Defining variables... "
export LAN="lan"
export interface="10.0.10"
export DDNS="website.ddns.com"
export peer_ID="1" # The ID number to start from
export peer_IP="2" # The IP address to start from
export AWG_${LAN}_server_port="51820"
export AWG_${LAN}_server_IP="${interface}.1"
export AWG_${LAN}_server_firewall_zone="${LAN}"
export quantity="4" # Change the number '4' to any number of peers you would like to create
export user_1="Alpha"
export user_2="Bravo"
export user_3="Charlie"
export user_4="Delta"


echo "Done"

# Create directories
echo -n "Creating directories and pre-defining permissions on those directories... "
mkdir -p /etc/amnezia/networks/${LAN}/peers
echo "Done"

# Remove pre-existing AmneziaWG interface
echo -n "Removing pre-existing AmneziaWG interface... "
uci del network.awg_${LAN} >/dev/null 2>&1
echo "Done"

# Generate AmneziaWG server keys
echo -n "Generating AmneziaWG server keys for '${LAN}' network... "
awg genkey | tee "/etc/amnezia/networks/${LAN}/${LAN}_server_private.key" | awg pubkey | tee "/etc/amnezia/networks/${LAN}/${LAN}_server_public.key" >/dev/null 2>&1
echo "Done"

echo -n "Rename firewall.@zone[0] to lan and firewall.@zone[1] to wan... "
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
echo "Done"

# Create AmneziaWG interface for 'LAN' network
echo -n "Creating AmneziaWG interface for '${LAN}' network... "
eval "server_port=\${AWG_${LAN}_server_port}"
eval "server_IP=\${AWG_${LAN}_server_IP}"
eval "firewall_zone=\${AWG_${LAN}_server_firewall_zone}"
uci set network.awg_${LAN}=interface
uci set network.awg_${LAN}.proto='amneziawg'
uci set network.awg_${LAN}.private_key="$(cat /etc/amnezia/networks/${LAN}/${LAN}_server_private.key)"
uci set network.awg_${LAN}.listen_port="${server_port}"
uci add_list network.awg_${LAN}.addresses="${server_IP}/24"
uci set firewall.${LAN}.network="${firewall_zone} awg_${firewall_zone}"
uci set network.awg_${LAN}.mtu='1420'
uci set network.awg_${LAN}.awg_jc="${JC}"
uci set network.awg_${LAN}.awg_jmin="${JMIN}"
uci set network.awg_${LAN}.awg_jmax="${JMAX}"
uci set network.awg_${LAN}.awg_s1="${S1}"
uci set network.awg_${LAN}.awg_s2="${S2}"
uci set network.awg_${LAN}.awg_s3="${S3}"
uci set network.awg_${LAN}.awg_s4="${S4}"
uci set network.awg_${LAN}.awg_h1="${H1}"
uci set network.awg_${LAN}.awg_h2="${H2}"
uci set network.awg_${LAN}.awg_h3="${H3}"
uci set network.awg_${LAN}.awg_h4="${H4}"
uci set network.awg_${LAN}.awg_i1="${I1}"
uci set network.awg_${LAN}.awg_i2="${I2}"
uci set network.awg_${LAN}.awg_i3="${I3}"
uci set network.awg_${LAN}.awg_i4="${I4}"
uci set network.awg_${LAN}.awg_i5="${I5}"
echo "Done"

# Add firewall rule
echo -n "Adding firewall rule for '${LAN}' network... "
uci set firewall.awg="rule"
uci set firewall.awg.name="Allow-AmneziaWG-${LAN}"
uci set firewall.awg.src="wan"
uci set firewall.awg.dest_port="${server_port}"
uci set firewall.awg.proto="udp"
uci set firewall.awg.target="ACCEPT"
echo "Done"

# Remove existing peers
echo -n "Removing pre-existing peers... "
while uci -q delete network.@amneziawg_awg_${LAN}[0]; do :; done
rm -R /etc/amnezia/networks/${LAN}/peers/* >/dev/null 2>&1
echo "Done"

# Loop
n="0"
while [ "$n" -lt ${quantity} ] ;
do

	for username in ${user_1} ${user_2} ${user_3} ${user_4}
	do

		# Configure variables
		eval "peer_ID_${username}=${peer_ID}"
		eval "peer_IP_${username}=${peer_IP}"

		eval "peer_ID=\${peer_ID_${username}}"
		eval "peer_IP=\${peer_IP_${username}}"

		eval "server_port=\${AWG_${LAN}_server_port}"
		eval "server_IP=\${AWG_${LAN}_server_IP}"

		echo ""
		# Create directory for storing peers
		echo -n "Creating directory for peer '${peer_ID}_${LAN}_${username}'... "
		mkdir -p "/etc/amnezia/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}"
		echo "Done"

		# Generate peer keys
		echo -n "Generating peer keys for '${peer_ID}_${LAN}_${username}'... "
		awg genkey | tee "/etc/amnezia/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_private.key" | awg pubkey | tee "/etc/amnezia/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_public.key" >/dev/null 2>&1
		echo "Done"

		# Generate Pre-shared key
		echo -n "Generating peer PSK for '${peer_ID}_${LAN}_${username}'... "
		awg genpsk | tee "/etc/amnezia/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk" >/dev/null 2>&1
		echo "Done"

		# Add peer to server
		echo -n "Adding '${peer_ID}_${LAN}_${username}' to AmneziaWG server... "
		uci add network amneziawg_awg_${LAN} >/dev/null 2>&1
		uci set network.@amneziawg_awg_${LAN}[-1].public_key="$(cat /etc/amnezia/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_public.key)"
		uci set network.@amneziawg_awg_${LAN}[-1].preshared_key="$(cat /etc/amnezia/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk)"
		uci set network.@amneziawg_awg_${LAN}[-1].description="${peer_ID}_${LAN}_${username}"
		uci add_list network.@amneziawg_awg_${LAN}[-1].allowed_ips="${interface}.${peer_IP}/32"
		uci set network.@amneziawg_awg_${LAN}[-1].route_allowed_ips='1'
		uci set network.@amneziawg_awg_${LAN}[-1].persistent_keepalive='25'
		echo "Done"

		# Create peer configuration
		echo -n "Creating config for '${peer_ID}_${LAN}_${username}'... "
		cat <<-EOF > "/etc/amnezia/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.conf"
		[Interface]
		Address = ${interface}.${peer_IP}/32
		PrivateKey = $(cat /etc/amnezia/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}_private.key) # Peer's private key
		DNS = ${server_IP}
		Jc = ${JC}
		Jmin = ${JMIN}
		Jmax = ${JMAX}
		S1 = ${S1}
		S2 = ${S2}
		S3 = ${S3}
		S4 = ${S4}
		H1 = ${H1}
		H2 = ${H2}
		H3 = ${H3}
		H4 = ${H4}
		I1 = ${I1}
		I2 = ${I2}
		I3 = ${I3}
		I4 = ${I4}
		I5 = ${I5}

		[Peer]
		PublicKey = $(cat /etc/amnezia/networks/${LAN}/${LAN}_server_public.key) # Server's public key
		PresharedKey = $(cat /etc/amnezia/networks/${LAN}/peers/${peer_ID}_${LAN}_${username}/${peer_ID}_${LAN}_${username}.psk) # Peer's pre-shared key
		PersistentKeepalive = 25
		AllowedIPs = 0.0.0.0/0, ::/0
		Endpoint = ${DDNS}:${server_port}
		EOF
		echo "Done"

		# Increment variables by '1'
		peer_ID=$((peer_ID+1))
		peer_IP=$((peer_IP+1))
		n=$((n+1))
	done
done

# Commit UCI changes
echo -en "\nCommiting changes... "
uci commit
echo "Done"

# Restart AmneziaWG interface
echo -en "\nRestarting AmneziaWG interface... "
ifup awg_${LAN}
echo "Done"

# Restart firewall
echo -en "\nRestarting firewall... "
service firewall restart >/dev/null 2>&1
echo "Done"
