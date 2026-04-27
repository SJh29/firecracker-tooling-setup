#!/usr/bin/env bash
# stages/05_deploy_function.sh — Stage 5: Deploy runtime + function into guest
#
# Copies lambda_runtime.py and the user's function.py into /opt/lambda/ inside
# the VM, then starts the runtime HTTP server in the background. Polls the
# /healthz endpoint until the server is ready to accept invocations.
#
# FUNCTION_FILE, KEY_NAME, GUEST_IP, LAMBDA_PORT, and RUNTIME_SCRIPT must be
# set in the environment (done by run_lambda.sh).
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
 
log "Stage 5: Deploying Lambda runtime and function to guest"
