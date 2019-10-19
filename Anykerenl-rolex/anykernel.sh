# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Hoi Bro!
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=redmi4a
device.name2=rolex
supported.versions=7.0 - 10.0
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel install
dump_boot;
write_boot;
## end install
