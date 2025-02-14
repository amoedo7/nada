#!/bin/bash

# Asegúrate de que el script esté ejecutándose en el directorio correcto
echo "Iniciando el proceso de subida de archivos a Git..."

# Cambiar al directorio del repositorio 'nada' (si no está ya allí)
cd /data/data/com.termux/files/home/nada

# Verificar el estado de los archivos
git status

# Agregar todos los archivos modificados al área de preparación
git add .

# Realizar un commit con un mensaje
git commit -m "Subida de nuevos archivos al repositorio"

# Subir los cambios al repositorio remoto en GitHub (asegúrate de estar en la rama correcta)
git push origin main  # Asegúrate de que la rama 'main' sea la correcta

# Confirmar que los cambios se han subido correctamente
echo "¡Los archivos se han subido a GitHub correctamente!"
