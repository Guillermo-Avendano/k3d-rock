

/volume/ip/MobiusRemoteCLI/MobiusRemoteCLIsmall.sh vdrdbxml -s Mobius -u ADMIN -f /inbox/AC2020_Definitions.xml -o /inbox/AC2020_Definitions.out -v 2
 
/volume/ip/MobiusRemoteCLI/acreate.sh -s Mobius -u ADMIN -f /inbox/AC2020_1.txt -r AC2020 -c AP_AC2020_v1 -v 2

/volume/ip/MobiusRemoteCLI/acreate.sh -s Mobius -u ADMIN -f /inbox/vader111.RDW -r VADERXEROX -c VADER_XEROX -v 2


/volume/ip/MobiusRemoteCLI/MobiusRemoteCLIsmall.sh vdrdbxml -s Mobius -u ADMIN -f /inbox/test_policy.PLC.xml -o /inbox/test_policy.PLC.out -v 2

/volume/ip/MobiusRemoteCLI/acreate.sh -s Mobius -u ADMIN -f /inbox/vader111.RDW -r AC2020 -c VADER_DJDE -v 2


acreate -s vdrnetdsc -u ADMIN -f /tmp/vader111.RDW -r AC2020 -c VADER_DJDE -v 2
