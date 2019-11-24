#!/bin/sh -e

INFILE=$1
URL=$2
SHA256=$3
TARDIR=$4

OUTDIR="${INFILE%".dl.txt"}"
DLFILENAME="$(basename "$OUTDIR").tar.gz"

[ -d "$OUTDIR" ] && mv "$OUTDIR" "$OUTDIR.bak-$(date '+%Y-%m-%d-at-%H-%M-%S.%s')"

cd "$(dirname "$INFILE")"
curl "$URL" --output "$DLFILENAME" -L
echo "$SHA256  $DLFILENAME" | shasum -a 256 -c
tar -xvf "$DLFILENAME"
mv "$TARDIR" "$(basename "$OUTDIR")"
rm $DLFILENAME