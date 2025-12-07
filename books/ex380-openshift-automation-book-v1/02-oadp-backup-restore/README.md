
# 02 – OADP : Sauvegarde et restauration

Objectifs de ce bloc :

- Installer l’operator **OpenShift API for Data Protection (OADP)**.
- Configurer un backend S3 (MinIO, AWS S3, etc.).
- Sauvegarder et restaurer des namespaces applicatifs.
- Utiliser des snapshots CSI et des backups planifiés.

Labs :

- `lab-01-install-oadp-operator.md` : installation de l’operator + DPA.
- `lab-02-backup-namespace-stateful.md` : backup d’un namespace avec PVC.
- `lab-03-restore-namespace.md` : restauration après suppression.
- `lab-04-schedules-snapshots.md` : backups planifiés + snapshots.
