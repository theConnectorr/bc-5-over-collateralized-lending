// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Lending } from "./Lending.sol";
import { CornDEX } from "./CornDEX.sol";
import { Corn } from "./Corn.sol";

contract Leverage {
    Lending i_lending;
    CornDEX i_cornDEX;
    Corn i_corn;
    address public owner;

    event LeveragedPositionOpened(address user, uint256 loops);
    event LeveragedPositionClosed(address user, uint256 loops);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor(address _lending, address _cornDEX, address _corn) {
        i_lending = Lending(_lending);
        i_cornDEX = CornDEX(_cornDEX);
        i_corn = Corn(_corn);
        // Approve hết cho các contract kia
        i_corn.approve(address(i_cornDEX), type(uint256).max);
        i_corn.approve(address(i_lending), type(uint256).max);
    }
    
    function claimOwnership() public {
        owner = msg.sender;
    }

    // Mở vị thế đòn bẩy: Loop (Nạp ETH -> Vay CORN -> Bán lấy ETH -> Nạp ETH)
    function openLeveragedPosition(uint256 reserve) public payable onlyOwner {
        uint256 loops = 0;
        // Vòng lặp vô tận, sẽ break khi còn ít tiền
        while (true) {
            uint256 balance = address(this).balance;
            
            // 1. Nạp hết ETH hiện có vào Lending
            i_lending.addCollateral{value: balance}();
            
            // Điều kiện thoát vòng lặp: Nếu số dư nạp vào nhỏ hơn mức dự trữ mong muốn
            if (balance <= reserve) {
                break;
            }
            
            // 2. Tính xem vay được bao nhiêu CORN
            uint256 maxBorrowAmount = i_lending.getMaxBorrowAmount(balance);
            
            // 3. Vay Max
            i_lending.borrowCorn(maxBorrowAmount);
            
            // 4. Bán CORN lấy ETH -> Quay lại đầu vòng lặp
            i_cornDEX.swap(maxBorrowAmount);
            
            loops++;
        }
        emit LeveragedPositionOpened(msg.sender, loops);
    }

    // Đóng vị thế: Loop (Rút ETH -> Mua CORN -> Trả nợ -> Rút ETH)
    function closeLeveragedPosition() public onlyOwner {
        uint256 loops = 0;
        while (true) {
            // 1. Rút lượng ETH tối đa cho phép
            uint256 maxWithdrawable = i_lending.getMaxWithdrawableCollateral(address(this));
            i_lending.withdrawCollateral(maxWithdrawable);
            
            // 2. Bán ETH đó để lấy CORN
            i_cornDEX.swap{value:maxWithdrawable}(maxWithdrawable);
            
            uint256 cornBalance = i_corn.balanceOf(address(this));
            uint256 debt = i_lending.s_userBorrowed(address(this));

            // 3. Trả nợ
            uint256 amountToRepay = cornBalance > debt ? debt : cornBalance;
            
            if (amountToRepay > 0) {
                i_lending.repayCorn(amountToRepay);
            } else {
                // Nếu hết nợ hoặc không còn gì để trả, bán nốt CORN lẻ ra ETH rồi nghỉ
                i_cornDEX.swap(i_corn.balanceOf(address(this)));
                break;
            }
            loops++;
        }
        emit LeveragedPositionClosed(msg.sender, loops);
    }
    
    // Rút tiền về ví thật của mình
    function withdraw() public onlyOwner {
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }

    receive() external payable {}
}