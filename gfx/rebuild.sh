#!/bin/bash

echo Rebuilding Graphics Files

for tileset in classic distorted adambolt nethack ascii ibsongrey akoimeexx akoi12 akoi10 lomaka ; do
	pushd $tileset
	echo Building tiles...
	tile2c
	popd
done

pushd akoi3x
    echo Building Akoi3x
    gzip -d -c sprite16_3x.bmp.gz > sprite16_3x.bmp
    bmp2c sprite16_3x.bmp
popd

echo Building Background images..
bmp2c tridude_goodbye.bmp
bmp2c tridude_goodbye_hires.bmp
bmp2c icon_sdl.bmp

echo Dirtying build...
rm -f all_bitmaps.o
