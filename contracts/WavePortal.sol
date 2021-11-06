// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
  uint totalWaves;
  uint private seed;

  // Notify of every new wave
  event NewWave(address indexed from, uint timestamp, string message);

  struct Wave {
    address waver;
    string message;
    uint timestamp;
  }

  Wave[] waves;
  
  // address => uint mapping, associating an andress with a number.
  // storing the address with the last time the user waved at us
  mapping(address => uint) public lastWavedAt;

  constructor() payable {
    console.log("Hello smart contract");
  }

  function wave(string memory _message) public {
    // we need to make sure that the current timestamp is at least
    // 15-minutes bigger than the last timestamp we stored.
    require(lastWavedAt[msg.sender] + 10 seconds < block.timestamp, "Please wait 10 seconds");

    // Update the current timestamp we have for the user
    lastWavedAt[msg.sender] = block.timestamp;

    totalWaves += 1;
    console.log("%s waved w/ message %s", msg.sender, _message);

    waves.push(Wave(msg.sender, _message, block.timestamp));

    // Generating a pseudorandom number in the range of 100.
    uint randomNumber = (block.difficulty + block.timestamp  + seed) % 100;
    console.log("Random # generated: %s", randomNumber);

    // Set the genereated random number as the seed for the next wave.
    seed = randomNumber;

    // Give a 50% change that the user wins the prize
    if (randomNumber < 50) {
      uint prizeAmount = 0.00001 ether;
      require(prizeAmount <= address(this).balance, "Trying to withdraw more money than the contract has.");
      (bool success, ) = (msg.sender).call{value: prizeAmount}("");
      require(success, "Failed to withdraw money from contract.");
    }
    emit NewWave(msg.sender, block.timestamp, _message);
  }

  // return all wave data
  function getAllWaves() view public returns (Wave[] memory) {
    return waves;
  }

  // return waves count 
  function getTotalWaves() view public returns (uint) {
    console.log("We have %d total waves", totalWaves);
    return totalWaves;
  }
}