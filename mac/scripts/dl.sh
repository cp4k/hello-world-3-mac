#!/bin/sh -e

# The Makefile calls this script like this:
#   cat something.dl.txt | xargs ./dl.sh something.txt
#
# something.dl.txt has three lines: the first is a URL to a tarball, the second
# is the SHA256 hash of it, and the third is the name of the directory it
# untars to.
#
# This script downloads the tarball, unpacks it, and moves it so its name
# matches the .dl.txt file (but without the .dl.txt extension.)

INFILE=$1
URL=$2
SHA256=$3
TARDIR=$4

OUTDIR="${INFILE%".dl.txt"}"
DLFILENAME="$(basename "$OUTDIR").tar.gz"

# If the folder already exists, move it out of the way.
[ -d "$OUTDIR" ] && mv "$OUTDIR" "$OUTDIR.bak-$(date '+%Y-%m-%d-at-%H-%M-%S.%s')"

cd "$(dirname "$INFILE")"
curl "$URL" --output "$DLFILENAME" -L
echo "$SHA256  $DLFILENAME" | shasum -a 256 -c
tar -xvf "$DLFILENAME"
mv "$TARDIR" "$(basename "$OUTDIR")"
rm $DLFILENAME
touch "$(basename "$OUTDIR")"