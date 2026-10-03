# ABI reference

Generated from the successfully compiled primary contract. Includes inherited methods. Authorization and economic semantics are documented in the source.

| Signature | Type | Mutability | Returns |
|---|---|---|---|
| `constructor(address stakeAsset,address rewardAsset,address admin)` | constructor | nonpayable |  |
| `EnforcedPause()` | error |  |  |
| `ExpectedPause()` | error |  |  |
| `OwnableInvalidOwner(address owner)` | error |  |  |
| `OwnableUnauthorizedAccount(address account)` | error |  |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `SafeERC20FailedOperation(address token)` | error |  |  |
| `OwnershipTransferStarted(address previousOwner,address newOwner)` | event |  |  |
| `OwnershipTransferred(address previousOwner,address newOwner)` | event |  |  |
| `Paused(address account)` | event |  |  |
| `RewardPaid(address account,uint256 amount)` | event |  |  |
| `Schedule(uint256 funded,uint256 duration,uint256 rate)` | event |  |  |
| `Staked(address account,uint256 amount)` | event |  |  |
| `Unpaused(address account)` | event |  |  |
| `Withdrawn(address account,uint256 amount)` | event |  |  |
| `acceptOwnership()` | function | nonpayable |  |
| `accrued(address )` | function | view | uint256  |
| `applicableTime()` | function | view | uint256  |
| `claim()` | function | nonpayable |  |
| `currentIndex()` | function | view | uint256  |
| `earned(address account)` | function | view | uint256  |
| `finish()` | function | view | uint256  |
| `idleRewards()` | function | view | uint256  |
| `lastUpdate()` | function | view | uint256  |
| `notify(uint256 amount,uint256 duration)` | function | nonpayable |  |
| `owner()` | function | view | address  |
| `paused()` | function | view | bool  |
| `pendingOwner()` | function | view | address  |
| `renounceOwnership()` | function | nonpayable |  |
| `rewardIndex()` | function | view | uint256  |
| `rewardRate()` | function | view | uint256  |
| `rewardToken()` | function | view | address  |
| `setPaused(bool value)` | function | nonpayable |  |
| `stake(uint256 amount)` | function | nonpayable |  |
| `stakeOf(address )` | function | view | uint256  |
| `stakeToken()` | function | view | address  |
| `totalStaked()` | function | view | uint256  |
| `transferOwnership(address newOwner)` | function | nonpayable |  |
| `userIndex(address )` | function | view | uint256  |
| `withdraw(uint256 amount)` | function | nonpayable |  |
