#!/bin/bash

# Asegurarse de que estamos en el directorio correcto
cd /data/data/com.termux/files/home/nada

# Crear el archivo README.md si no existe
if [ ! -f README.md ]; then
  echo "# nada" >> README.md
fi

# Inicializar el repositorio Git si no está inicializado
if [ ! -d ".git" ]; then
  git init
  git add README.md
  git commit -m "Primer commit: Crear README.md"
  git branch -M main
  git remote add origin https://github.com/amoedo7/nada.git
  git push -u origin main
fi

# Crear o reemplazar el archivo index.html básico
echo "<!DOCTYPE html>
<html lang='es'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Hola Mundo</title>
</head>
<body>
    <h1>¡Hola Mundo!</h1>
</body>
</html>" > index.html

# Agregar index.html al repositorio y hacer commit
git add index.html
git commit -m "Crear index.html básico"

# Subir los cambios al repositorio remoto
git push origin main

echo "Instalador finalizado. El archivo index.html y README.md han sido creados y subidos correctamente."
