// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 < 0.9.0; 

contract Auction {
    uint public inc;
    uint public endtime;
    uint public starttime; 
    uint public highestBid ;
    uint public highestPayableBid ;

    address payable public highBider;
    address payable public auctioneer;

    enum auc_state{start, running, end, cancelled}
    auc_state public AuctionState;

    constructor(){
        auctioneer = payable (msg.sender);
        AuctionState = auc_state.running;
        starttime = block.number;
        endtime = block.number + 240;
        inc = 1 ether;
    }

    mapping (address => uint) public bids;

    modifier notOwner(){
        require(msg.sender != auctioneer, "Owner cannot bid");
        _;
    }
    modifier Owner(){
        require(msg.sender == auctioneer, "Owner can bid");
        _;
    }   
    modifier started(){
        require(block.number > starttime);
        _;
    }
    modifier befended(){
        require(block.number < endtime);
        _;
    }
    
    function cancelAuc() public Owner{
        AuctionState = auc_state.cancelled;
    }

    function endAuc() public Owner{
        AuctionState = auc_state.end;
    }

    function min(uint a, uint b) pure private returns(uint){
        if(a <= b){
            return a;
        }
        return b;
    }

    function bid() payable public notOwner started befended returns(uint){
        require(AuctionState == auc_state.running);
        require(msg.value > 1 ether);
        
        uint currentBid; 
        currentBid = bids[msg.sender] + msg.value;

        require(currentBid > highestPayableBid);

        bids[msg.sender] = currentBid;
        if(currentBid < bids[highBider]){
            highestPayableBid = min(currentBid + inc, bids[highBider]);
        }
        highestPayableBid = min(currentBid, bids[highBider] + inc);
        highBider = payable(msg.sender);

        return highestPayableBid;
    }
    
    function FinalCheck() public{
        require(AuctionState == auc_state.cancelled || AuctionState == auc_state.end || block.number > endtime) ;
        require(msg.sender == auctioneer || bids[msg.sender] > 0);

        address payable person;
        uint val;

        if(AuctionState == auc_state.cancelled){
            person = payable(msg.sender);
            val = bids[msg.sender];
        }else{
            if(msg.sender == auctioneer){
                person = auctioneer;
                val = highestPayableBid + bids[highBider];
            }else{
                person = payable(msg.sender);
                val = bids[msg.sender];
            }
        }
        bids[msg.sender] = 0;
        person.transfer(val);
    }

    function aucBal() view public returns(uint){
        return auctioneer.balance;
    }
}  
