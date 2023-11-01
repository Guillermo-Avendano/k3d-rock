#!/bin/bash

# locate directory shell is sourced from
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SRC_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$SRC_DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SRC_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

if [[ "$1" = "acreate" ]] ; then
  # test for existence of required class files
  CLASS_FILE=$SRC_DIR/acreate-cli.jar
  # start java command line
  CMDLN="java -D\"log4j.configurationFile=BOOT-INF/classes/log4j2.yaml\" -jar $SRC_DIR/acreate-cli.jar "
else   
  # test for existence of required class files
  CLASS_FILE=$SRC_DIR/BOOT-INF/classes/com/asg/mobiuscli/MobiusCliApplication.class
  # start java command line
  CMDLN="java -cp \"BOOT-INF/classes:BOOT-INF/lib/*\" com.asg.mobiuscli.MobiusCliApplication "
fi

if test -f "$CLASS_FILE"; then
    # remove old run file if it exists
    if test -f mobiuscli_run.sh; then
        rm mobiuscli_run.sh
    fi

    for var in "$@"
        do
        # examine each command line argument
        if [[ $var = *[[:space:]]* ]]
        then
            # if it contains embedded spaces add to java command line
            # enclosed in escaped double quotes, and convert spaces
            # to a non-printing 7-bit ASCII character
            CMDLN="$CMDLN \"$(echo "$var" | tr " "  "\037")\""
        elif [[ $var = *\\* ]]
        then
            # if it contains embedded backslash, add it to java command line
            # enclosed in single quotes, and convert backslash
            # to non-printing 7-bit ASCII character "FILE SEPARATOR (FS) RIGHT ARROW",
            # its values are DEC: 28, HEX:1C and OCT: 034
            CMDLN="$CMDLN '$(echo "$var" | tr "\\"  "\034" 2> /dev/null)'"
        else
            # add argument to java command line
            CMDLN="$CMDLN $var"
        fi
    done

    # initialize temp script with crunchbang and lock it down
    echo '#!/usr/bin/bash' >mobiuscli_run.sh
    chmod 700 mobiuscli_run.sh

    # write java command line to temporary shell script
    # converting any non-printing chars back to spaces and FILE SEPARATOR("\034") back to backslash
    echo $CMDLN  | tr "\037" " " | tr "\034" "\\" 2> /dev/null >> mobiuscli_run.sh

    # make the temporary script executable and run it
    bash mobiuscli_run.sh

    # remove temporary script file
    rm mobiuscli_run.sh
else 
    echo "Cannot find required MobiusRemoteCLI classes in $SRC_DIR"
fi