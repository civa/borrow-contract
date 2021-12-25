// SPDX-License-Identifier: MATATA
pragma solidity 0.6.12;

interface token {
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function approve(address spender, uint tokens) external returns (bool success);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function totalSupply() external view returns (uint);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract Owned {
    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(owner, _newOwner);
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract lending is Owned {
    using SafeMath for uint;
    
    address public busd;
    address public matata;
    uint borrowAmount;
    uint public loaningRate;
    uint inputAmount;
    uint public loaningFee;
    uint public paybackFee;
    uint paybackAmount;
    uint outputAmount;
    mapping(address => bool) public debtor;
    mapping(address => uint) public borrowedAmount;
    bool active;
    

    constructor(
        address _proofToken,
        address _busd,
        uint _loaningFee,
        uint _paybackFee,
        uint _loaningRate,
        bool _active

    ) public {

        matata = _proofToken;
        busd = _busd;
        loaningFee = _loaningFee;
        loaningRate = _loaningRate;
        paybackFee = _paybackFee;
        active = _active;
    }
    function borrow(uint _amount) public { // Enter amount in BUSD to borrow
    require(active == true);
    borrowAmount = _amount.sub(loaningFee);
    inputAmount = _amount.mul(loaningRate);
    require(token(matata).transferFrom(msg.sender, address(this), inputAmount), "You need to have more MATATA to borrow the amount");
    require(token(busd).transfer(msg.sender, borrowAmount), ""); 

    borrowedAmount[msg.sender] =(borrowedAmount[msg.sender]).add(_amount);

    }

    function payback (uint _amount) public {
        require (debtor[msg.sender] == true, "You must owe to payback");
        require (borrowedAmount[msg.sender] <= _amount, "the amount for payback must be equal or less than the amount you owe");
        paybackAmount = _amount.sub(paybackFee);
        outputAmount = _amount.div(loaningRate);
        require(token(busd).transferFrom(msg.sender, address(this), _amount), "");
        require(token(matata).transfer(msg.sender, outputAmount), ""); 
      
        if (borrowedAmount[msg.sender] == 0){
            debtor[msg.sender] = false;
        }
    }

    function getBorrowedAmount() public view returns(uint){
        return (borrowedAmount[msg.sender]);
    }

    function setLoaningRate(uint _newLoaningRate) public onlyOwner{
    loaningRate = _newLoaningRate;
    }

    function setloaningFee (uint _newloaningFee) public onlyOwner{
        loaningFee = _newloaningFee;
    }
    function setpaybackFee (uint _newpaybackFee) public onlyOwner{
        paybackFee = _newpaybackFee;
        
    }
    function setStatus (bool _newStatus) public onlyOwner{
        active = _newStatus;
    }


}
