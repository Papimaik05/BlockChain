// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

interface IExecutableProposal {
    function executeProposal(uint proposalId, uint numVotes,uint numTokens) external payable;
}

contract Proposal {
    string private titulo;
    string private descripcion;
    uint private presupuesto;
    address private direccion;      // Direccion del contrato que implementa IExecutableProposal
    address private propietario;    // Propietario de la propuesta
    bool private aprobada;
    uint private id;
    uint private votostotales;
    mapping(address => uint) private num_votos;
    address[] private dirs;

    constructor(string memory tit, string memory descr, uint presup, address dir,address prop, uint i){
        titulo=tit;
        descripcion=descr;
        presupuesto=presup;
        direccion=dir;
        propietario=prop;
        aprobada=false;
        id=i;
    }
    function getTitulo() external view returns(string memory ){
        return titulo;
    }
    function getDescripcion() external view returns(string memory ){
        return descripcion;
    }
    function getPresupuesto() external view returns(uint){
        return presupuesto;
    }
    function getDireccion() external view returns(address) {
        return direccion;
    }
    function getPropietario() external view returns(address){
        return propietario;
    }
    function getAprobada() external view returns(bool){
        return aprobada;
    }
    function getId() external view returns(uint){
        return id;
    }   
    function getVotantes() public view returns(address[] memory){
        return dirs;
    }
    function numVotos(address a) public view returns(uint n){
        return num_votos[a];
    }
    function VotosTotales() public view returns(uint n){
        return votostotales;
    }

    function info() external view returns(string memory, string memory, uint, address, address, bool){
        return (titulo, descripcion, presupuesto, direccion, propietario, aprobada);
    }
    function votar(address a, uint nvotos) external {
        dirs.push(a);
        num_votos[a] += nvotos;
        votostotales += nvotos;
    }
    function retirarVotos(address a, uint nvotos) external {
        require(nvotos <= num_votos[a], "No has emitido tantos votos");
        num_votos[a] -= nvotos;
        if(!aprobada){
            votostotales -= nvotos;
        }
    }
    function acero(address a) external {
        //votostotales -= num_votos[a];
        num_votos[a] = 0;
        
    }
    function aprobar() external {
        aprobada = true;
    }

    function executeProp(uint numTokens) external payable{    // hay que mandar el presupuesto
        IExecutableProposal(direccion).executeProposal{gas: 100000, value:msg.value}(id, votostotales, numTokens);
    }
    
}

contract PropuestaPrueba is IExecutableProposal{
    event Print(string message, uint id, uint numVotes, uint numTokens, uint presupuesto);
    function executeProposal(uint proposalId, uint numVotes, uint numTokens) external payable{
        emit Print("Propuesta ejecutada ", proposalId, numVotes, numTokens, msg.value);
    }
}