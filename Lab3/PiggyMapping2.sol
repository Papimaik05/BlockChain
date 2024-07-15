// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

contract PiggyMapping2 {
    struct Cliente{
        uint saldo;
        string name;
    }

    mapping (address => Cliente) clientes;
    address[] dirs;

    event Print(string message);

    function addClient (string memory name) external payable{
        require(bytes(name).length > 0, "Nombre vacio");
        Cliente memory ncl = Cliente(msg.value, name);
        clientes[msg.sender] = ncl;
        dirs.push(msg.sender);
    }

    function deposit() external payable{
        address c = msg.sender;
        require(bytes(clientes[c].name).length > 0); 
        clientes[c].saldo += msg.value;
    }

    function withdraw(uint amountInWei) external{
        address c = msg.sender;
        require(bytes(clientes[c].name).length > 0);
        require(clientes[c].saldo >= amountInWei, "Saldo insuficiente");
        clientes[c].saldo -= amountInWei;
        payable(c).transfer(amountInWei);
        emit Print("Retiro completado");
    }

    function getBalance() external view returns (uint){
        address c = msg.sender;
        require(bytes(clientes[c].name).length > 0);
        return clientes[c].saldo;
    }

    function checkBalances() external view returns(bool){
        uint suma = 0;
        for (uint i = 0; i < dirs.length; i++){
            suma += clientes[dirs[i]].saldo;
        }
        return suma == address(this).balance;
    }
}