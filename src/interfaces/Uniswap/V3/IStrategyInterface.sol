// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {IStrategy} from "@tokenized-strategy/interfaces/IStrategy.sol";
import {IAuctionSwapper} from "@periphery/swappers/interfaces/IAuctionSwapper.sol";
import {IUniswapV3Swapper} from "@periphery/swappers/interfaces/IUniswapV3Swapper.sol";

interface IStrategyInterface is IStrategy, IUniswapV3Swapper, IAuctionSwapper {
    function reward() external view returns (address);

    function useAuction() external view returns (bool);

    function setUniFees(address _token0, address _token1, uint24 _fee) external;

    function setAuction(address _auction) external;

    function setUseAuction(bool _useAuction) external;
}
