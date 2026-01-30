# Headers de sécurité & HSTS

## Headers de base
Quand activé, Luciuz envoie un petit socle de headers sur les réponses HTTPS.

- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `X-Frame-Options: DENY`
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Resource-Policy: same-site`

## HSTS (Strict-Transport-Security)
HSTS indique au navigateur de n’utiliser que HTTPS pour un domaine.

### Déploiement progressif recommandé
1) 1 jour (`max-age=86400`)
2) 1 semaine
3) 1 mois
4) 6 mois

N’active `includeSubDomains` et `preload` que lorsque tu es sûr à 100%.
