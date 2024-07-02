// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./Schema.sol";
import "./Storage.sol";

contract PriceConsumer {

    function getLatestPrice() public view returns (uint) {
        Schema.GlobalState storage gs = Storage.state();
        (
            ,
            int price,
            ,
            ,
            
        ) = AggregatorV3Interface(gs.priceFeed).latestRoundData();
        require(price > 0, "Invalid price");
        return uint(price * 1e10); // Convert to 18 decimals
    }

    function updateLastGoodPrice() external {
        Schema.GlobalState storage gs = Storage.state();
        uint ethPrice = getLatestPrice();
        require(ethPrice > 0, "Invalid price");

        gs.lastGoodPrice = ethPrice;
    }
}
