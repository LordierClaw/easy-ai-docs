---
schemaVersion: 1
id: codex-atlassian-mcp
version: 1.0.0
name: Atlassian MCP cho Codex
description: Kết nối Jira và Confluence Cloud vào Codex của EasyAI qua OAuth và kiểm chứng một lệnh đọc thật.
tags: [mcp, codex, atlassian, integration]
icon: "🔗"
platform: win32-x64
actions: [install, configure, repair, doctor]
workflows:
  install: workflows/configure.json
  configure: workflows/configure.json
  repair: workflows/configure.json
  doctor: workflows/doctor.json
---
# Atlassian Rovo MCP cho Codex của EasyAI

## Điều kiện

Hoàn thành guide **Cài đặt Codex** trước. Guide dùng đúng `{workspace}/codex/home`, không sửa `~/.codex` cá nhân. Người dùng cần tài khoản Atlassian Cloud có quyền vào site Jira/Confluence; quản trị tổ chức có thể phải cho phép OAuth client.

## Các bước

1. Đọc GUIDE, gọi `prepare_workflow {}` để trình bày kế hoạch. `install`, `configure`, `repair` cùng thêm cấu hình MCP nếu còn thiếu; `doctor` chỉ kiểm tra đăng ký cục bộ.
2. Sau duyệt, gọi `execute_plan {}`. `configure-mcp.ps1` kiểm tra CLI và cấu hình TOML qua chính Codex, sao lưu rồi thêm duy nhất server `atlassian` với URL `https://mcp.atlassian.com/v2/mcp`. Đã đúng thì dùng lại; trùng tên nhưng khác cấu hình thì dừng để đánh giá.
3. Script tạo shortcut **Codex - Atlassian Login** và hiển thị đường dẫn. Khi EasyAI chờ đăng nhập, người dùng mở shortcut này, hoàn tất OAuth trong trình duyệt Atlassian, chọn site/quyền cần thiết. Không yêu cầu nhập mật khẩu, token hoặc mã MFA vào EasyAI.
4. Người dùng bấm xác nhận đăng nhập trong EasyAI. `verify-mcp.ps1` chạy Codex qua launcher, chỉ cho phép tool `getAccessibleAtlassianResources`. Kiểm chứng yêu cầu sự kiện JSON của một MCP tool call thật đã hoàn tất, đúng server/tool, có kết quả không lỗi. Câu trả lời văn bản của AI không đủ để kết luận.
5. Chỉ sau kiểm chứng, hướng dẫn mở **Codex (EasyAI)**, dùng `/mcp` xem server và hỏi **Liệt kê các site Atlassian tôi có quyền truy cập**.

## Ngoại lệ và phạm vi

MCP smoke chỉ đọc danh sách site; không tạo/sửa issue hay trang. Cấu hình bình thường vẫn có các tool Atlassian khác để người dùng sử dụng sau này. OAuth xác nhận chỉ chứng minh người dùng đã thao tác; check sau xác nhận mới chứng minh kết nối hoạt động. `doctor` chỉ xác nhận đăng ký, không xác nhận OAuth hoặc quyền dữ liệu.

Nếu chưa có Codex: giải thích điều kiện và chuyển guide cài Codex. Nếu cấu hình xung đột: đọc bằng chứng, trình bày sửa có backup, không xóa server khác. Nếu OAuth thất bại: kiểm tra domain callback/quyền tổ chức và URL, không cài lại Codex. Không ghi nội dung site hoặc credential vào log. Không tự gửi dữ liệu Atlassian cho bên thứ ba ngoài provider Codex đã chọn để thực hiện kiểm chứng này.

## Nguồn

[OpenAI MCP](https://learn.chatgpt.com/docs/extend/mcp?surface=cli), [Atlassian setup](https://support.atlassian.com/atlassian-ai-gateway/docs/get-started-with-the-atlassian-remote-mcp-server/), [Atlassian tools](https://support.atlassian.com/atlassian-ai-gateway/docs/supported-tools/). Kiểm tra ngày 2026-09-12.
