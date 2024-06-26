// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.18;

interface IPool {
    function poolId() external view returns (uint256);

    function token() external view returns (address);

    function totalLiquidity() external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function deltaCredit() external view returns (uint256);

    function convertRate() external view returns (uint256);

    function amountLPtoLD(uint256 _amountLP) external view returns (uint256);

    function balanceOf(address user) external view returns (uint256);
}
