// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {UniswapV2Swapper} from "./UniswapV2Swapper.sol";
import {IStrategyInterface} from "./interfaces/Uniswap/V2/IStrategyInterface.sol";
import {IVault} from "@vaults/interfaces/IVault.sol";

contract UniswapV2SwapperFactory {
    event NewUniswapV2Swapper(address indexed strategy, address indexed asset);

    address public immutable tokenizedStrategy;
    address public management;
    address public performanceFeeRecipient;
    address public keeper;
    address public base;
    address public router;

    constructor(
        address _tokenizedStrategy,
        address _management,
        address _performanceFeeRecipient,
        address _keeper,
        address _base,
        address _router
    ) {
        tokenizedStrategy = _tokenizedStrategy;
        management = _management;
        performanceFeeRecipient = _performanceFeeRecipient;
        keeper = _keeper;
        base = _base;
        router = _router;
    }

    /**
     * @notice Deploy a new Uniswap V2.
     * @dev This will set the msg.sender to all of the permissioned roles.
     * @param _asset The underlying asset for the lender to use.
     * @param _name The name for the lender to use.
     * @return . The address of the new lender.
     */
    function newUniswapV2Swapper(
        address _asset,
        string memory _name,
        address _reward,
        address _vault,
        uint256 _initialDebt
    ) external returns (address) {
        // We need to use the custom interface with the
        // tokenized strategies available setters.
        UniswapV2Swapper uniswapV2Swapper = new UniswapV2Swapper(
            tokenizedStrategy,
            _asset,
            _name,
            _reward
        );
        uniswapV2Swapper.setBase(base);
        uniswapV2Swapper.setRouter(router);

        IStrategyInterface newStrategy = IStrategyInterface(
            address(uniswapV2Swapper)
        );

        newStrategy.setPerformanceFeeRecipient(performanceFeeRecipient);
        newStrategy.setKeeper(keeper);
        newStrategy.setPendingManagement(management);

        if (_vault != address(0)) {
            // auto add strategy to vault
            IVault(_vault).addStrategy(address(newStrategy));

            // update initial debt
            if (_initialDebt > 0) {
                IVault(_vault).updateMaxDebtForStrategy(
                    address(newStrategy),
                    type(uint256).max
                );
                IVault(_vault).updateDebt(address(newStrategy), _initialDebt);
            }
        }

        emit NewUniswapV2Swapper(address(newStrategy), _asset);

        return address(newStrategy);
    }

    function newUniswapV2Swapper(
        address _asset,
        string memory _name,
        address _reward,
        address _vault
    ) external returns (address) {
        return this.newUniswapV2Swapper(_asset, _name, _reward, _vault, 0);
    }

    function newUniswapV2Swapper(
        address _asset,
        string memory _name,
        address _reward
    ) external returns (address) {
        return this.newUniswapV2Swapper(_asset, _name, _reward, address(0), 0);
    }

    function setAddresses(
        address _management,
        address _performanceFeeRecipient,
        address _keeper,
        address _base,
        address _router
    ) external {
        require(msg.sender == management, "!management");
        management = _management;
        performanceFeeRecipient = _performanceFeeRecipient;
        keeper = _keeper;
        base = _base;
        router = _router;
    }
}
