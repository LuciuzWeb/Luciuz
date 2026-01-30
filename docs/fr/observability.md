# Observabilité

Luciuz est conçu pour être **observable par défaut** : en production, on doit pouvoir comprendre rapidement ce qui se passe.

## Logs
- Des logs structurés (JSON ou key=value) sont recommandés.
- Les logs devraient inclure : méthode, chemin, hôte, statut, latence, et un identifiant de requête.

## Événements importants à tracer
- Événements ACME (émission/renouvellement/erreurs)
- Redirections d’hôte canonique
- Rejets d’hôtes inconnus et méthodes invalides
- Timeouts

## Métriques (roadmap)
Objectif : exposer des compteurs de base (requêtes, erreurs, timeouts, erreurs ACME), puis une intégration Prometheus/OTel.

## Objectif opérateur
- Déboguer sans « deviner »
- Rendre les erreurs compréhensibles
- Faciliter l’audit (sécurité)
