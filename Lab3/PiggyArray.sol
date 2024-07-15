// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

contract PiggyArray {
    struct Cliente{
        address dir;
        uint saldo;
        string name;
    }

    Cliente[] cl;

    event Print(string message);

    function addClient (string memory name) external payable{
        require(bytes(name).length > 0, "Nombre vacio");
        Cliente memory ncl = Cliente(msg.sender, msg.value, name);
        cl.push(ncl);
    }

    function deposit() external payable{
        address client = msg.sender;
        uint i = 0;
        bool found = false;
        while(i < cl.length && !found){
            if (cl[i].dir == client){
                found = true;
                cl[i].saldo += msg.value;
            }
            i++;
        }
    }

    function withdraw(uint amountInWei) external{
        address client = msg.sender;
        uint i = 0;
        bool found = false;
        while(i < cl.length && !found){
            if(cl[i].dir == client){
                found = true;
                require(cl[i].saldo >= amountInWei, "Saldo insuficiente");
                cl[i].saldo -= amountInWei;
                payable(client).transfer(amountInWei);
                emit Print("Retiro completado");
            }
            i++;
        }
    }

    function getBalance() external view returns (uint){
        address client = msg.sender;
        uint i = 0;
        bool found = false;
        while(i < cl.length && !found){
            if(cl[i].dir == client){
                found = true;
                return cl[i].saldo;
            }
            i++;
        }
        require(found);
        return i;       // No debería llegar, es para evitar el warning
    }
}