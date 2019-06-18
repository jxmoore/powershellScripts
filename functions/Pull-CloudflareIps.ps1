# Grab Cloudflare IP CIDRS
function Pull-CloudflareIps(){
    return $( (Invoke-WebRequest -Uri "https://www.cloudflare.com/ips-v4" | select -ExpandProperty Content) -split '\n');
}

