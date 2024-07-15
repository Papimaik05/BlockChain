// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "./Voting_T.sol";
import "./Proposal.sol";
contract QuadraticVoting {
    address private owner;
    bool private votingOpen;
    bool private closing;
    uint private presupuesto;
    uint private nparticipantes;
    uint private npending;
    uint private nsignaling;
    uint private napproved;
    Voting_T private gestorToken;
    Proposal[] private props;
    mapping(address => bool) participants;
    mapping(uint => uint) TokensInvertidos;
    
    constructor(uint _precio, uint _maximo){
        owner = msg.sender;
        gestorToken=new Voting_T("Gestor","Simbolo");
        gestorToken.initilize(_precio, _maximo);
        votingOpen = false;
    }

    modifier isOwner{
        require(msg.sender == owner, "Permiso denegado");
        _;
    }
    modifier isOpen{
        require(votingOpen, "Votacion cerrada");
        _;
    }
    modifier isParticipant{
        require(participants[msg.sender], "No eres un participante");
        _;
    }
    modifier aprobable(uint id){
        require(id < props.length && noCancelada(id) && !props[id].getAprobada(), "Cancelada/aprobada"); 
        _;
    }
   
    function noCancelada(uint id) internal view returns (bool){
        return address(props[id]) != address(0);
    }

    function openVoting () external payable isOwner{
        require(!votingOpen, "Ya abierta");
        votingOpen = true;
        presupuesto = msg.value;
        props = new Proposal[] (0);
    }

    function addParticipant() external payable{
        require(msg.value >= gestorToken.precio(), "Importe insuficiente");
        unchecked{
            uint cantidad = msg.value/gestorToken.precio();
            gestorToken.new_token(msg.sender, cantidad);
            if(!participants[msg.sender]){
                nparticipantes++;
            }
            participants[msg.sender] = true;
        }
    }

    function removeParticipant() external {
        unchecked{
        if(participants[msg.sender]){
            nparticipantes--;
            participants[msg.sender] = false;
            gestorToken.del_token(msg.sender, gestorToken.balanceOf(msg.sender));
        }
        }
    }

    function addProposal(string memory tit, string memory descr, uint presup, address dir) external isParticipant isOpen returns (uint id){
        unchecked{
            if (presup == 0){
                nsignaling++;
            }
            else{
                npending++;
            }
            props.push(new Proposal(tit,descr,presup, dir, msg.sender,props.length));
            id = props.length - 1;
        }
    }

    function cancelProposal(uint id) external isOpen aprobable(id){
        require(msg.sender==props[id].getPropietario(),"No eres el propietario");
        address[] memory dirs = props[id].getVotantes();
        unchecked{
        if (props[id].getPresupuesto() == 0){
            nsignaling--;
        }
        else{
            npending--;
        }
        for (uint i =0;i<dirs.length;i++){
            uint n = props[id].numVotos(dirs[i]);
            if(n!=0){
                props[id].acero(dirs[i]);
                uint amount = n*n;
                gestorToken.transfer(dirs[i], amount);
            }
        }}
        delete props[id];
    }

    function buyTokens() external payable isParticipant{
        require(msg.value >= gestorToken.precio(), "Importe insuficiente");
        unchecked{
            gestorToken.new_token(msg.sender, msg.value/gestorToken.precio());
        }
    }
    function sellTokens(uint c) external {
        require(c >0 && c <= gestorToken.balanceOf(msg.sender), "No tienes tantos tokens");
        gestorToken.del_token(msg.sender, c);
        unchecked{
        c *= gestorToken.precio();
        }
        payable(msg.sender).transfer(c);
    }

    function getERC20() external view returns (address) {
        return address(gestorToken);
    }

    function getPendingProposals() external view isOpen returns (uint[] memory) {
        uint len = props.length;
        uint[] memory arr = new uint[](npending);
        uint n = 0;
        unchecked{
        for(uint i=0;i<len;i++){
            if(noCancelada(i) && !props[i].getAprobada() && props[i].getPresupuesto() > 0){
                arr[n] = i;
                n++;
            }
        }
        }
        return arr;
    }
 
    function getApprovedProposals() external view isOpen returns (uint[] memory) {
        uint[] memory arr = new uint[](napproved);
        unchecked{
        uint len = props.length;
        uint n = 0;
        for(uint i=0;i<len;i++){
            if(noCancelada(i) && props[i].getAprobada()){
                arr[n] = i;
                n++;
            }
        }
        }
        return arr;
    }

    function getSignalingProposals() external view isOpen returns (uint[] memory) {
        uint[] memory arr = new uint[](nsignaling);
        unchecked{
        uint len = props.length;
        uint n = 0;
        for(uint i=0;i<len;i++){
            if(noCancelada(i) && props[i].getPresupuesto()==0){
                arr[n] = i;
                n++;
            }
        }
        }
        return arr;
    }

    function getProposalInfo(uint id) external view isOpen returns(string memory, string memory, uint, address, address, bool){
        return props[id].info();
    }

    function stake(uint id, uint nvotos) external isOpen isParticipant aprobable(id) {
        require(nvotos>0, "Tienes que aportar al menos un voto");
        uint n = props[id].numVotos(msg.sender);
        unchecked{
        uint importe = (nvotos + n)*(nvotos + n) - n*n;
        gestorToken.transferFrom(msg.sender, address(this), importe);
        props[id].votar(msg.sender, nvotos);
        TokensInvertidos[id] += importe;
        }
        _checkAndExecuteProposal(id);
    }

    function withdrawFromProposal(uint id, uint nvotos) external isParticipant aprobable(id) isOpen {
        require(nvotos > 0, "No puedes retirar 0 votos");
        uint n = props[id].numVotos(msg.sender);
        props[id].retirarVotos(msg.sender, nvotos);
        unchecked{
        uint importe = n*n - (n-nvotos)*(n-nvotos);
        gestorToken.transfer(msg.sender, importe);
        TokensInvertidos[id] -= importe;
        }
    }

    // Ya se ha comprobado que la propuesta no esta cancelada ni aprobada
    function _checkAndExecuteProposal(uint id) internal {
        uint presupuestoPropuesta = props[id].getPresupuesto();
        require (presupuestoPropuesta > 0, "La propuesta indicada no es de financiacion");
        unchecked{
        uint umbral = nparticipantes / 5 + presupuestoPropuesta * nparticipantes / presupuesto + npending;
        uint votostotales = props[id].VotosTotales();
        uint recaudado = TokensInvertidos[id]* gestorToken.precio();
        if(recaudado + presupuesto >= presupuestoPropuesta && umbral <  votostotales){
            props[id].aprobar();
            napproved++;
            npending--;
            presupuesto += recaudado - presupuestoPropuesta;
            // Borramos los tokens de los votos
            address[] memory dirs = props[id].getVotantes();
            for (uint i=0;i<dirs.length;i++){
                uint n = props[id].numVotos(dirs[i]);
                if (n > 0){
                    props[id].retirarVotos(dirs[i], n);
                    gestorToken.del_token(address(this), n*n);
                }
            }
            props[id].executeProp{value:presupuestoPropuesta}(TokensInvertidos[id]);
            
        }
        }
    }
    

    function closeVoting() external isOwner {
        votingOpen = false;
        unchecked{
        for(uint i=0;i<props.length;i++){ 
            if(noCancelada(i) && !props[i].getAprobada()){     // Si no esta cancelada ni aprobada
                address[] memory dirs = props[i].getVotantes();
                for (uint j =0;j<dirs.length;j++){
                    uint n = props[i].numVotos(dirs[j]);
                    if(n!=0){
                        props[i].acero(dirs[j]);
                        uint amount = n*n;
                        gestorToken.transfer(dirs[j], amount);
                    }  
                }
                if(props[i].getPresupuesto() == 0){     // Si es signaling
                    props[i].executeProp{value:0}(TokensInvertidos[i]);    // posible vulnerabilidad, votingOpen actua de lock
                }
                delete props[i];
            }
        }
        napproved = 0;
        nsignaling = 0;
        npending = 0;
        payable(owner).transfer(presupuesto);           //Se devuelve el presupuesto restante
    }
    }
}