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
