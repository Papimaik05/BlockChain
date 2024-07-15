// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

abstract contract PollingStation {
    bool public votingFinished;
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
    function openVoting() external isPresident{
        require(votingOpen == false, "Voting is already open");
        votingOpen = true;
    }

    function closeVoting() external isPresident isOpen{
        require(votingOpen == true, "Voting is not open");
        require(votingFinished == false, "Voting is already closed");
        votingOpen = false;
        votingFinished = true;
    }

    function castVote(uint partyId) external virtual  ;

    function getResults() external virtual view returns (uint[] memory);
}