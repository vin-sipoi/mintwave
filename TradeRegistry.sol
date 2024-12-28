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
    // Constructor to set the deployer as the initial admin
    constructor() {
        admin = msg.sender;
    }

    // Function to change the admin
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        address oldAdmin = admin;
        admin = newAdmin;
        emit AdminChanged(oldAdmin, newAdmin);
    }

    // Function for traders to register
    function registerTrader(string calldata name, string calldata metadata) external {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(metadata).length > 0, "Metadata cannot be empty");
        require(traders[msg.sender].traderAddress == address(0), "Trader already registered");

        // Add trader to the mapping
        traders[msg.sender] = Trader({
            traderAddress: msg.sender,
            name: name,
            metadata: metadata,
            isVerified: false
        });

        // Add trader address to the array
        traderAddresses.push(msg.sender);

        emit TraderRegistered(msg.sender, name);
    }

    // Function for admin to verify a trader
    function verifyTrader(address traderAddress) external onlyAdmin {
        require(traders[traderAddress].traderAddress != address(0), "Trader not registered");
        require(!traders[traderAddress].isVerified, "Trader already verified");

        traders[traderAddress].isVerified = true;

        emit TraderVerified(traderAddress);
    }

    // Function to get the total number of traders
    function getTraderCount() external view returns (uint256) {
        return traderAddresses.length;
    }

    // Function to get a trader's details
    function getTrader(address traderAddress) external view returns (Trader memory) {
        require(traders[traderAddress].traderAddress != address(0), "Trader not registered");
        return traders[traderAddress];
    }

    // Function to get all trader addresses
    function getAllTraders() external view returns (address[] memory) {
        return traderAddresses;
    }
}


    



