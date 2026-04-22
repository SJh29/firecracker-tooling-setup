#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
 
log "Stage 3: Booting microVM"
 
fc_api PUT /actions '{ "action_type": "InstanceStart" }'
 
# InstanceStart is also asynchronous. The guest kernel typically takes 1-2
# seconds to reach a state where SSH is available; waiting here avoids
# hammering SSH before the network stack is up.
sleep 2
 
success "Stage 3 complete: InstanceStart sent, waiting for guest to be ready"
 
