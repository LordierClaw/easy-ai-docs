# Hermes Agent

install/repair kiểm Git, tải uv theo checksum, lấy source Hermes tại commit đã ghim, chuẩn bị Python/venv và cài CLI trong workspace. configure tạo launcher; auth kiểm cấu hình; doctor báo hiện trạng và không cài/sửa.

Mở **Hermes - Setup**, chọn provider/model trong công cụ rồi quay lại EasyAI để tiếp tục. Runner kiểm file cấu hình và hermes config check trước hoàn tất; đây là kiểm cấu hình, không phải smoke API. Sau đó mở **Hermes (EasyAI)** để sử dụng. Không gửi khóa qua chat EasyAI.

Tài nguyên và venv thuộc workspace Hermes; launcher truyền HERMES_HOME và PATH riêng. Bản này mới kiểm metadata và PowerShell; chưa nghiệm thu cài Hermes thực tế trên Windows.
