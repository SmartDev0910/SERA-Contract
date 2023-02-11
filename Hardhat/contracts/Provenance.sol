//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Provenance is Ownable {
    enum ActionStatus {
        REMOVED,
        ADDED
    }

    struct Producer {
        string name;
        string producer_type;
        bool certification;
        ActionStatus action_status;
    }

    struct Product {
        address producer_address;
        string name;
        uint date_time_of_origin;
        ActionStatus action_status;
    }

    mapping(address => Producer) public producers;
    mapping(string => Product) public products;
    address[] public producer_list;
    string[] public product_list;
    uint256 public producer_count;
    uint256 public product_count;
    
    constructor() {
        producer_count = 0;
        product_count = 0;
    }

    function addProducer(address from, string memory name, string memory producer_type ) public {
      require(producers[from].action_status != ActionStatus.ADDED, "This producer is already exist.");
      producers[from] = Producer(name, producer_type, false, ActionStatus.ADDED);
      producer_list.push(from);
      producer_count ++;
    }

    function findProducer(address recipient) public view returns (Producer memory) {
        return producers[recipient];
    }

    function removeProducer(address recipient) public onlyOwner{
        producers[recipient].action_status = ActionStatus.REMOVED;
    }

    function certifyProducer(address recipient) public onlyOwner {
        producers[recipient].certification = true;
    }

    function addProduct(string memory pub_number, string memory name) public {
        require(products[pub_number].action_status != ActionStatus.ADDED, "This product is already exist.");
        products[pub_number] = Product(msg.sender, name, block.timestamp, ActionStatus.ADDED);
        product_list.push(pub_number);
        product_count ++;
    }

    function removeProduct(string memory pub_number) public onlyOwner {
        products[pub_number].action_status = ActionStatus.REMOVED;
    }
    
    function findProduct(string memory pub_number) public view returns (Product memory) {
        return products[pub_number];
    }

}
