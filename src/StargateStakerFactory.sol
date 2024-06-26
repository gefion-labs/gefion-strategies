// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {IStrategy} from "@tokenized-strategy/interfaces/IStrategy.sol";
import {IVault} from "@vaults/interfaces/IVault.sol";

import {StargateStaker} from "./StargateStaker.sol";

contract StargateStakerFactory {
    event NewStargateStaker(address indexed strategy, address indexed asset);

    address public immutable tokenizedStrategy;
    address public management;
    address public perfomanceFeeRecipient;
    address public keeper;
    address public base;
    address public router;

    constructor(
        address _tokenizedStrategy,
        address _management,
        address _peformanceFeeRecipient,
        address _keeper,
        address _base,
        address _router
    ) {
        tokenizedStrategy = _tokenizedStrategy;
        management = _management;
        perfomanceFeeRecipient = _peformanceFeeRecipient;
        keeper = _keeper;
        base = _base;
        router = _router;
    }

    function newStargateStaker(
        address _asset,
        string memory _name,
        address _lpStaker,
        address _stargateRouter,
        uint16 _stakingID,
        address _vault,
        uint256 _initialDebt
    ) external returns (address) {
        StargateStaker stargateStaker = new StargateStaker(
            tokenizedStrategy,
            _asset,
            _name,
            _lpStaker,
            _stargateRouter,
            _stakingID
        );
        stargateStaker.setBase(base);
        stargateStaker.setRouter(router);

        IStrategy newStrategy = IStrategy(address(stargateStaker));

        newStrategy.setPerformanceFeeRecipient(perfomanceFeeRecipient);
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

        emit NewStargateStaker(address(newStrategy), _asset);
        return address(newStrategy);
    }

    function newStargateStaker(
        address _asset,
        string memory _name,
        address _lpStaker,
        address _stargateRouter,
        uint16 _stakingID,
        address _vault
    ) external returns (address) {
        return
            this.newStargateStaker(
                _asset,
                _name,
                _lpStaker,
                _stargateRouter,
                _stakingID,
                _vault,
                0
            );
    }

    function newStargateStaker(
        address _asset,
        string memory _name,
        address _lpStaker,
        address _stargateRouter,
        uint16 _stakingID
    ) external returns (address) {
        return
            this.newStargateStaker(
                _asset,
                _name,
                _lpStaker,
                _stargateRouter,
                _stakingID,
                address(0),
                0
            );
    }

    function setAddresses(
        address _management,
        address _perfomanceFeeRecipient,
        address _keeper,
        address _base,
        address _router
    ) external {
        require(msg.sender == management, "!management");
        management = _management;
        perfomanceFeeRecipient = _perfomanceFeeRecipient;
        keeper = _keeper;
        base = _base;
        router = _router;
    }
}
