#!/bin/bash

# Crear archivo index.html
cat <<EOL > index.html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consulta de Billeteras</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>Consulta de Billeteras con Saldo</h1>
        <div id="conSaldo"></div>
        <h2>Billeteras sin saldo</h2>
        <div id="sinSaldo"></div>
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

h2 {
    color: #333;
    margin-top: 40px;
}

p {
    font-size: 1.2em;
    color: #555;
}

#conSaldo, #sinSaldo {
    margin-top: 20px;
    font-size: 1.1em;
}

.billetera {
    margin: 10px 0;
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 5px;
    background-color: #f1f1f1;
}

.saldo {
    font-weight: bold;
    color: #28a745; /* Verde para saldo */
}

.saldo-none {
    color: #ff0000; /* Rojo para sin saldo */
}

.hash {
    font-size: 0.9em;
    color: #aaa;
}
EOL

# Crear archivo script.js
cat <<EOL > script.js
// Función para consultar el saldo de una billetera
async function consultarSaldo(direccion) {
    const apiURL = \`https://blockchain.info/q/addressbalance/\${direccion}?confirmations=6\`;
    try {
        const response = await fetch(apiURL);
        const saldoSatoshis = await response.text();
        const saldoBTC = saldoSatoshis / 100000000;
        return saldoBTC;
    } catch (error) {
        return null; // Si hay un error, significa que no se pudo obtener el saldo
    }
}

// Función para generar una dirección Bitcoin a partir de un hash
function generarDireccionBitcoin(hash) {
    // Aquí iría la lógica para convertir un hash en una dirección Bitcoin
    return \`1Bitcoin\${hash.toString(16).slice(0, 12)}\`;
}

// Función para generar una dirección Bitcoin Cash a partir de un hash
function generarDireccionBitcoinCash(hash) {
    // Aquí iría la lógica para convertir un hash en una dirección Bitcoin Cash
    return \`bitcoincash:q\${hash.toString(16).slice(0, 12)}\`;
}

// Función para generar una dirección Ethereum a partir de un hash
function generarDireccionEthereum(hash) {
    // Aquí iría la lógica para convertir un hash en una dirección Ethereum
    return \`0x\${hash.toString(16).slice(0, 12)}\`;
}

// Función para generar una dirección Litecoin a partir de un hash
function generarDireccionLitecoin(hash) {
    // Aquí iría la lógica para convertir un hash en una dirección Litecoin
    return \`L\${hash.toString(16).slice(0, 12)}\`;
}

// Función para generar direcciones de varias criptomonedas
function generarDirecciones(hash) {
    return {
        bitcoin: generarDireccionBitcoin(hash),
        bitcoinCash: generarDireccionBitcoinCash(hash),
        ethereum: generarDireccionEthereum(hash),
        litecoin: generarDireccionLitecoin(hash),
    };
}

// Función principal que itera sobre los hashes
async function iterarHashes() {
    let conSaldoDiv = document.getElementById('conSaldo');
    let sinSaldoDiv = document.getElementById('sinSaldo');
    
    // Rango de hashes a iterar (desde el 0000000000000000000000000000000000000000000000000000000000000001 hasta el fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140)
    const hashInicial = BigInt("0x0000000000000000000000000000000000000000000000000000000000000001");
    const hashFinal = BigInt("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");

    let hashActual = hashInicial;
    while (hashActual <= hashFinal) {
        let direcciones = generarDirecciones(hashActual);
        
        let billeteraEncontrada = false;
        for (let tipo in direcciones) {
            let direccion = direcciones[tipo];
            let saldo = await consultarSaldo(direccion);

            // Crear un div para la billetera
            let divBilletera = document.createElement('div');
            divBilletera.classList.add('billetera');
            let saldoTexto = saldo !== null ? \`Saldo: \${saldo} BTC\` : "No disponible";

            // Si la billetera tiene saldo, la mostramos en la parte superior
            if (saldo && saldo > 0) {
                divBilletera.classList.add('saldo');
                divBilletera.innerHTML = \`
                    <p><strong>\${direccion} (\${tipo})</strong></p>
                    <p class="hash">Hash: \${hashActual.toString(16)}</p>
                    <p class="saldo">\${saldoTexto}</p>
                \`;
                conSaldoDiv.appendChild(divBilletera);
                billeteraEncontrada = true;
            } else {
                // Si no tiene saldo, la mostramos al final
                divBilletera.classList.add('saldo-none');
                divBilletera.innerHTML = \`
                    <p><strong>\${direccion} (\${tipo})</strong></p>
                    <p class="hash">Hash: \${hashActual.toString(16)}</p>
                    <p class="saldo">\${saldoTexto}</p>
                \`;
                sinSaldoDiv.appendChild(divBilletera);
            }
        }

        // Aumentar el hash para iterar al siguiente
        hashActual++;
    }
}

// Iniciar la iteración al cargar la página
window.onload = iterarHashes;
EOL

echo "¡Archivos creados correctamente! index.html, style.css y script.js generados."
