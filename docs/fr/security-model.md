# Modèle de sécurité

Luciuz vise à être **sécurisé par défaut**. Ce document décrit les protections de base et l’approche opérateur.

## Menaces prises en compte (pratique)
Luciuz est pensé pour être exposé sur Internet. On suppose notamment :
- abus du header Host (open redirect, confusion de vhost, empoisonnement de cache)
- clients lents (épuisement de ressources)
- entrées non fiables (headers/body/path)
- mauvaises configurations (valeurs par défaut dangereuses)

## Principes
1) **Fail closed** : rejeter ce qui n’est pas explicitement servi.
2) **Surface d’attaque minimale** : garder le port 80 minimal.
3) **Moindre privilège** : non-root, droits fichiers limités.
4) **Durcissement progressif** : HSTS/headers oui, mais avec prudence.

## Politique Host / redirections
- `server.canonical_host` (optionnel) :
  - redirige `www.<canonique>` → `<canonique>`
  - rejette les hôtes inconnus au lieu de les rediriger

Cela évite les comportements de type open-redirect.

## Comportement du port 80
En mode ACME `http-01`, le port 80 se limite à :
- `/.well-known/acme-challenge/...` (Let’s Encrypt)
- redirection vers HTTPS pour le reste

En mode `tls-alpn-01`, le port 80 peut rester en « redirect only » (et, en roadmap v1, être désactivé).

## Headers de sécurité en HTTPS
Quand activé, Luciuz envoie notamment :
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `X-Frame-Options: DENY`
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Resource-Policy: same-site`

## HSTS : recommandation de déploiement
HSTS est très puissant et « colle » longtemps.
Stratégie recommandée :
1) commencer bas (ex : 1 jour)
2) observer quelques jours
3) augmenter progressivement (1 semaine, 1 mois, 6 mois)
4) activer `includeSubDomains` / `preload` seulement quand tout est parfaitement maîtrisé

## Durcissement système
Exécute Luciuz via une unité `systemd` durcie :
- utilisateur dédié
- `CAP_NET_BIND_SERVICE` au lieu de root
- répertoires d’écriture explicitement autorisés (ex : `/var/lib/luciuz`)
- options de sandboxing (voir `systemd.md`)

## Signalement
Merci de signaler les failles de manière privée.
Voir `SECURITY.md`.
