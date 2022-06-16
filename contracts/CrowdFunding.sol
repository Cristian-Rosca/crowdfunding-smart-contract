// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract CrowdFunding {
    mapping(address => uint) public contributors;
    address public admin;
    uint public numOfContributors;
    uint public minContribution;
    uint public deadline; // timestamp
    uint public goal;
    uint public raisedAmount;
    struct Request {
        string description;
        address payable recipient;
        uint value;
        bool completed; 
        uint numOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint => Request) public requests;

    uint public numRequests;

    constructor(uint _goal, uint _deadline){
        goal = _goal;
        deadline = block.timestamp + _deadline;
        minContribution = 100 wei;
        admin = msg.sender;
    }

    function contribute() public payable {
        require(block.timestamp < deadline, "deadline has passed");
        require(msg.value >= minContribution, "minimum contribution not met");
        
        if(contributors[msg.sender] == 0){
            numOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;        
    }

    receive() payable external{
        contribute();
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function getRefund() public {
        require(block.timestamp > deadline && raisedAmount < goal);
        require(contributors[msg.sender] > 0);

        address payable recipient = payable(msg.sender);
        uint value = contributors[msg.sender];
        recipient.transfer(value);

        // payable(msg.sender).transfer(contributors[msg.sender]);

        contributors[msg.sender] = 0;
    }

    modifier onlyAdmin(){
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function createRequest(string memory _description, address payable _recipient, uint _value) public onlyAdmin{
        Request storage newRequest = requests[numRequests];
        numRequests++;

        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.completed = false;
        newRequest.numOfVoters = 0;
    }
}