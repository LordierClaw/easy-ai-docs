# Kiến trúc Contract

Luồng chính: **Contract Repository → Runner → PowerShell**. UI và AI Supervisor dùng cùng runner. Một công cụ là một contract, action chỉ là đầu vào. Không có workflow DSL, capability sản phẩm hoặc bảng ánh xạ guide ID trong engine.

| Phần | Mã nguồn | Trách nhiệm |
|---|---|---|
| Hợp đồng dữ liệu | src/shared/contract.ts, contract-run.ts | Metadata, giao tiếp script, trạng thái và IPC |
| Domain | src/domain/contract.ts | Parse, validate, đường dẫn, digest và tham chiếu |
| Runner | src/application/contract-runner.ts | Thứ tự script, chờ, retry, fallback, history và recovery |
| Ports | src/application/contract-ports.ts | Repository, storage, executor, Supervisor |
| Adapters | src/main/contract-*.ts | GitHub/cache, SQLite, PowerShell, cấu hình và Electron/Pi |
| Nội dung | content/contracts | Toàn bộ logic Git/Node, provider, cài đặt và kiểm chứng |

Composition root là src/main/contract-main.ts. Application/domain không import Electron, Pi, Windows hoặc adapter storage/network. Giữ Electron/TypeScript/Pi; chưa có plugin framework hay MCP client tổng quát. Giao tiếp JSON/file và fixtures là ranh giới để một implementation ngôn ngữ khác thay host sau này.

## Thực thi

start(ref, action, input) lấy catalog, ghim một revision cho toàn bộ cây contract và lưu phiên. Runner gọi scripts tuần tự; exit 0 chuyển ngay bước tiếp theo. Không gọi AI để lập kế hoạch/duyệt script. Câu hỏi thông tin trong chat không tự khởi chạy tác vụ.

Lỗi script → yêu cầu tương tác → fallback contract xác định → AI recovery → fallback cuối. Fallback choice luôn chờ người dùng. Fallback message/stop không chặn AI thử xử lý. Contract con resume:retry khắc phục điều kiện rồi thử lại script cha; resume:stop thành công đưa cha về redirected, không completed.

AI đọc guide, context và bằng chứng; có thể đọc/tìm contract, chạy contract phụ, viết PowerShell recovery riêng hoặc hỏi thông tin. Không chỉnh bundle đã ghim; không có operation bỏ kiểm chứng hay tự hoàn tất. Sau recovery, runner luôn chạy lại script lỗi. Tối đa hai vòng recovery/sự cố, AI ba phút; script hai mươi phút. Worker dừng vẫn chờ native tool đang chạy kết thúc trước khi nhả quyền thực thi.

V1 chỉ một tác vụ thay đổi máy tại một thời điểm. Cancel có hiệu lực giữa script và chặn bước/recovery tiếp theo. Timeout/crash lưu interrupted; không tự rollback/retry. Khi mở lại, running/queued/recovering chuyển interrupted; waiting giữ nguyên và tiếp tục thủ công. Script đã hoàn tất không chạy lại khi retry. Script phải tự kiểm hiện trạng vì lần trước có thể chỉ thực hiện một phần.

## Dữ liệu và tính toàn vẹn

Mỗi lần gọi script có folder context/problem/environment riêng. JSON hỏng/thiếu không biến thành thành công và stdout không phải kênh điều khiển. PATH chỉ truyền giữa các process/contract. Runtime portable do script kiểm checksum/ZIP/version; host không có nhánh Git, Node hoặc Codex.

Catalog phát hiện contract.json từ folder, logical ref lấy từ đường dẫn. GitHub adapter resolve branch thành commit SHA, đọc Git tree, tải đúng phiên bản, validate nội dung rồi tự tạo snapshot; không có catalog publish trên host. Toàn cây con và context giữ cùng revision; tìm kiếm trong recovery cũng dùng snapshot đó. Cache kiểm SHA256 từng file trước nạp, giữ binary, tách folder contract con khỏi resource cha. Giới hạn 100 contract, 100 file/contract, 1 MiB/file, 20 MiB/catalog; runtime lớn nằm ở release ZIP. Offline chỉ dùng snapshot đã kiểm chứng, không âm thầm thay bằng nội dung khác.

contracts.sqlite lưu revision, input, action, script hiện tại, attempts, quan hệ cha–con, log và recovery. contract-cache và contract-attempts là dữ liệu mới. Cleanup chuyển đổi chỉ xử lý tên dữ liệu legacy cụ thể dưới thư mục EasyAI, bỏ qua symlink; không gỡ công cụ/cấu hình/workspace. Chưa có chính sách tự dọn toàn bộ history.

## Quyền và credential

Script/recovery có quyền của tài khoản Windows hiện tại. Đây không phải sandbox. Backup/redaction phục vụ phục hồi và hạn chế lộ secret, không thay thế giới hạn OS. Provider được đọc lúc chạy; secret truyền qua process env, không nằm trong contract/context/prompt/bundle. PowerShell Codex xử lý DPAPI và bảo toàn cấu hình.

Doctor báo hiện trạng mà không cài/sửa; hoàn thành chẩn đoán không đồng nghĩa phần mềm hoạt động. Context-only chỉ hiển thị tài liệu. Hỗ trợ IT hoàn tất không chứng minh mạng/cài đặt đã xong. MCP phải có bằng chứng tool; smoke Codex cần API thật kể cả khi Supervisor bị tắt.
