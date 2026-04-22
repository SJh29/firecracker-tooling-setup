source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
 
log "Stage 2: Configuring microVM via API socket"
 
fc_api PUT /logger "{
    \"log_path\": \"${LOGFILE}\",
    \"level\": \"Debug\",
    \"show_level\": true,
    \"show_log_origin\": true
}"
log "Logger configured → $LOGFILE"
 

# console=ttyS0  — send kernel output to the serial console
# reboot=k       — treat a reboot syscall as a full halt (Firecracker exits)
# panic=1        — reboot (i.e. halt) 1 second after a kernel panic
KERNEL_BOOT_ARGS="console=ttyS0 reboot=k panic=1"
 
# aarch64 needs keep_bootcon to preserve early boot messages on the console
if [ "$(uname -m)" = "aarch64" ]; then
    KERNEL_BOOT_ARGS="keep_bootcon ${KERNEL_BOOT_ARGS}"
fi
 
fc_api PUT /boot-source "{
    \"kernel_image_path\": \"${KERNEL}\",
    \"boot_args\": \"${KERNEL_BOOT_ARGS}\"
}"
log "Boot source set: $KERNEL"
 

fc_api PUT /drives/rootfs "{
    \"drive_id\": \"rootfs\",
    \"path_on_host\": \"${ROOTFS}\",
    \"is_root_device\": true,
    \"is_read_only\": false
}"
log "Rootfs set: $ROOTFS"
 

# The guest MAC 06:00:AC:10:00:02 is the value the pre-built Ubuntu rootfs uses
# to derive its static IP (172.16.0.2) via fcnet-setup.sh. If you change the
# MAC you must also change the guest IP.
fc_api PUT /network-interfaces/net1 "{
    \"iface_id\": \"net1\",
    \"guest_mac\": \"$FC_MAC\",
    \"host_dev_name\": \"$TAP_DEV\"
}"
log "Network interface attached (MAC=$FC_MAC → $TAP_DEV)"
 
# Firecracker handles API requests asynchronously. Wait briefly so all config
# is applied before the InstanceStart action is sent in the next stage.
sleep 0.015
 
success "Stage 2 complete: microVM configured"
