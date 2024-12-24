// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TraderRegistry {
    struct Trader {
        address traderAddress;
        uint256 roi; // Return on Investment in percentage
        uint256 riskScore; // Risk level (1 = Low, 2 = Medium, 3 = High)
        uint256 totalTrades; // Number of trades executed
        bool isActive; // Active status
    }

    address public admin;
    mapping(address => Trader) public traders;
    address[] public traderList;

    event TraderAdded(address indexed trader, uint256 roi, uint256 riskScore);
    event PerformanceUpdated(address indexed trader, uint256 roi, uint256 riskScore);
    event TraderStatusChanged(address indexed trader, bool isActive);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Add a new trader to the registry
    function addTrader(
        address _trader,
        uint256 _roi,
        uint256 _riskScore
    ) external onlyAdmin {
        require(traders[_trader].traderAddress == address(0), "Trader already exists");

        traders[_trader] = Trader({
            traderAddress: _trader,
            roi: _roi,
            riskScore: _riskScore,
            totalTrades: 0,
            isActive: true
        });

        traderList.push(_trader);
        emit TraderAdded(_trader, _roi, _riskScore);
    }

    // Update performance metrics for a trader
    function updatePerformance(
        address _trader,
        uint256 _roi,
        uint256 _riskScore
    ) external onlyAdmin {
        require(traders[_trader].traderAddress != address(0), "Trader does not exist");
        require(traders[_trader].isActive, "Trader is not active");

        traders[_trader].roi = _roi;
        traders[_trader].riskScore = _riskScore;

        emit PerformanceUpdated(_trader, _roi, _riskScore);
    }

    // Change trader active status
    function changeTraderStatus(address _trader, bool _isActive) external onlyAdmin {
        require(traders[_trader].traderAddress != address(0), "Trader does not exist");

        traders[_trader].isActive = _isActive;

        emit TraderStatusChanged(_trader, _isActive);
    }

    // Fetch top-performing traders based on ROI
    function getTopTraders() external view returns (address[] memory) {
        address[] memory activeTraders = new address[](traderList.length);
        uint256 count = 0;

        for (uint256 i = 0; i < traderList.length; i++) {
            if (traders[traderList[i]].isActive) {
                activeTraders[count] = traderList[i];
                count++;
            }
        }

        // Resize array to actual count
        assembly {
            mstore(activeTraders, count)
        }

        return activeTraders;
    }
}
