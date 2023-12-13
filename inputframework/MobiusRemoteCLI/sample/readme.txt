

/volume/ip/MobiusRemoteCLI/MobiusRemoteCLIsmall.sh vdrdbxml -s Mobius -u ADMIN -f /inbox/AC2020_Definitions.xml -o /inbox/AC2020_Definitions.out -v 2
 
/volume/ip/MobiusRemoteCLI/acreate.sh -s Mobius -u ADMIN -f /inbox/AC2020_1.txt -r AC2020 -c AP_AC2020_v1 -v 2

/volume/ip/MobiusRemoteCLI/acreate.sh -s Mobius -u ADMIN -f /inbox/vader111.RDW -r VADERXEROX -c VADER_XEROX -v 2


/volume/ip/MobiusRemoteCLI/MobiusRemoteCLIsmall.sh vdrdbxml -s Mobius -u ADMIN -f /inbox/CECA.xml -o /inbox/CECA.out -v 2

/volume/ip/MobiusRemoteCLI/acreate.sh -s Mobius -u ADMIN -f /mnt/c/Rocket.Git/k3d-rock/mobius/monitor_acreate/vader111.RDW -r VADER -c CECABANK -v 2


acreate -s vdrnetdsc -u ADMIN -f /tmp/vader111.RDW -r VADER111 -c CECABANK -v 2
