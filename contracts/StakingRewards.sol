// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Checkpoint staking rewards
/// @notice ERC20 staking pool with funded reward schedules, per-user checkpoints and principal-preserving withdrawals.
/// @dev Reference implementation; independent audit required before production.

contract StakingRewards is SuiteBase {
    using SafeERC20 for IERC20;
    IERC20 public immutable stakeToken;
    IERC20 public immutable rewardToken;
    uint256 public totalStaked;
    uint256 public rewardRate;
    uint256 public finish;
    uint256 public lastUpdate;
    uint256 public rewardIndex;
    uint256 public idleRewards;
    mapping(address => uint256) public stakeOf;
    mapping(address => uint256) public userIndex;
    mapping(address => uint256) public accrued;
    event Staked(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);
    event RewardPaid(address indexed account, uint256 amount);
    event Schedule(uint256 funded, uint256 duration, uint256 rate);
    constructor(
        address stakeAsset,
        address rewardAsset,
        address admin
    ) SuiteBase(admin) {
        require(
            stakeAsset.code.length > 0 &&
                rewardAsset.code.length > 0 &&
                stakeAsset != rewardAsset,
            "assets"
        );
        stakeToken = IERC20(stakeAsset);
        rewardToken = IERC20(rewardAsset);
    }
    function applicableTime() public view returns (uint256) {
        return block.timestamp < finish ? block.timestamp : finish;
    }
    function currentIndex() public view returns (uint256) {
        if (totalStaked == 0) return rewardIndex;
        return
            rewardIndex +
            Math.mulDiv(
                (applicableTime() - lastUpdate) * rewardRate,
                1e18,
                totalStaked
            );
    }
    function earned(address account) public view returns (uint256) {
        return
            accrued[account] +
            Math.mulDiv(
                stakeOf[account],
                currentIndex() - userIndex[account],
                1e18
            );
    }
    function _checkpoint(address account) internal {
        uint256 time = applicableTime();
        if (totalStaked == 0) idleRewards += (time - lastUpdate) * rewardRate;
        rewardIndex = currentIndex();
        lastUpdate = time;
        if (account != address(0)) {
            accrued[account] = earned(account);
            userIndex[account] = rewardIndex;
        }
    }
    function notify(
        uint256 amount,
        uint256 duration
    ) external onlyOwner nonReentrant {
        require(duration > 0 && amount >= duration, "schedule");
        _checkpoint(address(0));
        AssetFlow.pullExact(rewardToken, msg.sender, amount);
        uint256 remaining =
            block.timestamp < finish
                ? (finish - block.timestamp) * rewardRate
                : 0;
        rewardRate = (amount + remaining) / duration;
        finish = block.timestamp + duration;
        lastUpdate = block.timestamp;
        emit Schedule(amount, duration, rewardRate);
    }
    function stake(uint256 amount) external nonReentrant whenNotPaused {
        _checkpoint(msg.sender);
        AssetFlow.pullExact(stakeToken, msg.sender, amount);
        stakeOf[msg.sender] += amount;
        totalStaked += amount;
        emit Staked(msg.sender, amount);
    }
    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0 && amount <= stakeOf[msg.sender], "amount");
        _checkpoint(msg.sender);
        stakeOf[msg.sender] -= amount;
        totalStaked -= amount;
        stakeToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
    function claim() external nonReentrant {
        _checkpoint(msg.sender);
        uint256 amount = accrued[msg.sender];
        require(amount > 0, "reward");
        accrued[msg.sender] = 0;
        rewardToken.safeTransfer(msg.sender, amount);
        emit RewardPaid(msg.sender, amount);
    }
}
