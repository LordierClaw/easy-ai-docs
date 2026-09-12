# Xuất bản guide và runtime

Ứng dụng mặc định đọc [catalog v3](https://raw.githubusercontent.com/LordierClaw/easy-ai-docs/main/content/guides-catalog.json). Guide mới được phát hiện từ `guides/<folder>/GUIDE.md`; không phải đăng ký tên guide trong mã ứng dụng. [Chuẩn tác giả](GUIDE-STANDARD.md) và [kiến trúc](ARCHITECTURE.md) mô tả hợp đồng.

## Guide

1. Thêm hoặc chỉnh folder `guides/<id>` trong checkout `easy-ai-docs`. Có thể lấy các mẫu từ `content/guides` của repo ứng dụng.
2. Từ repo ứng dụng, chạy `npm run docs:validate -- --repo <docs-checkout>`. Validator kiểm metadata, workflow của từng action, script, policy, template và giới hạn tài nguyên.
3. Commit nội dung trong kho docs, lấy full commit SHA.
4. Chạy `npm run docs:prepare -- <full-commit-sha> --repo <docs-checkout>`. Publisher liệt kê và đọc đúng byte từ commit đó, tạo `content/guides-catalog.json`; không ghép file đang sửa với file đã commit.
5. Commit catalog rồi push hai commit. Phiên mới lấy bản mới; phiên đang chạy giữ nguyên bản đã ghim. Giữ `content/manifest.json` và `content/guides-manifest.json` cũ cho client trước 0.4.
6. Chạy `npm run test:published` để kiểm tra tải từ GitHub và dùng cache khi offline.

Không đặt credential, token hay dữ liệu người dùng trong repo. Repo `LordierClaw/easy-ai-docs` hiện public; nội dung ở đây là bộ hướng dẫn thử nghiệm nội bộ có thể công khai, không phải tài liệu bí mật. Thư viện public là nguồn tin cậy do người duy trì kiểm soát; AI không thêm URL guide tuỳ ý.

JSON Schemas để editor/ngôn ngữ khác sử dụng nằm trong `contracts/`; chạy `npm run docs:schemas` sau khi thay schema TypeScript. Thêm operation executor mới cần cập nhật schema, adapter, prompt contract và tests rồi phát hành client mới. Thêm guide chỉ dùng operation đã hỗ trợ không cần phát hành lại client.

## Runtime portable

```powershell
npm run runtimes:prepare
npm run runtimes:publish -- --docs-repo <docs-checkout>
# Kiểm tra, commit content/runtimes-manifest.json rồi push kho docs.
```

Prepare tải đúng artifact Git for Windows/Node chính thức đã ghim trong publisher, kiểm checksum và ZIP, lưu dưới `.local/runtime-publication`. Publish tải nguyên byte lên một GitHub release có tag theo phiên bản và chép runtime manifest vào checkout docs. Publisher không ghi đè release đã tồn tại. Khi đổi phiên bản phải cập nhật version, checksum, nguồn và tên tag cùng nhau; giữ license có sẵn trong archive.

Runtime hiện tại: MinGit CLI 2.55.0.windows.5 và Node.js 24.21.0 x64 kèm npm. MinGit không chứa Git Bash; guide Claude xử lý prerequisite đó riêng. Client chỉ tải khi runtime cục bộ/cache không đáp ứng. Không dùng Git clone hoặc npm để bootstrap các runtime này.

Guide asset nhỏ ở Git; runtime ZIP lớn ở Releases. Hash tài nguyên guide được tính trên byte gốc, bao gồm BOM nếu có. Manifest đánh dấu binary bằng `encoding: base64`; nội dung trên GitHub vẫn là byte gốc, chỉ cache/IPC dùng base64.
