# container-SoftHSM
Containerized [SoftHSM](https://www.softhsm.org), based on [SoftHSMv2](https://github.com/softhsm/SoftHSMv2)

Combined with [pkcs11-proxy](https://github.com/bukka/pkcs11-proxy), to make the HSM accessible over network

This only intended for demo/test purposes, should not be used for any production workloads

The default config stores token data in `/home/softhsm/tokens`
