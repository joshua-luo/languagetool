#!/bin/bash
# re-build LT and run it on the given text file (e.g. Tatoeba) and
# show a diff to the previous results (if any)

CURRENT_DIR=`pwd`
CURRENT_BASE=`basename $CURRENT_DIR`
if [ "$(basename $CURRENT_DIR)" != 'scripts' ]; then
    echo "Error: Please start this script from inside the 'scripts' directory";
    exit 1;
fi

if [ $# -ne 3 ]
then
  echo "Usage: `basename $0` <langCode> <inputFile> <maxLines>"
  exit 2;
fi
LANGUAGE=$1
INPUT=$2
MAX=$3
TEMP_FILE=/tmp/languagetool-regression-test-input.txt

cd ../..
mv regression-test-output.log regression-test-output.log.bak

./build.sh languagetool-standalone package -DskipTests && \
  head -n $MAX $INPUT >$TEMP_FILE && \
  pv $TEMP_FILE | java -jar languagetool-standalone/target/LanguageTool-*-SNAPSHOT/LanguageTool-*-SNAPSHOT/languagetool-commandline.jar \
      --language $LANGUAGE | sed -e 's/[0-9]\+.) Line [0-9]\+, column [0-9]\+, //' >regression-test-output.log

cd -
rm $TEMP_FILE

if [ -e ../../regression-test-output.log.bak ]
then
  CMD="diff -u ../../regression-test-output.log.bak ../../regression-test-output.log"
  $CMD | less
  echo "========================================================================================================"
  echo "Run '$CMD' to see the diff again."
else
  echo "========================================================================================================"
  echo "No regression-test-output.log.bak file found. Make your changes and run this script again to see a diff."
  echo "The check result has been saved to ../../regression-test-output.log"
fi
