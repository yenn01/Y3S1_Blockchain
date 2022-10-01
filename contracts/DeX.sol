//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//import "hardhat/console.sol";
//import "@openzeppelin/contracts/utils/Strings.sol";

contract DeX{

    address private owner;
    // Rules(16/09/2022):
    // 1. One Y3Token = 100 usd (Our own token)
    // 2. Ether price = 1,472.00 usd
    // 3. Bitcoin price = 19,758.00 usd
    // 4. PAX Gold price = 1,685.00 usd

    //Add code to convert 1 ETH -> Y4 Token 
    //Add mapping for balance(address)

    struct pool{
        string cryptoName;
        uint cryptoAmt;
        uint tokenAmt;
        bool cryptoStatus;
    }

    // act like dictionary in python
    mapping(uint => pool) private cryptoList;
    uint cryptoListNum = 0;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event PoolValue(string indexed cryptoName,uint indexed cVal, uint indexed tVal);

    constructor() {
        owner = msg.sender; 
        emit OwnerSet(address(0), owner);
        addPool('Bitcoin', 101, 20000);
        addPool('Ether', 1359, 20000);
        addPool('PAX Gold', 1187, 20000);
        //console.log("Pool created successfully. Liquidity Provider:", msg.sender);
    }

    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier inList(string memory cName, int funcName) {
        //Used to validate add pool
        if(funcName == 0){
            bool resultStatus = true;
            for (uint j=0; j<cryptoListNum; j++) {
                if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cName))){
                    resultStatus = false;
                    break;
                }
            }
            require(resultStatus, string(abi.encodePacked("Cryptocurrency ", cName, " already exist.")));
        }
        //Used to validate add amount to pool
        else if(funcName == 1){
            bool resultStatus = false;
            for (uint j=0; j<cryptoListNum; j++) {
                if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cName))){
                    resultStatus = true;
                    break;
                }
            }
            require(resultStatus, string(abi.encodePacked("Cryptocurrency ", cName, " is not exist.")));
        }
        //Used to validate edit pool
        else if(funcName == 2 && bytes(cName).length!=0){
            bool resultStatus = true;
            for (uint j=0; j<cryptoListNum; j++) {
                if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cName))){
                    resultStatus = false;
                    break;
                }
            }
            require(resultStatus, string(abi.encodePacked("Cryptocurrency ", cName, " already exist.")));
        }
        //Used to validate exchange buy and sell crypto
        else if(funcName == 3){
            bool resultStatus = false;
            for (uint j=0; j<cryptoListNum; j++) {
                if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cName))){
                    resultStatus = true;
                    require(cryptoList[j].cryptoStatus, string(abi.encodePacked("Cryptocurrency ", cName, " is not available.")));
                    break;
                }
            }
            require(resultStatus, string(abi.encodePacked("Cryptocurrency ", cName, " is not exist.")));
        }
        _;
    }

    function addPool(string memory cName, uint cVal, uint tVal) public isOwner inList(cName, 0){
        if(bytes(cName).length!=0){
            cryptoList[cryptoListNum] = pool(cName, cVal, tVal, true);
            cryptoListNum ++;
        }
        emit PoolValue(cName,cVal,tVal);
    }

    function getPool(string memory cName) public view returns(pool memory){
        uint j;
        for (j=0; j<cryptoListNum; j++) {
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cName))) return cryptoList[j];
        }
        return cryptoList[j];
    }

    function addAmt(string memory cName, int cVal, int tVal) public isOwner inList(cName, 1){
        uint j;
        int tempCVal;
        int tempTVal;
        for (j=0; j<cryptoListNum; j++) {
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cName))){
                tempCVal = int(cryptoList[j].cryptoAmt);
                tempTVal = int(cryptoList[j].tokenAmt);
                if((tempCVal + cVal)<0){
                    cVal = -tempCVal;
                }
                if((tempTVal + tVal)<0){
                    tVal = -tempTVal;
                }
                cryptoList[j].cryptoAmt =  uint(tempCVal + cVal);
                cryptoList[j].tokenAmt = uint(tempTVal + tVal);
                break;
            }
        }
        emit PoolValue(cName,uint(cVal),uint(tVal));
        //Add write success or fail return/emit
    }

    // left the newCName empty if no update
    function editPoolDetail(string memory oldCName, string memory newCName, uint cVal, uint tVal, bool pStatus) public isOwner inList(oldCName, 1) inList(newCName, 2){
        uint j;
        for (j=0; j<cryptoListNum; j++) {
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(oldCName))) break;
        }
        if(cVal<0){
            cVal = 0;
        }
        if(tVal<0){
            tVal = 0;
        }
        if(bytes(newCName).length==0){
            newCName = oldCName;
        }
        cryptoList[j].cryptoName = newCName;
        cryptoList[j].cryptoAmt = cVal;
        cryptoList[j].tokenAmt = tVal;
        cryptoList[j].cryptoStatus = pStatus;
        emit PoolValue(newCName,cVal,tVal);
         //Add write success or fail return/emit
    }

    function listAllPool() public isOwner view returns(pool[] memory){
        pool[] memory tempPool = new pool[](cryptoListNum);
        for(uint j=0; j<cryptoListNum; j++){
            tempPool[j]=cryptoList[j];
        }
        return tempPool;
    }

    function listAllValidPool() public view returns(pool[] memory){
        pool[] memory tempPool = new pool[](cryptoListNum);
        for(uint j=0; j<cryptoListNum; j++){
            if(cryptoList[j].cryptoStatus == true) tempPool[j]=cryptoList[j];
        }
        return tempPool;
    }

    // Buy exchangeAmt of cryptoType with X targetCryptoType
    function exchangeBuy(string memory cryptoType, uint exchangeAmt, string memory targetCryptoType) public inList(cryptoType, 3) inList(targetCryptoType, 3) returns(string memory, uint){
        // Exchange cryptoType to token
        uint token = 0;
        uint j;
        uint i;
        for(j=0; j<cryptoListNum; j++){
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cryptoType))){
                if(cryptoList[j].cryptoAmt==0 || cryptoList[j].cryptoAmt<exchangeAmt){
                    //console.log(string(abi.encodePacked("Cryptocurrency ", cryptoList[j].cryptoName, " pool is not enough. Maximum amount: ", Strings.toString(cryptoList[j].cryptoAmt))));
                    revert();
                }
                token = ((cryptoList[j].tokenAmt*cryptoList[j].cryptoAmt)/(cryptoList[j].cryptoAmt-exchangeAmt))-cryptoList[j].tokenAmt;
                cryptoList[j].tokenAmt -= token;
                cryptoList[j].cryptoAmt += exchangeAmt;
                emit PoolValue(cryptoList[j].cryptoName,cryptoList[j].cryptoAmt,cryptoList[j].tokenAmt);
                break;
            }
        }

        // Token to targetCryptoType
        uint returnAmt = 0;
        for(i=0; i<cryptoListNum; i++){
            if(keccak256(abi.encodePacked(cryptoList[i].cryptoName)) == keccak256(abi.encodePacked(targetCryptoType))){
                returnAmt = ((cryptoList[i].tokenAmt*cryptoList[i].cryptoAmt)/(cryptoList[i].tokenAmt-token))-cryptoList[i].cryptoAmt;
                cryptoList[i].tokenAmt += token;
                cryptoList[i].cryptoAmt -= returnAmt;
                emit PoolValue(cryptoList[i].cryptoName,cryptoList[i].cryptoAmt,cryptoList[i].tokenAmt);
                break;
            }
        }
        
        return (targetCryptoType, returnAmt);
    }

    // Sell exchangeAmt of cryptoType to X TargetCryptoType
    function exchangeSell(string memory cryptoType, uint exchangeAmt, string memory targetCryptoType) public inList(cryptoType, 3) inList(targetCryptoType, 3) returns(string memory, uint){
        // Exchange cryptoType to token
        uint token = 0;
        uint i;
        uint j;
        for(j=0; j<cryptoListNum; j++){
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cryptoType))){
                token = cryptoList[j].tokenAmt-((cryptoList[j].tokenAmt*cryptoList[j].cryptoAmt)/(cryptoList[j].cryptoAmt+exchangeAmt));
                cryptoList[j].tokenAmt -= token;
                cryptoList[j].cryptoAmt += exchangeAmt;
                emit PoolValue(cryptoList[j].cryptoName,cryptoList[j].cryptoAmt,cryptoList[j].tokenAmt);
                break;
            }
        }

        // Token to targetCryptoType
        uint returnAmt = 0;
        for(i=0; i<cryptoListNum; i++){
            if(keccak256(abi.encodePacked(cryptoList[i].cryptoName)) == keccak256(abi.encodePacked(targetCryptoType))){
                if(cryptoList[i].cryptoAmt==0){
                    //console.log(string(abi.encodePacked("Cryptocurrency ", cryptoList[i].cryptoName, " pool is empty.")));
                    cryptoList[j].tokenAmt += token;
                    cryptoList[j].cryptoAmt -= exchangeAmt;
                    revert();
                }
                returnAmt = cryptoList[i].cryptoAmt-((cryptoList[i].tokenAmt*cryptoList[i].cryptoAmt)/(cryptoList[i].tokenAmt+token));
                cryptoList[i].tokenAmt += token;
                cryptoList[i].cryptoAmt -= returnAmt;
                emit PoolValue(cryptoList[i].cryptoName,cryptoList[i].cryptoAmt,cryptoList[i].tokenAmt);
                break;
            }
        }
        
        return (targetCryptoType, returnAmt);
    }
}