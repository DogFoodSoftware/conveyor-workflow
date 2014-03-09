#!/bin/bash

#/**
#* <pre>
#* Feature: sync
#*
#* Scenario: Sync discovers (non-current) topic closed.
#*
#* Given 'conveyor-workflow' is installed
#*   And I have cloned a conveyor-workflow repository
#*   And I have started topic '1-foo' and published changes
#*   And I am currontly on master
#*   And '1-foo' has been deleted, but not merged into master
#* When I type 'con topics sync'
#* Then I remain on the 'master' branch
#*   And the local topic branch remains intact
#*   And "Current topic '1-foo' abandoned on origin. Local branch left intact. Please abandon or re-start." is printed to stdout
#*   And the script exits with 0.
#* </pre>
#*/
