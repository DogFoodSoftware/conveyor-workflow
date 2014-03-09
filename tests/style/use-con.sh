#!/bin/bash

#/**
#* <pre>
#* Feature: Code style
#*
#* Scenario: Coud should use 'con' ratherthan 'git convey' except when necessary.
#* Given the code basae
#* When I search for 'git convey', excluding this file
#* Then I find one reference in the <code>con</code> script
#*   And I find one refernece in the <code>conveyor-workflow</code> script.
#* </pre>
#*/

cd `dirname $0`/../..
FILES=(`find . -type f -not -name "*~" -not -path "*/.git/*" -not -path "./tests/style/use-con.sh" | xargs grep 'git convey' | cut -d: -f1`)
if [ ${#FILES[@]} -ne 2 ]; then
    echo "ERROR: Expected 2 references to 'git convey', but got ${#FILES[@]}."
fi
for (( i=0; i < ${#FILES[@]}; i++ )); do
    if [ ${FILES[$i]} != './src/conveyor-workflow' ] && [ ${FILES[$i]} != './src/con' ]; then
	echo "ERROR: unexpected reference to conveyor-workflow: ${FILES[$i]}."
    fi
done
