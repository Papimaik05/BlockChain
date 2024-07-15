// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "./DhondtElectionRegion.sol";
import "./PollingStation.sol";


contract DhondtPollingStation is DhondtElectionRegion, PollingStation{

    constructor(address presi, uint n, uint regId) DhondtElectionRegion(n, regId) PollingStation(presi){}

    function castVote(uint part) override external isOpen{
        require(registerVote(part), "No se pudo registrar el voto");
    }

    function getResults() override external view isFinished returns (uint[] memory r){
        r = results;
        return r;
    }
}