# Screenshots Directory

This directory stores the testing and compilation evidence required by the assignment rubric (at least 2 screenshots per contract, 30+ total).

## Required Screenshots Breakdown

For each of the 15 contracts, capture:
1. `XX_compile.png`: Remix IDE showing the contract successfully compiled (Solidity 0.8.x) AND deployed to Ganache via `Custom - External Http Provider` (`http://127.0.0.1:7545`), showing the deployed address.
2. `XX_test1.png`: Happy-path execution showing function execution, returned values, or updated state.
3. `XX_test2.png`: Revert / edge-case handling (e.g., unauthorized caller, boundary checks, zero address) or Ganache transaction log / account balance verification.

| # | Contract | Compile & Deploy | Test Case 1 (Happy Path) | Test Case 2 (Edge/Revert) |
|---|----------|------------------|--------------------------|---------------------------|
| 01 | Storage | `01_compile.png` | `01_test1.png` (get/set 42->100) | `01_test2.png` (Ganache event log) |
| 02 | Greeting | `02_compile.png` | `02_test1.png` (owner setGreeting) | `02_test2.png` (non-owner revert) |
| 03 | Counter | `03_compile.png` | `03_test1.png` (increment/decrement) | `03_test2.png` (revert at 0 or 100) |
| 04 | Ownable | `04_compile.png` | `04_test1.png` (deposit & owner withdraw) | `04_test2.png` (non-owner revert) |
| 05 | SimpleBank | `05_compile.png` | `05_test1.png` (deposit 2 ETH, withdraw 1) | `05_test2.png` (withdraw 10 ETH revert) |
| 06 | Voting | `06_compile.png` | `06_test1.png` (authorize & vote) | `06_test2.png` (double vote / unauth revert) |
| 07 | MyToken | `07_compile.png` | `07_test1.png` (transfer & approve) | `07_test2.png` (transferFrom over allowance revert) |
| 08 | Crowdfunding | `08_compile.png` | `08_test1.png` (reach goal & claim) | `08_test2.png` (miss goal & refund) |
| 09 | Lottery | `09_compile.png` | `09_test1.png` (5 players enter, pickWinner) | `09_test2.png` (manager enter / wrong fee revert) |
| 10 | TimeLockVault | `10_compile.png` | `10_test1.png` (withdraw after lock expired) | `10_test2.png` (premature withdraw revert) |
| 11 | Escrow | `11_compile.png` | `11_test1.png` (confirm delivery -> seller) | `11_test2.png` (dispute resolution / wrong state) |
| 12 | SimpleNFT | `12_compile.png` | `12_test1.png` (mint 0.01 ETH, transferNFT) | `12_test2.png` (wrong fee / unauthorized revert) |
| 13 | EnglishAuction | `13_compile.png` | `13_test1.png` (bidding & pull-refund) | `13_test2.png` (sub-5% increment revert) |
| 14 | MultisigWallet | `14_compile.png` | `14_test1.png` (submit, 2 confirms, auto-execute) | `14_test2.png` (non-owner / duplicate confirm revert) |
| 15 | StakingRewards | `15_compile.png` | `15_test1.png` (stake, claim accrued reward) | `15_test2.png` (unstake principal+reward, double unstake revert) |
