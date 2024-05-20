// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {IStrategy} from "@tokenized-strategy/interfaces/IStrategy.sol";
import {IUniswapV2Swapper} from "@periphery/swappers/interfaces/IUniswapV2Swapper.sol";

interface IStrategyInterface is IStrategy, IUniswapV2Swapper {
    function reward() external view returns (address);
}
