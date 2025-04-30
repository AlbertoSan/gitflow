# GitFlow Overview

GitFlow es un modelo de branching que facilita el desarrollo organizado y controlado de software mediante el uso de ramas con propósitos claros.

## Ramas Principales

- `main`
  - Contiene el código en producción.
  - Sólo merges directos desde `release/*` y `hotfix/*`.

- `develop`
  - Integración de nuevas funcionalidades.
  - Base para crear `feature/*`, `release/*`.

- `feature/{nombre}`
  - Desarrollo de funcionalidades aisladas.
  - Nacen desde `develop` y se integran de nuevo a `develop`.

- `release/{versión}`
  - Preparación de la versión (tests, documentación, bump de versión).
  - Se crea desde `develop`, se corrige, luego se fusiona en `main` y `develop`.
  - Se etiqueta con `v{versión}`.

- `hotfix/{versión}`
  - Parche urgente sobre producción.
  - Nace de `main`, aplica el fix, se fusiona en `main` (y `develop`), y se etiqueta.

## Convenciones de Nombres

- Usar minúsculas y guiones: `feature/login-ui`, `hotfix/1.2.1`.
- Incluir ticket o ID de issue si aplica: `feature/JIRA-123-add-logging`.
- Versionado semántico en releases y hotfix: `release/2.0.0`, `hotfix/2.0.1`.

## Flujo de Trabajo

1. **Crear feature**:  
   `git checkout develop && git checkout -b feature/{nombre}`  
2. **Terminar feature**:  
   `git checkout develop && git merge --no-ff feature/{nombre}`  
3. **Crear release**:  
   `git checkout develop && git checkout -b release/{versión}`  
   Bump de versión, tests, correcciones.  
   `git checkout main && git merge --no-ff release/{versión}`  
   `git tag -a v{versión}`  
   `git checkout develop && git merge --no-ff release/{versión}`  
4. **Crear hotfix**:  
   `git checkout main && git checkout -b hotfix/{versión}`  
   Aplicar fix, tests rápidos.  
   `git checkout main && git merge --no-ff hotfix/{versión}`  
   `git tag -a v{versión}`  
   `git checkout develop && git merge --no-ff hotfix/{versión}`

## Protección de Ramas

- Proteger `main` y `develop`:  
  - Revisión obligatoria de PR (1+ aprobaciones).  
  - Checks de CI/CD deben pasar antes de merge.  
  - Deshabilitar push directo.
