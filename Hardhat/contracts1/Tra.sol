//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Tra is Ownable {

    enum ActionStatus {
        INPROGRESS,
        SUCCESS,
        FAILURE,
        CANCELED
    }

    struct Shipment {
        address sender;
        address recipient;
        uint start_time;
        string item1;
        uint256 quantity1;
        uint256 price1;
        string item2;
        uint256 quantity2;
        uint256 price2;
        bool receiver_sign;
        ActionStatus action_status;
    }

    struct Condition {
        uint end_time;
        string destination;
        uint256 token_amount;
    }

    event Log(string text);

    uint256 public shipment_id;
    uint256 public purchase_id;
    uint256 public invoice_id;
    ERC20 usdc;
    mapping(address => uint256) public balances;
    mapping(uint256 => Shipment) public shipments;
    mapping(uint256 => Condition) public conditions;
    mapping(uint256 => uint256) public purchase_list;
    mapping(uint256 => uint256) public invoice_list;
    mapping(address => uint256) public shipment_list;
    mapping(address => uint256) public success_shipment_list;

    constructor() {
        shipment_id = 0;
        purchase_id = 0;
        invoice_id = 0;
        usdc = ERC20(0x0FA8781a83E46826621b3BC094Ea2A0212e71B23);
    }

    function sendToken(address from, address to, uint256 token_amount) public payable {
        balances[from] = usdc.balanceOf(from);
        require(balances[from] >= token_amount, "You do not have enough tokens.");
        require(usdc.transferFrom(from, to, token_amount));
        emit Log("Payment sent.");
    }

    function getBalance(address supplier) public view returns (uint256) {
        return balances[supplier];
    }

    function recoverToken(uint purchase_cid) public onlyOwner {
        balances[shipments[purchase_cid].sender] -= conditions[purchase_cid].token_amount;
        balances[shipments[purchase_cid].recipient] += conditions[purchase_cid].token_amount;

        require(usdc.transfer(shipments[purchase_cid].recipient, conditions[purchase_cid].token_amount));
    }

    function setContractParameters(uint256 purchase_cid, uint end_time, string memory destination, uint256 token_amount) public onlyOwner {
        conditions[purchase_cid] = Condition(end_time, destination, token_amount);
    }
    
    function createContract(address recipient, string memory item1, uint256 quantity1, uint256 price1, string memory item2, uint256 quantity2, uint256 price2) public {
        shipments[shipment_id] = Shipment(msg.sender, recipient, block.timestamp, item1, quantity1, price1, item2, quantity2, price2, false, ActionStatus.INPROGRESS);
        shipment_list[msg.sender] ++;
        shipment_id ++;
    }
    
    function purchaseOrder(uint256 shipment_cid) public {
        uint256 token_amount = 0;
        require(shipments[shipment_cid].recipient == msg.sender, "This account is not buyer.");
        token_amount = shipments[shipment_cid].price1 * shipments[shipment_cid].quantity1 + shipments[shipment_cid].price2 * shipments[shipment_cid].quantity2;  
        // sendToken(msg.sender, address(this), token_amount);
        shipments[shipment_cid].receiver_sign = true;
        purchase_list[purchase_id] = shipment_cid;
        purchase_id ++;
    }
    
    function issueInvoice(uint256 purchase_cid) public payable {
        uint256 token_amount = 0;
        uint256 shipment_cid = purchase_list[purchase_cid];
        if(shipments[shipment_cid].sender != msg.sender){
            emit Log("This shipment is not yours.");
            shipments[shipment_cid].action_status = ActionStatus.FAILURE;
        } 
        else if(shipments[shipment_cid].receiver_sign == false) {
            emit Log("The receiver did not sign.");
        } else {
            token_amount = shipments[shipment_cid].price1 * shipments[shipment_cid].quantity1 + shipments[shipment_cid].price2 * shipments[shipment_cid].quantity2;  
            // require(usdc.transfer(msg.sender, token_amount));
            shipments[shipment_cid].action_status = ActionStatus.SUCCESS;
            success_shipment_list[shipments[shipment_cid].sender] ++;
            invoice_list[invoice_id] = shipment_cid;
            invoice_id ++;
        }

    }

    function deleteShipment(uint256 purchase_cid) public onlyOwner {
        shipments[purchase_cid].action_status = ActionStatus.CANCELED;
        shipment_list[shipments[purchase_cid].sender] --;
    }
    
    function checkShipment(uint256 purchase_cid) public view returns (Shipment memory) {
        return shipments[purchase_cid];
    }
    
    function checkSuccess(address recipient) public view returns (uint256) {
        return success_shipment_list[recipient];
    }
    
    function calculateReputation(address recipient) public view returns (uint256)  {
        if(shipment_list[recipient] > 0){
            return (uint256) (success_shipment_list[recipient] * 100 / shipment_list[recipient]);
        } else {
            return 0;
        }
    }
}
