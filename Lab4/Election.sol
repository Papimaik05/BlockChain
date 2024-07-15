// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "./DhondtPollingStation.sol";


contract Election {
    address private authority;
    bool[53] private regions; // Pues existen 52 regiones administrativas en España
    DhondtPollingStation[53] private stations;
    uint private npart;
    mapping(address => bool) private voters;
    
    modifier onlyAuthority{
        require(msg.sender == authority, "Permiso denegado");
        _;
    }
    modifier freshId(uint regionId){
        require(regionId < 53 && !regions[regionId], "Ya hay sede para esa region");
        _;
    }
    modifier validId(uint regionId){
        require(regions[regionId], "No hay sede para esa region");
        _;
    }

    constructor(uint n){
        npart = n;
        authority = msg.sender;
    }

    function createPollingStation(uint regId, address presi) external freshId(regId) onlyAuthority returns (address c){
        stations[regId] = new DhondtPollingStation(presi, npart, regId);
        regions[regId] = true;
        c = address(stations[regId]);
    }

    function castVote(uint regId, uint party) external validId(regId){
        require(!voters[msg.sender], "Usted ya ha emitido su voto");
        stations[regId].castVote(party);
        voters[msg.sender] = true;
    }

    function getResults() external onlyAuthority view returns (uint[] memory){
        uint[] memory res;
        uint[] memory aux;
        for (uint i = 0; i < npart; i++){ res[i] = 0; }
        for (uint i = 0; i < 53; i++){
            if(regions[i]){
                aux = stations[i].getResults();
                for (uint j = 0; j < npart; j++){ res[j] += aux[j]; } 
            }
        }
        return res;
    }

    /*function openVoting(uint regId) external validId(regId) returns (address, address){
        return stations[regId].openVoting();
    }

    function closeVoting(uint regId) external validId(regId){
        stations[regId].closeVoting();
    }*/
}