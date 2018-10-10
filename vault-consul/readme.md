# Vault with Consul Backend

## How to run

### Prerequisites
* Ubuntu 16.04 machine or VM with Docker 17.09 and Docker-Compose 1.22.

### Start the Stack

`docker-compose up -d`

* Wait for the stack to come up, monitor the compose logs as needed.
* Check out the Consul Dashboard at: `localhost:8500`.
* There should be a service entry called `vault` which shows an error.


![image](https://user-images.githubusercontent.com/13379978/46719405-74fc1c80-cc8b-11e8-9f28-98bf84cba003.png)

* If you click that service you should see that the Vault is sealed. This is intentional for security.

![image](https://user-images.githubusercontent.com/13379978/46719549-ce644b80-cc8b-11e8-9f1c-278c8c52c74c.png)


### Create the Unseal Keys and Root Token

Now we need to create the unseal keys (by default 5 keys) and root token.


```
docker exec vault-consul_vault_1 vault operator init
```

Output:

```
Unseal Key 1: 20bYlKpIDKOZtf2VQ72pAoF3hZ4G7yf9k4sxSmjbciPU
Unseal Key 2: kurGsDhNgaEbZ6cGOwQ2gI8xFVNAdJoQpCd+t54gkh5s
Unseal Key 3: gwatdra5bjZ3UlreGTdRbVGkVukZj+XtMiZeaK+YTOLA
Unseal Key 4: NEnI1un/MkND3HzQYZU36k9gVR8MOCsDeR2fAGaTVO7z
Unseal Key 5: V7E6wj6Vi+Avf3iNFjjpKRk9RnsRbs/gePnh+lzxj0tQ

Initial Root Token: 86s6txkXP4agSf3DiCsmBEOZ

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 3 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```

### Unseal the Vault

* Type the command below 3 times.
* Provide any 3 of the 5 unseal keys to unseal the vault.


```
docker exec -it vault-consul_vault_1 vault operator unseal
Unseal Key (will be hidden):
```

After executing this 3 times you will see `sealed: false`:

```
Unseal Key (will be hidden):
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           5
Threshold              3
Version                0.11.3
Cluster Name           vault-cluster-29d6f5dd
Cluster ID             5c5ca00f-0928-4872-aba2-69182f024b81
HA Enabled             true
HA Cluster             n/a
HA Mode                standby
Active Node Address    <none>
```

Now the dashboard in Consul would show 

![image](https://user-images.githubusercontent.com/13379978/46720024-fc965b00-cc8c-11e8-9881-d7bc3b194dcd.png)

### Storing a Secret: First Login

```
vagrant@ubuntu:~/work/vault-examples/vault-consul$ docker exec -it vault-consul_vault_1 vault login
Token (will be hidden):
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                86s6txkXP4agSf3DiCsmBEOZ
token_accessor       6LMELnorK8LmnmCkxRgeseYu
token_duration       
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

Provide the root token to log in.


### Store a sample secret

```
docker exec -it vault-consul_vault_1 vault write -address=http://127.0.0.1:8200 secret/awskey value=AKIABUHAHAHAHA
Success! Data written to: secret/awskey
docker exec -it vault-consul_vault_1 vault write -address=http://127.0.0.1:8200 secret/awssecret value=AKIABUHAHAHAHAREALLYINSECURE
Success! Data written to: secret/awssecret
```

### View Secrets in Consul

The secrets seem to be stored under `vault/logical/<UUID>`. 

![image](https://user-images.githubusercontent.com/13379978/46720288-c0afc580-cc8d-11e8-9eef-66ea76259761.png)

### View Secrets from Vault CLI


```
docker exec -it vault-consul_vault_1 vault read secret/awssecret
Key                 Value
---                 -----
refresh_interval    768h
value               AKIABUHAHAHAHAREALLYINSECURE
```

## Notes

1. Consul seems to require host networking - [ref](https://hub.docker.com/_/consul/).
1. Vault container needs to wait for the Consul container to be ready. 
   
   I use [`wait-for`](https://github.com/Eficode/wait-for) which is compatible with `sh`, for the reason that the containers do not have bash installed.

## References

1. [`consul` Docker Image](https://hub.docker.com/_/consul/)
1. [`vault` Docker Image](https://hub.docker.com/_/vault/)
1. [Vault Documentation](https://www.vaultproject.io/docs/)
1. [`wait-for-it.sh` for bash](https://github.com/vishnubob/wait-for-it)
1. [`wait-for.sh` for sh](https://github.com/Eficode/wait-for)
1. [Consul Secrets Engine for Vault](https://www.vaultproject.io/docs/secrets/consul/)
1. [Consul Agent options](https://www.consul.io/docs/agent/options.html)
