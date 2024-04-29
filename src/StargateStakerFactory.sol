// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import {IStrategy} from "@tokenized-strategy/interfaces/IStrategy.sol";

import {StargateStaker} from "./StargateStaker.sol";

contract StargateStakerFactory {
    event NewStargateStaker(address indexed strategy, address indexed asset);

    address public immutable tokenizedStrategy;
    address public management;
    address public perfomanceFeeRecipient;
    address public keeper;

    constructor(
        address _tokenizedStrategy,
        address _management,
        address _peformanceFeeRecipient,
        address _keeper
    ) {
        tokenizedStrategy = _tokenizedStrategy;
        management = _management;
        perfomanceFeeRecipient = _peformanceFeeRecipient;
        keeper = _keeper;
    }

    function newStargateStaker(
        address _asset,
        string memory _name,
        address _lpStaker,
        address _stargateRouter,
        uint16 _stakingID
    ) external returns (address) {
        IStrategy newStrategy = IStrategy(
            address(
                new StargateStaker(
                    tokenizedStrategy,
                    _asset,
                    _name,
                    _lpStaker,
                    _stargateRouter,
                    _stakingID
                )
            )
        );

        newStrategy.setPerformanceFeeRecipient(perfomanceFeeRecipient);
        newStrategy.setKeeper(keeper);
        newStrategy.setPendingManagement(management);

        emit NewStargateStaker(address(newStrategy), _asset);
        return address(newStrategy);
    }

    function setAddresses(
        address _management,
        address _perfomanceFeeRecipient,
        address _keeper
    ) external {
        require(msg.sender == management, "!management");
        management = _management;
        perfomanceFeeRecipient = _perfomanceFeeRecipient;
        keeper = _keeper;
    }
}
