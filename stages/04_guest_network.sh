#!/usr/bin/env bash

# stages/04_guest_network.sh - Stage 4: Guest networking over SSH
# The guest boots with an IP on eth0 but no default route and no DNS resolver.
# This stage:
#   1. Polls SSH until the guest accepts connections (up to 30 seconds)
#   2. Adds a default route via the host TAP IP
#   3. Writes a resolv.conf pointing at Google DNS (8.8.8.8)
#
# KEY_NAME and GUEST_IP must be set in the environment (done by run_lambda.sh).
