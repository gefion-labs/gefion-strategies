// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import "forge-std/Script.sol";

// Deploy a contract to a deterministic address with create2 factory.
contract Deploy is Script {
    // Create X address.
    Deployer public deployer =
        Deployer(0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed);

    address public governance = vm.envAddress("MANAGEMENT");
    address public lendingPool = vm.envAddress("AAVE_V3_LENDING_POOL");
    address public protocolDataProvider =
        vm.envAddress("AAVE_V3_PROTOCOL_DATA_PROVIDER");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Append constructor args to the bytecode
        bytes memory bytecode = abi.encodePacked(
            vm.getCode("AaveV3LenderAprOracle.sol:AaveV3LenderAprOracle"),
            abi.encode(
                "Aave V3 Lender Apr Oracle",
                governance,
                lendingPool,
                protocolDataProvider
            )
        );

        // Pick an unique salt
        bytes32 salt = keccak256("v1.0.0");

        address contractAddress = deployer.deployCreate2(salt, bytecode);

        console.log("Address is ", contractAddress);

        vm.stopBroadcast();
    }
}

interface Deployer {
    event ContractCreation(address indexed newContract, bytes32 indexed salt);

    function deployCreate2(
        bytes32 salt,
        bytes memory initCode
    ) external payable returns (address newContract);
}
