#!/bin/bash

TEST_DIR=`dirname $0`
TEST_DIR=`realpath $TEST_DIR`
SELF=`basename $0`

if [ $# -gt 0 ]; then
    FIND_PATH="$1"
else
    FIND_PATH="."
fi

cd $TEST_DIR

TEST_SCRIPTS=`find $FIND_PATH -not -path "./data/*" -not -path "*/lib/*" -name "*.sh" -not -name "$SELF" -not -name ".#*"`

for i in $TEST_SCRIPTS; do
    echo "Running ${i}..."
    bash $i
done

if [ -f $HOME/.conveory-workflow/implied-resources ]; then
    rm $HOME/.conveyor-workflow/implied-resource
fi
