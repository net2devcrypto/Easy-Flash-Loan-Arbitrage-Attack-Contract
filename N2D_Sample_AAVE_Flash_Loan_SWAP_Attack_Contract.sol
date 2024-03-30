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

import {SafeMath} from '../../dependencies/openzeppelin/contracts/SafeMath.sol';
import {GPv2SafeERC20} from '../../dependencies/gnosis/contracts/GPv2SafeERC20.sol';
import {IPoolAddressesProvider} from '../../interfaces/IPoolAddressesProvider.sol';
import {FlashLoanSimpleReceiverBase} from '../../flashloan/base/FlashLoanSimpleReceiverBase.sol';
import {MintableERC20} from '../tokens/MintableERC20.sol';
import {IPool} from '../../interfaces/IPool.sol';
import {DataTypes} from '../../protocol/libraries/types/DataTypes.sol';
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract FlashloanAttacker is FlashLoanSimpleReceiverBase {
  using GPv2SafeERC20 for IERC20;
  using SafeMath for uint256;

  IPoolAddressesProvider internal _provider;
  IPool internal _pool;
  address payable owner;
  address public swapTo;
  uint256 public amountOutV2;
  address public routerAddressV2 = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
  IUniswapV2Router02 public immutable swapRouterV2 = IUniswapV2Router02(routerAddressV2);
  address public routerAddressV3 = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
  ISwapRouter public immutable swapRouterV3 = ISwapRouter(routerAddressV3);


  constructor(IPoolAddressesProvider provider) FlashLoanSimpleReceiverBase(provider) {
    _pool = IPool(provider.getPool());
    owner = payable(msg.sender);
  }

  modifier onlyOwner() {
    require(address(msg.sender) == owner, "Access Denied");
    _;
  }

  function preApprove(address _token, uint256 amount, address routerAddress) internal {
        IERC20 token = IERC20(_token);
        token.approve(address(routerAddress), amount);
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

    function swapExactInputSingle(
        address from,
        address to,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {
        uint24 poolFee = 3000;
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: from,
                tokenOut: to,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        amountOut = swapRouterV3.exactInputSingle(params);
    }
  
    function swapUniV2(address _fromToken, address _toToken, uint256 amountIn) internal returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = _fromToken;
        path[1] = _toToken;
        uint256 amountReceived = swapRouterV2.swapExactTokensForTokens(amountIn, amountOutV2, path, address(this), block.timestamp)[1];
        require(amountReceived > 0, "Aborted Tx: Trade returned zero");
        return amountReceived;
    }


  function executeOperation(
    address asset,
    uint256 amount,
    uint256 premium,
    address, // initiator
    bytes memory // params
  ) public override returns (bool) {
    preApprove(asset, amount, routerAddressV3); //Approve First Swap
    swapExactInputSingle(asset, swapTo, amount); //First Swap UniswapV3 BUY TOKEN
    uint256 toBalance = IERC20(swapTo).balanceOf(address(this)); //Get New Token Balance
    preApprove(swapTo, toBalance, routerAddressV2); //Approve Second Swap UniswapV2 SELL TOKEN
    swapUniV2(swapTo, asset, toBalance); //Second Swap
    IERC20(asset).approve(address(POOL), amount.add(premium));
    return true;
  }

    function flashAttack(address _token, address to, uint256 _amount, uint256 _amountOut) external onlyOwner {
        swapTo = to;
        amountOutV2 = _amountOut;
        requestFlashLoan(_token, _amount);
    }


    function getBalance(address _tokenAddress) public view returns (uint256) {
        return IERC20(_tokenAddress).balanceOf(address(this));
    }

    function withdraw(address _tokenAddress) external onlyOwner {
        IERC20 token = IERC20(_tokenAddress);
        uint256 balance = IERC20(_tokenAddress).balanceOf(address(this));
        token.transfer(address(msg.sender), balance);
    }

}
