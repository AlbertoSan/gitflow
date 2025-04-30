**Archivo: examples/06-qa-failures/README.md**

```markdown
# Ejemplo 06: Gestión de Fallos en QA tras Múltiples Features

En este laboratorio simularemos un caso en el que tres features (**A**, **B**, **C**) se han mergeado en `develop`, QA detecta que **B** falla, y además los desarrolladores ya han creado **D** y **E** partiendo de ese `develop`. Aprenderemos a:  

1. Aislar la release sin incluir la feature defectuosa.  
2. Revertir o cherry-pick en `develop`.  
3. Limpiar las ramas de features D/E.  
4. (Opcional) Uso de feature flags para minimizar bloqueos.

## Estructura de la carpeta
```
06-qa-failures/
├── project/                   # Proyecto de ejemplo (main.py)
├── start.sh                   # Script de inicialización
└── README.md                  # Esta guía
```

## Prerrequisitos

- Haber completado los ejemplos anteriores de GitFlow.  
- Git v2.20+ y Bash.  
- Entorno limpio (`git reset --hard origin/develop`).

## 1. Inicializar el escenario

En la carpeta de ejemplo:
```bash
bash start.sh
```  
Este script realiza:
- `git init` + rama `develop` con `project/main.py` base.  
- Crea y mergea en `develop` las ramas `feature/A`, `feature/B`, `feature/C` (con commits que modifican la misma función).  
- Crea también ramas `feature/D` y `feature/E` partiendo del develop que incluye B.

## 2. QA detecta fallo en feature B

QA prueba la versión desplegada desde `develop`. Al ejecutar:
```bash
python project/main.py
```
Observa que la lógica de **B** genera un error.

## 3. Aislar la nueva release sin B

### Opción A: Punto de corte y cherry-pick selectivo
1. Identificar el commit de `develop` justo antes del merge de **B** (hash `XXXXXXX`).  
2. Crear la release sin B:
   ```bash
   git checkout -b release/x.x.x XXXXXXX    # punto limpio sin B
   git cherry-pick <merge-A> <merge-C>      # aplicar sólo A y C
   ```
3. Verificar y desplegar en QA/regresión.

### Opción B: Revert parcial en `develop`
1. En `develop`, revertir sólo el merge de **B**:
   ```bash
   git checkout develop
   git revert -m1 <merge-commit-de-B>
   git push origin develop
   ```
2. Crear la release desde `develop`:
   ```bash
   git checkout -b release/x.x.x
   ```
3. Verificar y desplegar.

## 4. Gestionar ramas D y E

Después del paso 3, `develop` ha sido revertido o aislado. Las ramas **D** y **E** contienen commits basados en B y pueden arrastrar el fallo.

- **Rebase de D/E** sobre el `develop` limpio:
  ```bash
  git checkout feature/D
  git rebase develop
  git checkout feature/E
  git rebase develop
  ```
- Resolver conflictos si surgen y continuar.

- Alternativamente, **cherry-pick** de D/E desde su punto de origen al branch de release:
  ```bash
  git checkout release/x.x.x
  git cherry-pick <commit-D1> <commit-Dn>
  ```

## 5. Propagación de la corrección

1. Tras validar la release, mergear de vuelta:
   ```bash
   git checkout main
   git merge --no-ff release/x.x.x
   git tag -a vX.Y.Z

   git checkout develop
   git merge --no-ff release/x.x.x
   ```
2. Si en `develop` quedó la lógica de B revertida, asegúrate de incorporar cualquier fix mediante cherry-pick.

## 6. (Opcional) Estrategia con Feature Flags

- Mantén todas las features en `develop` pero deshabilitadas en producción.  
- QA activa solo **A** y **C**, sin tocar **B**, evitando reverts y rebases.  
- Cuando B se corrija, simplemente habilita su flag.

## 7. Conclusiones y discusión

- ¿Qué opción (cherry-pick vs revert) prefieres y por qué?  
- ¿Cómo gestionarías un pipeline de CI/CD para este caso?  
- ¿Debería el equipo usar feature flags por defecto?
```

