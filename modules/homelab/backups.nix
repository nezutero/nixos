{ config, ... }:
{
  sops.secrets."restic_password" = { };
  sops.secrets."restic_sftp_key" = { };

  # Order a Hetzner Storage Box separate from this VM — backing up to a
  # volume on the same machine doesn't help if the server itself is lost.
  services.restic.backups.hetzner-server = {
    initialize = true;
    passwordFile = config.sops.secrets."restic_password".path;
    repository = "sftp:u000000@u000000.your-storagebox.de:/backups/hetzner-server";
    extraOptions = [
      "sftp.command='ssh u000000@u000000.your-storagebox.de -i ${config.sops.secrets."restic_sftp_key".path} -s sftp'"
    ];

    # Immich's Postgres shouldn't be backed up live — dump it first.
    backupPrepareCommand = ''
      mkdir -p /var/backup/postgres
      ${config.services.postgresql.package}/bin/pg_dumpall -U postgres -f /var/backup/postgres/dump.sql
    '';

    paths = [
      "/var/backup/postgres"
      "/mnt/data/immich"
      "/var/lib/vaultwarden"
      "/var/lib/uptime-kuma"
      "/var/lib/ntfy-sh"
    ];

    timerConfig = {
      OnCalendar = "03:30";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };
}
