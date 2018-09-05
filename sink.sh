#!/bin/sh

cores=$(nproc)

max=$(cgget -nvr cpu.cfs_period_us $(cat conf/cgroup))
max_allcores=$((max*cores))
val=$max

echo "cores: $cores, max: $max"
while read adjust; do
    newadjust=$((adjust*cores))
    newval=$((val+newadjust))
    if [ $newval -lt 0 ]; then
	newval=0
    elif [ $newval -gt $max_allcores ]; then
	newval=$max_allcores
    fi
    ratio=$((newval/max))
    echo "got $adjust, setting to $newval / $max_allcores ($ratio)"
    cgset -r cpu.cfs_quota_us=$newval $(cat conf/cgroup)
    val=$newval
done

#end: set low value
#cgset -r cpu.cfs_quota_us=$((10000*cores)) $(cat conf/cgroup)
