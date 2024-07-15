// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "./ArrayUtils.sol";
import "./ERC721simplified.sol";


contract MonsterTokens is ERC721simplified{
    uint tokenCont;
    address private owner;
    mapping(uint => Character) private characters;
    mapping(address => uint[]) private propietarios;

    struct Weapons {
        string[] names; // name of the weapon
        uint[] firePowers; // capacity of the weapon
    }
    struct Character {
        address propietario;
        address autorizado;
        string name; // character name
        Weapons weapons; // weapons assigned to this character
        // ... you must add other fields for handling the token.
    }
    constructor(){
        tokenCont = 10001;
        owner = msg.sender;
    }

    modifier isOwner{
        require(msg.sender == owner);
        _;
    }
    modifier isAuthorised(uint tId){
        require(msg.sender == characters[tId].propietario || msg.sender == characters[tId].autorizado);
        _;
    }

    function createMonsterToken(string memory _name, address _owner) external isOwner returns (uint) {
        require(bytes(_name).length != 0);
        characters[tokenCont] = Character(_owner, address(0), _name, Weapons(new string[] (0), new uint[] (0)));
        propietarios[_owner].push(tokenCont);
        tokenCont++;
        return tokenCont-1;
    }

    function addWeapon(uint _tokenId, string memory _name, uint _potencia) external isAuthorised(_tokenId){
        require(!ArrayUtils.contains(characters[_tokenId].weapons.names, _name));
        characters[_tokenId].weapons.names.push(_name);
        characters[_tokenId].weapons.firePowers.push(_potencia);
    }

    function incrementFirePower(uint _tokenId, uint8 _porcentaje) external {
        require(bytes(characters[_tokenId].name).length != 0);
        ArrayUtils.increment(characters[_tokenId].weapons.firePowers, _porcentaje);
    }

    function collectProfits() external isOwner{
        uint balance = address(this).balance;
        require(balance > 0); 
        payable(owner).transfer(balance);
    }

    // APPROVAL FUNCTIONS
    function approve(address _approved, uint256 _tokenId) external payable{
        require(characters[_tokenId].propietario == msg.sender);
        require(ArrayUtils.sum(characters[_tokenId].weapons.firePowers) <= msg.value);
        characters[_tokenId].autorizado = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    // TRANSFER FUNCTION
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable isAuthorised(_tokenId){
        require(_from == characters[_tokenId].propietario);
        require(ArrayUtils.sum(characters[_tokenId].weapons.firePowers) <= msg.value);
        characters[_tokenId].propietario = _to;
        characters[_tokenId].autorizado = address(0);
        propietarios[_to].push(_tokenId);
        ArrayUtils.remove(propietarios[_from], _tokenId);    //quitar de propietarios[_from] el elemento _tokenId
        emit Transfer(_from, _to, _tokenId);
    }

    // VIEW FUNCTIONS (GETTERS)
    function balanceOf(address _owner) external view returns (uint256){
        return propietarios[_owner].length;
    }
    function ownerOf(uint256 _tokenId) external view returns (address){
        address v = characters[_tokenId].propietario;
        require(v != address(0));
        return v;
    }
    function getApproved(uint256 _tokenId) external view returns (address){
        require(_tokenId > 10000 && _tokenId < tokenCont);
        return characters[_tokenId].autorizado;
    }

}