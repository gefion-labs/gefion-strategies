// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {UniswapV3Swapper} from "./UniswapV3Swapper.sol";
import {IStrategyInterface} from "./interfaces/Aave/V3/IStrategyInterface.sol";

contract UniswapV3SwapperFactory {
    /// @notice Revert message for when a strategy has already been deployed.
    error AlreadyDeployed(address _strategy);

    event NewUniswapV3Swapper(address indexed strategy, address indexed asset);

    address public immutable tokenizedStrategy;
    address public management;
    address public performanceFeeRecipient;
    address public keeper;
    address public base;
    address public router;

    /// @notice Track the deployments. asset => pool => strategy
    mapping(address => address) public deployments;

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
     * @notice Deploy a new Uniswap V3.
     * @dev This will set the msg.sender to all of the permissioned roles.
     * @param _asset The underlying asset for the lender to use.
     * @param _name The name for the lender to use.
     * @return . The address of the new lender.
     */
    function newUniswapV3Swapper(
        address _asset,
        string memory _name,
        address _reward
    ) external returns (address) {
        if (deployments[_asset] != address(0))
            revert AlreadyDeployed(deployments[_asset]);

        // We need to use the custom interface with the
        // tokenized strategies available setters.
        UniswapV3Swapper uniswapV3Swapper = new UniswapV3Swapper(
            tokenizedStrategy,
            _asset,
            _name,
            _reward
        );
        uniswapV3Swapper.setBase(base);
        uniswapV3Swapper.setRouter(router);

        IStrategyInterface newStrategy = IStrategyInterface(
            address(uniswapV3Swapper)
        );

        newStrategy.setPerformanceFeeRecipient(performanceFeeRecipient);
        newStrategy.setKeeper(keeper);
        newStrategy.setPendingManagement(management);

        emit NewUniswapV3Swapper(address(newStrategy), _asset);

        deployments[_asset] = address(newStrategy);
        return address(newStrategy);
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

    function isDeployedStrategy(
        address _strategy
    ) external view returns (bool) {
        address _asset = IStrategyInterface(_strategy).asset();
        return deployments[_asset] == _strategy;
    }
}
