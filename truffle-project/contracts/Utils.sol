// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Utils {

  function etherToWei(uint eth) public pure returns(uint) {
    return eth * 1 ether;
  }

  function minutesToSeconds(uint min) public pure returns(uint) {
    return min * 60 seconds;
  }
}