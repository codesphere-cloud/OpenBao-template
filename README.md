# Codesphere OpenBao Template

## ⚠️ Important Disclaimer

This template is **not production-ready**. It is intended for development and demonstration purposes only.

A secure, production-grade OpenBao (Vault) deployment requires complex, manual security procedures (especially for handling unseal keys) that cannot be fully automated within a template. This setup is sufficient for development but **must not** be used for sensitive data in a live environment.

---

## Development Setup (Recommended)

This is the fastest way to get a temporary server running for testing. All data will be lost when the server is stopped.

1.  **Start the Dev Server**
    Run OpenBao in `-dev` mode. You can specify a port using the `-dev-listen-address` flag:
    ```bash
    ./bao server -dev -dev-listen-address="0.0.0.0:3000"
    ```

2.  **Login**
    The server will print a **Root Token** to the console when it starts. Use this token to log in:
    ```bash
    export BAO_ADDR='[http://127.0.0.1:3000](http://127.0.0.1:3000)'
    ./bao login <YOUR_ROOT_TOKEN_FROM_THE_LOGS>
    ```

---

## Persistent Mode (Demonstration Only)

This flow demonstrates how to start a persistent server that requires unsealing.

### 🚨 Production Security Warning

This configuration is **critically insecure** and demonstrates an anti-pattern.

* **The Flaw:** The unseal keys and the root token are stored in plain text (`.codesphere-internal/keys.txt`) *on the same machine* as the OpenBao instance. If an attacker gains access to this server, they have immediate access to all keys needed to unseal and control your vault.
* **A real production setup requires:**
    a) Implementing a secure auto-unseal method (e.g., using a cloud KMS), OR
    b) Distributing the unseal keys to multiple human operators (admins) who must manually provide them on restart. The keys should **never** be stored on the server itself.

### Demo Steps

If you want to test this insecure demo flow:

1.  Start the main `run` stage, which launches the server in a sealed state (e.g., `./bao server -config=/home/user/app/openbao.hcl`).
2.  In a separate terminal, run the unseal script:
    ```bash
    ./scripts/unseal.sh
    ```
3.  Retrieve the generated root token from the file:
    ```bash
    cat .codesphere-internal/keys.txt
    ```
4.  You can now use this token to authenticate against your OpenBao instance.
