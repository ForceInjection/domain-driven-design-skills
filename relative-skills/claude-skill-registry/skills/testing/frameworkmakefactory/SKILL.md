---
name: framework:make:factory
description: Génère Factory Foundry pour tests
license: MIT
version: 1.0.0
---

# Framework Make Factory Skill

## Description
Génère une Factory Foundry pour créer des instances d'entités dans les tests.

## Usage
```
Use skill framework:make:factory
```

## Variables requises
- **{EntityName}** - Nom de l'entité en PascalCase (ex: Product)
- **{entityName}** - Nom de l'entité en camelCase (ex: product)
- **{namespace}** - Namespace du projet (défaut: App)
- **{properties}** - Liste des propriétés pour `defaults()`

## Dépendances
- Entité dans `src/Entity/{EntityName}.php`
- Zenstruck Foundry installé

## Outputs
- `src/Factory/{EntityName}Factory.php`

## Workflow

1. Demander le nom de l'entité (EntityName)
2. Vérifier que l'entité existe
3. Lire l'entité pour détecter les propriétés du constructeur `create()`
4. Générer la factory depuis le template `templates/Factory/`
5. Afficher le fichier créé

## Patterns appliqués

- Extends PersistentObjectFactory, classe `final`
- Méthode `class()` retournant FQCN
- Méthode `defaults()` avec valeurs Faker
- Méthode `initialize()` avec `instantiateWith()` appelant `Entity::create()`
- Méthodes custom (ex: `withSpecificId()`, `inactive()`)

## References

- [Usage](references/usage.md) - Exemples de tests et valeurs Faker recommandées

## Notes
- Utilise `instantiateWith()` pour respecter Elegant Objects (pas de `new Entity()`)
- Faker via `self::faker()`
- Méthodes custom uniquement si demandées (YAGNI)
- Persiste par défaut, `withoutPersisting()` si besoin
