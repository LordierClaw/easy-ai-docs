# Node.js portable

Contract kỹ thuật, mặc định ensure. Kiểm Node hệ thống và npm cùng runtime → cache hợp lệ → tải ZIP theo resources/artifact.json. Node thiếu npm không được coi là đủ điều kiện. Version, size, SHA256, ZIP và các file cache đều được kiểm trước sử dụng.

Thành công xuất pathPrepend cho runner; không sửa PATH hệ thống. doctor chỉ đọc hiện trạng. Git/Node không phải điều kiện để tải runtime: script dùng PowerShell và HTTP. Khi không có mạng, chỉ dùng cache đạt kiểm chứng; không bỏ qua hash.
