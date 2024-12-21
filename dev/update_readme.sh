#!/usr/bin/env bash

set -eou pipefail

# Get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Remove everyline in ../README.md between the following comments
#
# <!--AUTO-GENERATED-DOCS-BEGIN-->
#
# <!--AUTO-GENERATED-DOCS-END-->

# Find the line numbers of the comments
BEGINNING_LINE_NUMBER=$(grep -n "<!--AUTO-GENERATED-DOCS-BEGIN-->" $DIR/../README.md | cut -f1 -d:)
ENDING_LINE_NUMBER=$(grep -n "<!--AUTO-GENERATED-DOCS-END-->" $DIR/../README.md | cut -f1 -d:)
BEGINNING_LINE_NUMBER=$(($BEGINNING_LINE_NUMBER + 1))
ENDING_LINE_NUMBER=$(($ENDING_LINE_NUMBER - 1))

# Create the new content in a temporary file and use $DIR/generate_docs.py to generate the content
cat $DIR/../README.md | head -n $(($BEGINNING_LINE_NUMBER - 1)) > $DIR/../README.md.bak
$DIR/generate_docs.py >> $DIR/../README.md.bak
cat $DIR/../README.md | tail -n +$(($ENDING_LINE_NUMBER + 1)) >> $DIR/../README.md.bak

# Replace the old README.md with the new one
mv $DIR/../README.md.bak $DIR/../README.md
