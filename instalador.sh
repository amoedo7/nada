#!/bin/bash
# Instalador: genera los archivos necesarios para GitHub Pages
# Se borran los archivos previos y se crean los nuevos

# Borrar versiones antiguas (si existen)
rm -f index.html script.js style.css

# Crear index.html
cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Claves privadas y billeteras BTC</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <h1>Claves privadas y sus billeteras BTC</h1>
  <div id="lista"></div>
  <script src="script.js"></script>
</body>
</html>
EOF

# Crear style.css
cat << 'EOF' > style.css
body {
  font-family: Arial, sans-serif;
  background-color: #f2f2f2;
  color: #333;
  margin: 0;
  padding: 20px;
}
h1 {
  text-align: center;
}
.key-block {
  background: #fff;
  padding: 10px 15px;
  margin: 20px auto;
  max-width: 600px;
  border-radius: 5px;
  box-shadow: 0 2px 5px rgba(0,0,0,0.1);
}
.private-key {
  font-weight: bold;
  font-size: 1.1em;
}
.address {
  margin-left: 20px;
  font-family: monospace;
}
EOF

# Crear script.js
cat << 'EOF' > script.js
// Se define una lista de "wallets" con la clave privada y sus direcciones BTC.
// En este ejemplo se incluyen dos claves, cada una con 4 direcciones (que corresponden a formatos
// distintos: por ejemplo, no comprimida, comprimida, P2SH y bech32).
const wallets = [
  {
    privateKey: "0000000000000000000000000000000000000000000000000000000000000001",
    addresses: [
      { type: "U", address: "1BgGZ9tcN4rm9KBzDn7KprQz87SZ26SAMH" },
      { type: "C", address: "1EHNa6Q4Jz2uvNExL497mE43ikXhwF6kZm" },
      { type: "S", address: "3JvL6Ymt8MVWiCNHC7oWU6nLeHNJKLZGN" },
      { type: "W", address: "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f" }
    ]
  },
  {
    privateKey: "fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140",
    addresses: [
      { type: "U", address: "1GrLCmVQXoyJXaPJQdqssNqwxvha1eUo2E" },
      { type: "C", address: "1JPbzbsAx1HyaDQoLMapWGoqf9pD5uha5" },
      { type: "S", address: "38Kw57SDszoUEikRwJNBpypPSdpbAhToeD" },
      { type: "W", address: "bc1q4h0ycu78h88wzldxc7e79vhw5xsde0n8j" }
    ]
  }
];

// Función para consultar el saldo de una dirección usando la API pública de blockchain.info
function fetchBalance(address, element) {
  // Se usa el endpoint que devuelve el saldo en satoshis (se requieren 6 confirmaciones)
  const url = `https://blockchain.info/q/addressbalance/${address}?confirmations=6`;
  fetch(url)
    .then(response => response.text())
    .then(text => {
      // Convertir satoshis a BTC (dividiendo entre 100000000)
      let satoshis = parseInt(text, 10);
      let btc = (satoshis / 100000000).toFixed(8);
      element.textContent = `${address} :saldo ${btc}`;
    })
    .catch(err => {
      console.error("Error consultando saldo para " + address, err);
      element.textContent = `${address} :saldo Error`;
    });
}

// Crea el bloque HTML para cada clave privada y sus direcciones
function createWalletElement(wallet) {
  const container = document.createElement('div');
  container.className = 'key-block';
  
  // Mostrar la clave privada
  const keyP = document.createElement('p');
  keyP.className = 'private-key';
  keyP.textContent = wallet.privateKey;
  container.appendChild(keyP);
  
  // Listar cada dirección y consultar su saldo
  wallet.addresses.forEach(addrObj => {
    const addrP = document.createElement('p');
    addrP.className = 'address';
    addrP.textContent = `${addrObj.address} :saldo cargando...`;
    container.appendChild(addrP);
    fetchBalance(addrObj.address, addrP);
  });
  
  return container;
}

// Al cargar el DOM, se agregan todos los bloques de claves y direcciones
function loadWallets() {
  const lista = document.getElementById('lista');
  wallets.forEach(wallet => {
    const walletElement = createWalletElement(wallet);
    lista.appendChild(walletElement);
  });
}

document.addEventListener('DOMContentLoaded', loadWallets);
EOF

echo "Instalación completada. Se han creado index.html, script.js y style.css."
