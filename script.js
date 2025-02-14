// Función para consultar el saldo de una billetera
async function consultarSaldo(direccion) {
    const apiURL = `https://blockchain.info/q/addressbalance/${direccion}?confirmations=6`;
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
    return `1Bitcoin${hash.toString(16).slice(0, 12)}`;
}

// Función para generar una dirección Bitcoin Cash a partir de un hash
function generarDireccionBitcoinCash(hash) {
    // Aquí iría la lógica para convertir un hash en una dirección Bitcoin Cash
    return `bitcoincash:q${hash.toString(16).slice(0, 12)}`;
}

// Función para generar una dirección Ethereum a partir de un hash
function generarDireccionEthereum(hash) {
    // Aquí iría la lógica para convertir un hash en una dirección Ethereum
    return `0x${hash.toString(16).slice(0, 12)}`;
}

// Función para generar una dirección Litecoin a partir de un hash
function generarDireccionLitecoin(hash) {
    // Aquí iría la lógica para convertir un hash en una dirección Litecoin
    return `L${hash.toString(16).slice(0, 12)}`;
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
            let saldoTexto = saldo !== null ? `Saldo: ${saldo} BTC` : "No disponible";

            // Si la billetera tiene saldo, la mostramos en la parte superior
            if (saldo && saldo > 0) {
                divBilletera.classList.add('saldo');
                divBilletera.innerHTML = `
                    <p><strong>${direccion} (${tipo})</strong></p>
                    <p class="hash">Hash: ${hashActual.toString(16)}</p>
                    <p class="saldo">${saldoTexto}</p>
                `;
                conSaldoDiv.appendChild(divBilletera);
                billeteraEncontrada = true;
            } else {
                // Si no tiene saldo, la mostramos al final
                divBilletera.classList.add('saldo-none');
                divBilletera.innerHTML = `
                    <p><strong>${direccion} (${tipo})</strong></p>
                    <p class="hash">Hash: ${hashActual.toString(16)}</p>
                    <p class="saldo">${saldoTexto}</p>
                `;
                sinSaldoDiv.appendChild(divBilletera);
            }
        }

        // Aumentar el hash para iterar al siguiente
        hashActual++;
    }
}

// Iniciar la iteración al cargar la página
window.onload = iterarHashes;
