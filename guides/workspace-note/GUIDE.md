---
schemaVersion: 1
id: workspace-note
version: 1.0.0
name: Tạo ghi chú làm việc
description: Tạo file ghi chú trong vùng làm việc riêng và kiểm chứng nội dung; không cài phần mềm.
tags: [example, workspace]
icon: "📝"
platform: win32-x64
actions: [install, configure, repair, doctor]
workflows:
  install: workflows/install.json
  configure: workflows/install.json
  repair: workflows/install.json
  doctor: workflows/doctor.json
---
# Tạo ghi chú làm việc

Không cần Git, Node, Codex hay kiểm tra phần mềm khác. Sau khi đọc GUIDE.md, gọi `prepare_workflow {}` để engine chọn workflow theo action. Đọc `references/note.md` khi cần giải thích nội dung ghi chú.

Workflow install/configure/repair ghi `{workspace}/welcome.txt`, nội dung chính xác `EASYAI_OK`, có backup. Doctor chỉ đọc và kiểm chứng nội dung, không sửa file.

Sau duyệt gọi `execute_plan {}` để chạy script/thao tác đã khai báo và kiểm chứng độc lập. Nếu bước đã hoàn tất, không chạy lại. Chỉ báo sẵn sàng khi check đạt. AI xử lý ngoại lệ dựa trên bằng chứng quyền/file, không kéo dependency không liên quan.
