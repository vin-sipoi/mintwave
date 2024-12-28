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

    
