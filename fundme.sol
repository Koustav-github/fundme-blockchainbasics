// Get fund from user
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import {PriceConverter} from "./priceConvertor.sol";


contract FundMe{

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping (address funders => uint256 amountFunded) public AddressToAmountFunded;

    address public immutable i_owner;

    constructor () {
        i_owner = msg.sender;
    }

    function fund() public payable{
        //Allow user to send $
        // Have a minimum $ sent
        // 1. How do we send ETH to this contract?
        require((msg.value.getConversionRate()) >= MINIMUM_USD, "did not send enough ETH"); // 1e18 = 1ETH = 1 * 10 ** 18 wei
        funders.push(msg.sender);
        AddressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner{
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            AddressToAmountFunded[funder] = 0;
        }  
        //funders
        funders = new address[](0);
        //actually withdraw the funds
        // payable(msg.sender).transfer(address(this).balance);
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "send failed");
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Sender is not Owner");
        _;
    }

    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }
}
