// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TraderRegistry.sol";

contract FollowerContract {
    TraderRegistry public traderRegistry;

    struct Follower {
        address trader;
        uint256 allocatedFunds;
        bool isFollowing;
    }

    mapping(address => Follower) public followers;
    mapping(address => uint256) public balances; // User balances for trading

    event TraderFollowed(address indexed follower, address indexed trader, uint256 funds);
    event TraderUnfollowed(address indexed follower, address indexed trader);
    event TradeReplicated(address indexed trader, address indexed follower, uint256 tradeAmount);

    modifier onlyRegisteredTrader(address _trader) {
        require(traderRegistry.traders(_trader).traderAddress != address(0), "Trader not registered");
        require(traderRegistry.traders(_trader).isActive, "Trader is not active");
        _;
    }

    constructor(address _traderRegistry) {
        traderRegistry = TraderRegistry(_traderRegistry);
    }

    // Follow a trader and allocate funds
    function followTrader(address _trader, uint256 _funds) external onlyRegisteredTrader(_trader) {
        require(_funds > 0, "Funds must be greater than zero");
        require(balances[msg.sender] >= _funds, "Insufficient balance");

        followers[msg.sender] = Follower({
            trader: _trader,
            allocatedFunds: _funds,
            isFollowing: true
        });

        balances[msg.sender] -= _funds;

        emit TraderFollowed(msg.sender, _trader, _funds);
    }

    // Unfollow a trader and reclaim funds
    function unfollowTrader() external {
        require(followers[msg.sender].isFollowing, "You are not following any trader");

        address trader = followers[msg.sender].trader;
        uint256 allocatedFunds = followers[msg.sender].allocatedFunds;

        balances[msg.sender] += allocatedFunds;

        delete followers[msg.sender];

        emit TraderUnfollowed(msg.sender, trader);
    }

    // Deposit funds to be used for copy trading
    function depositFunds() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    // Replicate a trader's trade
    function replicateTrade(address _trader, uint256 _tradeAmount) external onlyRegisteredTrader(_trader) {
        require(followers[msg.sender].isFollowing, "You are not following any trader");
        require(followers[msg.sender].trader == _trader, "You are not following this trader");

        uint256 allocatedFunds = followers[msg.sender].allocatedFunds;
        require(allocatedFunds >= _tradeAmount, "Insufficient allocated funds");

        followers[msg.sender].allocatedFunds -= _tradeAmount;

        emit TradeReplicated(_trader, msg.sender, _tradeAmount);
    }

    // Check user balance
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
}
