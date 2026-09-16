# EasyAI Contract Library

Kho nội dung thử nghiệm cho EasyAI 0.5. Mỗi công cụ là một contract với contract.json, guide.md và các script PowerShell tự chứa. UI tải metadata động, script quyết định nghiệp vụ; luồng thành công không cần AI.

- [Chuẩn Contract](CONTRACTS.md)
- [Catalog Contract](content/contracts-catalog.json)
- [JSON Schemas Contract](schemas/contracts/)
- [Quy trình publish](PUBLISHING.md)
- [Mã ứng dụng và kiến trúc](https://github.com/LordierClaw/easy-ai)

Các contract: Codex, Atlassian MCP cho Codex, Claude Code, Hermes Agent (NousResearch), và workspace note dùng kiểm thử. Claude/Hermes chưa chạy thử cài đặt trong đợt phát triển này. OAuth Atlassian cần người dùng đăng nhập.

Ứng dụng đọc catalog động và ghim commit/hash cho mỗi phiên. Các folder GUIDE, workflow/policy schema và manifest legacy đã được dọn khỏi nhánh hiện tại. Runtime Git/Node portable được phân phối nguyên byte từ nguồn chính thức trong GitHub Releases, kèm checksum và license.

Kho này public. Không thêm API key, token hoặc dữ liệu doanh nghiệp bí mật.
