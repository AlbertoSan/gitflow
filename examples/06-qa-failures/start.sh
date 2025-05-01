#!/usr/bin/env bash

# Ejemplo 04: Inicialización de escenario QA Failures
# Crea un repo, ramas develop, features A, B, C, mergea y genera D/E

# 1. Inicializar repo y rama develop
git init .
git checkout -b develop

# 2. Crear proyecto base
mkdir -p project
cat > project/main.py << 'EOF'
def process():
    print("Feature base: All good")

if __name__ == "__main__":
    process()
EOF

git add project/main.py
git commit -m "chore: init project on develop"

# 3. Feature A
git checkout -b feature/A
sed -i "s/All good/All good - A/" project/main.py
git commit -am "feat(A): add behavior A"
git checkout develop

# 4. Feature B (introduce bug)
git checkout -b feature/B
sed -i "s/All good/All good - B/" project/main.py
# Introducir un error intencional en la llamada
git apply << 'PATCH'
*** Begin Patch
*** Update File: project/main.py
@@
-if __name__ == "__main__":
-    process()
+if __name__ == "__main__":
+    proces()  # llamada con typo para simular fallo
*** End Patch
PATCH

git commit -am "feat(B): add behavior B with bug"
git checkout develop

# 5. Feature C
git checkout -b feature/C
sed -i "s/All good/All good - C/" project/main.py
git commit -am "feat(C): add behavior C"
git checkout develop

# 6. Merge A, B, C en develop
git merge --no-ff feature/A -m "merge: feature/A"
git merge --no-ff feature/B -m "merge: feature/B"
git merge --no-ff feature/C -m "merge: feature/C"

# 7. Crear ramas D y E partiendo del develop actual
git checkout -b feature/D
sed -i "s/Feature base/Feature base - D/" project/main.py
git commit -am "feat(D): add behavior D"
git checkout develop

git checkout -b feature/E
sed -i "s/Feature base/Feature base - E/" project/main.py
git commit -am "feat(E): add behavior E"
git checkout develop

# Fin de inicialización
echo "Escenario QA Failures inicializado: develop con A,B,C merged y ramas D/E creadas."
