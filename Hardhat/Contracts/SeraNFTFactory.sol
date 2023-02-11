//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

import "./SeraNFT.sol";

contract SeraNFTFactory {
    function createSeraNFT () public {
      SeraNFT seraNFT = new SeraNFT();
      seraNFT.transferOwnership(msg.sender);
    }
}
