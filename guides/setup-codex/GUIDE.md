---
schemaVersion: 1
id: setup-codex
version: 1.0.0
name: Cài đặt Codex
description: Cài Codex CLI, dùng model/API của EasyAI, kiểm tra hoạt động và tạo lối mở nhanh.
tags: [ai-agent, coding, openai]
icon: "💻"
platform: win32-x64
actions: [install, configure, repair, doctor]
workflows:
  install: workflows/install.json
  configure: workflows/configure.json
  repair: workflows/install.json
  doctor: workflows/doctor.json
---
# Cài đặt và chăm sóc Codex CLI

## Khi sử dụng

Guide quản lý Codex tại `{workspace}/codex`. `install` cài và kiểm chứng; `configure` cập nhật provider/launcher của CLI đã có; `repair` phục hồi từ hiện trạng; `doctor` kiểm tra cục bộ, không cài và không gửi prompt tới model.

## Luồng thực hiện

1. Đọc GUIDE này, gọi `prepare_workflow {}`. Engine chọn workflow theo action, chạy preflight và policy, trình bày phạm vi cụ thể. Giải thích ngắn kết quả và dùng cơ chế duyệt kế hoạch của EasyAI.
2. Gọi `execute_plan {}` sau khi kế hoạch được duyệt. Ưu tiên script đã khai báo; không tự sinh lại installer.
3. `ensure-git` và `ensure-node` dùng bản hệ thống đạt Git ≥2.40, Node ≥22 kèm npm. Nếu thiếu/quá cũ, runtime resolver tải bundle từ easy-ai-docs, kiểm tra SHA-256 và dùng trong vùng riêng. Không thay PATH toàn máy. Khi tải lỗi, đọc bằng chứng nguồn/hash/mạng; không tự đổi sang nguồn không được khai báo.
4. `install-cli` chạy `scripts/install-cli.ps1`. Lần cài mới ghim `@openai/codex@0.154.0` từ npm registry chính thức. CLI đã có và khỏe thì dùng lại, giữ phiên bản đang chạy; CLI lỗi thì giữ nguyên hiện trạng để sửa, không cài đè mù quáng.
5. `configure-provider` dùng thao tác engine để lấy đúng model/baseURL/key của EasyAI. `configure-launcher` sao lưu và tạo shortcut **Codex (EasyAI)** với đường dẫn runtime đã chọn.
6. Kiểm chứng bắt buộc: `provider-matches` khớp cấu hình thực; `codex-smoke` kiểm tra Git/Node/CLI rồi gọi `codex exec` qua launcher trong thư mục thử riêng. Chỉ hoàn tất nếu câu trả lời chính xác `EASYAI_OK`.
7. Hiển thị phần **Bắt đầu dùng** bên dưới và kết quả kiểm chứng. Không nói đã sẵn sàng khi smoke test thất bại.

## AI xử lý ngoại lệ

Đọc script và log của bước lỗi. Phân biệt dependency, quyền/proxy, lỗi package, cấu hình TOML, xác thực, model và Responses API. Kế hoạch sửa chỉ gồm phần còn lỗi; giữ bước đã thành công và các check bắt buộc. Không chạy lại installer khi chỉ lỗi cấu hình/kết nối. Tối đa ba vòng sửa cùng lỗi; sau đó dùng mẫu hỗ trợ kèm bằng chứng.

`doctor` không sửa file; nếu phát hiện lỗi thì giải thích và đề xuất chuyển sang `repair` hoặc `configure` với kế hoạch riêng. Không biến chẩn đoán thành cài đặt ngầm.

## Phạm vi cấu hình và hỗ trợ

Launcher đặt `CODEX_HOME={workspace}/codex/home`; không sửa Codex cá nhân ngoài vùng này. Cấu hình TOML được sao lưu, khóa được main mã hóa DPAPI theo tài khoản Windows. Không đưa khóa vào guide, prompt, plan, log hoặc config.toml. Không yêu cầu `codex login` cho provider EasyAI.

Đọc `references/enterprise-policy.md` khi cần giải thích chặn. Mẫu `templates/request-installation.md` dùng cho quyền/hệ điều hành/chính sách; `templates/request-network-access.md` dùng cho mạng. Hiển thị người nhận, tiêu đề và nội dung để người dùng sao chép gửi; không gửi email tự động. HTTP 401/403 không chứng minh chặn mạng. Trong VM, loopback provider phải tồn tại bên trong guest.

## Bắt đầu dùng

Mở **Start Menu → Codex (EasyAI)**. Nhập: **Hãy giải thích cấu trúc thư mục hiện tại và gợi ý bước tiếp theo**. Duyệt các thay đổi Codex đề xuất trước khi áp dụng.

Để chọn dự án khác: gõ `/quit`, dùng `Set-Location 'D:\duong-dan-du-an'` trong cửa sổ PowerShell đang mở, rồi chạy `& ([scriptblock]::Create([IO.File]::ReadAllText('DUONG_DAN_LAUNCHER')))`. Thay `DUONG_DAN_LAUNCHER` bằng đường dẫn `launch-codex.ps1` bước cài đặt hiển thị. Kiểm tra model/cấu hình bằng `/status`.

## Nguồn

[Cấu hình Codex](https://learn.chatgpt.com/docs/config-file/config-advanced), [Codex CLI](https://learn.chatgpt.com/docs/cli), [Package Codex 0.154.0](https://www.npmjs.com/package/@openai/codex/v/0.154.0). Kiểm tra tài liệu/phiên bản ngày 2026-09-12.

