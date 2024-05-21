// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Holi {
    uint256 private credit = 100;
    mapping(bytes32 => uint256) colorCredits; 

    constructor(){
       colorCredits[keccak256("red")] = 40;
       colorCredits[keccak256("blue")] = 40;
       colorCredits[keccak256("green")] = 30;
    }

    // this function is used to buy the desired colour
    function buyColour(string memory colour, uint price) public {
       require(credit >= price , "Insufficient Balance") ;
       require(keccak256(abi.encodePacked(colour)) == keccak256("red") || 
       keccak256(abi.encodePacked(colour)) == keccak256("blue") || 
       keccak256(abi.encodePacked(colour)) == keccak256("green") , "Invalid color");

       bytes32  colourr = keccak256(abi.encodePacked(colour));
       if(colorCredits[colourr] >= price){
          colorCredits[colourr] -= price;
          credit -= price;
       }else{
        revert();
       }
       
    }

    //this functions will return credit balance
    function credits() public view returns(uint n) {
        n = credit;
    }

}