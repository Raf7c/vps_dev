# ansible-vps – Configuration Ansible VPS Fedora (OVH)

> ⚠️ **Note de sécurité** : Ce dépôt contient un fichier Vault chiffré (`inventory/group_vars/all/vault.yml`). Les données sensibles (IP du VPS, mots de passe hashés, port SSH, nom d'utilisateur, etc.) sont protégées par Ansible Vault (AES256). Vous devez créer votre propre fichier vault avec vos propres secrets. Voir [doc/VAULT.md](doc/VAULT.md) pour les instructions.

Objectif : une configuration Ansible **reproductible** pour un VPS Fedora (une seule machine, usage dev / prod).


## Documentation

Toute la description et le cadre du projet sont décrits dans les documents suivants.

**Ordre de lecture recommandé** : Architecture → Déploiement → Sécurité → Runbook → Politique de mise à jour.

| Document | Contenu |
|----------|---------|
| [Architecture](doc/ARCHITECTURE.md) | Composants, flux, inventaire, principes |
| [Déploiement](doc/DEPLOYMENT.md) | Stratégie de déploiement, ordre d’exécution, rollback |
| [Sécurité](doc/SECURITY.md) | Menaces, surface d’attaque, gestion des secrets |
| [Runbook](doc/RUNBOOK.md) | Procédures opérationnelles (bootstrap, incidents, rollback) |
| [Politique de mise à jour](doc/UPDATE_POLICY.md) | Mises à jour système et paquets |
| [Ansible Vault](doc/VAULT.md) | Données sensibles (vault.yml), création et utilisation |

---

## Structure du projet

```
ansible-vps/
├── .github/
│   └── workflows/
│       └── ansible.yml      # CI : syntax-check + ansible-lint
├── ansible.cfg
├── requirements.yml
├── Makefile
├── inventory/
│   ├── production.ini
│   └── group_vars/
│       ├── all.yml
│       ├── vps.yml
│       ├── all/
│       │   └── vault.yml    # chiffré (Ansible Vault)
├── playbooks/
│   ├── site.yml
│   ├── 01-bootstrap.yml
│   └── 02-update.yml
├── roles/
│   ├── base/
│   ├── ssh/
│   ├── security/
│   ├── firewall/
│   └── fail2ban/
└── doc/
    ├── ARCHITECTURE.md
    ├── DEPLOYMENT.md
    ├── SECURITY.md
    ├── RUNBOOK.md
    ├── UPDATE_POLICY.md
    └── VAULT.md
```

Chaque rôle suit la structure standard Ansible (tasks, defaults, handlers, meta).

## Commandes (Makefile)

Après `make install` (installation des collections), les cibles utiles demandent le mot de passe Vault :

| Cible | Description |
|-------|-------------|
| `make ping` | Teste la connectivité SSH (demande le mot de passe Vault) |
| `make list-hosts` | Affiche l'inventaire (demande le mot de passe Vault) |
| `make bootstrap` | Bootstrap (première fois) : main_user, root, désactivation fedora ; connexion en fedora |
| `make deploy` | Déploie la configuration complète (site.yml) ; demande le mot de passe Vault et le mot de passe root (become) |
| `make update` | Met à jour tous les paquets du VPS ; demande le mot de passe Vault et le mot de passe root |
| `make check` | Vérifie la syntaxe des playbooks (01-bootstrap.yml, site.yml, 02-update.yml) |

Voir `make help` pour la liste complète. **Ansible Vault** : toutes les données sensibles (vps_ip, root_password_hashed, main_user, ssh_key_name, bootstrap_user, ssh_port) sont dans `inventory/group_vars/all/vault.yml`. Voir [doc/VAULT.md](doc/VAULT.md). Main_user n'a pas de sudo ; élévation via mot de passe root (`su -` ou Ansible become).

---

## ⚠️ Avant le premier déploiement

* [ ] Avoir créé puis chiffré `inventory/group_vars/all/vault.yml` avec toutes les variables (vps_ip, main_user_password_hashed (optionnel), **root_password_hashed**, main_user, ssh_key_name, bootstrap_user, ssh_port) — voir [doc/VAULT.md](doc/VAULT.md)
* [ ] Avoir exécuté une première fois `make bootstrap` (connexion en fedora ; crée main_user, root, désactive fedora)
* [ ] Ensuite : `make deploy` pour appliquer la configuration complète (ssh, base, security, firewall, fail2ban) — entrer le **mot de passe root** quand Ansible demande le BECOME password
