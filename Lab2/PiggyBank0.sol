// SPDX-License-Identifier: GPL-3.0

// Adrián Pérez Peinador y Miguel Mateos Matias
pragma solidity >=0.7.0 <0.8.0;

contract PiggyBank0 {
    event Print(string message);
    
    function deposit()external payable{
        // Muchas gracias
    }
    function withdraw(uint amountInWei)external{
        uint saldo = address(this).balance;
        if (saldo >= amountInWei){                      // Se comprueba que haya saldo suficiente
            payable(msg.sender).transfer(amountInWei);  // Se retira el importe indicado
            emit Print("Retiro completado");            // Se informa del movimiento
        }
        else{
            emit Print("Saldo insuficiente");           // Se informa de que no hay saldo suficiente
        }
    }

    function getBalance()external view returns (uint){
        return address(this).balance;
    }


}