# Hôte canonique (www → apex)

Quand `server.canonical_host` est défini, Luciuz impose un hôte officiel unique.

## Ce que ça apporte
- Les requêtes vers `www.<canonique>` sont redirigées vers `<canonique>`.
- Les hôtes inconnus sont rejetés (pas d’open-redirect).

## Exemple
```toml
[server]
canonical_host = "luciuz.com"
```

## Certificats
Si tu rediriges `www` vers apex en HTTPS, `www` doit quand même être couvert par le certificat (sinon erreur TLS avant la redirection).

Dans la pratique : ajoute aussi `www` dans `acme.domains`.
