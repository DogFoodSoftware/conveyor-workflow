#!/bin/bash

TEST_DIR=`dirname $0`
TEST_DIR=`realpath $TEST_DIR`
SELF=`basename $0`

cd $TEST_DIR

TEST_SCRIPTS=`find . -not -path "./data/*" -not -path "./lib/*" -name "*.sh" -not -name "$SELF"`

for i in $TEST_SCRIPTS; do
    echo "Running ${i}..."
    bash $i
done
