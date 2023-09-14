// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.4.22 <0.9.0;

contract Auction  {
    address payable owner;
    uint256 start_time;
    uint256 reserve_price;
    uint256 current_price;
    uint256 start_register;
    //mapping(address => uint256) bids;
    address payable winner;
    struct Bidder {
        uint256 Value;
        address payable addr_emitter;
        bool isRegister;
    }
    mapping (address => Bidder) bidders;
    Bidder[]  bids;

    constructor(uint256 _reserve_price)  {
        reserve_price = _reserve_price;
    }
    modifier ownable() {
        require(msg.sender != owner, "le payeur est le proprietaire");
        _;
    }
    modifier register() {
        require(block.timestamp<TimeDuringRegister(), "Les inscriptions sont terminees");
        _;
    }
     modifier isBidder(){
     require(bidders[msg.sender].isRegister==true,"le bidder doit etre inscrit");
     _;
    }
    modifier AuctionTime() {
        require(block.timestamp<TimeDuringAuction(), "Les inscriptions sont terminees");
        _;
    }
    modifier ActionAfterAuction(){
      require(block.timestamp>TimeDuringAuction(), "l'enchere n'est pas terminee");
      _;
    }
    modifier ActionBeforeLastBid(){
        require(block.timestamp<TimeBeforeSold(), "l'enchere est adjugee vendu");
    }
    modifier ActionAfterLastBid(){
        require(block.timestamp<TimeBeforeSold(), "l'enchere est adjugee vendu");
    }
    function TimeDuringRegister() public returns(uint256){
        start_register = block.timestamp;
        return (start_register +3 minutes);
    }
    function TimeDuringAuction() public returns(uint256) {
        start_time = block.timestamp;
        return (start_time +5 minutes);
    }
    function TimeBeforeSold() public returns(uint256) {
        start_time = block.timestamp;
        return(start_time + 45 seconds);
    }
   
    function addBidder (uint256 _value, address payable addr, bool able2register) public ownable register{
        require(bidders[msg.sender].isRegister,"le bidder ne doit pas etre inscrit");
        Bidder memory newBidder = Bidder(_value, addr,true);
        bidders[msg.sender] = newBidder;
        bids.push(newBidder);
    }
    function bid(uint256 amount) public payable ownable AuctionTime isBidder ActionBeforeLastBid {
        require(amount > current_price, "le montant est trop faible");
         bidders[msg.sender].Value=amount;
         current_price = amount;
    }
    function biggestBidder() public isBidder returns(address payable) {
      uint max = 0;
      uint win = 0;
      for(uint8 i = 0; i <= bids.length; i++){
            if (max<(bids[i].Value)){
              max = bids[i].Value;
              win = i;
            }
        }
        return (bids[win].addr_emitter);

    }
    function refund() public ownable ActionAfterAuction ActionAfterLastBid isBidder{
      for(uint8 i = 0; i <= bids.length; i++){
            (bids[i].addr_emitter).transfer(bids[i].Value);
        }
    }
    function transfertOwnership() public ownable ActionAfterAuction ActionAfterLastBid isBidder{
        
        owner = winner;
    }
    function auctionEnd() public ActionAfterLastBid ActionAfterAuction isBidder{

        if (current_price >= reserve_price) {
            owner.transfer(bidders[biggestBidder()].Value);
        }
        refund();
        winner = biggestBidder();
        transfertOwnership();
    }
} 
