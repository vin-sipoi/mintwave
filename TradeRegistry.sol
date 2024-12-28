// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TraderRegistry {
    // Struct to hold trader details
    struct Trader {
        address traderAddress;
        string name;
        string metadata; // Additional info like trading style, strategies, etc.
        bool isVerified;
    }

    // Mapping to store traders by address
    mapping(address => Trader) public traders;

    // Array to store all trader addresses for enumeration
    address[] public traderAddresses;

    // Admin address
    address public admin;
    / Events
    event TraderRegistered(address indexed trader, string name);
    event TraderVerified(address indexed trader);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    // Modifier to restrict actions to the admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    // incomplete
    

    



