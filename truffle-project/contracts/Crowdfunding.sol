// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Utils.sol";

contract Crowdfunding is Ownable {

  using Utils for uint;

  enum State { Ongoing, Failed, Succeded, PaidOut }

  event CampaignFinished(
      address addr,
      uint totalCollected,
      bool succeeded
  );

  string public name;
  uint public targetAmount;
  uint public fundindDeadline;
  address payable public beneficiary;
  
  State public state;

  mapping(address => uint) public amounts;
  bool public collected;

  constructor(
    string memory _name, 
    uint _targetAmountEth, 
    uint _fundingDeadlineDurationInMin,
    address payable _beneficiary

    )
  {
    name = _name;
    targetAmount = _targetAmountEth.etherToWei() ;
    fundindDeadline = blockTimestamp() + _fundingDeadlineDurationInMin.minutesToSeconds();
    beneficiary = _beneficiary;
    state = State.Ongoing;
  }

  modifier inState(State expectedState)
  {
    require(expectedState == state, "Incorrect crowdfunding state");
    _;
  }

  receive() external payable inState(State.Ongoing){
    require(beforeDeadline(), "Deadline has passed");
    
    amounts[msg.sender] += msg.value;

    if(totalCollected() >= targetAmount){
      collected = true;
    }
  }

  function beforeDeadline() public view returns(bool){
    return blockTimestamp() < fundindDeadline; 
  }

  function afterDeadline() public view returns(bool){
    return !beforeDeadline();
  }

  function totalCollected() public view returns(uint){
    return address(this).balance;
  }

  function finishCrowdfunding() public inState(State.Ongoing){
    require(afterDeadline(), "Deadline has not passed");

    if(!collected){
      state = State.Failed;
    }else{
      state = State.Succeded;
      emit CampaignFinished(address(this), totalCollected(), true);
    }

    emit CampaignFinished(address(this), totalCollected(), collected);
  }

  function collect() inState(State.Succeded) public{
    if(beneficiary.send(totalCollected())){
      state = State.PaidOut;
    } else {
      state = State.Failed;
    }
  }

  function withdraw() inState(State.Failed) public{
    require(amounts[msg.sender] > 0, "No founds for this account" );

    uint amount = amounts[msg.sender];

    amounts[msg.sender] = 0;

    payable(msg.sender).transfer(amount);
  }

  function cancelCrowdfunding() public inState(State.Ongoing) onlyOwner(){
    require(beforeDeadline(), "Deadline has passed");

    state = State.Failed;
  }

  function blockTimestamp() public view returns(uint){
    return block.timestamp;
  }
}