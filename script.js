// Definimos el hash inicial y el final
const hashInicial = BigInt("0x0000000000000000000000000000000000000000000000000000000000000001");
const hashFinal = BigInt("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff");

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
function generarDireccion(hash) {
    // Aquí se utilizaría una librería para generar una dirección Bitcoin válida a partir de un hash
    // Esto es solo un ejemplo de cómo se vería la dirección generada a partir de un hash.
    return `1Billetera${hash.toString(16).slice(0, 12)}`;
}

// Función principal que itera sobre los hashes
async function iterarHashes() {
    let resultadosDiv = document.getElementById('resultados');
    let hashActual = hashInicial;

    while (hashActual <= hashFinal) {
        let direccion = generarDireccion(hashActual);
        let saldo = await consultarSaldo(direccion);
        
        let divBilletera = document.createElement('div');
        divBilletera.classList.add('billetera');
        divBilletera.innerHTML = `
            <p><strong>${direccion}</strong></p>
            <p id="saldo${direccion}">Saldo: ${saldo !== null ? saldo + " BTC" : "No disponible"}</p>
        `;

        resultadosDiv.appendChild(divBilletera);
        
        hashActual++;
    }
}

// Iniciar la iteración al cargar la página
window.onload = iterarHashes;
