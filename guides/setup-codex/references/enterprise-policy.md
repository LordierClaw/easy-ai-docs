# Chính sách Codex trong EasyAI

- Dùng Git ≥2.40, Node ≥22 và npm hệ thống nếu phù hợp; thiếu hoặc quá cũ thì `ensure_runtime` lấy bundle được khai báo từ easy-ai-docs. Chỉ sửa PATH trong tiến trình và lưu đường dẫn runtime vào launcher.
- Chạy bằng user thường trên Windows x64 build ≥19045. Không tự nâng quyền hay sửa proxy/firewall/TLS của Windows.
- CLI, provider và launcher dùng vùng EasyAI quản lý. Sao lưu trước khi sửa. Không tác động Codex cá nhân bên ngoài.
- Provider/model/key lấy từ EasyAI; DPAPI bảo vệ khóa, AI/renderer không nhận khóa.
- Cài đặt chỉ hoàn tất sau kiểm chứng CLI và API trả đúng EASYAI_OK. Doctor chỉ xác nhận trạng thái cục bộ, không thay thế smoke test API.
- Nếu bundle/hash/mạng/quyền thất bại, giữ log có lọc secret và dùng mẫu hỗ trợ. Người dùng tự gửi email.
- Policy và workflow phải thuộc cùng bundle đã ghim cho phiên; AI không thay chính sách để vượt lỗi.

