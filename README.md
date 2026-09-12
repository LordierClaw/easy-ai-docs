# EasyAI Guide Library

Kho hướng dẫn thử nghiệm cho EasyAI 0.4. Mỗi guide là một folder có GUIDE.md, metadata, workflows và scripts tự chứa.

- [Chuẩn GUIDE](GUIDE-STANDARD.md)
- [Catalog v3](content/guides-catalog.json)
- [Runtime manifest](content/runtimes-manifest.json)
- [JSON Schemas](contracts/)
- [Quy trình publish](PUBLISHING.md)
- [Mã ứng dụng và kiến trúc](https://github.com/LordierClaw/easy-ai)

Các guide: Codex, Atlassian MCP cho Codex, Claude Code, Hermes Agent (NousResearch), và workspace note dùng kiểm thử. Claude/Hermes chưa chạy thử cài đặt trong đợt phát triển này. OAuth Atlassian cần người dùng đăng nhập.

Ứng dụng đọc catalog động và ghim commit/hash cho mỗi phiên. Catalog v1/v2 cũ giữ nguyên để client đã phát hành tiếp tục đọc được. Runtime Git/Node portable được phân phối nguyên byte từ nguồn chính thức trong GitHub Releases, kèm checksum và license.

Kho này public. Không thêm API key, token hoặc dữ liệu doanh nghiệp bí mật.
