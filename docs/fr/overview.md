<p align="center">
  <img src="../../assets/logo/luciuz-logo-256.png" alt="Logo Luciuz" width="160" />
</p>

# Aperçu

Luciuz est un serveur web / reverse proxy écrit en Rust, conçu pour être **secure-by-default** (sécurisé par défaut) et **observable-by-default** (facile à exploiter en production).

Il vise le même type d’usage que Nginx ou Caddy, avec un accent fort sur :

- **Des réglages sûrs par défaut** (surface d’attaque minimale, gestion stricte des hôtes, exécution durcie)
- **Une exploitation claire** (logs et signaux fiables en production)
- **Une extensibilité propre** (roadmap Wasm)

## Fonctionnement (haut niveau)
- **:443 (HTTPS)** = le vrai service.
- **:80 (HTTP)** = volontairement minimal :
  - en mode `http-01` : challenge ACME + redirection vers HTTPS
  - en mode `tls-alpn-01` : redirection vers HTTPS (ACME passe par 443)

## Modèle (Community / Pro)
- **Community** : dépôt public (open source) avec le cœur du serveur.
- **Pro** : crate privée commerciale pour des modules/intégrations avancés.

## Suite
- Démarrage rapide : `quickstart.md`
- Configuration : `configuration.md`
- Modèle de sécurité : `security-model.md`
