#!/bin/sh

cores=$(nproc)

max=$(cgget -nvr cpu.cfs_period_us $(cat conf/cgroup))
val=$max

echo "cores: $cores, max: $max"
while read adjust; do
    newadjust=$((adjust*cores))
    newval=$((val+newadjust))
    ratio=$((newval/max))
    echo "got $adjust, setting to $newval / $max ($ratio)"
    cgset -r cpu.cfs_quota_us=$newval $(cat conf/cgroup)
    val=$newval
done

#end: set low value
#cgset -r cpu.cfs_quota_us=$((10000*cores)) $(cat conf/cgroup)
