// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract maxSol {
  function getMax(uint[] memory arr) public pure returns (uint){
    uint maxVal = arr[0];
    for (uint i = 0; i< arr.length;i++)
      { if (arr[i] > maxVal) maxVal = arr[i]; }
    return maxVal;
  }
}

contract maxAsm1 {
  function getMax(uint[] memory arr) public pure returns (uint){
    uint maxVal = arr[0];
    for (uint i = 0; i< arr.length;i++){
      assembly{
        let felem := add(arr,0x20)
        let offset := mul(i,0x20)
        let pos := add(felem,offset)
        let elem := mload(pos)
        if gt(elem,maxVal){ maxVal := elem }
    } }
    return maxVal;
  }
}

contract maxAsm2 {
  function completeMaxAsm(uint[] memory arr) public pure returns (uint maxVal){
    // Complete for loop in Yul
    assembly{
      let len := mload(arr)
      let data := add(arr, 0x20)
      maxVal := mload(data)
      let i := 1
      for {} lt(i,len) {i:= add(i,1)}
      {
       let elem := mload(add(data,mul(i,0x20)))
       if gt(elem,maxVal) { maxVal := elem }
      }
    }
  } 

  function maxMinMemory(uint[] memory arr) public pure returns (uint maxmin) {
    
    assembly{
      function fmaxmin (array_pointer) -> maxVal, minVal
      {
        let len := mload(array_pointer)
        let data := add(array_pointer, 0x20)
        maxVal := mload(data)
        minVal := mload(data)
        let i := 1
        for {} lt(i,len) {i:= add(i,1)}
        {
          let elem := mload(add(data,mul(i,0x20)))
          if gt(elem,maxVal) { maxVal := elem }
          if lt(elem,minVal) { minVal := elem }
        }
      }
      let max, min := fmaxmin(arr)
      maxmin := sub(max, min)
    }
  } 
}

contract lab6ex6 {
    uint[] public arr;

    function generate(uint n) external {
        // Populates the array with some weird small numbers.
        bytes32 b = keccak256("seed");
        for (uint i = 0; i < n; i++) {
            uint8 number = uint8(b[i % 32]);
            arr.push(number);
        }
    }

    function ver() external view returns (uint[] memory a){
        a = arr;
    }
    function maxMinStorage() public view returns (uint maxmin){
        assembly{
          function fmaxmin (slot) -> maxVal, minVal
          {
            let len := sload(slot)
            mstore(0,len) // 0 y slot mejor
            let data := keccak256(0, 0x20)
            maxVal := sload(data)
            minVal := maxVal
            let i := 1
            for {} lt(i,len) {i:= add(i,1)}
            {
              let elem := sload(add(data,i))
              if gt(elem,maxVal) { maxVal := elem }
              if lt(elem,minVal) { minVal := elem }
            }
          }

          let max, min := fmaxmin(arr.slot)
          maxmin := sub(max, min)
          
        }
    } 
    
}

contract lab6ex7 {
    uint[] public arr;

    function generate(uint n) external {
        // Populates the array with some weird small numbers.
        bytes32 b = keccak256("seed");
        for (uint i = 0; i < n; i++) {
            uint8 number = uint8(b[i % 32]);
            arr.push(number);
        }
    }

    function ver() external view returns (uint[] memory a){
        a = arr;
    }
    function maxMinStorage() public view returns (uint maxmin){
        uint min = arr[0];
        uint max  = min;
        uint l = arr.length;
        for (uint i = 0; i < l; i++){
            uint elem = arr[i];
            if(elem > max){ max = elem;}
            if(elem < min){ min = elem;}
        }
        maxmin = max - min;
    } 
    
}