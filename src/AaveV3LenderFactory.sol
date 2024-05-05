// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;

import {AaveV3Lender} from "./AaveV3Lender.sol";
import {IStrategyInterface} from "./interfaces/Aave/V3/IStrategyInterface.sol";
import {IVault} from "@vaults/interfaces/IVault.sol";

contract AaveV3LenderFactory {
    event NewAaveV3Lender(address indexed strategy, address indexed asset);

    address public immutable tokenizedStrategy;
    address public immutable auctionFactory;
    address public management;
    address public performanceFeeRecipient;
    address public keeper;
    address public base;
    address public router;

    constructor(
        address _tokenizedStrategy,
        address _auctionFactory,
        address _management,
        address _performanceFeeRecipient,
        address _keeper,
        address _base,
        address _router
    ) {
        tokenizedStrategy = _tokenizedStrategy;
        auctionFactory = _auctionFactory;
        management = _management;
        performanceFeeRecipient = _performanceFeeRecipient;
        keeper = _keeper;
        base = _base;
        router = _router;
    }

    /**
     * @notice Deploy a new Aave V3 Lender.
     * @dev This will set the msg.sender to all of the permissioned roles.
     * @param _asset The underlying asset for the lender to use.
     * @param _name The name for the lender to use.
     * @return . The address of the new lender.
     */
    function newAaveV3Lender(
        address _asset,
        string memory _name,
        address _lendingPool,
        address _stkAave,
        address _AAVE,
        address _vault,
        uint256 _initialDebt
    ) external returns (address) {
        // We need to use the custom interface with the
        // tokenized strategies available setters.
        AaveV3Lender aaveV3Lender = new AaveV3Lender(
            tokenizedStrategy,
            auctionFactory,
            _asset,
            _name,
            _lendingPool,
            _stkAave,
            _AAVE
        );
        aaveV3Lender.setBase(base);
        aaveV3Lender.setRouter(router);

        IStrategyInterface newStrategy = IStrategyInterface(
            address(aaveV3Lender)
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
                    _initialDebt
                );
                IVault(_vault).updateDebt(address(newStrategy), _initialDebt);
            }
        }

        emit NewAaveV3Lender(address(newStrategy), _asset);

        return address(newStrategy);
    }

    function newAaveV3Lender(
        address _asset,
        string memory _name,
        address _lendingPool,
        address _stkAave,
        address _AAVE,
        address _vault
    ) external returns (address) {
        return
            this.newAaveV3Lender(
                _asset,
                _name,
                _lendingPool,
                _stkAave,
                _AAVE,
                _vault,
                0
            );
    }

    function newAaveV3Lender(
        address _asset,
        string memory _name,
        address _lendingPool,
        address _stkAave,
        address _AAVE
    ) external returns (address) {
        return
            this.newAaveV3Lender(
                _asset,
                _name,
                _lendingPool,
                _stkAave,
                _AAVE,
                address(0),
                0
            );
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
