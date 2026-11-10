# Solidity Smart Contracts Assignment — Technical Report

This report provides the technical documentation and testing verification summary for all 15 smart contracts developed, compiled, and deployed using Solidity `^0.8.20`, Remix IDE, and Ganache local blockchain.

---

## 01 Simple Storage (`01_Storage.sol`)
- **What it does**: Stores an unsigned integer on-chain and permits authorized reads and writes with event notification.
- **Key concept**: Basic state variable manipulation, constructor initialization, gas-efficient `view` functions, and `emit` event logging.
- **Tested**: Deployed with `_init = 42` -> verified `get()` returns 42 -> executed `set(100)` -> verified Ganache transaction mined and `ValueSet(sender, 100)` logged -> confirmed `get()` returns 100.
- **Ganache proof**: `screenshots/01_compile.png`, `screenshots/01_test1.png`, `screenshots/01_test2.png`

---

## 02 Greeting (`02_Greeting.sol`)
- **What it does**: Stores a string greeting readable by anyone, but restricted so that only the contract owner can alter or reset it.
- **Key concept**: Access control via caller validation (`msg.sender == owner`), custom error messaging with `require()`, and dynamic string storage handling.
- **Tested**: Deployed with initial greeting "Welcome" -> verified `greet()` returns "Welcome" -> owner called `setGreeting("GM Ganache")` successfully -> switched to Account 2 and called `setGreeting("Hacked")` -> reverted with `"Caller is not the owner"` -> owner called `resetGreeting()` -> verified reset to `"Hello, World!"`.
- **Ganache proof**: `screenshots/02_compile.png`, `screenshots/02_test1.png`, `screenshots/02_test2.png`

---

## 03 Counter with Events (`03_Counter.sol`)
- **What it does**: Implements an on-chain counter bounded strictly within the range $[0, 100]$.
- **Key concept**: Boundary enforcement, state mutation safeguards, and granular lifecycle event logging (`Incremented`, `Decremented`, `Reset`).
- **Tested**: Initial count at 0 -> called `decrement()` -> reverted with `"Count is zero"` -> incremented to 100 -> next `increment()` reverted with `"Max limit reached"` -> called `reset()` -> counter returned to 0 with `Reset` event logged.
- **Ganache proof**: `screenshots/03_compile.png`, `screenshots/03_test1.png`, `screenshots/03_test2.png`

---

## 04 Ownable & ProtectedVault (`04_Ownable.sol`)
- **What it does**: Provides a reusable ownership base contract (`Ownable`) inherited by a treasury vault (`ProtectedVault`) where anyone can deposit ETH, but only the owner can withdraw funds.
- **Key concept**: Contract inheritance (`is Ownable`), custom modifier pattern (`onlyOwner`), and zero-address validation.
- **Tested**: Account 1 deployed contract -> Account 1 deposited 1 ETH -> Account 2 attempted `withdraw()` -> transaction reverted with `"Not the owner"` -> Account 1 transferred ownership to Account 2 -> Account 2 withdrew 0.5 ETH successfully -> verified Ganache account balances.
- **Ganache proof**: `screenshots/04_compile.png`, `screenshots/04_test1.png`, `screenshots/04_test2.png`

### Viva Focus: Why Modifiers Save Code Duplication
Function modifiers in Solidity encapsulate common pre-condition and post-condition checks into reusable syntax blocks. Without modifiers, every sensitive administrative function would need to repeat:
```solidity
require(msg.sender == owner, "Not the owner");
```
By centralizing validation into `modifier onlyOwner() { require(msg.sender == owner, "Not the owner"); _; }`:
1. **DRY (Don't Repeat Yourself)**: Code readability is dramatically improved and maintenance is centralized to a single source of truth.
2. **Auditability & Security**: Security reviewers can inspect modifier definitions once rather than auditing dozens of individual validation lines across contract hierarchies.
3. **Execution Safety**: The merge-point `_;` clearly separates pre-checks from function execution, preventing accidental execution of critical logic when permissions fail.

---

## 05 Simple Bank (`05_SimpleBank.sol`)
- **What it does**: Implements a personal banking ledger where users deposit and withdraw ETH independently.
- **Key concept**: Mapping state management (`mapping(address => uint256)`), Checks-Effects-Interactions (CEI) anti-reentrancy pattern, and secure transfer via `call{value: amount}("")`.
- **Tested**: Account 1 deposited 2 ETH and Account 2 deposited 3 ETH -> confirmed `bankTotal()` was 5 ETH -> Account 1 attempted to withdraw 10 ETH -> reverted with `"Insufficient balance"` -> Account 1 withdrew 1 ETH -> verified balance updated to 1 ETH and Ganache balance increased by 1 ETH minus gas.
- **Ganache proof**: `screenshots/05_compile.png`, `screenshots/05_test1.png`, `screenshots/05_test2.png`

### Viva Focus: Checks-Effects-Interactions (CEI) Pattern
Re-entrancy occurs when an external call passes control flow to an untrusted recipient contract before internal state is updated. If the malicious contract's fallback or receive function invokes the vulnerable function again, it can drain funds because balances have not yet decreased.

The CEI pattern strictly orders execution:
1. **Checks**: Validate conditions (`require(balances[msg.sender] >= amount)`).
2. **Effects**: Mutate internal contract state **first** (`balances[msg.sender] -= amount`).
3. **Interactions**: Interact with external addresses **last** (`(bool s, ) = msg.sender.call{value: amount}("")`).

Even if the external receiver re-enters `withdraw()`, the balance is already decremented to 0 or remainder, causing subsequent checks to fail immediately and neutralizing the exploit without requiring heavy re-entrancy locks.

---

## 06 Voting System (`06_Voting.sol`)
- **What it does**: Orchestrates a democratic election where a chairperson registers candidates and authorizes voters who can cast one vote each.
- **Key concept**: Dynamic struct arrays (`Candidate[]`), voter mapping tracking authorization and participation, and candidate winner calculation algorithms.
- **Tested**: Deployed with candidates `["Alice", "Bob", "Carol"]` -> chairperson authorized Accounts 1, 2, and 3 -> Account 1 voted for Alice (idx 0), Accounts 2 and 3 voted for Bob (idx 1) -> Account 1 attempted to vote a second time -> reverted with `"Already voted"` -> unauthorized Account 4 attempted to vote -> reverted with `"Not authorized to vote"` -> called `winnerName()` -> correctly returned `"Bob"`.
- **Ganache proof**: `screenshots/06_compile.png`, `screenshots/06_test1.png`, `screenshots/06_test2.png`

---

## 07 MyToken (`07_MyToken.sol`)
- **What it does**: Full implementation of an ERC-20 fungible token built from scratch without external libraries.
- **Key concept**: Decimals scaling ($10^{18}$), 2-step delegated transfers (`approve` & `transferFrom`), allowance accounting, and token balance transfer invariants.
- **Tested**: Deployed with 1,000,000 supply -> Account 1 transferred 500 tokens to Account 2 -> verified balances -> Account 2 approved Account 3 for 200 tokens -> Account 3 called `transferFrom(Account 2, Account 3, 200)` -> succeeded -> Account 3 attempted second `transferFrom` of 200 -> reverted with `"Insufficient allowance"`.
- **Ganache proof**: `screenshots/07_compile.png`, `screenshots/07_test1.png`, `screenshots/07_test2.png`

---

## 08 Crowdfunding (`08_Crowdfunding.sol`)
- **What it does**: Time-limited crowdfunding campaign with automatic conditional settlement.
- **Key concept**: Block timestamp comparison (`block.timestamp >= deadline`), conditional disbursement based on goal thresholds, and one-shot safe contributor refunds.
- **Tested**:
  - *Campaign Path A (Goal Achieved)*: 5 ETH goal -> contributors funded 5.5 ETH -> deadline expired -> owner called `claimFunds()` -> contract balance became 0 and owner received full amount.
  - *Campaign Path B (Goal Missed)*: 10 ETH goal -> contributors pledged 3 ETH -> deadline expired -> contributors called `refund()` -> each received exact ETH deposit back -> repeated `refund()` call reverted with `"No contributions to refund or already refunded"`.
- **Ganache proof**: `screenshots/08_compile.png`, `screenshots/08_test1.png`, `screenshots/08_test2.png`

---

## 09 Lottery (`09_Lottery.sol`)
- **What it does**: Autonomous pooled lottery where players enter with exact ticket fees; manager draws a winner who receives the entire prize pool.
- **Key concept**: Dynamic player arrays, entry fee validation, array resetting, and modulo pseudo-random winner selection.
- **Tested**: Entry fee set to 0.01 ETH -> 5 separate accounts entered with 0.01 ETH -> manager attempted to enter -> reverted with `"Manager cannot enter lottery"` -> entrant sending 0.02 ETH reverted with `"Must pay exact entry fee"` -> manager called `pickWinner()` with 5 players -> entire balance transferred to chosen winner -> verified player array cleared and new round ready.
- **Ganache proof**: `screenshots/09_compile.png`, `screenshots/09_test1.png`, `screenshots/09_test2.png`

### Viva Focus: Insecurity of On-Chain Blockhash Randomness & Chainlink VRF
Generating randomness on Ethereum via `uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp)))` is fundamentally insecure for high-value applications:
1. **Miner/Validator Manipulation**: Block producers can choose to omit a block if the lottery winner outcome is unfavorable to them (block withholding attack).
2. **Predictability**: The block timestamp and prior blockhash are publicly known before transactions are finalized within the block, allowing frontrunning bots to calculate winning inputs before submitting their entry.

**The Solution — Chainlink VRF (Verifiable Random Function)**:
Chainlink VRF uses an off-chain oracle that generates an unpredictable 256-bit random number paired with a cryptographic proof generated using the oracle's private key and on-chain seed. The proof is verified by an on-chain coordinator contract before delivering the random word to the consuming smart contract, ensuring neither node operators, users, nor miners can manipulate or anticipate the lottery outcome.

---

## 10 TimeLockVault (`10_TimeLockVault.sol`)
- **What it does**: Secures deposits until a designated maturity timestamp has elapsed; only the beneficiary can withdraw upon maturity.
- **Key concept**: Timestamp scheduling (`block.timestamp`), time extensions, access control, and balance clearing.
- **Tested**: Deployed with 120-second lock duration -> deposited 1 ETH -> beneficiary called `withdraw()` immediately -> reverted with `"Vault is still locked"` -> advanced Ganache time past 120 seconds -> beneficiary called `withdraw()` -> succeeded -> contract balance reached 0.
- **Ganache proof**: `screenshots/10_compile.png`, `screenshots/10_test1.png`, `screenshots/10_test2.png`

---

## 11 Escrow (`11_Escrow.sol`)
- **What it does**: A trustless 3-party commercial escrow between Buyer, Seller, and Arbiter with strict finite state machine transitions.
- **Key concept**: Solidity `enum State`, state transition guards (`inState` modifier), multi-role permissions, and arbitration dispute resolution.
- **Tested**:
  - *Outcome 1 (Normal Delivery)*: Buyer deployed with 1 ETH payment -> Buyer called `confirmDelivery()` -> state became `Complete` and Seller received 1 ETH.
  - *Outcome 2 (Seller Refund)*: Buyer deposited 1 ETH -> Seller called `refundBuyer()` -> state became `Refunded` and Buyer received refund.
  - *Outcome 3 (Dispute to Seller)*: Buyer raised dispute -> state became `Disputed` -> Arbiter called `resolveToSeller()` -> Seller paid.
  - *Outcome 4 (Dispute to Buyer)*: Buyer raised dispute -> Arbiter called `resolveToBuyer()` -> Buyer refunded.
  - *Edge Case*: Calling `confirmDelivery()` while in `Disputed` state reverted with `"Invalid state for this action"`.
- **Ganache proof**: `screenshots/11_compile.png`, `screenshots/11_test1.png`, `screenshots/11_test2.png`

---

## 12 SimpleNFT (`12_SimpleNFT.sol`)
- **What it does**: Standalone ERC-721 inspired non-fungible token collection with unique token IDs, mint price, supply caps, ownership transfers, and approvals.
- **Key concept**: Non-fungible token ownership mappings (`ownerOf`), approval delegation (`approvals`), supply limits (`MAX_SUPPLY`), and administrative treasury withdrawals.
- **Tested**: Account 1 and Account 2 each minted a token paying 0.01 ETH -> minting without exact payment reverted -> Account 1 transferred Token #0 to Account 3 -> verified `ownerOf(0)` updated to Account 3 -> Account 1 approved Account 2 for Token #1 -> Account 2 called `transferFrom` -> transfer completed -> owner withdrew 0.02 ETH mint revenue.
- **Ganache proof**: `screenshots/12_compile.png`, `screenshots/12_test1.png`, `screenshots/12_test2.png`

---

## 13 English Auction (`13_EnglishAuction.sol`)
- **What it does**: Timed competitive auction where bidders submit higher bids, losing bidders pull refunds independently, and the highest bid is awarded to the seller upon expiration.
- **Key concept**: Pull-Payment (withdrawal) pattern, minimum bid increment calculation ($+5\%$), and denial-of-service immunity.
- **Tested**: Started with 0.1 ETH base price -> Bidder A bid 0.11 ETH -> Bidder B bid 0.12 ETH -> Bidder C bid 0.121 ETH -> reverted with `"Bid increment too low (min 5% required)"` -> Bidder A called `withdrawPending()` and received 0.11 ETH back -> time expired -> seller called `endAuction()` and received 0.12 ETH -> subsequent bid reverted with `"Auction has already ended"`.
- **Ganache proof**: `screenshots/13_compile.png`, `screenshots/13_test1.png`, `screenshots/13_test2.png`

### Viva Focus: Pull-Payment Pattern vs Push Payments (Contract 13 vs Contract 05)
In a naive auction design, when Bidder B outbids Bidder A, the contract might attempt to "push" the refund directly to Bidder A inside `bid()`:
```solidity
// UNSAFE PUSH PATTERN:
(bool sent, ) = highestBidder.call{value: highestBid}("");
require(sent, "Refund failed");
```
This is vulnerable to severe **Denial of Service (DoS)** attacks:
- If Bidder A is a malicious contract whose fallback function contains `revert()` or consumes infinite gas, `bid()` will always revert. No one can ever outbid Bidder A, permanently locking the auction.
- Furthermore, pushing ETH during a new bid incurs unpredictable gas costs for the new bidder.

In contrast, the **Pull-Payment Pattern** separates the bid action from the refund action:
- Outbid funds are merely credited to an internal ledger (`pendingReturns[highestBidder] += highestBid`).
- Each bidder independently "pulls" their funds by executing `withdrawPending()`.
- If a bidder's transfer fails, it only impacts their own withdrawal, completely isolating all other auction participants from external failures.

---

## 14 Multi-Signature Wallet (`14_MultisigWallet.sol`)
- **What it does**: M-of-N multi-signature treasury wallet requiring $M$ confirmations out of $N$ authorized owners before executing an arbitrary ETH transfer.
- **Key concept**: Quorum authorization, transaction proposal lifecycle, multi-dimensional confirmation mappings, and automated execution thresholds.
- **Tested**: Deployed with 3 owners (Accounts 1, 2, 3) and `required = 2` confirmations -> funded wallet with 5 ETH -> Account 1 submitted proposal to send 1 ETH to Account 4 (auto-confirmed by Account 1, pending 1/2) -> verified Account 4 balance unchanged -> Account 2 called `confirmTransaction()` -> threshold met -> transaction auto-executed -> Account 4 balance increased by 1 ETH -> non-owner Account 5 attempted to confirm -> reverted with `"Caller is not an authorized owner"` -> Account 1 tried to confirm again -> reverted with `"Transaction already executed"`.
- **Ganache proof**: `screenshots/14_compile.png`, `screenshots/14_test1.png`, `screenshots/14_test2.png`

---

## 15 Staking Rewards (`15_StakingRewards.sol`)
- **What it does**: Continuous yield staking platform where users deposit ETH and accrue rewards second-by-second proportionally to their stake.
- **Key concept**: Per-second accumulator mathematics, reward debt snapshotting, non-reentrant atomic unstaking, and reward pool solvency guarantees.
- **Tested**: Owner deployed with rate = `1000 wei/s` per ETH and funded 5 ETH reward pool -> User A staked 1 ETH, User B staked 2 ETH -> after 60 seconds `pendingReward(User A)` reached $\approx 60,000\text{ wei}$ -> User A called `claimReward()` -> rewards transferred and debt reset -> User B called `unstake()` -> received 2 ETH principal plus all accrued rewards -> User B called `unstake()` a second time -> reverted with `"No staked balance to unstake"`.
- **Ganache proof**: `screenshots/15_compile.png`, `screenshots/15_test1.png`, `screenshots/15_test2.png`

### Viva Focus: Continuous Reward Calculation Formula
To enable high-frequency reward accrual without iterating over arrays or running gas-intensive loops, the contract applies continuous snapshot mechanics:

$$\text{accrued} = \frac{\text{amount} \times \text{rewardRatePerSecond} \times (t_{\text{current}} - t_{\text{start}})}{10^{18}}$$

$$\text{pendingReward} = \text{rewardDebt} + \text{accrued}$$

When a user alters their staked balance (or claims rewards):
1. Any accrued yield up to $t_{\text{current}}$ is added to `rewardDebt`.
2. $t_{\text{start}}$ is updated to $t_{\text{current}}$.
3. Principal amount is adjusted.
This guarantees $O(1)$ constant-time and constant-gas execution regardless of duration or number of stakers.
