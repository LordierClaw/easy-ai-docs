# Publish Contract

Ứng dụng đọc content/contracts-catalog.json trên kho LordierClaw/easy-ai-docs. Kho hiện public: chỉ publish nội dung thử nghiệm có thể công khai, không có khóa, token, log hay dữ liệu người dùng. .local/ của repo ứng dụng là dữ liệu riêng được ignore.

1. Chép các folder trong content/contracts sang contracts của checkout easy-ai-docs, gồm cả .shared.
2. Chạy npm run docs:validate -- --repo <docs-checkout>.
3. Commit nội dung trong kho docs, lấy full SHA 40 ký tự.
4. Chạy npm run docs:prepare -- <SHA> --repo <docs-checkout>. Publisher phát hiện contract.json và đọc đúng byte từ commit, không đọc thay thế từ working tree.
5. Commit content/contracts-catalog.json rồi push cả hai commit.
6. Chạy npm run test:published để kiểm tải, chạy script và cache offline qua ứng dụng.

Phiên mới dùng catalog mới; toàn bộ ref trong phiên hiện tại giữ cùng revision. Hash từng file tính trên byte gốc (kể cả BOM). Binary chỉ base64 trong cache/IPC; file Git vẫn là byte gốc. Folder contract con được loại khỏi tài nguyên cha. Symlink, path traversal, tên trùng không phân biệt hoa thường, reference thiếu và hash sai bị từ chối.

Schema metadata/problem/fallback/wait/catalog nằm trong contracts/ của repo ứng dụng, xuất bằng npm run docs:schemas. Không nhầm folder schema này với folder nội dung contracts của kho docs.

Runtime lớn tiếp tục dùng release ZIP đã publish: MinGit 2.55.0.windows.5 và Node.js 24.21.0 kèm npm. URL, SHA256, size, version nằm trong resources/artifact.json của contract Git/Node. Đổi artifact bằng một revision nội dung mới sau khi kiểm checksum/ZIP/version; không ghi đè asset đã phát hành. Script PowerShell tải/kiểm/cache, engine không biết loại runtime. MinGit không chứa Git Bash.

Catalog GUIDE cũ trên server có thể giữ cho client cũ; EasyAI 0.5 không đọc chúng và không chứa đường thực thi GUIDE.
