#!/bin/bash
# instalador.sh – Crea index.html, style.css y script.js para generar direcciones reales a partir de un hash256

# Genera index.html
cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Consulta de Billeteras Derivadas</title>
  <link rel="stylesheet" href="style.css">
  <!-- Se incluyen las bibliotecas desde CDN -->
  <script src="https://unpkg.com/bitcoinjs-lib@6.0.0/dist/bitcoinjs-lib.min.js"></script>
  <script src="https://cdn.ethers.io/lib/ethers-5.2.umd.min.js"></script>
</head>
<body>
  <div class="container">
    <h1>Billeteras CON Saldo</h1>
    <div id="withBalance"></div>
    <h1>Billeteras SIN Saldo</h1>
    <div id="noBalance"></div>
  </div>
  <script src="script.js"></script>
</body>
</html>
EOF

# Genera style.css
cat << 'EOF' > style.css
body {
  font-family: Arial, sans-serif;
  background: #f0f0f0;
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
.address-box {
  background: #fff;
  margin: 10px;
  padding: 10px;
  border-radius: 5px;
  box-shadow: 0 0 5px rgba(0,0,0,0.1);
}
.with-balance {
  border-left: 5px solid #28a745;
}
.no-balance {
  border-left: 5px solid #dc3545;
}
EOF

# Genera script.js
cat << 'EOF' > script.js
// ---------------------------
// CONFIGURACIÓN DE CRIPTOMONEDAS
// ---------------------------

// Configuraciones para monedas basadas en Bitcoin (se usarán para Bitcoin, Bitcoin Cash, SV, Gold, Litecoin, Dogecoin, Dash, Zcash y Clams)
// Los parámetros de red se basan en bitcoinjs-lib
const bitcoinCoins = [
  {
    coin: "Bitcoin",
    network: {
      messagePrefix: '\x18Bitcoin Signed Message:\n',
      bech32: 'bc',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x00,
      scriptHash: 0x05,
      wif: 0x80
    },
    api: "https://api.blockchair.com/bitcoin/dashboards/address/"
  },
  {
    coin: "Bitcoin Cash",
    network: {
      messagePrefix: '\x18Bitcoin Signed Message:\n',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x00,
      scriptHash: 0x05,
      wif: 0x80
    },
    api: "https://api.blockchair.com/bitcoin-cash/dashboards/address/"
  },
  {
    coin: "Bitcoin SV",
    network: {
      messagePrefix: '\x18Bitcoin Signed Message:\n',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x00,
      scriptHash: 0x05,
      wif: 0x80
    },
    api: "https://api.blockchair.com/bitcoin-sv/dashboards/address/"
  },
  {
    coin: "Bitcoin Gold",
    network: {
      messagePrefix: '\x18Bitcoin Signed Message:\n',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x26,
      scriptHash: 0x17,
      wif: 0x80
    },
    api: "https://api.blockchair.com/bitcoin-gold/dashboards/address/"
  },
  {
    coin: "Litecoin",
    network: {
      messagePrefix: '\x19Litecoin Signed Message:\n',
      bech32: 'ltc',
      bip32: { public: 0x019da462, private: 0x019d9cfe },
      pubKeyHash: 0x30,
      scriptHash: 0x32,
      wif: 0xb0
    },
    api: "https://api.blockchair.com/litecoin/dashboards/address/"
  },
  {
    coin: "Dogecoin",
    network: {
      messagePrefix: '\x19Dogecoin Signed Message:\n',
      bip32: { public: 0x02facafd, private: 0x02fac398 },
      pubKeyHash: 0x1e,
      scriptHash: 0x16,
      wif: 0x9e
    },
    api: "https://api.blockchair.com/dogecoin/dashboards/address/"
  },
  {
    coin: "Dash",
    network: {
      messagePrefix: '\x19DarkCoin Signed Message:\n',
      bip32: { public: 0x02fe52cc, private: 0x02fe52f8 },
      pubKeyHash: 0x4c,
      scriptHash: 0x10,
      wif: 0xcc
    },
    api: "https://api.blockchair.com/dash/dashboards/address/"
  },
  {
    coin: "Zcash",
    network: {
      messagePrefix: '\x18Zcash Signed Message:\n',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x1c,
      scriptHash: 0x1c,
      wif: 0x80
    },
    api: "https://api.blockchair.com/zcash/dashboards/address/"
  },
  {
    coin: "Clams",
    network: {
      messagePrefix: '\x18Clams Signed Message:\n',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x89,
      scriptHash: 0x14,
      wif: 0xc9
    },
    api: "https://api.blockchair.com/clams/dashboards/address/" // Puede no estar operativo
  }
];

// Configuración para Ethereum (se tratará por separado)
const ethereumCoin = {
  coin: "Ethereum",
  api: "https://api.blockchair.com/ethereum/dashboards/address/"
};

// ---------------------------
// FUNCIONES DE GENERACIÓN DE DIRECCIONES
// ---------------------------

// Para monedas basadas en Bitcoin (usa bitcoinjs-lib)
// Se asume que el hash (clave privada) se provee como string hexadecimal de 64 dígitos
function generateBitcoinAddress(privateKeyHex, network) {
  try {
    const pkBuffer = Buffer.from(privateKeyHex, 'hex');
    const keyPair = bitcoinjsLib.ECPair.fromPrivateKey(pkBuffer, { network: network });
    const { address } = bitcoinjsLib.payments.p2pkh({ pubkey: keyPair.publicKey, network: network });
    return address;
  } catch (err) {
    console.error("Error generando dirección para clave:", privateKeyHex, err);
    return null;
  }
}

// Para Ethereum (usa ethers.js)
function generateEthereumAddress(privateKeyHex) {
  try {
    const wallet = new ethers.Wallet(privateKeyHex);
    return wallet.address;
  } catch (err) {
    console.error("Error generando dirección Ethereum para clave:", privateKeyHex, err);
    return null;
  }
}

// ---------------------------
// FUNCIÓN PARA CONSULTAR SALDO
// Se utiliza la API de Blockchair; se espera que la respuesta tenga
// data.data[ADDRESS].address.balance
async function getBalance(apiUrl, address) {
  try {
    const response = await fetch(apiUrl + address);
    const json = await response.json();
    if (json && json.data && json.data[address] && json.data[address].address) {
      return Number(json.data[address].address.balance);
    }
  } catch (err) {
    console.error("Error consultando balance para", address, err);
  }
  return 0;
}

// ---------------------------
// FUNCIÓN PRINCIPAL: ITERAR SOBRE UN RANGO DE HASHES
// Para efectos de demostración, se iterarán 'iterations' claves consecutivas
(async function() {
  const startHash = "0000000000000000000000000000000000000000000000000000000000000001";
  const iterations = 10; // Número de claves a probar (puedes aumentarlo si lo deseas)
  const resultsWithBalance = [];
  const resultsNoBalance = [];
  
  for (let i = 0; i < iterations; i++) {
    // Sumar i al hash inicial y formatear a 64 dígitos
    let currentBig = BigInt("0x" + startHash) + BigInt(i);
    let currentHash = currentBig.toString(16).padStart(64, '0');
    
    // Para cada moneda basada en Bitcoin:
    for (const coinConfig of bitcoinCoins) {
      const addr = generateBitcoinAddress(currentHash, coinConfig.network);
      if (!addr) continue;
      const bal = await getBalance(coinConfig.api, addr);
      const result = {
        coin: coinConfig.coin,
        address: addr,
        hash: currentHash,
        balance: bal
      };
      if (bal > 0) {
        resultsWithBalance.push(result);
      } else {
        resultsNoBalance.push(result);
      }
    }
    
    // Para Ethereum:
    const ethAddr = generateEthereumAddress(currentHash);
    if (ethAddr) {
      const ethBal = await getBalance(ethereumCoin.api, ethAddr);
      const ethResult = {
        coin: ethereumCoin.coin,
        address: ethAddr,
        hash: currentHash,
        balance: ethBal
      };
      if (ethBal > 0) {
        resultsWithBalance.push(ethResult);
      } else {
        resultsNoBalance.push(ethResult);
      }
    }
  }
  
  // Mostrar los resultados en la página:
  const withBalanceDiv = document.getElementById("withBalance");
  const noBalanceDiv = document.getElementById("noBalance");
  
  resultsWithBalance.forEach(res => {
    const div = document.createElement("div");
    div.className = "address-box with-balance";
    div.innerHTML = `<strong>${res.coin}</strong>: ${res.address}<br>Hash: ${res.hash}<br>Balance: ${res.balance}`;
    withBalanceDiv.appendChild(div);
  });
  
  resultsNoBalance.forEach(res => {
    const div = document.createElement("div");
    div.className = "address-box no-balance";
    div.innerHTML = `<strong>${res.coin}</strong>: ${res.address}<br>Hash: ${res.hash}<br>Balance: ${res.balance}`;
    noBalanceDiv.appendChild(div);
  });
})();
EOF

echo "Archivos creados correctamente: index.html, style.css y script.js"
