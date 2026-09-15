# Viết Contract

Một công cụ, một folder, một contract.json và một guide.md. Có thể thêm scripts, references, template, ảnh hoặc resource tùy ý. Folder có contract.json riêng là contract con, không đóng gói chung với cha.

    contracts/ai/my-tool/
      contract.json
      guide.md
      scripts/run.ps1
      resources/settings.json

Metadata tối thiểu:

    { "schema": 1, "name": "My tool", "description": "Mục đích", "scripts": ["scripts/run.ps1"], "actions": ["install", "doctor"] }

Các trường: schema, name, description, icon (emoji hoặc resource), tags, scripts, context, fallback; actions mặc định ["run"] với phần tử đầu là mặc định; hidden mặc định false. Namespace không quyết định hành vi. context có thể là ref tuyệt đối hoặc file trong folder; đọc context không chạy script. Schema editor nằm trong contracts/*.schema.json; validator còn kiểm tham chiếu, tài nguyên và đường dẫn.

Một scripts[] dùng cho mọi action. Mỗi script đọc action, thực hiện hoặc exit 0 để bỏ qua phần không liên quan. Không workflow map, predicates hay mandatory-check DSL. Nên tách preflight, cài đặt, cấu hình, chờ/kiểm chứng để giữ tiến độ khi retry.

## Giao tiếp file

Host cung cấp EASYAI_CONTEXT_PATH, EASYAI_PROBLEM_PATH, EASYAI_ENV_PATH. Context JSON có runId, rootRunId, ref, revision, action, input và paths.workspace/shared/attempt/contract; không có secret. Mỗi lần gọi script có paths.attempt riêng. paths.workspace giữ dữ liệu công cụ; paths.contract chứa tài nguyên đã ghim.

    $ErrorActionPreference='Stop'
    $c=[IO.File]::ReadAllText($env:EASYAI_CONTEXT_PATH) | ConvertFrom-Json
    if($c.action -eq 'doctor'){ Write-Output 'Báo hiện trạng'; exit 0 }
    # Thực hiện và kiểm chứng. Dùng $PSScriptRoot cho resource nội bộ.
    exit 0

Thành công chỉ cần exit 0. stdout/stderr là log, không dùng làm lệnh điều khiển. Với lỗi, exit khác 0; có thể ghi problem JSON để runner biết cách xử lý:

    { "code": "runtime.missing", "message": "Cần Node", "fallback": { "type": "contract", "ref": "/.shared/nodejs", "action": "ensure", "input": { "minVersion": "22.0.0" }, "resume": "retry" } }

Problem có code, message, refs tùy chọn (các contract context), fallback, wait. Nếu problem thiếu/hỏng runner vẫn dùng exit code và log. File problem chỉ có ý nghĩa cho lần chạy hiện tại và khi script lỗi.

wait gồm type text/choice/confirm/reboot, key, message; choice cần options [{label,value}]. Câu trả lời được đưa vào input[key], sau đó runner chạy lại script để kiểm trạng thái thật. Không hỏi secret qua wait/chat. OAuth hoặc reboot không được coi là xong chỉ vì người dùng bấm tiếp tục.

fallback có type contract/choice/message/stop. Contract dùng ref, action/input tùy chọn và resume retry/stop (mặc định stop). Choice có options chứa label và các trường target; không tự chọn. Message dùng message và details là resource văn bản tùy chọn. Chuyển hỗ trợ thành công không làm tác vụ cha hoàn tất. Runner chặn ref đang nằm trong stack và không lặp cùng fallback cho cùng sự cố.

Script thành công có thể ghi môi trường:

    { "pathPrepend": ["C:\\portable\\bin"] }

Các đường dẫn phải là thư mục tuyệt đối tồn tại. Runner truyền sang script sau/contract cha, không sửa PATH hệ thống. JSON môi trường không hợp lệ làm lần chạy thất bại.

## Quy tắc script và guide

- Windows PowerShell 5.1, UTF-8 BOM; dùng -LiteralPath và quote đúng đường dẫn có dấu/nháy.
- Kiểm LASTEXITCODE ngay sau native command. Không để lệnh kiểm tiếp theo che mất mã lỗi.
- Idempotent: kiểm hiện trạng, backup trước thay file; validate file tạm trước publish. Không ghi đè cấu hình không liên quan.
- Doctor chỉ đọc. Phát hiện thiếu công cụ có thể là báo cáo hoàn chỉnh exit 0; lỗi thực thi là nonzero riêng.
- Retry có thể xảy ra sau tác động một phần; không giả định rollback. Không tự reboot hay resume cùng Windows.
- Không tải/chạy resource tùy ý từ prompt. Secret chỉ qua env được host cấp; không in/log hoặc ghi vào context.
- Helper nằm trong folder contract; không cần SDK capability host. Runtime artifact nằm trong resource đã ghim revision.

guide.md là văn bản thường: mục đích → đầu vào/action → các bước → lỗi/wait/fallback → kiểm chứng → cách dùng sau cài. UI đọc được dù không cấu hình AI. Contract không script chỉ hiển thị tài liệu; AI hỗ trợ theo yêu cầu rõ ràng, không tự coi đó là yêu cầu cài đặt.

Chạy docs:validate và test fixture trước publish. Không cần sửa engine để thêm contract.
