// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Practise {
  uint256 startTime;
  uint256 stopTime;
  bool isRunning;

  function start() public {
    require(!isRunning, "Stopwatch is still running");
    if(stopTime == 0){
      startTime = block.timestamp;
    } 

    isRunning = true;
  }

  function stop() public {
    require(isRunning, "Stopwatch is not running");
    stopTime = block.timestamp;
    isRunning = false;
  }

  function elapsedTime() public view returns(uint256){
    require(!isRunning, "Stopwatch is still running");
    return stopTime - startTime;
  }

  function reset() public{
    require(!isRunning, "Stopwatch is still running");
    startTime = 0;
    stopTime = 0;
  }
}