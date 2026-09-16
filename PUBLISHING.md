# Publish Contract

Nguồn mặc định: repo GitHub public LordierClaw/easy-ai-docs, branch main, folder contracts. Không có catalog phải sinh hoặc publish. EasyAI 0.5.2 tự khám phá contract.json qua GitHub API và tạo index trong cache cục bộ.

1. Chép nội dung content/contracts sang contracts của checkout easy-ai-docs, gồm cả .shared.
2. Chạy npm run docs:validate -- --repo <docs-checkout>.
3. Review diff rồi commit và push lên main. Chỉ publish nội dung được phép công khai; không đưa khóa, token hoặc log người dùng lên host.
4. Chạy npm run test:published để kiểm discovery, chạy contract theo ref và cache offline sau restart.

Repository resolve ref thành commit SHA, lấy Git tree tại commit đó và tải tài nguyên qua URL ghim SHA. Kiểm phiên bản, kích thước và cấu trúc nội dung tải về; tính SHA-256 từ byte gốc để kiểm snapshot cache khi đọc lại. Không kiểm Git blob hash và không yêu cầu manifest checksum trên host. Hash cache phát hiện thay đổi sau khi tải, không phải bằng chứng checksum độc lập của nguồn. Chỉ thay cache khi toàn bộ nội dung hợp lệ. Folder có contract.json riêng không được đóng gói vào contract cha; symlink, submodule, đường dẫn sai, tree truncated và cache có hash sai bị từ chối.

Cấu hình nguồn qua EASYAI_CONTRACT_OWNER, EASYAI_CONTRACT_REPO, EASYAI_CONTRACT_REF, EASYAI_CONTRACT_PATH; mặc định lần lượt LordierClaw, easy-ai-docs, main, contracts. EASYAI_CONTRACT_ROOT vẫn chỉ định folder local cho chế độ thử nghiệm. EASYAI_CATALOG_URL đã bỏ. Adapter chỉ hỗ trợ GitHub public, không cần Git hoặc token trên máy người dùng.

Ứng dụng kiểm cập nhật khi khởi động; các yêu cầu catalog tiếp theo cách tối thiểu 10 phút, được gộp khi đồng thời. Không polling nền. Khi commit không đổi, tái sử dụng snapshot đã kiểm. Offline/lỗi/rate limit dùng cache hợp lệ cùng nguồn; chưa có cache thì báo lỗi. Phiên hiện tại, contract con, context và recovery giữ revision ban đầu. Snapshot cũ vẫn đọc được cho retry/lịch sử; pointer catalog cũ không dùng để chọn nguồn mới.

UI chỉ hiển thị contract có hidden: false (mặc định); contract ẩn vẫn có trong index để đọc/chạy theo ref, AI và fallback. Hiện chỉ quảng bá Codex, Claude, Hermes và Atlassian MCP. Context, runtime, hỗ trợ IT và ví dụ vẫn có đầy đủ trên host.

Schema editor được duy trì trong contracts/*.schema.json của repo EasyAI, xuất bằng npm run docs:schemas. Đây là schema dữ liệu, khác folder contracts chứa nội dung trên kho docs; catalog.schema.json ở repo ứng dụng mô tả manifest cache nội bộ. Kho docs không giữ bản sao schema.

Runtime lớn tiếp tục dùng release ZIP đã publish. URL, SHA256, size và version nằm trong resources/artifact.json đã ghim revision của contract Git/Node. Không ghi đè asset runtime đã phát hành. Engine không có logic riêng cho runtime.

EasyAI 0.5.1 cần nâng cấp khi catalog cũ bị xóa khỏi host. Không duy trì song song đường publish cũ. Kho docs chỉ cần contracts/ và tài liệu tác giả; content/contracts-catalog.json cùng schemas/ đã được bỏ.
