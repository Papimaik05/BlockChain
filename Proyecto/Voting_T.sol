// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Voting_T is ERC20{
    address private owner;
    uint private p_token;
    uint256 private max_tokens;
    
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        owner = msg.sender;
    }

    modifier isOwner{
        require(msg.sender == owner, "Permiso denegado");
        _;
    }

    function initilize(uint precio_token, uint256 maximo) external payable isOwner{
        p_token = precio_token;
        max_tokens = maximo;
    }
    
    function new_token(address prop, uint cantidad) external isOwner{
        require(totalSupply() + cantidad <= max_tokens, "No se pueden crear tantos tokens");
        _mint(prop, cantidad);
    }

    function del_token(address prop, uint cantidad) external isOwner{
        require(cantidad < totalSupply(), "No hay tantos tokens que borrar");
        _burn(prop, cantidad);
    }
    function precio() external view returns(uint){
        return p_token;
    }
    
}