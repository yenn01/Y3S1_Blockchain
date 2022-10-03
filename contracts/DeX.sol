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

    function deposit(uint256 amount) public payable {
        require(msg.value == amount);
        yBalances[msg.sender] += amount;
        emit Deposited(msg.sender,amount);
    }

    function withdraw(uint256 amount) public {
        require(amount < yBalances[msg.sender]);
        yBalances[msg.sender] -= amount;
        payable(msg.sender).transfer(address(this).balance); //Change to call
        emit Withdrawn(msg.sender,amount);
    }

    function getEther() public view returns (uint) {
        return address(this).balance;
    }

    function balanceOf(address addr) public view returns(uint256) {
        return yBalances[addr];
    }

    

    // act like dictionary in python
    mapping(uint => pool) private cryptoList;
    mapping(address => uint256) private yBalances;

    uint cryptoListNum = 0;
    //uint decimalPlace = 10000;

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event PoolValue(string indexed cryptoName,uint indexed cVal, uint indexed tVal);
    event Deposited(address indexed addr,uint indexed amount);
    event Withdrawn(address indexed addr,uint indexed amount);

    constructor() {
        owner = msg.sender; 
        emit OwnerSet(address(0), owner);
        //Values are in GWEI
        initPool('wBitcoin', 100000000000, 1469000000000);
        initPool('BAT', 875010000000000, 200000000000);
        initPool('BNB', 931000000000000, 2000000000000);
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

    function addPool(string memory cName, uint cVal, uint tVal) public inList(cName, 0){

        require(yBalances[msg.sender] >= tVal);

        if(bytes(cName).length!=0){
            cryptoList[cryptoListNum] = pool(cName, cVal, tVal, true);
            cryptoListNum ++;
            yBalances[msg.sender] -= uint256(tVal * 1000000000);
        }
        emit PoolValue(cName,cVal,tVal);
    }

    function initPool(string memory cName, uint cVal, uint tVal) public isOwner inList(cName, 0){
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
                yBalances[msg.sender] -= uint256(tVal * 1000000000);
                break;
            }
        }
        emit PoolValue(cName,uint(tempCVal + cVal),uint(tempTVal + tVal));
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
        uint amtTokenRequired = 0;
        uint j;
        uint i;
        uint y_remain;
        for(j=0; j<cryptoListNum; j++){
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cryptoType))){
                if(cryptoList[j].cryptoAmt==0 || cryptoList[j].cryptoAmt<exchangeAmt){
                    //console.log(string(abi.encodePacked("Cryptocurrency ", cryptoList[j].cryptoName, " pool is not enough. Maximum amount: ", Strings.toString(cryptoList[j].cryptoAmt))));
                    revert();
                }
                // deduct amout of cryptoType frist to get the amount token required
                // For example buy 10 bitcoin(cryptoType) with ether (targetCryptoType), in here we deduct 10 bitcoin from the pool to calculate the amount of token required.
                y_remain = ((cryptoList[j].tokenAmt*cryptoList[j].cryptoAmt)/(cryptoList[j].cryptoAmt-exchangeAmt));
                amtTokenRequired = y_remain-cryptoList[j].tokenAmt;
                cryptoList[j].tokenAmt = y_remain;
                cryptoList[j].cryptoAmt -= exchangeAmt;
                emit PoolValue(cryptoList[j].cryptoName,cryptoList[j].cryptoAmt,cryptoList[j].tokenAmt);
                break;
            }
        }

        // Token to targetCryptoType
        uint amtCryptoRequired = 0;
        for(i=0; i<cryptoListNum; i++){
            if(keccak256(abi.encodePacked(cryptoList[i].cryptoName)) == keccak256(abi.encodePacked(targetCryptoType))){
                // decrease the token in the ether (targetCryptoType) pool to calculate how much targetCryptoType we should receive.
                y_remain = (cryptoList[i].tokenAmt*cryptoList[i].cryptoAmt)/(cryptoList[i].tokenAmt-amtTokenRequired);
                amtCryptoRequired = y_remain-cryptoList[i].cryptoAmt;
                cryptoList[i].tokenAmt -= amtTokenRequired;
                cryptoList[i].cryptoAmt = y_remain;
                emit PoolValue(cryptoList[i].cryptoName,cryptoList[i].cryptoAmt,cryptoList[i].tokenAmt);
                break;
            }
        }
        
        return (targetCryptoType, amtCryptoRequired);
    }

    // Sell exchangeAmt of cryptoType to X TargetCryptoType
    function exchangeSell(string memory cryptoType, uint exchangeAmt, string memory targetCryptoType) public inList(cryptoType, 3) inList(targetCryptoType, 3) returns(string memory, uint){
        // Exchange cryptoType to token
        uint poolOut = 0;
        uint i;
        uint j;
        uint y_remain;
        for(j=0; j<cryptoListNum; j++){
            if(keccak256(abi.encodePacked(cryptoList[j].cryptoName)) == keccak256(abi.encodePacked(cryptoType))){
                //                   (           x           *           y          )/(           x           +    ^x     )
                y_remain = ((cryptoList[j].cryptoAmt*cryptoList[j].tokenAmt)/(cryptoList[j].cryptoAmt+exchangeAmt));
                poolOut = cryptoList[j].tokenAmt-y_remain;
                cryptoList[j].tokenAmt = y_remain;
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
                    cryptoList[j].tokenAmt += poolOut;
                    cryptoList[j].cryptoAmt -= exchangeAmt;
                    revert();
                }
                //                   (           x          *           y           )/(           x          +   ^x  )
                //y_remain = roundOff(((cryptoList[i].tokenAmt*cryptoList[i].cryptoAmt*decimalPlace)/(cryptoList[i].tokenAmt+poolOut)));
                y_remain = ((cryptoList[i].tokenAmt*cryptoList[i].cryptoAmt)/(cryptoList[i].tokenAmt+poolOut));
                returnAmt = cryptoList[i].cryptoAmt-y_remain;
                cryptoList[i].tokenAmt += poolOut;
                cryptoList[i].cryptoAmt = y_remain;
                emit PoolValue(cryptoList[i].cryptoName,cryptoList[i].cryptoAmt,cryptoList[i].tokenAmt);
                break;
            }
        }
        return (targetCryptoType, returnAmt);
    }

    // function roundOff(uint unprocessedInput) public view returns(uint){
    //     // 4 decimalPlace, example input 188776261, it will return 18878
    //     uint input = unprocessedInput;
    //     uint temp = uint(input/decimalPlace);
    //     uint tempNet = uint(input-(temp*decimalPlace));
    //     uint ans = 0;
    //     if(tempNet >= uint(decimalPlace/2)){
    //         ans = uint((input+decimalPlace)/decimalPlace);
    //     }
    //     else{
    //         ans = uint(input/decimalPlace);
    //     }
    //     return(ans);
    // }
}