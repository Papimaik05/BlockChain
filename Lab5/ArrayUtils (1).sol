// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;


library ArrayUtils {

    function contains(string[] storage s, string memory val) internal view returns (bool) {
        bool b = false;
        uint i = 0;
        while(i < s.length && !b){
            if(sha256(bytes(s[i])) == sha256(bytes(val))){ b = true;  }
            i++;
        }
        return b;
    }
  
    function increment(uint[] storage s, uint8 porcentaje) internal {
        for(uint i = 0; i < s.length; i++){
           s[i] = (100*s[i]+porcentaje*s[i])/100;
        }
    }

    function sum(uint[] storage s) internal view returns(uint suma){
        suma = 0;
        for(uint i = 0; i < s.length; i++){
           suma += s[i];
        }
    }

    function remove(uint[] storage s, uint x) internal {
        bool found = false;
        uint i = 0;
        while(!found && i < s.length){
            if(s[i] == x){
                found = true;
                s[i] = s[s.length - 1];
                s.pop();
            }
            i++;
        }
    }
}