// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract DhondtElectionRegion {
    mapping(uint => uint) private weights;
    uint internal regionId;
    uint[] internal results;
    uint internal npart;

    function savedRegionInfo() private{
        weights[28] = 1; // Madrid
        weights[8] = 1; // Barcelona
        weights[41] = 1; // Sevilla
        weights[44] = 5; // Teruel
        weights[42] = 5; // Soria
        weights[49] = 4; // Zamora
        weights[9] = 4; // Burgos
        weights[29] = 2; // Malaga
    }

    constructor(uint n, uint rid){
        regionId = rid;
        npart = n;
        savedRegionInfo();
    }

    function registerVote(uint part) internal returns (bool){
        if(part < npart){
            results[part] += weights[regionId];
            return true;
        }
        else{
            return false;
        }
    }

}
