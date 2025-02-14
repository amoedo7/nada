// Función para consultar el saldo usando la API de Blockchair para Bitcoin
async function getBalance(address) {
  const apiUrl = "https://api.blockchair.com/bitcoin/dashboards/address/";
  try {
    const response = await fetch(apiUrl + address);
    const json = await response.json();
    if (json && json.data && json.data[address] && json.data[address].address) {
      return Number(json.data[address].address.balance);
    }
  } catch (error) {
    console.error("Error al obtener saldo para", address, error);
  }
  return 0;
}

// Función principal: derivar direcciones BTC (P2PKH) a partir de una clave privada base
(async function() {
  // Clave privada base (hash256 en 64 dígitos)
  const baseKey = "0000000000000000000000000000000000000000000000000000000000000001";
  const iterations = 5; // Número de claves a probar (puedes aumentarlo)
  const resultsWithBalance = [];
  const resultsNoBalance = [];
  
  for (let i = 0; i < iterations; i++) {
    // Sumar i a la clave base y formatear a 64 caracteres hexadecimales
    let currentKeyBig = BigInt("0x" + baseKey) + BigInt(i);
    let currentKeyHex = currentKeyBig.toString(16).padStart(64, '0');
    
    try {
      // Generar dirección BTC P2PKH usando bitcoinjs-lib
      const pkBuffer = bitcoinjsLib.Buffer.from(currentKeyHex, 'hex');
      const keyPair = bitcoinjsLib.ECPair.fromPrivateKey(pkBuffer);
      const { address } = bitcoinjsLib.payments.p2pkh({ pubkey: keyPair.publicKey });
      
      // Consultar saldo para la dirección
      let balance = await getBalance(address);
      const result = { address: address, key: currentKeyHex, balance: balance };
      
      if (balance > 0) {
        resultsWithBalance.push(result);
      } else {
        resultsNoBalance.push(result);
      }
    } catch (error) {
      console.error("Error generando dirección para clave", currentKeyHex, error);
    }
  }
  
  // Mostrar resultados en la página
  const withBalanceDiv = document.getElementById("withBalance");
  const noBalanceDiv = document.getElementById("noBalance");
  
  resultsWithBalance.forEach(res => {
    const div = document.createElement("div");
    div.className = "address-box with-balance";
    div.innerHTML = `<strong>BTC (P2PKH)</strong>: ${res.address}<br>
                     Clave: ${res.key}<br>
                     Balance: ${res.balance}`;
    withBalanceDiv.appendChild(div);
  });
  
  resultsNoBalance.forEach(res => {
    const div = document.createElement("div");
    div.className = "address-box no-balance";
    div.innerHTML = `<strong>BTC (P2PKH)</strong>: ${res.address}<br>
                     Clave: ${res.key}<br>
                     Balance: ${res.balance}`;
    noBalanceDiv.appendChild(div);
  });
})();
