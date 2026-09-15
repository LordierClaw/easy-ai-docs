# Ngữ cảnh Windows

EasyAI hiện nhắm Windows x64 và Windows PowerShell 5.1. Script chạy bằng tài khoản hiện tại. Dùng -LiteralPath, quote đường dẫn có dấu/nháy, đọc resource qua $PSScriptRoot và bảo toàn LASTEXITCODE của lệnh native. Không giả định tài khoản có quyền admin. Không sửa PATH hệ thống để thêm runtime portable.

Kiểm hiện trạng trước thay đổi; backup cấu hình; giữ thiết lập không liên quan. Timeout/crash không có nghĩa đã rollback. Sau reboot, mở EasyAI và tiếp tục thủ công. Đây là context chỉ đọc, không có script.
