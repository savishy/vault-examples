#!/usr/bin/env sh

# Start Vault Server as Background process. Store PID.
nohup vault server -dev -dev-root-token-id="root" &
PROC_ID=$!
# Wait for Server to finish initializing.
/wait-for 127.0.0.1:8200 -t 30

# Initialize Vault with secret store and secrets.
vault login root
vault secrets disable secret
vault secrets enable -version=1 -path=secret kv
vault write secret/myawesomesecret value=SUPERINSECUREVALUE
wait $PROC_ID
