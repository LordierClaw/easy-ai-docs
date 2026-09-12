---
schemaVersion: 1
id: setup-claude
version: 1.0.0
name: Cài đặt Claude Code
description: Cài CLI chính thức của Anthropic, tạo shortcut và hướng dẫn đăng nhập tài khoản riêng.
tags: [ai-agent, coding, anthropic]
icon: "✳️"
platform: win32-x64
actions: [install, configure, repair, doctor]
workflows:
  install: workflows/install.json
  configure: workflows/configure.json
  repair: workflows/install.json
  doctor: workflows/doctor.json
---
# Claude Code trên Windows

## Phạm vi

Dùng native installer của Anthropic ở phạm vi user. Binary chính thức ở `%USERPROFILE%/.local/bin/claude.exe`; vùng `{workspace}/claude` giữ bootstrap/launcher của EasyAI. Claude dùng tài khoản và cấu hình Anthropic riêng; không tái sử dụng key EasyAI ngầm. Guide này chưa được chạy thử cài đặt trong đợt phát triển này.

## Các bước

1. Đọc GUIDE rồi `prepare_workflow {}`. Nêu phạm vi cài native, tải binary từ nhà cung cấp và tạo shortcut. Sau duyệt gọi `execute_plan {}`.
2. `ensure-git` dùng Git hệ thống hoặc bundle của EasyAI. Native Claude không cần Node.js. Launcher tìm Git Bash khi có; nếu bundle không có Bash, Claude có thể dùng PowerShell theo tài liệu hiện tại.
3. `install-claude.ps1` dùng lại CLI native chạy được; nếu chưa có, tải `https://claude.ai/install.ps1`, đối chiếu SHA-256 đã ghim trong script rồi chạy target `stable`. Installer Anthropic tự kiểm tra hash binary. Nếu hash bootstrap đổi, dừng để người quản lý cập nhật guide, không bỏ kiểm tra.
4. `configure-launcher.ps1` tạo **Claude Code (EasyAI)** trong Start Menu và giữ PATH runtime. Sao lưu launcher/shortcut trước sửa.
5. Người dùng mở shortcut, hoàn tất đăng nhập trong ứng dụng/trình duyệt chính thức, rồi xác nhận trong EasyAI. Check sau xác nhận dùng `claude auth status` và exit code, không đọc hoặc in credential.
6. Hoàn tất khi CLI và trạng thái đăng nhập đạt. Hướng dẫn mở shortcut và hỏi **Giải thích cấu trúc dự án hiện tại**. Đây là kiểm chứng cài đặt/đăng nhập, chưa kiểm chứng một lượt model trả lời.

## Doctor và sửa lỗi

`doctor` đọc phiên bản CLI, không cài và không buộc đăng nhập. `configure` tạo lại launcher và hướng dẫn đăng nhập cho CLI đã có. `repair` giữ CLI khỏe; không xóa cấu hình cá nhân, token hoặc gỡ cài đặt. AI đọc lỗi thực, phân biệt download/hash, binary, Git Bash và tài khoản. Không vô hiệu hóa TLS hoặc tự chạy installer khác.

## Nguồn

[Anthropic installation](https://code.claude.com/docs/en/installation), [CLI/auth reference](https://code.claude.com/docs/en/cli-reference). Kiểm tra ngày 2026-09-12. Native install có cơ chế cập nhật của nhà cung cấp; bootstrap được ghim hash, binary theo kênh stable tại thời điểm chạy.
