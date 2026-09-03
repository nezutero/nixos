# Setting up immich / vaultwarden / uptime-kuma / miniflux / jellyfin / ntfy on Hetzner

Files to drop in (paths match your repo):

```
modules/nixos/homelab/default.nix
modules/nixos/homelab/secrets.nix
modules/nixos/homelab/caddy.nix
modules/nixos/homelab/immich.nix
modules/nixos/homelab/vaultwarden.nix
modules/nixos/homelab/uptime-kuma.nix
modules/nixos/homelab/miniflux.nix
modules/nixos/homelab/jellyfin.nix
modules/nixos/homelab/ntfy.nix
modules/nixos/homelab/backups.nix
hosts/server/configuration.nix   (replaces your existing one)
```

## 1. Wire sops-nix into your flake

Add the input and pass its NixOS module into your server system in `flake.nix`:

```nix
inputs.sops-nix = {
  url = "github:Mic92/sops-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};

# in the nixosSystem call for hosts/server:
modules = [
  ./hosts/server/configuration.nix
  inputs.sops-nix.nixosModules.sops
  # ...whatever else you already have there
];
```

## 2. Bootstrap secrets

You need `sops` and `age` locally (`nix shell nixpkgs#sops nixpkgs#age nixpkgs#ssh-to-age`).

1. After the server exists and has booted at least once, grab its host key and turn it into an age recipient:
   ```
   ssh root@<server-ip> cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
   ```
2. Create `.sops.yaml` at the repo root:
   ```yaml
   keys:
     - &server age1qyourconvertedkeyhere...
   creation_rules:
     - path_regex: secrets/server\.yaml$
       key_groups:
         - age: [*server]
   ```
3. Create the encrypted file:
   ```
   sops secrets/server.yaml
   ```
   and fill in (sops opens your $EDITOR, encrypts on save):
   ```yaml
   vaultwarden_admin_token: <openssl rand -base64 48>
   miniflux_admin_credentials: |
     ADMIN_USERNAME=youruser
     ADMIN_PASSWORD=<something >= 6 chars, a real generated password>
   restic_password: <another long random string>
   restic_sftp_key: |
     -----BEGIN OPENSSH PRIVATE KEY-----
     ...(a dedicated keypair for the Storage Box, not your personal one)...
     -----END OPENSSH PRIVATE KEY-----
   ```

Commit `.sops.yaml` and the encrypted `secrets/server.yaml` — they're safe in git, that's the point of sops.

## 3. Provision the Hetzner side

- **Server**: an 8GB-RAM box (CPX31 or CX32) — Immich's machine-learning service (face/object search) is the RAM-hungry part, not the CPU. You can disable smart search later in Immich's admin settings if you want to run smaller.
- **Volume**: attach a separate Hetzner Volume sized for your photo library, format it (`mkfs.ext4 /dev/sdX`), find its stable path with `ls /dev/disk/by-id/`, and put that into `immich.nix`.
- **Storage Box**: order one for backups, separate from the VM. Create an SSH keypair just for restic and add its public half in the Storage Box panel.
- **Cloud Firewall**: restrict inbound to 22, 80, 443 at the Hetzner project level too — defense in depth on top of the NixOS firewall.

## 4. DNS

Your apex `nezutero.dev` stays pointed at Codeberg Pages for the blog — don't touch that. Add three new records at whatever DNS provider manages the domain, pointing at the new server's IP(s):

```
photos.nezutero.dev   A     <server-ipv4>
vault.nezutero.dev    A     <server-ipv4>
status.nezutero.dev   A     <server-ipv4>
feeds.nezutero.dev    A     <server-ipv4>
watch.nezutero.dev    A     <server-ipv4>
ntfy.nezutero.dev     A     <server-ipv4>
# + AAAA records too if the server has IPv6
```

Caddy handles TLS automatically via Let's Encrypt once these resolve and 80/443 are reachable.

## 5. Deploy

If the server doesn't exist yet, `nixos-anywhere` pairs naturally with the disko config you already have:

```
nix run github:nix-community/nixos-anywhere -- --flake .#server root@<server-ip>
```

Otherwise, once it's up:

```
nixos-rebuild switch --flake .#server --target-host root@<server-ip>
```

## 6. Post-install, per service

- **Vaultwarden**: visit `https://vault.nezutero.dev`, create your account while `SIGNUPS_ALLOWED` is still `true`, then flip it back to `false` and redeploy. The admin panel is at `/admin`, using the token you put in sops.
- **Uptime Kuma**: visit `https://status.nezutero.dev`, the first visit is the admin account setup wizard. Add a monitor for each of the other two services (and for itself, from an external host, if you want to know when the server is fully down).
- **Immich**: visit `https://photos.nezutero.dev`, create your admin account, then install the mobile app and point it at that URL for background backup.
- **Miniflux**: visit `https://feeds.nezutero.dev`, log in with the credentials from `miniflux_admin_credentials`, then just start adding feeds.
- **Jellyfin**: visit `https://watch.nezutero.dev`, the setup wizard runs on first visit — point it at wherever your media ends up living (e.g. `/mnt/data/jellyfin`) once you've decided on that.
- **ntfy**: it doesn't have a web signup — SSH in and run `ntfy user add --role=admin <youruser>` once, then use that login in the ntfy Android/iOS app pointed at `https://ntfy.nezutero.dev`, or subscribe to a topic straight from Uptime Kuma's notification settings.
- **Verify backups** once, don't just trust the timer: `systemctl start restic-backups-hetzner-server` then `restic -r sftp:... snapshots` (with `RESTIC_PASSWORD_FILE` exported) to confirm a snapshot actually landed.
