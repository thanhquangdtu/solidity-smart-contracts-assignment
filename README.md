# Solidity Smart Contract Assignment

**Name   :** Le Thanh Quang  
**Roll No:** 29211120739  
**Email  :** thanhquangk2@gmail.com  
**Repository:** [https://github.com/thanhquangdtu/solidity-smart-contracts-assignment](https://github.com/thanhquangdtu/solidity-smart-contracts-assignment)

---

## Contracts Overview & Status Table

| #  | Contract | File Name | Level | Tested on Ganache | Screenshots |
|:--:|:---------|:----------|:-----:|:-----------------:|:------------|
| 01 | Simple Storage | [`01_Storage.sol`](contracts/01_Storage.sol) | Basic | YES | `01_compile.png`, `01_test1.png`, `01_test2.png` |
| 02 | Greeting Contract | [`02_Greeting.sol`](contracts/02_Greeting.sol) | Basic | YES | `02_compile.png`, `02_test1.png`, `02_test2.png` |
| 03 | Counter with Events | [`03_Counter.sol`](contracts/03_Counter.sol) | Basic | YES | `03_compile.png`, `03_test1.png`, `03_test2.png` |
| 04 | Ownable & Vault | [`04_Ownable.sol`](contracts/04_Ownable.sol) | Medium | YES | `04_compile.png`, `04_test1.png`, `04_test2.png` |
| 05 | Simple Bank | [`05_SimpleBank.sol`](contracts/05_SimpleBank.sol) | Medium | YES | `05_compile.png`, `05_test1.png`, `05_test2.png` |
| 06 | Voting System | [`06_Voting.sol`](contracts/06_Voting.sol) | Medium | YES | `06_compile.png`, `06_test1.png`, `06_test2.png` |
| 07 | MyToken (ERC-20) | [`07_MyToken.sol`](contracts/07_MyToken.sol) | Medium | YES | `07_compile.png`, `07_test1.png`, `07_test2.png` |
| 08 | Crowdfunding | [`08_Crowdfunding.sol`](contracts/08_Crowdfunding.sol) | Advanced | YES | `08_compile.png`, `08_test1.png`, `08_test2.png` |
| 09 | Lottery | [`09_Lottery.sol`](contracts/09_Lottery.sol) | Advanced | YES | `09_compile.png`, `09_test1.png`, `09_test2.png` |
| 10 | TimeLock Vault | [`10_TimeLockVault.sol`](contracts/10_TimeLockVault.sol) | Advanced | YES | `10_compile.png`, `10_test1.png`, `10_test2.png` |
| 11 | Escrow Service | [`11_Escrow.sol`](contracts/11_Escrow.sol) | Advanced | YES | `11_compile.png`, `11_test1.png`, `11_test2.png` |
| 12 | Simple NFT (ERC-721) | [`12_SimpleNFT.sol`](contracts/12_SimpleNFT.sol) | Advanced | YES | `12_compile.png`, `12_test1.png`, `12_test2.png` |
| 13 | English Auction | [`13_EnglishAuction.sol`](contracts/13_EnglishAuction.sol) | Expert | YES | `13_compile.png`, `13_test1.png`, `13_test2.png` |
| 14 | Multisig Wallet | [`14_MultisigWallet.sol`](contracts/14_MultisigWallet.sol) | Expert | YES | `14_compile.png`, `14_test1.png`, `14_test2.png` |
| 15 | Staking Rewards | [`15_StakingRewards.sol`](contracts/15_StakingRewards.sol) | Expert | YES | `15_compile.png`, `15_test1.png`, `15_test2.png` |

---

## How to Run & Test

1. **Start Local Ganache Blockchain**:
   - Open Ganache GUI -> Click **QUICKSTART Ethereum** (or run `ganache --port 7545`).
   - Confirm RPC Server address is `HTTP://127.0.0.1:7545` and Network ID is `5777` or `1337`.
   - Ensure 10 accounts preloaded with 100 ETH are displayed.

2. **Open Remix IDE**:
   - Navigate to [https://remix.ethereum.org](https://remix.ethereum.org).
   - In File Explorer, create workspace `Assignment15` and import the contract files from the `contracts/` directory.

3. **Compile Contracts**:
   - Switch to **Solidity Compiler** tab.
   - Choose compiler version `0.8.20` (or any `^0.8.x`).
   - Click **Compile <ContractName>.sol** and ensure compilation succeeds with zero errors.

4. **Connect Remix to Ganache (Mandatory Method A)**:
   - Go to **Deploy & Run Transactions** tab.
   - Set **ENVIRONMENT** to `Custom - External Http Provider`.
   - Enter provider endpoint: `http://127.0.0.1:7545` -> click **OK**.
   - Remix **ACCOUNT** dropdown will now display Ganache accounts with ~100 ETH balance.

5. **Deploy and Verify**:
   - Deploy each contract to Ganache.
   - Interact with functions in the deployed contracts panel in Remix.
   - Open Ganache GUI to verify blocks mined, gas consumed, events logged, and account balance changes in real-time.

---

## Repository Structure

```text
solidity-smart-contracts-assignment/
|-- README.md                      <- Project summary, student info, and run guide
|-- contracts/                     <- All 15 Solidity smart contracts (^0.8.20)
|   |-- 01_Storage.sol
|   |-- 02_Greeting.sol
|   |-- 03_Counter.sol
|   |-- 04_Ownable.sol
|   |-- 05_SimpleBank.sol
|   |-- 06_Voting.sol
|   |-- 07_MyToken.sol
|   |-- 08_Crowdfunding.sol
|   |-- 09_Lottery.sol
|   |-- 10_TimeLockVault.sol
|   |-- 11_Escrow.sol
|   |-- 12_SimpleNFT.sol
|   |-- 13_EnglishAuction.sol
|   |-- 14_MultisigWallet.sol
|   |-- 15_StakingRewards.sol
|-- screenshots/                   <- Evidence of compilation and Ganache test execution
|   |-- README.md                  <- Checklist of screenshot test cases
|   |-- 01_compile.png ... 15_test2.png
|-- report/
    |-- REPORT.md                  <- Detailed test analysis and theoretical answers
```
