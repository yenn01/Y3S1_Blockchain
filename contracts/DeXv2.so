//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//import "hardhat/console.sol";

contract DeX{

    address private owner;
    // Rules(16/09/2022):
    // 1. Y3Token price = 1000 usd (Our own token)
    // 2. Ether price = 1,472.00 usd
    // 3. Bitcoin price = 19,758.00 usd
    // 4. PAX Gold price = 1,685.00 usd

    //Add code to convert 1 ETH -> Y4 Token 
    //Add mapping for balance(address)

    struct pool{
        string cryptoName;
        uint cryptoAmt;
        bool cryptoStatus;
    }

    // act like dictionary in python
    mapping(uint => pool) private cryptoList;
    uint cryptoListNum = 0;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender; 
        emit OwnerSet(address(0), owner);
        addPool('Bitcoin', 101);
        addPool('Ether', 1359);
        addPool('PAX Gold', 1187);
        addPool('Y3', 2000);
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

    // for buy crypto return error while exceed pool limit
    modifier exceedLimit(string memory cName, uint amount) {
        bool resultStatus = false;
        for (uint j=0; j<cryptoListNum; j++) {
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cName))){
                resultStatus = true;
                string memory temp = uint2str(cryptoList[j].cryptoAmt);
                require(cryptoList[j].cryptoAmt>=amount, string(abi.encodePacked("Maximum amount changable of Cryptocurrency ", cName, " is ", temp)));
                break;
            }
        }
        require(resultStatus, string(abi.encodePacked("Cryptocurrency ", cName, " is not exist.")));
         _;
    }

    function addPool(string memory cName, uint cVal) public isOwner inList(cName, 0){
        if(bytes(cName).length!=0){
            cryptoList[cryptoListNum] = pool(cName, cVal, true);
            cryptoListNum ++;
        }
    }

    function getPool(string memory cName) public view returns(pool memory){
        uint j;
        for (j=0; j<cryptoListNum; j++) {
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cName))) return cryptoList[j];
        }
        return cryptoList[j];
    }

    function addAmt(string memory cName, int cVal) public returns(string memory){
        uint j;
        int tempCVal;
        for (j=0; j<cryptoListNum; j++) {
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cName))){
                tempCVal = int(cryptoList[j].cryptoAmt);
                if((tempCVal + cVal)<0){
                    cVal = -tempCVal;
                }
                cryptoList[j].cryptoAmt =  uint(tempCVal + cVal);
                return(string(abi.encodePacked("Cryptocurrency ", cName, " added successfully.")));
            }
        }
        //Add write success or fail return/emit
        //Like this ok or you want to return the pool description?
        return(string(abi.encodePacked("Fail to add cryptocurrency ", cName, ".")));
    }

    // left the newCName empty if no update
    function editPoolDetail(string memory oldCName, string memory newCName, uint cVal, bool pStatus) public isOwner inList(oldCName, 1) inList(newCName, 2) returns(string memory){
        uint j;
        for (j=0; j<cryptoListNum; j++) {
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(oldCName))) break;
        }
        if(cVal<0){
            cVal = 0;
        }
        if(bytes(newCName).length==0){
            newCName = oldCName;
        }
        cryptoList[j].cryptoName = newCName;
        cryptoList[j].cryptoAmt = cVal;
        cryptoList[j].cryptoStatus = pStatus;
        //Add write success or fail return/emit
        if(j==cryptoListNum){
            return(string(abi.encodePacked("Fail to update pool detail.")));
        }
        else{
            return(string(abi.encodePacked("Pool detail updated successfully.")));
        }
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
    function exchangeBuy(string memory cryptoType, uint exchangeAmt, string memory targetCryptoType) public inList(cryptoType, 3) inList(targetCryptoType, 3) exceedLimit(cryptoType, exchangeAmt) returns(string memory, uint){
        uint token = 0;
        uint nettoken = 0;
        uint i;
        uint j;
        for(j=0; j<cryptoListNum; j++){
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cryptoType))){
                for(i=0; i<cryptoListNum; i++){
                    if(keccak256(abi.encodePacked(cryptoList[i].cryptoName)) == keccak256(abi.encodePacked(targetCryptoType))){
                        token = (cryptoList[i].cryptoAmt*cryptoList[j].cryptoAmt)/(cryptoList[j].cryptoAmt-exchangeAmt);
                        nettoken = token-cryptoList[i].cryptoAmt;
                        cryptoList[i].cryptoAmt = token;
                        cryptoList[j].cryptoAmt = cryptoList[j].cryptoAmt-exchangeAmt;
                        break;
                    }
                }
                break;
            }
        }
        return (targetCryptoType, nettoken);
    }

    // Sell exchangeAmt of cryptoType to X TargetCryptoType
    function exchangeSell(string memory cryptoType, uint exchangeAmt, string memory targetCryptoType) public inList(cryptoType, 3) inList(targetCryptoType, 3) returns(string memory, uint){
        uint token = 0;
        uint nettoken = 0;
        uint i;
        uint j;
        for(j=0; j<cryptoListNum; j++){
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cryptoType))){
                for(i=0; i<cryptoListNum; i++){
                    if(keccak256(abi.encodePacked(cryptoList[i].cryptoName)) == keccak256(abi.encodePacked(targetCryptoType))){
                        token = (cryptoList[i].cryptoAmt*cryptoList[j].cryptoAmt)/(cryptoList[j].cryptoAmt+exchangeAmt);
                        nettoken = cryptoList[i].cryptoAmt-token;
                        cryptoList[i].cryptoAmt = token;
                        cryptoList[j].cryptoAmt = cryptoList[j].cryptoAmt+exchangeAmt;
                        break;
                    }
                }
                break;
            }
        }
        return (targetCryptoType, nettoken);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}