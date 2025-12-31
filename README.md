# 🏦 Challenge 5: Over-Collateralized Lending - Speedrun Ethereum

**Bài tập môn Blockchain:** Xây dựng nền tảng cho vay phi tập trung (DeFi Lending Protocol) cho phép người dùng thế chấp ETH để vay Token ERC20, đảm bảo tính thanh khoản thông qua cơ chế thanh lý và thế chấp vượt mức.

**Sinh viên:** 22120165 - Lê Anh Khôi

## 🛠 Tech Stack

- **Framework:** Scaffold-ETH 2
- **Blockchain:** Optimism Sepolia (Testnet)
- **Language:** Solidity (Smart Contract) & TypeScript (Frontend)
- **Core Concepts:** Lending Pools, Over-collateralization (Thế chấp vượt mức), Liquidation Logic (Thanh lý), Price Oracle, Flash Loans (Vay nóng), Leverage (Đòn bẩy).

## 🌟 Cơ chế hoạt động (Game Mechanics)

Dự án mô phỏng một "Ngân hàng DeFi" với các quy tắc tài chính chặt chẽ:

1. **Collateral & Borrowing (Thế chấp & Vay):**

- **Tỉ lệ thế chấp:** 120%. Để vay giá trị 100 $CORN, người dùng phải thế chấp lượng ETH trị giá 120 $CORN.
- **Math Logic:** Sử dụng các hàm Helper (`calculateCollateralValue`, `_calculatePositionRatio`) để liên tục kiểm tra sức khỏe tài chính (Health Factor) của khoản vay dựa trên giá thị trường.
- **Oracle:** Sử dụng Smart Contract `CornDEX` làm nguồn cung cấp giá (Price Feed) quy đổi giữa ETH và CORN.

2. **Liquidation (Cơ chế thanh lý):**

- Khi giá trị tài sản thế chấp giảm, nếu tỉ lệ an toàn xuống dưới 120%, khoản vay bị đánh dấu là "Liquidatable".
- **Incentive:** Bất kỳ ai (Liquidator) cũng có thể trả nợ thay cho người vay và nhận lại tài sản thế chấp (ETH) tương ứng cộng thêm **10% phần thưởng**.

3. **Side Quest 1: Flash Loans (Vay nóng - Đã hoàn thành):**

- Hiện thực hóa tính năng vay không cần thế chấp, miễn là trả lại đủ trong cùng một Transaction.
- **FlashLoanLiquidator:** Bot sử dụng Flash Loan để vay CORN từ pool, thực hiện thanh lý người dùng khác, đổi thưởng ra ETH, trả nợ và giữ lại lợi nhuận mà không cần vốn ban đầu.

4. **Side Quest 2: Leverage (Đòn bẩy - Đã hoàn thành):**

- **Looping:** Tự động hóa quy trình: Nạp ETH -> Vay CORN -> Bán lấy ETH -> Nạp lại ETH.
- Cho phép người dùng mở vị thế (Long position) với đòn bẩy cao hơn số vốn thực có chỉ trong 1 giao dịch.

## 🚀 Hướng dẫn chạy chương trình (How to run)

### 1. Cài đặt (Installation)

Yêu cầu: Node.js (>= 20.17.0) và Yarn.

```bash
git clone https://github.com/theConnectorr/bc-5-over-collateralized-lending
cd bc-5-over-collateralized-lending
yarn install

```

### 2. Cấu hình môi trường (Environment)

Tạo file `.env` (nếu cần) hoặc dùng cấu hình mặc định của Scaffold-ETH 2.

### 3. Deploy Smart Contract

Triển khai hệ thống gồm: `Corn` (Token), `CornDEX` (Oracle), `Lending` (Core), và 2 Bot (`FlashLoanLiquidator`, `Leverage`).

```bash
# 1. Tạo ví deployer & Nạp ETH (nếu chưa có)
yarn generate
yarn account

# 2. Deploy (Sử dụng flag reset để đảm bảo state mới nhất)
yarn deploy --network optimismSepolia --reset

```

### 4. Kiểm thử (Testing)

Chạy bộ test case đã được tối ưu hóa (sử dụng Custom Errors thay vì Require string).

```bash
yarn test

```

### 5. Chạy Frontend

```bash
yarn start

```

Truy cập `http://localhost:3000`.

### 6. Verify Contract

```bash
yarn verify --network optimismSepolia

```

## 📸 Minh chứng hoàn thành (Evidence)

### 1. Live Demo

- **Website URL:** https://challenge-over-collateralized-lendi-delta.vercel.app
- **Lending Contract:** https://sepolia-optimism.etherscan.io/address/0x0718b6522FE1c898692d0C9d5787418BB55584A5

### 2. Các chức năng chính (Screenshots)

- **Lending Dashboard:** Giao diện Deposit ETH và Borrow CORN, hiển thị thanh trạng thái nợ (Health Factor).
- **Liquidation Event:** Minh chứng giao diện hoặc log transaction khi thực hiện thanh lý một tài khoản nợ xấu.
- **Bot Interaction (Debug Tab):** Hình ảnh tương tác với contract `FlashLoanLiquidator` và `Leverage` thông qua tab Debug Contracts để thực hiện các nghiệp vụ nâng cao.
