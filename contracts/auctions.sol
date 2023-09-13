// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.4.22 <0.9.0;
import "hardhat/console.sol";
contract Auction {
/**owner: L'adresse du propriétaire du smart contract.
start_time: La date et l'heure de début de l'enchère.
end_time: La date et l'heure de fin de l'enchère.
reserve_price: Le prix minimum auquel l'enchère doit être vendue.
current_price: Le prix actuel de l'enchère.
bids:  dictionnaire qui mappe les adresses des participants aux enchères au montant de leurs enchères. 
*/
    address payable owner;
    uint256 start_time;
    uint256 end_time;
    uint256 reserve_price;
    uint256 current_price;
    //mapping(address => uint256) bids;
    address payable winner;
struct Bidder {
        uint Value;
    }
     
    mapping (address => Bidder) bidders;
    address[] public bids;

    
      constructor(uint256 _reserve_price) {
        owner = payable(msg.sender);
        winner = owner;
        reserve_price = _reserve_price;
    }
    modifier ownable() {
    require(msg.sender != owner, "le payeur est le proprietaire");
    _;
  }
 function TimeDuringAuction(uint256 _start_time) public returns(uint256) {
      start_time = block.timestamp;
      return (start_time +5 minutes);
    }

    function addBidder (string  _value) public ownable{
        Bidder newBidder = Bidder(_value);
        bidders[msg.sender] = newBidder;
        bids.push(msg.sender);
    }
     
    function voirUtilisateur(address _address) public view returns (uint)  {
        return (bids[_address].Value);
    }
    function bid(uint256 amount) public payable ownable {
        
        require(block.timestamp >= start_time && block.timestamp <= end_time, "hors delai");
        require(amount > current_price, "le montant est trop faible");

        bids[msg.sender] = amount;
        winner = payable(msg.sender);
        current_price = bids[msg.sender];
    }
   function send(address to, uint256 amount) external ownable {
    require(bids[to].value <= current_price, "Vous ne pouvez pas etre rembourse (proprietaire ou gagnant)");


    emit owner.transfer(bids[to].Value,to);
}
function refund(address[] toSend) external ownable {
  for(uint8 i=0; i<= toSend.length(); i++){
    send()
    }
}

   
    
    function transfertOwnership(address payable newAddress) public ownable{
        require(newAddress != address(0), "Adresse invalide");
        owner = newAddress;
    }
    function auctionEnd() public {
        require(block.timestamp >= end_time, "on a depasse le temps limite");

        if (current_price >= reserve_price) {
            winner.transfer(current_price);
        }
        transfertOwnership(winner);
    }
   
    
}