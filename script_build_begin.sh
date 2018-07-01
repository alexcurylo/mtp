#!/bin/sh

# undone work warnings

TAGS="TODO:|FIXME:|\?\?\?:|\!\!\!:"
echo "searching ${SRCROOT} for ${TAGS}"
find "${SRCROOT}/MTP" "${SRCROOT}/MTPTests" "${SRCROOT}/MTPUITests" \( -name "*.swift" -or -name "*.m" -or -name "*.h" \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($TAGS).*\$" | perl -p -e "s/($TAGS)/ warning: \$1/"

# finished

return 0
