# amtm scripts:

- skynet
- merlinAU
- uiDivStats
- connmon
- scMerlin

# Asus merlin ddns

link: https://github.com/RMerl/asuswrt-merlin.ng/wiki/Custom-DDNS

path: `/jffs/scripts`

```
#!/bin/sh
# source: https://github.com/RMerl/asuswrt-merlin.ng/wiki/DDNS-Sample-Scripts#cloudflare

CLOUDFLARE_API_TOKEN='...'
DNS_ZONE_ID='...'
DNS_RECORD_ID='...'
DNS_RECORD_NAME='mothership.hjarl.com'
IP=${1}

curl -fs -o /dev/null -X PUT "https://api.cloudflare.com/client/v4/zones/$DNS_ZONE_ID/dns_records/$DNS_RECORD_ID" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$DNS_RECORD_NAME\",\"content\":\"$IP\",\"ttl\":1,\"proxied\":false}"

if [ $? -eq 0 ]; then
  /sbin/ddns_custom_updated 1
else
  /sbin/ddns_custom_updated 0
fi
```
