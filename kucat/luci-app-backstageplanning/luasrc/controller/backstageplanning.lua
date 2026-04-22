module("luci.controller.backstageplanning", package.seeall)

function index()
    if luci.sys.call("[ -x /usr/bin/backstageplanning ]") ~= 0 then
        return
    end
    entry({"admin", "services", "backstageplanning"}, call("action_index"), _("后台规划"), 10)
end

function action_index()
    local uci = require("luci.model.uci").cursor()
    local http = require("luci.http")
    local sys = require("luci.sys")
    local template = require("luci.template")

    if http.formvalue("save") then
        local new_proto = http.formvalue("proto")
        if new_proto == "static" then
            uci:set("network", "lan", "proto", "static")
            uci:set("network", "lan", "ipaddr", http.formvalue("ip"))
            uci:set("network", "lan", "netmask", http.formvalue("mask"))
            uci:set("network", "lan", "gateway", http.formvalue("gw"))
            uci:set("network", "lan", "broadcast", http.formvalue("bcast"))

            -- 修复：使用 set_list 替代 add_list
            local dns_str = http.formvalue("dns") or ""
            uci:delete("network", "lan", "dns")
            if dns_str ~= "" then
                local dns_list = {}
                for dns in string.gmatch(dns_str, "[^%s]+") do
                    table.insert(dns_list, dns)
                end
                if #dns_list > 0 then
                    uci:set_list("network", "lan", "dns", dns_list)
                end
            end

            uci:set("network", "lan", "peerdns", "0")
            uci:set("network", "lan", "delegate", "0")
        else
            uci:set("network", "lan", "proto", "dhcp")
            uci:delete("network", "lan", "ipaddr")
            uci:delete("network", "lan", "netmask")
            uci:delete("network", "lan", "gateway")
            uci:delete("network", "lan", "broadcast")
            uci:delete("network", "lan", "dns")
            uci:delete("network", "lan", "peerdns")
            uci:delete("network", "lan", "delegate")
        end

        uci:commit("network")
        sys.exec("/etc/init.d/network restart >/dev/null 2>&1 &")

        http.prepare_content("text/html; charset=utf-8")
        http.write([[
            <!DOCTYPE html>
            <html><head><meta charset="utf-8"><title>网络重启中</title></head>
            <body><h2>配置已保存，网络正在重启...</h2>
            <p><a href="]] .. luci.dispatcher.build_url("admin/services/backstageplanning") .. [[">返回</a></p>
            </body></html>
        ]])
        return
    end

    -- 读取配置
    local uci_proto = uci:get("network", "lan", "proto") or "dhcp"
    local is_static = (uci_proto == "static")

    local ip = ""
    local mask = ""
    local gw = ""
    local dns = ""
    local bcast = ""

    if is_static then
        ip = uci:get("network", "lan", "ipaddr") or ""
        mask = uci:get("network", "lan", "netmask") or "255.255.255.0"
        gw = uci:get("network", "lan", "gateway") or ""
        bcast = uci:get("network", "lan", "broadcast") or ""

        -- 兼容读取 DNS（支持 list 和 string 两种存储方式）
        local dns_list = uci:get_list("network", "lan", "dns")
        if type(dns_list) == "table" and #dns_list > 0 then
            dns = table.concat(dns_list, " ")
        else
            local dns_val = uci:get("network", "lan", "dns")
            if type(dns_val) == "string" and dns_val ~= "" then
                dns = dns_val
            end
        end
    else
        -- DHCP 模式：从运行状态获取实际值
        local shell_script = [[
STATUS=$(ubus call network.interface.lan status 2>/dev/null)
IP=$(echo "$STATUS" | jsonfilter -e "@[\"ipv4-address\"][0].address")
GW=$(echo "$STATUS" | jsonfilter -e "@.route" | grep -oE "\"nexthop\": \"[0-9.]+\"" | head -n 1 | cut -d\" -f4)
MASK_BITS=$(echo "$STATUS" | jsonfilter -e "@[\"ipv4-address\"][0].mask")

decode_cidr() {
    local bits=$1; local mask=""
    for i in 1 2 3 4; do
        if [ $bits -ge 8 ]; then mask="$mask.255"; bits=$((bits - 8))
        elif [ $bits -gt 0 ]; then mask="$mask.$((256 - 2**(8 - bits)))"; bits=0
        else mask="$mask.0"; fi
    done
    echo ${mask#.}
}
MASK=$(decode_cidr ${MASK_BITS:-24})

DNS_A=$(echo "$STATUS" | jsonfilter -e "@[\"dns-server\"][*]")
DNS_I=$(echo "$STATUS" | jsonfilter -e "@.inactive[\"dns-server\"][*]")
DNS_ALL=$(echo "$DNS_A $DNS_I" | tr " " "\n" | grep -vE "^$|table:" | sort -u | xargs)
[ -z "$DNS_ALL" ] && DNS_ALL="$GW"

DEV=$(echo "$STATUS" | jsonfilter -e "@.l3_device" || echo "br-lan")
BCAST=$(ip -4 addr show dev "$DEV" | awk "/brd / {print \$4}" | head -n 1)

echo "IP=$IP"
echo "MASK=$MASK"
echo "GW=$GW"
echo "DNS=$DNS_ALL"
echo "BCAST=$BCAST"
]]
        local result = sys.exec(shell_script)

        for line in string.gmatch(result, "[^\n]+") do
            if line:match("^IP=") then
                ip = line:sub(4)
            elseif line:match("^MASK=") then
                mask = line:sub(6)
            elseif line:match("^GW=") then
                gw = line:sub(4)
            elseif line:match("^DNS=") then
                dns = line:sub(5)
            elseif line:match("^BCAST=") then
                bcast = line:sub(7)
            end
        end
    end

    template.render("backstageplanning", {
        is_static = is_static,
        ip = ip,
        mask = mask,
        gw = gw,
        dns = dns,
        bcast = bcast
    })
end