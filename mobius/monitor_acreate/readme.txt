pushd /mnt/c/Rocket/DataSampler
. ./MobiusRemoteCLI.sh adelete -s Mobius -u ADMIN -r AC2020 -c -n -y vfd
popd

pushd /mnt/c/Rocket/DataSampler
. ./MobiusRemoteCLI.sh adelete -s Mobius -u ADMIN -r Jobs -c -n -y vfd
. ./MobiusRemoteCLI.sh adelete -s Mobius -u ADMIN -r JOBLOGS -y vf -t 20241231000000
popd

pushd /mnt/c/Rocket/DataSampler
. ./MobiusRemoteCLI.sh vdrdbxml -s Mobius -u ADMIN -f /mnt/c/Rocket.Git/k3d-rock/mobius/monitor_acreate/Jobs_index.xml -o /mnt/c/Rocket.Git/k3d-rock/mobius/monitor_acreate/Jobs_index.out -v 2
popd

pushd /mnt/c/Rocket/DataSampler
. ./MobiusRemoteCLI.sh vdrdbxml -s Mobius -u ADMIN -f /mnt/c/Rocket.Git/k3d-rock/mobius/monitor_acreate/getall.xml -o /mnt/c/Rocket.Git/k3d-rock/mobius/monitor_acreate/getall.out.xml -v 2
popd

