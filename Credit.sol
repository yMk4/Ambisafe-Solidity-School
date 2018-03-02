pragma solidity ^0.4.19;

import "./Ownable.sol";
import "./SafeMath.sol";

contract Credit is Ownable {
    
    // SafeMath should solve the overflow and underflow problems
    using SafeMath for uint256;
    
    // events
    event NewDebtor(uint debtorId, string name, string surname, string idNumber, uint amount);
    event Credited(address debtor, uint amount);
    event NewRefundRequestor(uint refundRequestorId, string name, string surname, string idNumber, uint amount);
    event Refunded(address debtor, uint amount);
    
     // modifiers (onlyOwner modifier has been stated in Ownable.sol)
    modifier onlyNotOwner() {
        require(msg.sender != owner);
        _;
    }
    
    // warranties for creditor (this information could help to identify the debtor in real world in case of proceedings)
    struct Debtor {
        string name;
        string surname;
        string idNumber;
        uint amount;
    }
    
    // information about persons that want to receive a refund
    struct RefundRequestors {
        string name;
        string surname;
        string idNumber;
        uint amount;
    }
    
    // arrays
    Debtor[] private debtors; // an array of all debtors
    RefundRequestors[] private refundRequestors; // an array of refund requestors
    
    // mappings
    mapping(address => uint) private debtorsCount; 
    mapping(address => uint) private refundRequestorsCount;
    mapping(address => uint) public credits; 
    mapping(address => uint) public requested;
    mapping(address => uint) public refunded;
    
    // functions
    function newRequestedCredit(string _name, string _surname, string _idNumber, uint _amount) onlyNotOwner public returns (bool success) {
        require(_amount >= 0);
        requested[msg.sender] += _amount;
        uint debtorId = debtors.push(Debtor(_name, _surname, _idNumber, _amount)) - 1;
        debtorsCount[msg.sender]++;
        return true;
        NewDebtor(debtorId, _name, _surname, _idNumber, _amount);
    }
    
    function approveRequestedCredit(address _requestor) onlyOwner public returns(bool success) {
     	uint amount = requested[_requestor];
        requested[_requestor] -= amount;
        credits[_requestor] += amount;
        Credited(_requestor, amount);
        return true;
    }
    
    function newRequestedRefund(string _name, string _surname, string _idNumber, uint _amount) onlyNotOwner public returns (bool success) {
        require(_amount >= 0);
        credits[msg.sender] -= _amount;
        refunded[msg.sender] += _amount;
        uint refundRequestorId = debtors.push(Debtor(_name, _surname, _idNumber, _amount)) - 1;
        refundRequestorsCount[msg.sender]++;
        return true;
        NewRefundRequestor(refundRequestorId, _name, _surname, _idNumber, _amount);
    }
    
     function approveRequestedRefund(address _debtor) onlyOwner public returns(bool success) {
        uint amount = refunded[_debtor];
        refunded[_debtor] -= amount;
        Refunded(_debtor, amount);
        return true;
    }
}
