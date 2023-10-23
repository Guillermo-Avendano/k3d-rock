#!/bin/bash

export USR=2002
export GRP=4004

cd /volume/ip
mkdir -p MobiusRemoteCLI
mkdir -p audit
chown -R $USR:$GRP audit/
chown -R $USR:$GRP MobiusRemoteCLI/
chmod 777 templates/
cd MobiusRemoteCLI

echo "#!/bin/bash" > /volume/ip/MobiusRemoteCLI/acreate.sh
echo "PATH=/opt/asg/java/bin:\$PATH" >> /volume/ip/MobiusRemoteCLI/acreate.sh
echo "java -D\"log4j.configurationFile=/volume/ip/MobiusRemoteCLI/BOOT-INF/classes/log4j2.yaml\" -jar /volume/ip/MobiusRemoteCLI/acreate-cli.jar acreate \$@" >> /volume/ip/MobiusRemoteCLI/acreate.sh

echo "#!/bin/bash" > /volume/ip/MobiusRemoteCLI/MobiusRemoteCLIsmall.sh
echo "PATH=/opt/asg/java/bin:\$PATH" >> /volume/ip/MobiusRemoteCLI/MobiusRemoteCLIsmall.sh
echo "java -cp \"/volume/ip/MobiusRemoteCLI/BOOT-INF/classes:/volume/ip/MobiusRemoteCLI/BOOT-INF/lib/*\" com.asg.mobiuscli.MobiusCliApplication \$@" >> /volume/ip/MobiusRemoteCLI/MobiusRemoteCLIsmall.sh


tar xvf /inbox/MobiusRemoteCLI.tar
chown -R $USR:$GRP BOOT-INF/
chown $USR:$GRP *.sh
chown $USR:$GRP *.jar
chmod 777 *.sh
