#!/bin/sh

TMP1="/tmp/temp_gfwlist1"
TMP2="/tmp/temp_gfwlist2"
TMP3="/tmp/temp_gfwlist3"
TMP_ALL="/tmp/temp_gfwlist"

# 下载源
wget -qO- https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt | \
    base64 -d | sort -u | sed '/^$\|@@/d'| sed 's#!.\+##; s#|##g; s#@##g; s#http:\/\/##; s#https:\/\/##;' | \
    sed '/apple\.com/d; /sina\.cn/d; /sina\.com\.cn/d; /baidu\.com/d; /qq\.com/d' | \
    sed '/^[0-9]\+\.[0-9]\+\.[0-9]\+$/d' | grep '^[0-9a-zA-Z\.-]\+$' | \
    grep '\.' | sed 's#^\.\+##' | sort -u > "$TMP1"

wget -qO- https://raw.githubusercontent.com/hq450/fancyss/master/rules/gfwlist.conf | \
    sed 's/ipset=\/\.//g; s/\/gfwlist//g; /^server/d' > "$TMP2"

wget -qO- https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/gfw.txt > "$TMP3"

# 合并处理
cat "$TMP1" "$TMP2" "$TMP3" | sort -u | sed 's/^\.*//g' > "$TMP_ALL"

# 生成 gfw.conf
{
    echo "# gfw.conf generated at $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    cat "$TMP_ALL" | sed 's/^/\./g'
} > gfw.conf

sed -i 's/^/domain-rules \//' gfw.conf
sed -i 's/$/\/GFW/' gfw.conf
sed -i 's/GFW/ -nameserver ext -ipset ext -address #6/g' gfw.conf
sed -i 's/domain-rules \/./domain-rules \//' gfw.conf
sed -i 's/\/\./\//g' gfw.conf
