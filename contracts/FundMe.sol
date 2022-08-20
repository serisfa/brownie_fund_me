// SPDX-License-Identifier: MIT
pragma solidity >=0.6;
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
//import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
contract FundMe  {
    //using SafeMathChainLink for uint256;

    mapping(address =>uint256) public addressToAmountFunded;
    address[] public funders;
    address payable public owner;
    AggregatorV3Interface public priceFeed;

    constructor (address _pricefeed) public {
        priceFeed=AggregatorV3Interface(_pricefeed);
        owner=payable(msg.sender);
    } 
    function fund() public payable{
        //$50
        uint256 minimumUSD=50*10**18;
        // 1 gwei < $50
        require(getConversionRate(msg.value)>=minimumUSD,"You need to spend more ETH");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        //what the ETH -> USD conversion
        //data.chain.link
        //There are many Oracles providing price conversion. More secure and more efficient.
        //DeFi short for decentralized financial infrastructures
        //value for ETH -> USD conversion is very big number. Beacuse it is expressed in WEI not ETH.
        // such as 2,614.97384316*10**8 (That float number times ten to the eight)
    }
    function getVersion() public view returns(uint256){
        //Net   :Rinkeby Testnet
        //Adress:0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        return priceFeed.version();
    }
    function getPrice() public view returns (uint256){
        (,int256 answer,,,)=priceFeed.latestRoundData();//comas shows some variables not used
        return uint256(answer)*10**10;
        //1,933.33967269 USD
    }
    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice=getPrice();
        uint256 ethAmountUsd=(ethPrice*ethAmount)/ 1000000000000000000;
        return ethAmountUsd;
        //194071602932
        //1925970536290 
        //0.00001925970536290
    }
    function getEntranceFee() public view returns (uint256){
        //mininmumUSD
        uint256 minimumUSD = 50*10**18;
        uint256 price = getPrice();
        uint256 precision = 1*10**18;
        return (minimumUSD * precision) / price;
    }
       

    modifier onlyOwner{
        require(msg.sender==owner);
        _;
    }
    function withdraw () payable onlyOwner public{
        owner.transfer(address(this).balance);
        for (uint256 funderIndex=0; funderIndex < funders.length;  funderIndex++)
        {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder]=0;
        }
        funders=new address[](0);
    } 
}