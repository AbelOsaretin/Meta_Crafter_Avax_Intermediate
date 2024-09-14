// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Investment {
    address superAdmin;

    uint256 interestRate;

    IERC20 token;

    uint256 TotalDepositEthers;

    uint256 TotalDepositERC20;

    mapping(address => uint256) BalancesERC20;

    mapping(address => uint256) public WithdrawnDepositAndRewardERC20;

    mapping(address => uint256) BalancesEthers;

    mapping(address => uint256) public WithdrawnDepositAndRewardEthers;

    mapping(address => uint256) DepositTimeERC20;

    mapping(address => uint256) DepositTimeEthers;

    mapping(address => bool) isInvestor;

    mapping(address => bool) isAdmin;

    mapping(address => uint256) InvestorsAmount;

    event AdminAdded(address indexed _admin);

    event AdminRemoved(address indexed _admin);

    event InvestorAdded(address indexed _investor);

    event InvestorRemoved(address indexed _investor);

    event SuperAdminDepositedEthers(
        address indexed _investor,
        uint256 indexed _amount
    );

    event InvestorDepositedEthers(
        address indexed _investor,
        uint256 indexed _amount
    );

    event InvestorWithdrawedEthers(
        address indexed _investor,
        uint256 indexed _amount
    );

    event InvestorDepositedERC20(
        address indexed _investor,
        uint256 indexed _amount
    );

    event InvestorWithdrawedERC20(
        address indexed _investor,
        uint256 indexed _amount
    );

    modifier onlyAdmin() {
        require(isAdmin[msg.sender], "Msg.Sender is not Admin");
        _;
    }

    modifier onlyInvestor() {
        require(isInvestor[msg.sender], "Msg.Sender is not Investor");
        _;
    }

    modifier onlySuperAdmin() {
        require(msg.sender == superAdmin, "Msg.Sender is not SuperAdmin");
        _;
    }

    constructor(address _token, address _superadmin, uint256 _interestRate) {
        superAdmin = _superadmin;
        token = IERC20(_token);
        interestRate = _interestRate;
    }

    function setAdmin(address _admin) external onlySuperAdmin {
        require(!isAdmin[_admin], "Admin Already Added");
        isAdmin[_admin] = true;

        emit AdminAdded(_admin);
    }

    function checkAdmin(
        address _admin
    ) external view onlySuperAdmin returns (bool) {
        return isAdmin[_admin];
    }

    function removeAdmin(address _admin) external onlySuperAdmin {
        require(isAdmin[_admin], "Admin Does Not Exits");

        isAdmin[_admin] = false;

        emit AdminRemoved(_admin);
    }

    function addInvestor(address _investor) external onlyAdmin {
        require(!isInvestor[_investor], "Investor Already Added");

        isInvestor[_investor] = true;

        emit InvestorAdded(_investor);
    }

    function checkInvestor(
        address _investor
    ) external view onlyAdmin returns (bool) {
        return isInvestor[_investor];
    }

    function removeInvestor(address _investor) external onlyAdmin {
        require(isInvestor[_investor], "Investor Does Not Exist");

        isInvestor[_investor] = false;

        emit InvestorRemoved(_investor);
    }

    function addInvestmentEthers(
        uint256 _amount
    ) external payable onlyInvestor {
        require(_amount > 0, "Can't deposit zero value");

        payable(msg.sender).transfer(_amount);
        BalancesEthers[msg.sender] += _amount;
        TotalDepositEthers += _amount;

        DepositTimeEthers[msg.sender] = block.timestamp;

        emit InvestorDepositedEthers(msg.sender, _amount);
    }

    function withdrawInvestmentEthers() external payable onlyInvestor {
        require(BalancesEthers[msg.sender] > 0, "No funds to withdraw");

        uint256 interest = calculateRewardEthers(msg.sender);
        uint256 totalAmount = BalancesEthers[msg.sender] + interest;

        TotalDepositEthers - BalancesEthers[msg.sender];
        WithdrawnDepositAndRewardEthers[msg.sender] = totalAmount;
        BalancesEthers[msg.sender] = 0;
        DepositTimeEthers[msg.sender] = 0;

        payable(msg.sender).transfer(totalAmount);

        emit InvestorWithdrawedEthers(msg.sender, totalAmount);
    }

    function getInvestmentEthers() external view returns (uint256) {
        return BalancesEthers[msg.sender];
    }

    function addInvestmentERC20(uint256 _amount) external onlyInvestor {
        require(_amount > 0, "Can't deposit zero value");
        require(token.balanceOf(msg.sender) >= _amount, "Not enough tokens");
        token.transferFrom(msg.sender, address(this), _amount);
        BalancesERC20[msg.sender] += _amount;

        DepositTimeERC20[msg.sender] = block.timestamp;
        emit InvestorDepositedERC20(msg.sender, _amount);
    }

    function withdrawInvestmentERC20() external onlyInvestor {
        require(BalancesERC20[msg.sender] > 0, "No funds to withdraw");

        uint256 interest = calculateRewardERC20(msg.sender);
        uint256 totalAmount = BalancesERC20[msg.sender] + interest;

        TotalDepositERC20 - BalancesERC20[msg.sender];
        WithdrawnDepositAndRewardERC20[msg.sender] = totalAmount;
        BalancesERC20[msg.sender] = 0;
        DepositTimeERC20[msg.sender] = 0;

        token.transfer(msg.sender, totalAmount);
        emit InvestorWithdrawedERC20(msg.sender, totalAmount);
    }

    function getInvestmentERC20() external view returns (uint256) {
        return BalancesERC20[msg.sender];
    }

    function getInvestmentToken() external view returns (address) {
        return address(token);
    }

    function calculateRewardEthers(
        address _user
    ) internal view returns (uint256) {
        uint256 principal = BalancesEthers[_user];
        uint256 timeElapsed = block.timestamp - DepositTimeEthers[_user];
        uint256 timeInYears = timeElapsed / 365 days;

        uint256 interest = (principal * interestRate * timeInYears) / 10000;
        return interest;
    }

    function calculateRewardERC20(
        address _user
    ) internal view returns (uint256) {
        uint256 principal = BalancesERC20[_user];
        uint256 timeElapsed = block.timestamp - DepositTimeERC20[_user];
        uint256 timeInYears = timeElapsed / 365 days;

        uint256 interest = (principal * interestRate * timeInYears) / 10000;
        return interest;
    }

    function setInterestRate(uint256 _interestRate) external onlyAdmin {
        interestRate = _interestRate;
    }

    fallback() external payable onlySuperAdmin {
        require(msg.value > 0, "Can't deposit zero value");

        BalancesEthers[msg.sender] += msg.value;

        emit SuperAdminDepositedEthers(msg.sender, msg.value);
    }

    receive() external payable onlySuperAdmin {
        require(msg.value > 0, "Can't deposit zero value");

        BalancesEthers[msg.sender] += msg.value;

        emit SuperAdminDepositedEthers(msg.sender, msg.value);
    }
}
