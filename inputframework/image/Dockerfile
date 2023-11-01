FROM asgthorstenk/inputframework_tef:4.8

ENV MOBIUS_REMOTE_CLI_PATH=/opt/MobiusRemoteCLI

ENV PATH=$PATH:$MOBIUS_REMOTE_CLI_PATH/

RUN mkdir -p $MOBIUS_REMOTE_CLI_PATH


COPY ./BOOT-INF ${MOBIUS_REMOTE_CLI_PATH}/BOOT-INF/
COPY ./acreate-cli.jar ${MOBIUS_REMOTE_CLI_PATH}/acreate-cli.jar
COPY ./acreate.sh ${MOBIUS_REMOTE_CLI_PATH}/acreate.sh
COPY ./MobiusRemoteCLI.sh ${MOBIUS_REMOTE_CLI_PATH}/MobiusRemoteCLI.sh
COPY ./MobiusRemoteCLIsmall.sh ${MOBIUS_REMOTE_CLI_PATH}/MobiusRemoteCLIsmall.sh


