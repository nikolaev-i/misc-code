#Experimenting with networking using Docker
#Two subnets, client, router and a webserver

# Create Custom Networks


# Subnet A (192.168.10.0/24)
docker network create --subnet=192.168.10.0/24 subnet_a

# Subnet B (192.168.20.0/24)
docker network create --subnet=192.168.20.0/24 subnet_b



# Launch Router Container
docker run -dit \
  --name router \
  --net subnet_a --ip 192.168.10.1 \
  --privileged \
  alpine sh

# Connect Router to Subnet B
docker network connect --ip 192.168.20.1 subnet_b router

# Install iptables in the Router
docker exec -it router sh -c "apk add --no-cache iptables"

# Enable IP Forwarding and Configure NAT in Router
docker exec -it router sh -c "echo '1' > /proc/sys/net/ipv4/ip_forward && iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"

# Launch Web Server Container
docker run -dit \
  --name web_server \
  --net subnet_a --ip 192.168.10.2 \
  nginx

# Launch Client Container
docker run -dit \
  --name client \
  --net subnet_b --ip 192.168.20.2 \
  alpine sh

# Set the default gateway for the client container
docker exec -it client sh -c "ip route add default via 192.168.20.1"

# Testing: Fetch webpage from the client
docker exec -it client sh -c "wget -qO- http://192.168.10.2"


