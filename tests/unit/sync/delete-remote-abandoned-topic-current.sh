#/**
#* <pre>
#* Feature: sync
#*
#* Scenario: Sync discovers (non-current) topic abandoned.
#*
#* Given 'git-convey' is installed
#*   And I have cloned a git-convey repository
#*   And I have started topic '1-foo' and published changes
#*   And I am currently on 'topics-1-foo'
#*   And '1-foo' has been deleted, but not merged into master
#* When I type 'con topics sync'
#* Then I remain on the 'topics-1-foo' branch
#*   And the local topic branch remains intact
#*   And "Current topic '1-foo' abandoned on origin. Local branch left intact. Please abandon or re-start." is printed to stdout
#*   And the script exits with 0.
#* </pre>
#*/
