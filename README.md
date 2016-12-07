# alpine-inside
Base docker-in-docker build

# SSH
SSH is enabled, but without password authentication, only key
Either add a script to put your pubkey in authorized_keys (with correct permissions)
Or put it in inside-home volume (mounted in ./run) (check permissions)
Set username in ./env ($MYSSH_USER)

# Network
Separate network is created on 172.50.0.0/30, edit in ./env
$DOCKER_NETWORK - set network name, comment out to use default (bridge)
$DOCKER_SUBNET - subnet, must be set if DOCKER_NETWORK is set


