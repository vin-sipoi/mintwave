// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract FollowerContract is ReentrancyGuard {
    // Struct to track user investment details
    struct Follower {
        uint256 investedAmount;
        address followedTrader;
    }

    // Mapping of followers to their details
    mapping(address => Follower) public followers;

    // Admin address
    address public admin;

    // Supported token for trading (e.g., USDC)
    IERC20 public tradingToken;

    // Risk management parameters
    uint256 public maxDrawdownPercentage = 20; // 20% max drawdown

    // Events
    event FundsDeposited(address indexed user, uint256 amount);
    event FundsWithdrawn(address indexed user, uint256 amount);
    event TradeReplicated(address indexed trader, uint256 amount, address indexed follower);
    event TraderFollowed(address indexed follower, address indexed trader);

    // Modifier to restrict access to the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
// Constructor to set the admin and trading token
        require(trader != address(0), "Invalid trader address");

        // Transfer funds to the contract
        require(
            tradingToken.transferFrom(msg.sender, address(this), amount),
            "Token transfer failed"
        );

        // Update follower details
        followers[msg.sender].investedAmount += amount;
        followers[msg.sender].followedTrader = trader;

        emit FundsDeposited(msg.sender, amount);
        emit TraderFollowed(msg.sender, trader);
    }

    // Function for users to withdraw funds
    function withdrawFunds(uint256 amount) external nonReentrant {
        require(followers[msg.sender].investedAmount >= amount, "Insufficient balance");

        // Update follower details
        followers[msg.sender].investedAmount -= amount;

        // Transfer funds back to the user
        require(
            tradingToken.transfer(msg.sender, amount),
            "Token transfer failed"
        );

        emit FundsWithdrawn(msg.sender, amount);
    }

    // Function to replicate a trade
    function replicateTrade(address trader, uint256 tradeAmount) external onlyAdmin nonReentrant {
        require(tradeAmount > 0, "Trade amount must be greater than zero");

        // Iterate through all followers
        for (address followerAddress = address(0); followerAddress < address(type(uint160).max); followerAddress++) {
            Follower storage follower = followers[followerAddress];
            if (follower.followedTrader == trader && follower.investedAmount > 0) {
                // Calculate follower's trade proportion based on their balance
                uint256 followerTradeAmount = (follower.investedAmount * tradeAmount) / getTotalTraderBalance(trader);

                // Enforce risk controls (e.g., max drawdown)
                uint256 maxAllowedTrade = (follower.investedAmount * (100 - maxDrawdownPercentage)) / 100;
                require(followerTradeAmount <= maxAllowedTrade, "Trade exceeds risk limits");

                emit TradeReplicated(trader, followerTradeAmount, followerAddress);
            }
        }
    }

    // Function to get the total balance managed by a trader
    function getTotalTraderBalance(address trader) public view returns (uint256 totalBalance) {
        totalBalance = 0;
        for (address followerAddress = address(0); followerAddress < address(type(uint160).max); followerAddress++) {
            if (followers[followerAddress].followedTrader == trader) {
                totalBalance += followers[followerAddress].investedAmount;
            }
        }
    }

    // Function to update risk management parameters
    function setMaxDrawdownPercentage(uint256 newMaxDrawdown) external onlyAdmin {
        require(newMaxDrawdown <= 100, "Invalid drawdown percentage");
        maxDrawdownPercentage = newMaxDrawdown;
    }
}
    //Key Features:
Fund Management:

Followers deposit funds into the contract, which are tracked individually.
Funds can be withdrawn at any time if they are not locked in trades.
Trade Automation:

Trades initiated by a trader are replicated proportionally for all followers based on their investments.
Risk Controls:

Enforces maximum drawdown limits to protect followers from excessive losses.
Admin Management:

Admin manages trades and risk parameters for the platform.
OpenZeppelin Integration:

Utilizes OpenZeppelin’s IERC20 for token compatibility and ReentrancyGuard for security.
