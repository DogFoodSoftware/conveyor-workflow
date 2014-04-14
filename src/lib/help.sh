#/**
#  *   <div class="subHeader">Helper Functions and Usage Check</div>
#  *   <div class="p">
#  *     It's bash, so helper funtctions have to come first.
#  *   </div>
#  */

global_help() {
    echo "Use 'con help [<resource> [<action>]]' for details and refer to "
    echo "http://dogfoodsoftware.com/documentatione/conveyor/ref/Branching-Strategy for"
    echo "more on the underlying branch strategy which conveyor-workflow implements."
    echo
}

# /**
#  * <div class="subHeader"><span>usage()</span></div>
#  * <div class="p">
#  *   Prints usage information for the <code>conveyor-workflow</code> script. Takes a
#  *   single optional argument, which is interpretted as a string containing
#  *   additional information about whyt he usage is being displayed. The error
#  *   is printed to <code>stderr</code>.
#  * </div>
#  */
usage() {
    if [ x"$1" != x"" ]; then
	echo $1 >&2
	echo >&2
    fi

    echo "usage: con <resource|global action>"
    echo
    echo "Available resources:"
    echo "   topics    Manage topics / topic branches."
    echo "   releases  Manage releases."
    echo
    echo "Available global actions:"
    echo "   sync      Clones and synchronizes local repo with origin."
    echo "   -s        Set implied resource."
    echo "   help      Prints this help."
    echo
    global_help
}
