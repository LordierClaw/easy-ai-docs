# EasyAI Contract Library

Kho nội dung thử nghiệm cho EasyAI 0.5.2. Mỗi công cụ là một contract với contract.json, guide.md và các script PowerShell tự chứa. UI tải metadata động, script quyết định nghiệp vụ; luồng thành công không cần AI.

- [Chuẩn Contract](CONTRACTS.md)
- [JSON Schemas trong repo EasyAI](https://github.com/LordierClaw/easy-ai/tree/main/contracts)
- [Quy trình publish](PUBLISHING.md)
- [Mã ứng dụng và kiến trúc](https://github.com/LordierClaw/easy-ai)

Các contract: Codex, Atlassian MCP cho Codex, Claude Code, Hermes Agent (NousResearch), và workspace note dùng kiểm thử. Claude/Hermes chưa chạy thử cài đặt trong đợt phát triển này. OAuth Atlassian cần người dùng đăng nhập.

Ứng dụng tự khám phá contracts/**/contract.json tại commit đã ghim và tạo index/cache cục bộ. Chỉ cần validate, commit và push; không có catalog hay schema trùng lặp phải publish. SHA-256 chỉ dùng để kiểm cache, không kiểm Git blob hash. Các folder GUIDE, workflow/policy schema và manifest legacy đã được dọn khỏi nhánh hiện tại. Runtime Git/Node portable được phân phối nguyên byte từ nguồn chính thức trong GitHub Releases, kèm checksum và license.

Kho này public. Không thêm API key, token hoặc dữ liệu doanh nghiệp bí mật.

Catalog phổ thông chỉ hiển thị Codex, Claude, Hermes và Atlassian MCP. Contract runtime, context, hỗ trợ IT và ví dụ có hidden: true; vẫn dùng được qua ref, AI và fallback. EasyAI 0.5.1 cần nâng cấp sau khi catalog cũ bị xóa.
