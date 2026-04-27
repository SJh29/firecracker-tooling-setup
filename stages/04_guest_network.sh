#!/usr/bin/env bash

# stages/04_guest_network.sh - Stage 4: Guest networking over SSH
# The guest boots with an IP on eth0 but no default route and no DNS resolver.
# This stage:
#   1. Polls SSH until the guest accepts connections (up to 30 seconds)
#   2. Adds a default route via the host TAP IP
#   3. Writes a resolv.conf pointing at Google DNS (8.8.8.8)
#
# KEY_NAME and GUEST_IP must be set in the environment (done by run_lambda.sh).

source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
 
log "Stage 4: Waiting for guest SSH and configuring guest network"

# Wait for SSH to be available on the guest

attempts=0
max=30
while ! ssh_guest true 2>/dev/null; do
    sleep 1
    (( attempts++ ))
    if (( attempts >= max )); then
        error "Guest SSH never became available after ${max}s"
        exit 1
    fi
    log "SSH attempt $attempts/$max …"
done
success "Guest is up (SSH ready)"

# Add default route via host TAP IP for internet access

ssh_guest "ip route add default via $TAP_IP dev eth0" || true
log "Default route added via $TAP_IP"
 
ssh_guest "echo 'nameserver 8.8.8.8' > /etc/resolv.conf"
log "DNS resolver set to 8.8.8.8"
 
success "Stage 4 complete: guest network configured"
