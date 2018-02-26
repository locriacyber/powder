#!/bin/csh

echo If this fails due to trying to write
echo to allrooms.cpp, make sure you do not
echo have MSVC running, as it is trying to
echo do an auto-load and thrashing.

echo Compiling rooms...

set nummap = `ls -r *.map | wc -w`

foreach s (*.map)
    echo Compiling $s...
    map2c $s $s:r.cpp
end

echo Building header file...
echo "// Auto-generated .h file" > allrooms.h
echo "// DO NOT HAND EDIT" >> allrooms.h
echo "// Generated by buildrooms.sh" >> allrooms.h
echo " " >> allrooms.h
echo "#define NUM_ALLROOMDEFS $nummap" >> allrooms.h
echo "extern const ROOM_DEF *glb_allroomdefs[$nummap+1];" >> allrooms.h

echo Building .cpp file..
echo "// Auto-generated .cpp file" > allrooms.cpp
echo "// DO NOT HAND EDIT" >> allrooms.cpp
echo "// Generated by buildrooms.sh" >> allrooms.cpp
echo " " >> allrooms.cpp
echo '#include "../map.h"' >> allrooms.cpp

foreach s (*.map)
    echo -n '#include "' >> allrooms.cpp
    echo -n $s:r.cpp >> allrooms.cpp
    echo '"' >> allrooms.cpp
end 

echo " " >> allrooms.cpp

echo "const ROOM_DEF *glb_allroomdefs[$nummap+1] =" >> allrooms.cpp
echo "{" >> allrooms.cpp
foreach s (*.map)
    echo "	&glb_$s:r_roomdef," >> allrooms.cpp
end
echo "	0" >> allrooms.cpp
echo "};" >> allrooms.cpp