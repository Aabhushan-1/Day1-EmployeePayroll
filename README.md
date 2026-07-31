# Day 1 — EmployeePayroll

A Solidity smart contract that manages employee payroll on-chain.
Built as part of a simulated workplace challenge to practice real-world contract development.

## What it does
- Owner registers employees with a wallet address and monthly salary in ETH
- Owner removes employees
- Owner triggers `runPayroll()` which pays all employees or reverts if funds are insufficient
- No partial payouts — the contract checks total payroll cost before sending a single payment

## Tests
20 tests | 100% line coverage | 100% statement coverage

## How to run

Clone the repo then:

```bash
forge install
forge test
forge coverage
```

## Key concepts practiced
- Checks-Effects-Interactions pattern
- Mapping cleanup on delete
- Correct delete ordering to avoid stale state
- Skipping zero address slots in loops
