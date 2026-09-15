# Atlassian MCP cho Codex

Contract dùng Codex do EasyAI quản lý. Chọn configure hoặc install. input.codexPrefix có thể chỉ đến một workspace Codex khác đã có launcher EasyAI.

1. Nếu thiếu Codex, hoàn thành /ai/codex install rồi thử lại.
2. Dùng Codex CLI để đọc, kiểm và cập nhật server atlassian tại https://mcp.atlassian.com/v2/mcp. Backup cấu hình trước thay đổi; giữ nguyên provider và các server khác.
3. Mở **Codex - Atlassian Login** trong Start Menu và hoàn tất OAuth với tài khoản được phép truy cập tenant. Chỉ bấm tiếp tục khi đã đăng nhập.
4. Codex gọi getAccessibleAtlassianResources. Chỉ sự kiện item.completed/mcp_tool_call đúng server, tool, trạng thái và không có lỗi mới được chấp nhận. Lời trả lời của AI không phải bằng chứng.

auth kiểm tra lại OAuth và tool; doctor chỉ đọc cấu hình. Chờ đăng nhập không phải trạng thái hoàn tất. Retry sau OAuth không chạy lại script cấu hình đã thành công. Không lưu tên site, dữ liệu tài khoản hoặc kết quả MCP trong log EasyAI.

Sau khi hoàn tất, mở Codex (EasyAI) và yêu cầu một truy vấn Jira/Confluence phù hợp quyền tài khoản. OAuth và quyền tenant cần nghiệm thu với tài khoản thật; không thể chứng minh chỉ bằng việc ghi URL vào TOML.
