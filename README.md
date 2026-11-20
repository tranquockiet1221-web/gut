# LocalHub iOS (Không yêu cầu Key)

Dự án ứng dụng iOS viết bằng SwiftUI, mở trực tiếp vào giao diện quản lý thư mục `Mods` mà không qua bước xác thực key.

## Cấu trúc thư mục
- `project.yml`: Tệp cấu hình dùng với XcodeGen để tự động tạo file `.xcodeproj`.
- `LocalHub/LocalHubApp.swift`: Điểm khởi chạy ứng dụng, mở thẳng `ContentView`.
- `LocalHub/Models/ModItem.swift`: Mô hình dữ liệu cho từng tệp trong thư mục `Mods`.
- `LocalHub/Services/ModManager.swift`: Đọc, nhập, xóa và lưu trạng thái bật/tắt của các tệp trong `Documents/Mods` (hỗ trợ chia sẻ tệp qua ứng dụng Tệp/Files trên iOS).
- `LocalHub/Views/ContentView.swift`: Giao diện danh sách, tìm kiếm, nhập tệp và công tắc bật/tắt.
- `LocalHub/Info.plist`: Cấu hình ứng dụng, đã bật `UIFileSharingEnabled` và `LSSupportsOpeningDocumentsInPlace`.
- `LocalHub/Resources/Mods/`: Thư mục chứa tệp cấu hình mẫu được đóng gói sẵn trong bundle.

## Cách tạo dự án Xcode và xuất file `.ipa`

### Cách 1: Tạo tự động bằng XcodeGen (Nhanh nhất)
1. Cài XcodeGen trên macOS: `brew install xcodegen`
2. Mở Terminal tại thư mục giải nén và chạy: `xcodegen generate`
3. Mở file `LocalHub.xcodeproj` vừa được tạo.

### Cách 2: Tạo thủ công trong Xcode
1. Mở Xcode -> **File > New > Project...** -> chọn **iOS > App**.
2. Đặt Product Name là `LocalHub`, Interface chọn **SwiftUI**, Language chọn **Swift**.
3. Kéo thả toàn bộ các thư mục `Models`, `Services`, `Views`, `Resources` và thay thế `LocalHubApp.swift`, `Info.plist` vào dự án.
4. Trong tab **Build Settings** của Target, đảm bảo **Info.plist File** trỏ đúng tới `LocalHub/Info.plist`.

## Xuất file `.ipa` để cài trên iOS 18.7.9
1. Vào tab **Signing & Capabilities**, chọn **Team** (tài khoản Apple ID của bạn) và đặt **Bundle Identifier** duy nhất (ví dụ: `com.tenban.localhub`).
2. Trên thanh chọn thiết bị ở trên cùng, chọn **Any iOS Device (arm64)**.
3. Chọn menu **Product > Archive**.
4. Khi cửa sổ **Organizer** hiện ra, chọn bản Archive -> nhấn **Distribute App** -> chọn **Custom** -> **Development** (hoặc **Ad Hoc**) -> **Export** để lưu file `.ipa`.
