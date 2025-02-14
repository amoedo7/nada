#!/bin/bash
# instalador.sh – Crea index.html, style.css y script.js con funcionalidad real

cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Consulta de Billeteras Derivadas</title>
  <link rel="stylesheet" href="style.css">
  <!-- Incluir bibliotecas desde CDN -->
  <script src="https://unpkg.com/bitcoinjs-lib@6.0.0/dist/bitcoinjs-lib.min.js"></script>
  <script src="https://cdn.ethers.io/lib/ethers-5.2.umd.min.js"></script>
</head>
<body>
  <div class="container">
    <h1>Billeteras con Saldo</h1>
    <div id="withBalance"></div>
    <h1>Billeteras sin Saldo</h1>
    <div id="noBalance"></div>
  </div>
  <script src="script.js"></script>
</body>
</html>
EOF

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

cat << 'EOF' > script.js
// ---------------------------
// CONFIGURACIÓN DE REDES Y APIS
// ---------------------------

// Para las monedas basadas en Bitcoin, definimos los parámetros personalizados.
const networks = {
  bitcoin: {
    name: "Bitcoin",
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
  bitcoincash: {
    name: "Bitcoin Cash",
    network: {
      messagePrefix: '\x18Bitcoin Signed Message:\n',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x00,
      scriptHash: 0x05,
      wif: 0x80
    },
    api: "https://api.blockchair.com/bitcoin-cash/dashboards/address/"
  },
  bitcoinsv: {
    name: "Bitcoin SV",
    network: {
      messagePrefix: '\x18Bitcoin Signed Message:\n',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x00,
      scriptHash: 0x05,
      wif: 0x80
    },
    api: "https://api.blockchair.com/bitcoin-sv/dashboards/address/"
  },
  bitcoingold: {
    name: "Bitcoin Gold",
    network: {
      messagePrefix: '\x18Bitcoin Signed Message:\n',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x26,
      scriptHash: 0x17,
      wif: 0x80
    },
    api: "https://api.blockchair.com/bitcoin-gold/dashboards/address/"
  },
  litecoin: {
    name: "Litecoin",
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
  dogecoin: {
    name: "Dogecoin",
    network: {
      messagePrefix: '\x19Dogecoin Signed Message:\n',
      bip32: { public: 0x02facafd, private: 0x02fac398 },
      pubKeyHash: 0x1e,
      scriptHash: 0x16,
      wif: 0x9e
    },
    api: "https://api.blockchair.com/dogecoin/dashboards/address/"
  },
  dash: {
    name: "Dash",
    network: {
      messagePrefix: '\x19DarkCoin Signed Message:\n',
      bip32: { public: 0x02fe52cc, private: 0x02fe52f8 },
      pubKeyHash: 0x4c,
      scriptHash: 0x10,
      wif: 0xcc
    },
    api: "https://api.blockchair.com/dash/dashboards/address/"
  },
  zcash: {
    name: "Zcash",
    network: {
      messagePrefix: '\x18Zcash Signed Message:\n',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x1c,  // Aproximado para direcciones transparentes
      scriptHash: 0x1c,
      wif: 0x80
    },
    api: "https://api.blockchair.com/zcash/dashboards/address/"
  },
  clams: {
    name: "Clams",
    network: {
      messagePrefix: '\x18Clams Signed Message:\n',
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x89,
      scriptHash: 0x14,
      wif: 0xc9
    },
    api: "https://api.blockchair.com/clams/dashboards/address/" // Si existe endpoint
  }
};

// Configuración para Ethereum (usamos ethers.js)
const ethereum = {
  name: "Ethereum",
  api: "https://api.blockchair.com/ethereum/dashboards/address/"
};

// ---------------------------
// FUNCIONES PARA GENERAR DIRECCIONES
// ---------------------------

// Para monedas basadas en Bitcoin (usando bitcoinjs-lib)
function generateAddress(networkParams, privateKeyHex) {
  const pkBuffer = bitcoinjsLib.Buffer.from(privateKeyHex, 'hex');
  const keyPair = bitcoinjsLib.ECPair.fromPrivateKey(pkBuffer, { network: networkParams });
  const { address } = bitcoinjsLib.payments.p2pkh({ pubkey: keyPair.publicKey, network: networkParams });
  return address;
}

// Para Ethereum (usando ethers.js)
function generateEthereumAddress(privateKeyHex) {
  const wallet = new ethers.Wallet(privateKeyHex);
  return wallet.address;
}

// ---------------------------
// FUNCIÓN PARA CONSULTAR SALDO MEDIANTE API (Blockchair)
// La función espera que la respuesta tenga la estructura: 
// data.data[ADDRESS].address.balance
async function getBalance(apiUrl, address) {
  try {
    let response = await fetch(apiUrl + address);
    let data = await response.json();
    // Si la API responde correctamente:
    if (data && data.data && data.data[address] && data.data[address].address) {
      return data.data[address].address.balance;
    } else {
      return 0;
    }
  } catch (err) {
    console.error("Error en getBalance:", err);
    return 0;
  }
}

// ---------------------------
// FUNCIÓN PRINCIPAL: ITERAR SOBRE UN RANGO DE HASHES
// NOTA: Debido a que el rango completo de un hash256 es gigantesco,
// para efectos de demostración iteramos solo 'iterations' valores consecutivos.
(async function() {
  // Hash inicial (en formato de 64 dígitos hex)
  const startHash = "0000000000000000000000000000000000000000000000000000000000000001";
  const iterations = 10; // Cambiar este valor según lo deseado
  const withBalance = [];
  const noBalance = [];
  
  for (let i = 0; i < iterations; i++) {
    // Calcular hash actual (como BigInt) y formatearlo a 64 dígitos
    let currentHashBig = BigInt("0x" + startHash) + BigInt(i);
    let currentHashHex = currentHashBig.toString(16).padStart(64, '0');
    
    // Para cada moneda basada en Bitcoin
    for (let coin in networks) {
      const net = networks[coin];
      let address;
      try {
        address = generateAddress(net.network, currentHashHex);
      } catch (e) {
        address = "Error generando dirección";
      }
      // Consultar saldo (balance en satoshis)
      let balanceRaw = await getBalance(net.api, address);
      // Convertir satoshis a la unidad principal (si es mayor a 0)
      let displayBalance = (balanceRaw > 0) ? (balanceRaw / 1e8).toFixed(8) : "0.00000000";
      
      const result = {
        coin: net.name,
        address: address,
        hash: currentHashHex,
        balance: displayBalance
      };
      if (balanceRaw > 0) {
        withBalance.push(result);
      } else {
        noBalance.push(result);
      }
    }
    
    // Para Ethereum:
    let ethAddress = generateEthereumAddress(currentHashHex);
    let ethBalanceRaw = await getBalance(ethereum.api, ethAddress);
    // Convertir de wei a ETH (asumiendo que la API devuelve wei)
    let ethDisplayBalance = (ethBalanceRaw > 0) ? (ethBalanceRaw / 1e18).toFixed(8) : "0.00000000";
    const ethResult = {
      coin: ethereum.name,
      address: ethAddress,
      hash: currentHashHex,
      balance: ethDisplayBalance
    };
    if (ethBalanceRaw > 0) {
      withBalance.push(ethResult);
    } else {
      noBalance.push(ethResult);
    }
  }
  
  // Mostrar los resultados en la página:
  const withBalanceDiv = document.getElementById("withBalance");
  const noBalanceDiv = document.getElementById("noBalance");
  
  withBalance.forEach(res => {
    const div = document.createElement("div");
    div.className = "address-box with-balance";
    div.innerHTML = `<strong>${res.coin}</strong>: ${res.address} <br>Hash: ${res.hash} <br>Balance: ${res.balance}`;
    withBalanceDiv.appendChild(div);
  });
  
  noBalance.forEach(res => {
    const div = document.createElement("div");
    div.className = "address-box no-balance";
    div.innerHTML = `<strong>${res.coin}</strong>: ${res.address} <br>Hash: ${res.hash} <br>Balance: ${res.balance}`;
    noBalanceDiv.appendChild(div);
  });
})();
EOF

echo "Archivos creados correctamente: index.html, style.css y script.js"
