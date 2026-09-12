---
schemaVersion: 1
id: setup-hermes
version: 1.0.0
name: Cài đặt Hermes Agent
description: Cài Hermes của Nous Research trong vùng riêng, chuẩn bị CLI và hướng dẫn cấu hình provider.
tags: [ai-agent, nous-research, assistant]
icon: "⚕️"
platform: win32-x64
actions: [install, configure, repair, doctor]
workflows:
  install: workflows/install.json
  configure: workflows/configure.json
  repair: workflows/install.json
  doctor: workflows/doctor.json
---
# Hermes Agent của Nous Research

## Phạm vi và lựa chọn

Tên Hermes trong guide này là **NousResearch/hermes-agent**. Cài CLI cơ bản cùng extra MCP từ source đã ghim commit, theo phương thức manual install chính thức, vào `{workspace}/hermes`. Dùng venv bên ngoài checkout, `HERMES_HOME` riêng và launcher giữ runtime EasyAI. Đây là starter guide; chưa chạy thử cài đặt trong đợt phát triển này.

Hermes hỗ trợ Windows native. Bootstrap chuẩn của hãng còn cài nhiều dependency; guide này chủ động dùng Git/Node của EasyAI, uv/Python riêng, không sửa PATH user/machine. Chưa bao gồm Desktop, browser/WhatsApp bridge, voice, gateway hoặc tác vụ chạy nền. Các tính năng đó cần guide mở rộng và dependency phù hợp.

## Các bước

1. Đọc GUIDE, gọi `prepare_workflow {}`, giải thích tải source GitHub/uv/Python/dependency và phạm vi thư mục. Sau duyệt gọi `execute_plan {}`.
2. `ensure-git`, `ensure-node` chọn bản hệ thống hoặc bundle từ easy-ai-docs. `install-hermes.ps1` tải uv Windows bản cố định, kiểm SHA-256, clone đúng commit Hermes, tạo Python 3.11 + venv riêng và cài CLI với extra MCP. Package phụ thuộc lấy từ PyPI theo metadata của commit đã ghim.
3. Bản cài khỏe được dùng lại. Checkout khác commit, dở dang hoặc thay đổi nội dung thì dừng để AI đánh giá; không reset/xóa source hoặc dữ liệu người dùng.
4. `configure-launcher.ps1` tạo **Hermes Agent (EasyAI)** và **Hermes - Setup** trong Start Menu. Launcher dùng `{workspace}/hermes/home`; không sửa cấu hình Hermes khác.
5. Người dùng mở **Hermes - Setup**, chọn provider/model và hoàn tất đăng nhập/nhập key trong CLI chính thức, rồi xác nhận trong EasyAI. Key không đi qua chat hoặc log EasyAI. Check sau đó dùng `hermes config check`; đó là kiểm chứng cấu trúc cấu hình, không phải model smoke test.
6. Mở **Hermes Agent (EasyAI)** và hỏi **Bạn có thể giúp tôi làm những việc gì?**. Chỉ nói CLI/cấu hình đã đạt các check khai báo; không suy ra mọi tính năng hoặc kết nối model đều đã được thử.

## Ngoại lệ và doctor

`doctor` chỉ kiểm tra CLI có chạy; `configure` tạo lại shortcut cho bản cài sẵn và chạy luồng thiết lập thủ công. Nếu thiếu package, checkout không đúng, mạng/hash/quyền lỗi, AI đọc bằng chứng và đề xuất sửa đúng phần. Không gọi upstream installer để vô tình tải Git/Node khác, không tự bật gateway, không đụng provider EasyAI.

## Nguồn

[Hermes installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation), [Windows native](https://hermes-agent.nousresearch.com/docs/user-guide/windows-native), [Development setup](https://hermes-agent.nousresearch.com/docs/developer-guide/contributing), [Source commit](https://github.com/NousResearch/hermes-agent/tree/a84a2223f82c3d9906fd4a9d778a188774e7a08e). Kiểm tra ngày 2026-09-12.
