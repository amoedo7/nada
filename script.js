// =============================
// CONFIGURACIÓN DE MONEDAS A DERIVAR
// =============================

// Para monedas basadas en Bitcoin, se usan parámetros personalizados
const bitcoinCoins = [
  {
    coin: "Bitcoin",
    // Parámetros para red principal de Bitcoin
    network: {
      messagePrefix: "\x18Bitcoin Signed Message:\n",
      bech32: "bc",
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
      messagePrefix: "\x18Bitcoin Signed Message:\n",
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x00,  // Se usará el mismo método de derivación (P2PKH) y luego se deberá convertir a CashAddr; aquí se mostrará la dirección P2PKH
      scriptHash: 0x05,
      wif: 0x80
    },
    api: "https://api.blockchair.com/bitcoin-cash/dashboards/address/"
  },
  {
    coin: "Bitcoin SV",
    network: {
      messagePrefix: "\x18Bitcoin Signed Message:\n",
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
      messagePrefix: "\x18Bitcoin Signed Message:\n",
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
      messagePrefix: "\x19Litecoin Signed Message:\n",
      bech32: "ltc",
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
      messagePrefix: "\x19Dogecoin Signed Message:\n",
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
      messagePrefix: "\x19DarkCoin Signed Message:\n",
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
      messagePrefix: "\x18Zcash Signed Message:\n",
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
      messagePrefix: "\x18Clams Signed Message:\n",
      bip32: { public: 0x0488b21e, private: 0x0488ade4 },
      pubKeyHash: 0x89,
      scriptHash: 0x14,
      wif: 0xc9
    },
    api: "https://api.blockchair.com/clams/dashboards/address/" // Si el endpoint funciona
  }
];

// Configuración para monedas tipo Ethereum (usando ethers.js)
const ethereumCoins = [
  {
    coin: "Ethereum",
    api: "https://api.blockchair.com/ethereum/dashboards/address/"
  },
  {
    coin: "Ethereum Classic",
    api: "https://api.blockchair.com/ethereum-classic/dashboards/address/"
  }
];

// =============================
// FUNCIONES DE GENERACIÓN DE DIRECCIONES
// =============================

// Para monedas basadas en Bitcoin: genera tres tipos de dirección (P2PKH, P2WPKH y P2SH-P2WPKH)
function generateBitcoinAddresses(privateKeyHex, network) {
  try {
    const pkBuffer = bitcoinjsLib.Buffer.from(privateKeyHex, 'hex');
    const keyPair = bitcoinjsLib.ECPair.fromPrivateKey(pkBuffer, { network: network });
    const p2pkh = bitcoinjsLib.payments.p2pkh({ pubkey: keyPair.publicKey, network: network });
    const p2wpkh = bitcoinjsLib.payments.p2wpkh({ pubkey: keyPair.publicKey, network: network });
    const p2sh = bitcoinjsLib.payments.p2sh({ redeem: bitcoinjsLib.payments.p2wpkh({ pubkey: keyPair.publicKey, network: network }), network: network });
    return {
      P2PKH: p2pkh.address,
      P2WPKH: p2wpkh.address,
      P2SH: p2sh.address
    };
  } catch (err) {
    console.error("Error generando direcciones para clave", privateKeyHex, err);
    return null;
  }
}

// Para Ethereum y Ethereum Classic
function generateEthereumAddress(privateKeyHex) {
  try {
    const wallet = new ethers.Wallet(privateKeyHex);
    return wallet.address;
  } catch (err) {
    console.error("Error generando dirección Ethereum para clave", privateKeyHex, err);
    return null;
  }
}

// =============================
// FUNCIÓN DE CONSULTA DE SALDO
// Se usa la API de Blockchair; se espera que la respuesta incluya data.data[ADDRESS].address.balance
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

// =============================
// FUNCIÓN PRINCIPAL
// Itera sobre un número limitado de claves (para demostración) a partir de un hash base.
(async function() {
  // Hash base (clave privada en formato hexadecimal de 64 dígitos)
  const baseKey = "0000000000000000000000000000000000000000000000000000000000000001";
  // Número de claves a iterar (puedes aumentar este número)
  const iterations = 5;
  const resultsWithBalance = [];
  const resultsNoBalance = [];

  // Para cada iteración, sumar un número al valor base
  for (let i = 0; i < iterations; i++) {
    let currentKeyBig = BigInt("0x" + baseKey) + BigInt(i);
    let currentKeyHex = currentKeyBig.toString(16).padStart(64, '0');

    // Para cada moneda basada en Bitcoin (y sus variantes)
    for (const coin of bitcoinCoins) {
      const addrs = generateBitcoinAddresses(currentKeyHex, coin.network);
      if (!addrs) continue;
      // Para cada tipo de derivación (por ejemplo, P2PKH, P2WPKH, P2SH)
      for (const type in addrs) {
        const address = addrs[type];
        const balance = await getBalance(coin.api, address);
        const result = {
          coin: coin.coin + " (" + type + ")",
          address: address,
          key: currentKeyHex,
          balance: balance
        };
        if (balance > 0) {
          resultsWithBalance.push(result);
        } else {
          resultsNoBalance.push(result);
        }
      }
    }

    // Para cada moneda Ethereum (y Ethereum Classic)
    for (const ethCoin of ethereumCoins) {
      const ethAddress = generateEthereumAddress(currentKeyHex);
      if (!ethAddress) continue;
      const ethBalance = await getBalance(ethCoin.api, ethAddress);
      const ethResult = {
        coin: ethCoin.coin,
        address: ethAddress,
        key: currentKeyHex,
        balance: ethBalance
      };
      if (ethBalance > 0) {
        resultsWithBalance.push(ethResult);
      } else {
        resultsNoBalance.push(ethResult);
      }
    }
  }

  // Mostrar resultados en la página: primero los que tienen saldo, luego los que no
  const withBalanceDiv = document.getElementById("withBalance");
  const noBalanceDiv = document.getElementById("noBalance");

  resultsWithBalance.forEach(res => {
    const div = document.createElement("div");
    div.className = "address-box with-balance";
    div.innerHTML = `<span class="coin-type">${res.coin}</span>: ${res.address}<br>
                     Clave: ${res.key}<br>
                     Balance: ${res.balance}`;
    withBalanceDiv.appendChild(div);
  });

  resultsNoBalance.forEach(res => {
    const div = document.createElement("div");
    div.className = "address-box no-balance";
    div.innerHTML = `<span class="coin-type">${res.coin}</span>: ${res.address}<br>
                     Clave: ${res.key}<br>
                     Balance: ${res.balance}`;
    noBalanceDiv.appendChild(div);
  });
})();
