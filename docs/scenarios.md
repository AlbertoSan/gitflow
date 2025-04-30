# Índice de Escenarios

A continuación, se listan los escenarios de la POC GitFlow con una breve descripción de cada caso de uso.

## 1. Feature con conflicto

- **Objetivo:** Simular dos ramas `feature/` que modifican la misma sección de código.
- **Aprendizaje:** Uso de `git merge` vs `git rebase`, resolución de conflictos manual y con herramientas.

## 2. Preparar un release

- **Objetivo:** Crear la rama `release/1.2.0` desde `develop`.
- **Aprendizaje:** Bump de versión, ejecución de tests, etiquetado (`v1.2.0`) y merge en `main` y `develop`.

## 3. Hotfix urgente en producción

- **Objetivo:** Simular un fallo crítico en `main` y aplicar un parche rápido.
- **Aprendizaje:** Creación de `hotfix/1.2.1`, tests rápidos, merge y etiquetado, y posible rollback con `git revert`.

## 4. Propagar cambios de hotfix a develop

- **Objetivo:** Integrar el parche de `hotfix/1.2.1` de vuelta a `develop`.
- **Aprendizaje:** `git merge hotfix/1.2.1` vs `git rebase`, mantener la historia limpia.

## 5. Integración CI/CD básica

- **Objetivo:** Configurar un pipeline en GitHub Actions para validar PRs.
- **Aprendizaje:** Linting, tests unitarios y despliegue automático a staging al mergear en `develop`.

## 6. Gestión de fallos en QA tras múltiples features

- **Premisa:** Tres features (`feature/A`, `feature/B`, `feature/C`) han sido mergeadas a `develop` y, tras pruebas de QA, `feature/B` falla. Mientras tanto, los desarrolladores han creado `feature/D` y `feature/E` partiendo de ese `develop`.
- **Objetivo:** Promocionar sólo las funcionalidades estables (A y C) a una nueva release (`release/x.x.x`) y gestionar el trabajo en D y E sin bloquear al equipo.
- **Buenas prácticas y estrategias:**
  1. **Code-freeze y punto de corte claro**
     - Antes de iniciar la release, define un commit de `develop` previo a la inclusión de B como punto de corte. No merges adicionales deben llegar a `develop` durante la preparación de la release.
     - Crea la rama `release/x.x.x` desde ese commit limpio (evitando incluir B).  
     ```bash
     git checkout -b release/x.x.x <commit-sin-B>
     ```
  2. **Excluir la feature defectuosa**
     - **Revert parcial en develop**: Si ya se ha continuado trabajando en `develop`, revierte sólo el merge de B y luego crea la release:
       ```bash
       git checkout develop
       git revert -m1 <merge-commit-de-feature-B>
       git push
       git checkout -b release/x.x.x
       ```
     - **Cherry-pick selectivo**: Alternativamente, cherry-pick de A y C sobre un branch iniciado en el commit limpio:
       ```bash
       git checkout -b release/x.x.x <commit-sin-B>
       git cherry-pick <merge-commit-A> <merge-commit-C>
       ```
  3. **Gestionar las ramas D y E**
     - **Rebase de D/E**: Una vez revertido B o iniciado el release, rebase de D/E sobre el develop limpio para eliminar B de su historia:
       ```bash
       git checkout feature/D
       git rebase develop
       ```
     - **Cherry-pick en release**: Si D/E están listos y la release lo permite, cherry-pick de sus commits al branch de release.
  4. **Uso de Feature Flags**
     - Integrar todas las features en `develop` desactivadas por defecto en producción. QA activa sólo A y C, dejando B deshabilitada.
     - Minimiza la necesidad de reverts y rebases, favorece integración continua.
  5. **Flujo recomendado resumido**
     1. Identificar el commit de `develop` sin B y crear `release/x.x.x` desde ahí.  
     2. Revertir B en `develop` (si corresponde) para mantener el mainline limpio.  
     3. Promocionar A y C en la release branch.  
     4. Rebase o cherry-pick de D/E cuando QA confirme estabilidad.  
     5. Finalizar release: merge a `main` (+ tag) y a `develop` para propagar parches.

## 7. Soporte de versiones anteriores y evolución paralela Soporte de versiones anteriores y evolución paralela. Soporte de versiones anteriores y evolución paralela

- **Premisa:** El software en producción está en `v2.1`, pero un cliente requiere mantenimiento y nuevas evoluciones sobre `v1.6`.
- **Objetivo:** Mantener la rama de mantenimiento `maintenance/1.6`, aplicar parches (hotfixes) y planificar evolutivos sin interferir con el desarrollo de `develop` (v2.x).
- **Aprendizaje:** Flujo recomendado:
  1. **Crear rama de mantenimiento:** `git checkout main && git checkout -b maintenance/1.6`
  2. **Aplicar hotfix en v1.6:** `git checkout maintenance/1.6 && <fix> && git commit` + merge en `main` + tag `v1.6.x`.
  3. **Evolutivos:** Crear `feature/maintenance-1.6-Y` desde `maintenance/1.6` para nuevas funcionalidades demandadas por el cliente.
  4. **Sincronización:** Tras finalizar evolutivos, merge de `maintenance/1.6` a `develop` (o `release/2.x`) para incorporar fixes al mainline.
