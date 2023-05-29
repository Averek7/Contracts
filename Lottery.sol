//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Lottery{
    address public manager;
    address payable[] public participants;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable{
        require(msg.value >= 1 ether);
        participants.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint){
        require(msg.sender == manager);
        return address(this).balance;
    }

    function random() public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty,block.timestamp, participants.length)));
    }
    
    function result() public{
        require(msg.sender == manager);
        require(participants.length >= 3);
        uint index = random() % participants.length;
        address payable winner;
        
        winner = participants[index];
        winner.transfer(getBalance());
        
        participants = new address payable[](0);
    }
}
