# Investment Contract

## Overview

The `Investment` contract allows users to invest either Ether or ERC20 tokens and earn rewards based on a set interest rate. The contract includes different roles: SuperAdmin, Admin, and Investor, each with specific permissions and actions. It uses `require()`, `revert()`, and `assert()` to manage conditions for operations, ensuring correct functionality and security.

## Key Features

- **Roles**:

  - **SuperAdmin**: Manages admins and the interest rate.
  - **Admin**: Adds or removes investors.
  - **Investor**: Invests Ether or ERC20 tokens and withdraws investments with rewards.

- **Investment Types**:

  - **Ether**: Investors can deposit and withdraw Ether with interest.
  - **ERC20 Tokens**: Investors can deposit and withdraw ERC20 tokens with interest.

- **Interest Calculation**: Interest is calculated based on the deposit amount and the time elapsed since the deposit, applying the defined interest rate.

## Safety Checks and Error Handling

The contract uses:

- **`require()`**: To validate conditions and input values. Reverts the transaction if the condition is not met.
- **`revert()`**: Used for custom error handling and stopping execution in certain cases.
- **`assert()`**: Used to check invariants or conditions that should always be true in the contract's logic.

### Example of `require()` Usage

```solidity
require(isAdmin[msg.sender], "Msg.Sender is not Admin");
require(msg.sender == superAdmin, "Msg.Sender is not SuperAdmin");
require(_amount > 0, "Can't deposit zero value");
require(token.balanceOf(msg.sender) >= _amount, "Not enough tokens");
```

- Used for validating that only authorized roles can execute specific actions and ensuring that valid values are provided.

### Example of `revert()` Usage

```solidity
if (!isInvestor[msg.sender]) {
    revert("Msg.Sender is not Investor");
}
if (_amount == 0) {
    revert("Can't deposit zero value");
}
if (BalancesERC20[msg.sender] == 0) {
    revert("No funds to withdraw");
}
```

- Used to throw a custom error when certain conditions are not met, providing a descriptive reason for failure.

### Example of `assert()` Usage

```solidity
assert(msg.sender == superAdmin);
assert(msg.value != 0);
```

- Used for conditions that should **always** be true. If an `assert()` fails, it indicates a serious issue in the contract logic.

## Contract Deployment

```solidity
$ forge script script/Investment.s.sol:InvestmentScript \
  --rpc-url <your_rpc_url> \
  --private-key <your_private_key>
```

- `_token`: The address of the ERC20 token used for investments.
- `_superadmin`: The address of the SuperAdmin.
- `_interestRate`: The interest rate (in basis points) used for calculating rewards.

## Functions

### Admin Management

- `setAdmin(address _admin)`: Adds an admin. Only callable by the SuperAdmin.
  - **require**: Checks if the `_admin` is already an admin.
- `removeAdmin(address _admin)`: Removes an admin. Only callable by the SuperAdmin.

  - **require**: Checks if the `_admin` exists.

- `checkAdmin(address _admin)`: Checks if an address is an admin. Only callable by the SuperAdmin.

### Investor Management

- `addInvestor(address _investor)`: Adds an investor. Only callable by an admin.
  - **require**: Ensures the `_investor` isn't already added.
- `removeInvestor(address _investor)`: Removes an investor. Only callable by an admin.

  - **require**: Ensures the `_investor` exists.

- `checkInvestor(address _investor)`: Checks if an address is an investor. Only callable by an admin.

### Ether Investments

- `addInvestmentEthers(uint256 _amount)`: Invests Ether. Only callable by an investor.

  - **revert**: Throws an error if `_amount` is 0.
  - **require**: Ensures a valid deposit value is provided.

- `withdrawInvestmentEthers()`: Withdraws Ether and earned rewards. Only callable by an investor.
  - **require**: Ensures the caller has a balance to withdraw.
- `getInvestmentEthers()`: Returns the Ether balance of the caller.

### ERC20 Token Investments

- `addInvestmentERC20(uint256 _amount)`: Invests ERC20 tokens. Only callable by an investor.

  - **revert**: Throws an error if `_amount` is 0.
  - **require**: Ensures the investor has enough tokens in their balance.

- `withdrawInvestmentERC20()`: Withdraws ERC20 tokens and earned rewards. Only callable by an investor.
  - **revert**: Throws an error if there are no funds to withdraw.
- `getInvestmentERC20()`: Returns the ERC20 token balance of the caller.
- `getInvestmentToken()`: Returns the address of the ERC20 token used for investments.

### Interest and Rewards

- `calculateRewardEthers(address _user)`: Calculates the Ether interest for a user based on the amount and time since deposit.
- `calculateRewardERC20(address _user)`: Calculates the ERC20 token interest for a user based on the amount and time since deposit.

- `setInterestRate(uint256 _interestRate)`: Sets the interest rate. Only callable by the SuperAdmin.

  - **assert**: Ensures that only the SuperAdmin can set the interest rate.

- `getInterestRate()`: Returns the current interest rate.

### Fallback and Receive Functions

- `fallback()`: Allows the SuperAdmin to deposit Ether into the contract.
  - **assert**: Ensures the value is greater than 0.
- `receive()`: Automatically handles Ether deposits from the SuperAdmin.
  - **assert**: Ensures the value is greater than 0.

## Events

- `AdminAdded(address indexed _admin)`: Emitted when an admin is added.
- `AdminRemoved(address indexed _admin)`: Emitted when an admin is removed.
- `InvestorAdded(address indexed _investor)`: Emitted when an investor is added.
- `InvestorRemoved(address indexed _investor)`: Emitted when an investor is removed.
- `SuperAdminDepositedEthers(address indexed _investor, uint256 indexed _amount)`: Emitted when the SuperAdmin deposits Ether.
- `InvestorDepositedEthers(address indexed _investor, uint256 indexed _amount)`: Emitted when an investor deposits Ether.
- `InvestorWithdrawedEthers(address indexed _investor, uint256 indexed _amount)`: Emitted when an investor withdraws Ether.
- `InvestorDepositedERC20(address indexed _investor, uint256 indexed _amount)`: Emitted when an investor deposits ERC20 tokens.
- `InvestorWithdrawedERC20(address indexed _investor, uint256 indexed _amount)`: Emitted when an investor withdraws ERC20 tokens.

## License

This contract is licensed under the MIT License.
