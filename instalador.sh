#!/bin/bash
# instalador.sh – Genera index.html, style.css y script.js para mostrar una lista filtrable
# de las top 1000 claves privadas derivadas de un hash base

# Crear index.html
cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Top 1000 Claves Privadas</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <div class="container">
    <h1>Top 1000 Claves Privadas</h1>
    <input type="text" id="searchInput" placeholder="Buscar clave privada...">
    <div id="keyList"></div>
  </div>
  <script src="script.js"></script>
</body>
</html>
EOF

# Crear style.css
cat << 'EOF' > style.css
body {
  font-family: Arial, sans-serif;
  background-color: #f7f7f7;
  margin: 0;
  padding: 20px;
}
.container {
  max-width: 800px;
  margin: auto;
}
h1 {
  text-align: center;
  color: #333;
}
#searchInput {
  display: block;
  width: 100%;
  padding: 10px;
  margin-bottom: 20px;
  font-size: 1em;
  border: 1px solid #ccc;
  border-radius: 4px;
}
.key-item {
  background: #fff;
  margin: 5px 0;
  padding: 10px;
  border-radius: 4px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  font-family: monospace;
  font-size: 0.9em;
}
EOF

# Crear script.js
cat << 'EOF' > script.js
// script.js: Genera y muestra una lista de 1000 claves privadas derivadas de un hash base
// y permite filtrarlas mediante un cuadro de búsqueda

// Función para generar una clave privada a partir de un índice
function generateKey(i) {
  const baseKey = "0000000000000000000000000000000000000000000000000000000000000001";
  // Convertir la clave base a BigInt, sumar el índice y formatear a 64 dígitos hexadecimales
  const keyBig = BigInt("0x" + baseKey) + BigInt(i);
  const keyHex = keyBig.toString(16).padStart(64, '0');
  return keyHex;
}

// Función para crear la lista de claves privadas
function createKeyList() {
  const totalKeys = 1000;
  const keyListDiv = document.getElementById("keyList");
  for (let i = 0; i < totalKeys; i++) {
    const key = generateKey(i);
    const div = document.createElement("div");
    div.className = "key-item";
    div.textContent = key;
    keyListDiv.appendChild(div);
  }
}

// Función para filtrar la lista según la búsqueda
function filterList() {
  const filter = document.getElementById("searchInput").value.toLowerCase();
  const items = document.getElementsByClassName("key-item");
  for (let item of items) {
    const text = item.textContent.toLowerCase();
    if (text.indexOf(filter) > -1) {
      item.style.display = "";
    } else {
      item.style.display = "none";
    }
  }
}

// Inicializar la lista y configurar el filtro
document.addEventListener("DOMContentLoaded", function() {
  createKeyList();
  document.getElementById("searchInput").addEventListener("input", filterList);
});
EOF

echo "Archivos creados correctamente: index.html, style.css y script.js"
