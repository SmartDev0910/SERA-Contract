// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SeraNFT is ERC1155, ReentrancyGuard, Ownable {

    uint256 private constant tokenID = 1;
    mapping(uint256 => string) private tokenURI;

    constructor() ERC1155("https://game.example/api/item/{id}.json")
    {
    }

    function mintToken() external nonReentrant onlyOwner{
        _mint(msg.sender, tokenID, 1, "0x00");
    }

}