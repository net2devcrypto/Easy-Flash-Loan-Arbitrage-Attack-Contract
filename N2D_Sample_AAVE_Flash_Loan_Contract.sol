/*

 ██████  ██████   ██████  ██   ██ ██████   ██████   ██████  ██   ██    ██████  ███████ ██    ██
██      ██    ██ ██    ██ ██  ██  ██   ██ ██    ██ ██    ██ ██  ██     ██   ██ ██      ██    ██
██      ██    ██ ██    ██ █████   ██████  ██    ██ ██    ██ █████      ██   ██ █████   ██    ██
██      ██    ██ ██    ██ ██  ██  ██   ██ ██    ██ ██    ██ ██  ██     ██   ██ ██       ██  ██
 ██████  ██████   ██████  ██   ██ ██████   ██████   ██████  ██   ██ ██ ██████  ███████   ████

Find any smart contract, and build your project faster: https://www.cookbook.dev/?utm=code
Twitter: https://twitter.com/cookbook_dev
Discord: https://discord.gg/cookbookdev

Find this contract on Cookbook: https://www.cookbook.dev/contracts/FlashloanAttacker?utm=code

PLEASE DO NOT DEPLOY ON A MAINNET, ONLY ON A TESTNET
NET2DEV NOR COOKBOOK.DEV WILL NOT ASSUME ANY RESPONSIBILITY FOR ANY USE, LOSS OF FUNDS OR ANY OTHER ISSUES.
*/

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.10;

import {IERC20} from '../../dependencies/openzeppelin/contracts/IERC20.sol';
import {GPv2SafeERC20} from '../../dependencies/gnosis/contracts/GPv2SafeERC20.sol';
import {SafeMath} from '../../dependencies/openzeppelin/contracts/SafeMath.sol';
import {IPoolAddressesProvider} from '../../interfaces/IPoolAddressesProvider.sol';
import {FlashLoanSimpleReceiverBase} from '../../flashloan/base/FlashLoanSimpleReceiverBase.sol';
import {MintableERC20} from '../tokens/MintableERC20.sol';
import {IPool} from '../../interfaces/IPool.sol';
import {DataTypes} from '../../protocol/libraries/types/DataTypes.sol';

contract FlashloanAttacker is FlashLoanSimpleReceiverBase {
  using GPv2SafeERC20 for IERC20;
  using SafeMath for uint256;

  IPoolAddressesProvider internal _provider;
  IPool internal _pool;

  constructor(IPoolAddressesProvider provider) FlashLoanSimpleReceiverBase(provider) {
    _pool = IPool(provider.getPool());
  }

  function executeOperation(
    address asset,
    uint256 amount,
    uint256 premium,
    address, // initiator
    bytes memory // params
  ) public override returns (bool) {

    IERC20(asset).approve(address(POOL), amount.add(premium));
    return true;
  }

  function requestFlashLoan(address _token, uint256 _amount) public {
    address receiverAddress = address(this);
    address asset = _token;
    uint256 amount = _amount;
    bytes memory params = "";
    uint16 referralCode = 0;

    POOL.flashLoanSimple(
        receiverAddress,
        asset,
        amount,
        params,
        referralCode
        );
    }

}
