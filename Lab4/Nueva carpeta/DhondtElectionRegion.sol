// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract DhondtElectionRegion {
    mapping(uint => uint) private weights;
    uint internal regionId;
    uint[] internal results;

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
        require(n > 0, "Number of parties must be greater than 0.");
        regionId = rid;
        results = new uint[](n);
        savedRegionInfo();
    }

    function registerVote(uint part) internal returns (bool){
        require(part >= 0 && part < results.length, "Invalid party ID.");
        results[part] += weights[regionId];
        return true;
    }

}
