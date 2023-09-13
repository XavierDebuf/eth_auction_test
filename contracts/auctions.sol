// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.4.22 <0.9.0;

contract Auction {
/**owner: L'adresse du propriétaire du smart contract.
start_time: La date et l'heure de début de l'enchère.
reserve_price: Le prix minimum auquel l'enchère doit être vendue.
bids:  tableau qui mappe les adresses des participants aux enchères au montant de leurs enchères. 
*/
    address payable owner;
    uint256 start_time;
    uint256 reserve_price;
    uint256 current_price;
    uint256 start_register;
    //mapping(address => uint256) bids;
    address payable winner;
    struct Bidder {
        uint256  Value;
        address  payable addr_emitter;
    }
    mapping (address => Bidder) bidders;
    Bidder[]  bids;

    constructor(uint256 _reserve_price) public {
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
    modifier AuctionTime() {
        require(block.timestamp<TimeDuringAuction(), "Les inscriptions sont terminees");
        _;
    }
    modifier ActionAfterAuction(){
      require(block.timestamp>TimeDuringAuction(), "l'enchere n'est pas terminee");
      _;
    }
    function TimeDuringRegister() public returns(uint256){
        start_register = block.timestamp;
        return (start_register +3 minutes);
    }
    function TimeDuringAuction() public returns(uint256) {
        start_time = block.timestamp;
        return (start_time +5 minutes);
    }
    function addBidder (uint256 _value, address payable addr) public ownable register{
        Bidder memory newBidder = Bidder(_value, addr);
        bidders[msg.sender] = newBidder;
        bids.push(newBidder);
    }
    function bid(uint256 amount) public payable ownable AuctionTime{
        require(amount > current_price, "le montant est trop faible");
         bidders[msg.sender].Value=amount;
         current_price = amount;
    }
    function biggestBidder() public returns(address payable){
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
    function refund() public ownable ActionAfterAuction{
      for(uint8 i = 0; i <= bids.length; i++){
            (bids[i].addr_emitter).transfer(bids[i].Value);
        }
    }
    function transfertOwnership(address payable newAddress) public ownable ActionAfterAuction{
        require(newAddress != address(0), "Adresse invalide");
        owner = newAddress;
    }
    function auctionEnd() public ActionAfterAuction{

        if (current_price >= reserve_price) {
            owner.transfer(bidders[biggestBidder()].Value);
        }
        refund();
        transfertOwnership(biggestBidder());
    }
} 
