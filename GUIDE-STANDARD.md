# Chuẩn Guide của EasyAI

Guide là một thư mục tự chứa. `GUIDE.md` là điểm vào cho người đọc và AI; metadata dùng cho tìm kiếm/hiển thị, workflow JSON là hợp đồng thực thi, script làm công việc cụ thể. Việc thêm guide không cần sửa danh sách trong ứng dụng.

```text
guides/
  my-tool/
    GUIDE.md
    workflows/
      install.json
      doctor.json
    scripts/
      install.ps1
      verify.ps1
    references/             # tùy chọn
    templates/              # tùy chọn
    assets/                 # tùy chọn
    policy.json             # tùy chọn
```

Ngoài `GUIDE.md`, người viết được tự tổ chức thư mục và tài liệu. Workflow/script chỉ được thực thi khi khai báo đúng hợp đồng; không tự chạy mọi file có trong guide. Không tham chiếu `../`, đường dẫn tuyệt đối hoặc symlink ra ngoài bundle. Tài nguyên binary được giữ bằng encoding base64 trong catalog/cache; không diễn giải ảnh/PDF/binary thành mã hoặc văn bản instruction. Hiện tại giới hạn mỗi file 1 MB, mỗi guide tối đa 100 file, catalog tải tối đa 20 MB. Runtime archive lớn nằm ở release assets riêng.

## Metadata bắt buộc cho guide mới

```yaml
---
schemaVersion: 1
id: my-tool
version: 1.0.0
name: Cài đặt công cụ của tôi
description: Mô tả ngắn kết quả và đối tượng sử dụng.
tags: [ai-agent, coding]
icon: "🛠️"
platform: win32-x64
actions: [install, doctor]
workflows:
  install: workflows/install.json
  doctor: workflows/doctor.json
---
```

`id` ổn định, duy nhất, dùng chữ thường/số/dấu gạch ngang. `version` theo SemVer cho phiên bản nội dung; `schemaVersion` cho phiên bản hợp đồng. `name`, `description`, `tags`, `icon` phục vụ catalog, không chứa lệnh hoặc URL script. Mỗi action khai báo phải có một workflow tương ứng trong thư mục guide. Nhiều action được phép trỏ cùng file khi cùng semantics. Guide cũ không khai báo workflow map còn được đọc qua `workflow.json` để tương thích; tác giả mới luôn dùng map.

| Action | Mục đích | Kỳ vọng |
| --- | --- | --- |
| `install` | Đưa máy về trạng thái có thể dùng | Dùng lại bản cài khỏe, cài phần còn thiếu, kiểm chứng |
| `configure` | Cập nhật cấu hình của công cụ đã có | Giữ dữ liệu, backup trước sửa |
| `doctor` | Thu thập dữ kiện và kiểm tra hiện trạng | `steps: []`; script check chỉ đọc, không cài/sửa |
| `repair` | Sửa lỗi dựa trên hiện trạng | Giữ bước thành công; phạm vi sửa được duyệt lại |

Không bắt buộc mọi guide hỗ trợ đủ bốn action. Chỉ khai báo những action có workflow hữu ích.

## Nội dung GUIDE.md

Viết ngắn, theo thứ tự: **Khi sử dụng / Điều kiện → Các bước → Ngoại lệ → Kiểm chứng → Bắt đầu dùng → Nguồn**. Mỗi bước nêu đầu vào, script/thao tác, dấu hiệu thành công và nhánh khi lỗi. Phân biệt điều kiện thực thi với hướng dẫn xử lý; không giấu luật quan trọng chỉ trong văn xuôi khi engine có thể kiểm tra bằng policy/predicate.

AI phải đọc GUIDE trước, gọi `prepare_workflow {}`, giải thích bằng chứng preflight và kế hoạch. Engine chọn workflow từ action; AI không đoán tên file. Sau duyệt gọi `execute_plan {}`. AI ưu tiên script đã khai báo, chỉ đọc thêm references/script khi cần giải thích hoặc xử lý lỗi; không tải toàn thư mục vào prompt ngay từ đầu. Quyền đọc một tài nguyên không đồng nghĩa quyền chạy nội dung đó.

## Workflow JSON schemaVersion 1

```json
{
  "schemaVersion": 1,
  "completion": "Mở ứng dụng, chọn thư mục dự án và nhập yêu cầu đầu tiên.",
  "preflight": [
    {"id": "system", "title": "Kiểm tra máy", "query": {"operation": "system_info"}}
  ],
  "plan": {
    "summary": "Phạm vi thay đổi cụ thể, nơi ghi file, nguồn tải và cách kiểm chứng.",
    "steps": [
      {"id": "ensure-node", "title": "Chuẩn bị Node.js", "change": {"operation": "ensure_runtime", "runtime": "node", "minVersion": "22.0.0"}},
      {"id": "install-cli", "title": "Cài CLI", "change": {"operation": "guide_script", "path": "scripts/install.ps1", "parameters": {"Prefix": "{workspace}/my-tool"}, "timeout": 600000, "installer": true}}
    ],
    "checks": [
      {"id": "cli-ready", "title": "CLI chạy được", "query": {"operation": "guide_script", "path": "scripts/verify.ps1", "parameters": {"Prefix": "{workspace}/my-tool"}, "timeout": 60000, "installer": false}, "expect": {"field": "code", "operator": "equals", "value": 0}}
    ]
  }
}
```

`preflight` chỉ chứa query có sẵn, ít nhất một mục. `plan.steps` chạy tuần tự, tối đa 30; `checks` bắt buộc, từ 1–30. ID step/check duy nhất trong plan. `completion` là hướng dẫn sử dụng hiển thị sau khi mọi check đạt, không phải kết quả tự chứng nhận. Các predicate hỗ trợ `equals`, `not_equals`, `exists`, `contains`, `gte`, `lt`, `version_lt` trên trường dữ liệu có cấu trúc.

Query preflight gồm `system_info`, `find_executable`, `find_package`, `read_file`, `read_registry`, `http_probe`, `ai_provider`, `codex_provider_status`. Thao tác thay đổi gồm `guide_script`, `ensure_runtime`, `configure_codex_provider`, `write_file`, `edit_toml`, `download`, `powershell`, `process`. Ưu tiên các thao tác có tên rõ; dùng `guide_script` cho logic riêng của công cụ. `powershell` tự sinh là đường xử lý ngoại lệ với phạm vi được duyệt, không phải cách viết workflow mặc định.

Check dùng script cũng nằm trong plan được duyệt. `installer: false` không tự chứng minh script chỉ đọc: tác giả phải bảo đảm không cài/sửa file ở doctor. Preflight không được chạy script tùy ý. Kiểm chứng bắt buộc của workflow không được bỏ đi trong kế hoạch sửa.

## Script contract

- Script PowerShell nằm trong `scripts/*.ps1`, tự chứa, khai báo `param(...)`. Engine lấy nội dung từ bundle đã ghim và truyền tham số đã quote; không sử dụng `$PSScriptRoot` để đọc file cạnh script vì script hiện chạy trong scriptblock. Truyền đường dẫn dữ liệu qua `parameters`.
- `{workspace}` được engine thay bằng vùng quản lý, không tự lấy cwd làm đường dẫn cài. Không ghép input người dùng thành chuỗi lệnh shell. Không ghi/sửa tài khoản khác hoặc công cụ ngoài phạm vi plan.
- Thiết kế idempotent: đọc hiện trạng trước, dùng lại nếu check đạt, sao lưu trước khi ghi. CLI có nhưng lỗi phải cho bằng chứng; không cài đè, reset source hoặc xóa thư mục tự động để che lỗi.
- Thành công `exit 0`; thất bại `throw` hoặc exit khác 0. Luôn kiểm tra `$LASTEXITCODE` sau lệnh native. Output ngắn, rõ bước và bằng chứng, không in credential hoặc dữ liệu doanh nghiệp không cần thiết.
- `installer: true` cho bước có thể cài package hoặc thay dependency để engine áp dụng khóa/marker cài đặt. Timeout phù hợp, tối đa 1.200.000 ms. Bị ngắt không có nghĩa đã rollback.
- File tải trực tiếp qua thao tác `download` phải có SHA-256. Script tải bootstrap cũng kiểm hash và dừng khi lệch. Hash upstream đổi thì cập nhật guide qua review/publish, không fallback bỏ kiểm tra.

## Runtime dùng chung

`ensure_runtime` hỗ trợ `git` và `node`. Resolver dùng bản hệ thống đạt minimum trước; nếu thiếu/quá cũ hoặc Node thiếu npm thì tải bundle khai báo trong easy-ai-docs và kiểm SHA-256. Archive/cache theo phiên bản thuộc vùng EasyAI, không thay PATH user/machine.

Executor cung cấp PATH đã chọn và `EASYAI_RUNTIME_PATH` (các thư mục ngăn bằng dấu chấm phẩy). Script không reset PATH về registry. Launcher lưu `EASYAI_RUNTIME_PATH` khi tạo để chạy được sau khi đóng EasyAI; khi chạy thì prepend các thư mục đó vào PATH của tiến trình. Thiếu Git/Node không phải lý do tự động yêu cầu IT cài nếu resolver có bundle phù hợp.

## Đăng nhập và xác nhận thủ công

Thêm check `userConfirmation` với hướng dẫn rõ app/shortcut/lệnh cần mở. Thêm check thực thi riêng với `afterConfirmation` trỏ ID đó; check sau phải chứng minh trạng thái cần thiết bằng dữ liệu thật. Không coi việc bấm xác nhận là bằng chứng token/quyền truy cập còn hiệu lực. Không đưa OAuth/mật khẩu/MFA vào chat, tool arguments hoặc trace.

Guide Atlassian là ví dụ: ghi cấu hình → mở shortcut đăng nhập → user xác nhận → gọi MCP tool chỉ đọc → xác minh sự kiện tool thành công. Guide Codex là ví dụ kiểm chứng CLI, provider configuration và một câu hỏi API thật. Claude/Hermes ghi rõ giới hạn check và chưa chạy thử cài đặt trong đợt này.

## Publish, version và tính di động

Chạy `npm run docs:validate` để kiểm metadata, map action, workflow, script path và policy. Publisher quét mọi thư mục có `GUIDE.md`; catalog chứa đường dẫn/hash tài nguyên, ghim nội dung theo commit. Tài liệu [publishing.md](publishing.md) mô tả publish kho easy-ai-docs và runtime assets. Mỗi phiên giữ nguyên bundle/digest được tải lúc bắt đầu; cập nhật catalog không thay script giữa phiên. Offline dùng cache đã xác minh.

Khi sửa hành vi, tăng `version`, giữ ID step ổn định nếu semantics giữ nguyên và thêm check cho điều kiện hoàn tất mới. Điểm di chuyển sang agent/ngôn ngữ khác là metadata + workflow + policy + sự kiện/bằng chứng có cấu trúc. Hệ điều hành, runtime resolution, provider/secret, chạy process và UI là adapter; không đưa Electron/TypeScript vào nội dung guide. Engine mới có thể giữ hợp đồng JSON và thay adapter thực thi. Script Windows vẫn là tài nguyên platform cụ thể; chuyển hệ điều hành cần script tương ứng.
