// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CustomToken {
    //Properties
    uint noOfTokens;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256[]) private userTokens;
    mapping(uint256 => address) private tokenOwners;

    //Events 
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    constructor(string memory _name, string memory _symbol, uint8 _decimal, uint _totalSupply, uint _tokens) {
        name = _name;
        symbol = _symbol;
        decimals = _decimal;
        totalSupply = _totalSupply;
        noOfTokens = _tokens;
        balanceOf[msg.sender] = _totalSupply;
        userTokens[msg.sender] = new uint256[](0);
        
        //No. of Tokens
        for (uint256 i = 0; i < noOfTokens; i++) {
            userTokens[msg.sender].push(i);
            tokenOwners[i] = msg.sender;
        }

    }

    // Transfer Token from host address to another address
    function transfer(address to, uint256 tokenId) public returns (bool) {
        require(tokenOwners[tokenId] == msg.sender, "You are not an Owner of the Token");

        tokenOwners[tokenId] = to;

        // Update user's token ownership
        uint256[] storage ownedTokens = userTokens[msg.sender];
        uint256 tokenIndex;
        for (uint256 i = 0; i < ownedTokens.length; i++) {
            if (ownedTokens[i] == tokenId) {
                tokenIndex = i;
                break;
            }
        }
        ownedTokens[tokenIndex] = ownedTokens[ownedTokens.length - 1];
        ownedTokens.pop();
        userTokens[to].push(tokenId);

        emit Transfer(msg.sender, to, tokenId);
        return true;
    }

    function getTokensByUser(address user) public view returns (uint256[] memory) {
        return userTokens[user];
    }

    // Rest of the functions...
}
