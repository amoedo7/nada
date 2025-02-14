// Dirección de la billetera Bitcoin
const address = "1MewpRkpcbFdqamPPYc1bXa9AJ189Succy";

// URL de la API para obtener el saldo
const apiURL = `https://blockchain.info/q/addressbalance/${address}?confirmations=6`;

// Función para obtener el saldo de la billetera
async function obtenerSaldo() {
    try {
        // Realizar la solicitud a la API
        const response = await fetch(apiURL);
        const saldoSatoshis = await response.text();

        // Convertir Satoshis a BTC (1 BTC = 100,000,000 Satoshis)
        const saldoBTC = saldoSatoshis / 100000000;

        // Mostrar el saldo en la página
        document.getElementById('saldo').textContent = `${saldoBTC} BTC`;
    } catch (error) {
        document.getElementById('saldo').textContent = 'Error al obtener el saldo.';
        console.error("Error al obtener el saldo: ", error);
    }
}

// Llamar a la función para obtener el saldo cuando se cargue la página
window.onload = obtenerSaldo;
