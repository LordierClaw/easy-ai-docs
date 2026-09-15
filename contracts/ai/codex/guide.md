# Codex

Chọn **install** để cài Codex CLI trong workspace do EasyAI quản lý. Cấu hình provider của EasyAI phải có model, baseURL và key; không nhập key vào chat.

## Các bước
1. Kiểm Git >= 2.40 và Node >= 22 có npm. Nếu thiếu, gọi contract runtime portable rồi thử lại bước đang lỗi.
2. Cài hoặc dùng lại CLI trong workspace. Không thay bản cài Codex ở nơi khác.
3. Kiểm TOML hiện tại và cấu hình tạm bằng chính Codex CLI. Giữ các thiết lập không liên quan, backup trước thay đổi. Khóa được mã hóa DPAPI theo tài khoản Windows.
4. Tạo **Codex (EasyAI)** trong Start Menu, hỗ trợ đường dẫn Unicode.
5. Chạy Codex exec với provider thực và yêu cầu EASYAI_OK. Chỉ hoàn tất khi tiến trình thành công và phản hồi đúng.

## Tác vụ
- install, repair: thực hiện toàn bộ chuỗi, dùng lại CLI chạy được.
- configure: cấu hình provider/shortcut và kiểm chứng; cần CLI đã có.
- doctor: báo hiện trạng file/CLI; không cài, sửa hoặc gọi API. Chẩn đoán hoàn tất không có nghĩa công cụ đã sẵn sàng.
- auth: chỉ kiểm chứng kết nối provider đã cấu hình.

## Bắt đầu dùng
Mở Start Menu → **Codex (EasyAI)**. Trong cửa sổ Codex, mở thư mục dự án và thử yêu cầu: “Đọc dự án và giải thích cấu trúc”. Launcher giữ CODEX_HOME, runtime PATH và giải mã credential trong tiến trình; không thay PATH hệ thống.

Nếu kiểm chứng API lỗi, kiểm provider rồi chọn thử lại. Runner giữ các script trước đó đã hoàn tất. input.shortcutDirectory chỉ dùng khi muốn đổi nơi tạo shortcut, chẳng hạn trong bài kiểm thử.
