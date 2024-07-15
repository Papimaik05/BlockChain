// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

abstract contract PollingStation {
    bool private votingFinished;
    bool private votingOpen;
    address internal president;

    constructor(address presi){
        president = presi;
        votingFinished = false;
        votingOpen = false;
    }


    modifier isPresident{
        require(msg.sender == president, "Permiso denegado");
        _;
    }
    modifier isOpen {
        require(votingOpen, "La votacion no ha comenzado");
        _;
    }

    modifier isFinished {
        require(votingFinished, "Votacion no terminada");
        _;
    }

    function openVoting() external /*isPresident*/ returns (address, address){
        votingOpen = true;
        return (msg.sender, president);
    }

    function closeVoting() external isPresident isOpen{
        votingOpen = false;
        votingFinished = true;
    }

    function castVote(uint part) virtual external;

    function getResults() virtual external returns(uint[] memory);
}