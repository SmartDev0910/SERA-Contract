//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Tracking.sol";

contract Reputation is Ownable {
    Tracking trackings;
    
    enum ActionStatus {
        REMOVED,
        ADDED
    }

    struct Supplier {
        string name;
        string phone_number;
        string city;
        string state;
        string country_of_origin;
        string type_of_goods;
        uint256 reputation;
        ActionStatus action_status;
    }

    mapping(address => Supplier) public suppliers;
    address[] private supplier_list;

    constructor(address _address) {
        trackings = Tracking(_address);
    }

    function addSupplier(address from, string memory name, string memory phone_number, string memory city, string memory state, string memory country_of_origin, string memory type_of_goods) public {
        require(suppliers[from].action_status != ActionStatus.ADDED, "This supplier is already exist");
        suppliers[from] = Supplier(name, phone_number, city, state, country_of_origin, type_of_goods, 0, ActionStatus.ADDED);
        supplier_list.push(from);
    }

    function removeSupplier(address recipient) public onlyOwner {
        suppliers[recipient].action_status = ActionStatus.REMOVED;
    }

    function findSupplier(address recipient) public view returns (Supplier memory) {
        return suppliers[recipient];
    }

    function allSuppliers() public view returns (Supplier[] memory){
        Supplier[] memory all_suppliers = new Supplier[](supplier_list.length);
        for(uint256 i = 0; i < supplier_list.length; i++) {
            if (suppliers[supplier_list[i]].action_status == ActionStatus.ADDED) {
                all_suppliers[i] = suppliers[supplier_list[i]];
            }
        }
        return all_suppliers;
    }

    function filterByGoodsType(string memory type_of_goods) public view returns (Supplier[] memory) {
        Supplier[] memory filter_suppliers = new Supplier[](supplier_list.length);
        for(uint256 i = 0; i < supplier_list.length; i++) {
            Supplier memory supplier = suppliers[supplier_list[i]];
            if (supplier.action_status == ActionStatus.ADDED && keccak256(abi.encodePacked(supplier.type_of_goods)) == keccak256(abi.encodePacked(type_of_goods))) {
                filter_suppliers[i] = supplier;
            }
        }
        return filter_suppliers;
    }

    function filterByReputation(uint256 reputation) public view returns (Supplier[] memory) {
        Supplier[] memory filter_suppliers = new Supplier[](supplier_list.length);
        for(uint256 i = 0; i < supplier_list.length; i++) {
            Supplier memory supplier = suppliers[supplier_list[i]];
            if (supplier.action_status == ActionStatus.ADDED && supplier.reputation >= reputation) {
                filter_suppliers[i] = supplier;
            }
        }
        return filter_suppliers;
    }
    
    function checkReputation(address recipient) public view returns (uint256) {
        return trackings.calculateReputation(recipient);
    }
    
    function updateReputations() public onlyOwner {
        for(uint256 i = 0; i < supplier_list.length; i++) {
            if (suppliers[supplier_list[i]].action_status == ActionStatus.ADDED) {
                suppliers[supplier_list[i]].reputation = trackings.calculateReputation(supplier_list[i]);
            }
        }
    }
}
