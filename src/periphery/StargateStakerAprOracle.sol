// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {AprOracleBase} from "@periphery/AprOracle/AprOracleBase.sol";
import {UniswapV2Swapper} from "@periphery/swappers/UniswapV2Swapper.sol";

import {ILPStaking} from "../interfaces/Stargate/ILPStaking.sol";
import {IStrategyInterface} from "../interfaces/Stargate/IStrategyInterface.sol";

contract StrategyAprOracle is AprOracleBase, UniswapV2Swapper {
    uint256 public blockPerYear = 2_628_000; // based on 12s block on Ethereum

    constructor(
        address _base,
        address _router,
        uint256 _blockPerYear
    ) AprOracleBase("Stargate Staker Oracle", msg.sender) {
        base = _base;
        router = _router;
        blockPerYear = _blockPerYear;
    }

    function setBlockPerYear(uint256 _blockPerYear) external onlyGovernance {
        blockPerYear = _blockPerYear;
    }

    /**
     * @notice Will return the expected Apr of a strategy post a debt change.
     * @dev _delta is a signed integer so that it can also represent a debt
     * decrease.
     *
     * This should return the annual expected return at the current timestamp
     * represented as 1e18.
     *
     *      ie. 10% == 1e17
     *
     * _delta will be == 0 to get the current apr.
     *
     * This will potentially be called during non-view functions so gas
     * efficiency should be taken into account.
     *
     * @param _strategy The token to get the apr for.
     * @param _delta The difference in debt.
     * @return . The expected apr for the strategy represented as 1e18.
     */
    function aprAfterDebtChange(
        address _strategy,
        int256 _delta
    ) external view override returns (uint256) {
        IStrategyInterface strategy = IStrategyInterface(_strategy);
        ILPStaking lpStaking = ILPStaking(strategy.lpStaker());
        uint256 stakingID = strategy.stakingID();
        uint256 poolShareBps = ((lpStaking.poolInfo(stakingID).allocPoint *
            1e4) / lpStaking.totalAllocPoint());
        uint256 poolRewardsPerBlock = (lpStaking.stargatePerBlock() *
            poolShareBps) / 10_000;
        uint256 yearlyRewardsInAsset = _getAmountOut(
            strategy.reward(),
            strategy.asset(),
            poolRewardsPerBlock
        ) * blockPerYear;
        uint256 multiplier = (strategy.decimals() == 6) ? 1e18 : 1e6;

        if (_delta < 0) {
            return
                (yearlyRewardsInAsset * multiplier) /
                (lpStaking.lpBalances(strategy.stakingID()) - uint256(-_delta));
        }

        return
            (yearlyRewardsInAsset * multiplier) /
            (lpStaking.lpBalances(strategy.stakingID()) + uint256(_delta));
    }
}
