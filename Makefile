help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install: ## Installe les collections Ansible
	ansible-galaxy install -r requirements.yml

check: ## Vérifie la syntaxe des playbooks
	ansible-playbook playbooks/01-bootstrap.yml --syntax-check
	ansible-playbook playbooks/site.yml --syntax-check
	ansible-playbook playbooks/02-update.yml --syntax-check

ping: ## Teste la connectivité SSH vers les hôtes (demande le mot de passe Vault)
	ansible vps -m ping --ask-vault-pass

list-hosts: ## Affiche l'inventaire (demande le mot de passe Vault)
	ansible-inventory -i inventory/production.ini --list --ask-vault-pass

bootstrap: ## Bootstrap (première fois) : crée main_user, root, désactive fedora ; connexion en fedora
	ansible-playbook playbooks/01-bootstrap.yml -e "ansible_user=fedora" --ask-vault-pass

replay-bootstrap: ## Rejouer le bootstrap sur VPS existant (connexion main_user, BECOME = mot de passe root)
	ansible-playbook playbooks/01-bootstrap.yml --ask-vault-pass --ask-become-pass

deploy: ## Déploie la configuration complète (site.yml) ; demande le mot de passe root (become)
	ansible-playbook playbooks/site.yml --ask-vault-pass --ask-become-pass

update: ## Met à jour tous les paquets du VPS (demande le mot de passe Vault et mot de passe root)
	ansible-playbook playbooks/02-update.yml --ask-vault-pass --ask-become-pass

clean: ## Nettoie les fichiers temporaires (cache facts + retry)
	rm -rf .cache/ansible_facts
	find . -name "*.retry" -delete

.PHONY: help install check ping list-hosts bootstrap replay-bootstrap deploy update clean
