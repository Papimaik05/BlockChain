// SPDX-License-Identifier: GPL-3.0

// Adrián Pérez Peinador y Miguel Mateos Matias
pragma solidity >=0.7.0 <0.8.0;
contract hello {
    event Print(string message);
    function helloWorld() public {
        emit Print("Hello, World!");
    }
    function factorial(uint n) public pure returns (uint){
        uint fact = 1;
        for (uint i = 0; i < n; i++){
            fact *= i+1;
        }
        return fact;
    }

}