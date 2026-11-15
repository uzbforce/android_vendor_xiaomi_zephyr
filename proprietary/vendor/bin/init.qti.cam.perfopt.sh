#!/system/bin/sh

SYS_WATERMARK=90
SYS_SWAPPINESS=130
CAM_STATUS=$(getprop vendor.camera.vm.status)

drop_page_caches() {
    MemFreeStr=$(cat /proc/meminfo | grep MemFree)
    MemFree=${MemFreeStr:16:8}
    if [ $MemFree -lt 153600 ]; then
        echo 1 > /proc/sys/vm/drop_caches
    fi
}

if [ "$CAM_STATUS" == "open" ]; then
    SYS_WATERMARK=$(cat /proc/sys/vm/watermark_scale_factor)
    SYS_SWAPPINESS=$(cat /proc/sys/vm/swappiness)
    setprop vendor.camera.vm.watermark_bak $SYS_WATERMARK
    setprop vendor.camera.vm.swappiness_bak $SYS_SWAPPINESS

    echo 150 > /proc/sys/vm/watermark_scale_factor
    echo 10 > /proc/sys/vm/swappiness

    drop_page_caches

elif [ "$CAM_STATUS" == "close" ]; then
    SYS_WATERMARK=$(getprop vendor.camera.vm.watermark_bak)
    SYS_SWAPPINESS=$(getprop vendor.camera.vm.swappiness_bak)
    echo $SYS_WATERMARK > /proc/sys/vm/watermark_scale_factor
    echo $SYS_SWAPPINESS > /proc/sys/vm/swappiness
fi