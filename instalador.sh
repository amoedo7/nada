#!/bin/bash

# Crear archivo index.html
cat <<EOL > index.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Saldo de Billetera Bitcoin</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>Saldo de Billetera Bitcoin</h1>
        <p>Dirección: <strong>1MewpRkpcbFdqamPPYc1bXa9AJ189Succy</strong></p>
        <p>Saldo: <span id="saldo">Cargando...</span></p>
    </div>
    <script src="script.js"></script>
</body>
</html>
EOL

# Crear archivo style.css
cat <<EOL > style.css
body {
    font-family: Arial, sans-serif;
    text-align: center;
    background-color: #f9f9f9;
    margin: 0;
    padding: 0;
}

.container {
    margin-top: 50px;
}

h1 {
    color: #333;
}

p {
    font-size: 1.2em;
    color: #555;
}

#saldo {
    font-size: 1.5em;
    color: #28a745;
    font-weight: bold;
}
EOL

# Crear archivo script.js
cat <<EOL > script.js
// Dirección de la billetera Bitcoin
const address = "1MewpRkpcbFdqamPPYc1bXa9AJ189Succy";

// URL de la API para obtener el saldo
const apiURL = \`https://blockchain.info/q/addressbalance/\${address}?confirmations=6\`;

// Función para obtener el saldo de la billetera
async function obtenerSaldo() {
    try {
        // Realizar la solicitud a la API
        const response = await fetch(apiURL);
        const saldoSatoshis = await response.text();

        // Convertir Satoshis a BTC (1 BTC = 100,000,000 Satoshis)
        const saldoBTC = saldoSatoshis / 100000000;

        // Mostrar el saldo en la página
        document.getElementById('saldo').textContent = \`\${saldoBTC} BTC\`;
    } catch (error) {
        document.getElementById('saldo').textContent = 'Error al obtener el saldo.';
        console.error("Error al obtener el saldo: ", error);
    }
}

// Llamar a la función para obtener el saldo cuando se cargue la página
window.onload = obtenerSaldo;
EOL

echo "¡Archivos creados correctamente! index.html, style.css y script.js generados."
