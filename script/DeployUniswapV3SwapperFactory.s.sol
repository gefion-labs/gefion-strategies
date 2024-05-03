// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

import "forge-std/Script.sol";

// Deploy a contract to a deterministic address with create2 factory.
contract Deploy is Script {
    // Create X address.
    Deployer public deployer =
        Deployer(0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed);

    address public tokenizedStrategy = vm.envAddress("TOKENIZED_STRATEGY");
    address public base = vm.envAddress("BASE_TOKEN");
    address public router = vm.envAddress("UNISWAP_V3_ROUTER");

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address management = vm.addr(deployerPrivateKey);

        // Append constructor args to the bytecode
        bytes memory bytecode = abi.encodePacked(
            vm.getCode("UniswapV3SwapperFactory.sol:UniswapV3SwapperFactory"),
            abi.encode(
                tokenizedStrategy,
                management,
                management,
                management,
                base,
                router
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
