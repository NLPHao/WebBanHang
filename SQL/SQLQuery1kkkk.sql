CREATE DATABASE BANHANG
GO
USE BANHANG
GO

-- 1. T?o b?ng Vai trò (Qu?n lý phân quy?n: Admin, Nhan vien, Khach hang)
CREATE TABLE vai_tro (
    id_vai_tro INT IDENTITY(1,1) PRIMARY KEY not null,
    ten_vai_tro VARCHAR(50) NOT NULL, -- Ví d?: Quan tri vien, Khach hang
    mo_ta VARCHAR(255)
);

-- 2. T?o b?ng Ng??i dùng (Tài kho?n ??ng nh?p)
-- Liên k?t v?i b?ng vai_tro
CREATE TABLE nguoi_dung (
    id_nguoi_dung NVARCHAR(50) PRIMARY KEY not null,
    tai_khoan VARCHAR(50) NOT NULL UNIQUE,
    mat_khau VARCHAR(255) NOT NULL, -- L?u chu?i mã hóa hash
    ho_ten VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    so_dien_thoai VARCHAR(15),
    dia_chi VARCHAR(255),
    id_vai_tro INT NOT NULL,
    ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
	anh_dai_dien NVARCHAR (100),
    FOREIGN KEY (id_vai_tro) REFERENCES vai_tro(id_vai_tro)
);

-- 3. T?o b?ng Danh m?c s?n ph?m (Ví d?: Dien thoai, Laptop, Tu lanh)
CREATE TABLE danh_muc (
    id_danh_muc INT IDENTITY(1,1) PRIMARY KEY,
    ten_danh_muc VARCHAR(100) NOT NULL,
    id_danh_muc_cha INT, -- Ví d?: 'iPhone' thu?c cha là 'Dien thoai'
);

-- 4. T?o b?ng Th??ng hi?u (Ví d?: Samsung, Apple, Sony)
CREATE TABLE thuong_hieu (
    id_thuong_hieu INT IDENTITY(1,1) PRIMARY KEY,
    ten_thuong_hieu VARCHAR(100) NOT NULL,
    hinh_anh_logo VARCHAR(255)
);

-- 5. T?o b?ng S?n ph?m (B?ng trung tâm)
-- Liên k?t v?i: danh_muc, thuong_hieu
CREATE TABLE san_pham (
    id_san_pham INT IDENTITY(1,1) PRIMARY KEY,
    ten_san_pham VARCHAR(200) NOT NULL,
    gia_ban DECIMAL(15, 0) NOT NULL, -- Giá ti?n VN?
    gia_khuyen_mai DECIMAL(15, 0),
    so_luong_ton INT DEFAULT 0,
    mo_ta_chi_tiet NVARCHAR(100),
    hinh_anh_dai_dien VARCHAR(255),
    id_danh_muc INT NOT NULL,
    id_thuong_hieu INT,
    trang_thai BIT DEFAULT 1, -- 1: ?ang bán, 0: Ng?ng kinh doanh
    FOREIGN KEY (id_danh_muc) REFERENCES danh_muc(id_danh_muc),
    FOREIGN KEY (id_thuong_hieu) REFERENCES thuong_hieu(id_thuong_hieu)
);

-- 7. T?o b?ng Thông s? k? thu?t (Quan tr?ng cho ?i?n máy)
-- Giúp phân bi?t RAM/CPU (Laptop) v?i Dung tích/Inverter (T? l?nh)
-- Liên k?t v?i: san_pham
CREATE TABLE thong_so_ky_thuat (
    id_thong_so INT IDENTITY(1,1) PRIMARY KEY,
    id_san_pham INT NOT NULL,
    ten_thong_so VARCHAR(50) NOT NULL, -- Ví d?: "RAM", "Dung tích"
    gia_tri VARCHAR(100) NOT NULL,     -- Ví d?: "8GB", "200 Lít"
    FOREIGN KEY (id_san_pham) REFERENCES san_pham(id_san_pham) ON DELETE CASCADE
);

-- 8. T?o b?ng ??n hàng
-- Liên k?t v?i: nguoi_dung
CREATE TABLE don_hang (
    id_don_hang NVARCHAR(50) PRIMARY KEY not null,
    id_nguoi_dung NVARCHAR(50) NOT NULL, -- Khách hàng mua
    ngay_dat_hang DATETIME DEFAULT CURRENT_TIMESTAMP,
    tong_tien DECIMAL(15, 0) NOT NULL,
    trang_thai_don_hang VARCHAR(50) DEFAULT 'Cho xu ly', -- Cho xu ly, Dang giao, Da giao, Da huy
    dia_chi_giao_hang VARCHAR(255) NOT NULL,
    so_dien_thoai_nhan VARCHAR(15) NOT NULL,
    ghi_chu NVARCHAR(100),
    FOREIGN KEY (id_nguoi_dung) REFERENCES nguoi_dung(id_nguoi_dung)
);

-- 9. T?o b?ng Chi ti?t ??n hàng (L?u s?n ph?m trong ??n)
-- Liên k?t v?i: don_hang, san_pham
CREATE TABLE chi_tiet_don_hang (
    id_chi_tiet INT IDENTITY(1,1) PRIMARY KEY,
    id_don_hang NVARCHAR(50) NOT NULL,
    id_san_pham INT NOT NULL,
    so_luong INT NOT NULL,
    don_gia DECIMAL(15, 0) NOT NULL, -- Giá t?i th?i ?i?m mua (?? tránh giá sp thay ??i sau này)
    FOREIGN KEY (id_don_hang) REFERENCES don_hang(id_don_hang) ON DELETE CASCADE,
    FOREIGN KEY (id_san_pham) REFERENCES san_pham(id_san_pham)
);

USE BANHANG
GO

USE BANHANG
GO

-- 1. Thêm dữ liệu VAI TRÒ
-- ID tự tăng nên không cần nhập
INSERT INTO vai_tro (ten_vai_tro, mo_ta) VALUES 
(N'Quản trị viên', N'Admin hệ thống, toàn quyền quản lý'),
(N'Nhân viên', N'Nhân viên bán hàng, xử lý đơn'),
(N'Khách hàng', N'Người dùng mua sắm');
GO

-- 2. Thêm dữ liệu NGƯỜI DÙNG
-- Vì id_nguoi_dung là VARCHAR nên ta tự đặt mã (VD: U01, U02...)
INSERT INTO nguoi_dung (id_nguoi_dung, tai_khoan, mat_khau, ho_ten, email, so_dien_thoai, dia_chi, id_vai_tro, anh_dai_dien) VALUES 
('U01', 'admin', '123456', N'Nguyễn Văn Admin', 'admin@shop.com', '0901111111', N'Hà Nội', 1, 'admin.jpg'),
('U02', 'staff01', '123456', N'Trần Thị Nhân Viên', 'staff@shop.com', '0902222222', N'Đà Nẵng', 2, 'staff.jpg'),
('U03', 'khachhangA', '123456', N'Lê Văn Khách', 'khacha@gmail.com', '0903333333', N'TP. Hồ Chí Minh', 3, 'user1.jpg'),
('U04', 'khachhangB', '123456', N'Phạm Thị Mua', 'khachb@gmail.com', '0904444444', N'Cần Thơ', 3, 'user2.jpg');
GO

-- 3. Thêm dữ liệu DANH MỤC
INSERT INTO danh_muc (ten_danh_muc, id_danh_muc_cha) VALUES 
(N'Điện thoại', NULL),      -- ID sẽ là 1
(N'Laptop', NULL),          -- ID sẽ là 2
(N'Điện lạnh', NULL),       -- ID sẽ là 3
(N'Tủ lạnh', 3),            -- ID sẽ là 4 (Con của Điện lạnh)
(N'Máy giặt', 3);           -- ID sẽ là 5 (Con của Điện lạnh)
GO

-- 4. Thêm dữ liệu THƯƠNG HIỆU
INSERT INTO thuong_hieu (ten_thuong_hieu, hinh_anh_logo) VALUES 
(N'Apple', 'logo_apple.png'),
(N'Samsung', 'logo_samsung.png'),
(N'Dell', 'logo_dell.png'),
(N'LG', 'logo_lg.png'),
(N'Sony', 'logo_sony.png'),    -- ID sẽ là 5
(N'Xiaomi', 'logo_xiaomi.png'), -- ID sẽ là 6
(N'Asus', 'logo_asus.png');     -- ID sẽ là 7
GO

-- 5. Thêm dữ liệu SẢN PHẨM
-- Giả sử ID danh mục và thương hiệu theo thứ tự insert bên trên
INSERT INTO san_pham (ten_san_pham, gia_ban, gia_khuyen_mai, so_luong_ton, mo_ta_chi_tiet, hinh_anh_dai_dien, id_danh_muc, id_thuong_hieu) VALUES 
-- Sản phẩm 1
(N'iPhone 15 Pro Max 256GB', 34990000, 33990000, 50, N'Màn hình Super Retina XDR, khung Titan, chip A17 Pro mạnh mẽ.', 'iphone15pm.jpg', 1, 1),
-- Sản phẩm 2
(N'Samsung Galaxy S24 Ultra', 31990000, 30000000, 45, N'Tích hợp Galaxy AI, bút S-Pen, camera 200MP.', 's24ultra.jpg', 1, 2),
-- Sản phẩm 3
(N'Laptop Dell XPS 13', 45000000, 42000000, 10, N'Laptop doanh nhân cao cấp, thiết kế mỏng nhẹ, màn hình vô cực.', 'dellxps.jpg', 2, 3),
-- Sản phẩm 4
(N'Tủ lạnh LG Inverter', 22000000, 19900000, 20, N'Tủ lạnh Side by Side, công nghệ Door-in-Door, tiết kiệm điện.', 'tulanh_lg.jpg', 4, 4),-- === ĐIỆN THOẠI (4 sản phẩm) ===
-- ID 5
(N'iPhone 13 128GB', 15990000, 13990000, 100, N'Thiết kế vuông vức, camera chéo độc đáo, chip A15 Bionic.', 'iphone13.jpg', 1, 1),
-- ID 6
(N'Samsung Galaxy Z Flip5', 25990000, 19990000, 30, N'Điện thoại gập vỏ sò thời thượng, màn hình phụ Flex Window lớn.', 'zflip5.jpg', 1, 2),
-- ID 7
(N'Xiaomi 13T Pro 5G', 16990000, 15490000, 40, N'Camera Leica chuyên nghiệp, màn hình 144Hz siêu mượt.', 'xiaomi13t.jpg', 1, 6),
-- ID 8
(N'Sony Xperia 1 V', 29990000, NULL, 15, N'Màn hình 4K OLED tỉ lệ 21:9, cảm biến Exmor T chuẩn điện ảnh.', 'sony_xperia.jpg', 1, 5),

-- === LAPTOP (4 sản phẩm) ===
-- ID 9
(N'MacBook Air M2 13 inch', 27990000, 24990000, 50, N'Thiết kế hoàn toàn mới, chip M2 mạnh mẽ, pin 18 tiếng.', 'macairm2.jpg', 2, 1),
-- ID 10
(N'Asus TUF Gaming F15', 21990000, 19490000, 25, N'Laptop Gaming bền bỉ chuẩn quân đội, RTX 3050, màn hình 144Hz.', 'asustuf.jpg', 2, 7),
-- ID 11
(N'Dell Vostro 3510', 14990000, 11990000, 60, N'Laptop văn phòng bền bỉ, màn hình lớn 15.6 inch, bàn phím số.', 'dellvostro.jpg', 2, 3),
-- ID 12
(N'Asus Zenbook 14 OLED', 24990000, 22990000, 20, N'Màn hình OLED 2.8K rực rỡ, thiết kế siêu mỏng nhẹ.', 'zenbook14.jpg', 2, 7),

-- === TỦ LẠNH (4 sản phẩm) ===
-- ID 13
(N'Tủ lạnh Samsung Bespoke', 35000000, 32000000, 10, N'Thiết kế linh hoạt, màu sắc tùy chọn, giữ thực phẩm tươi ngon.', 'samsung_bespoke.jpg', 4, 2),
-- ID 14
(N'Tủ lạnh LG Inverter 315L', 9900000, 8500000, 40, N'Công nghệ Linear Cooling, luồng khí lạnh đa chiều.', 'lg_315l.jpg', 4, 4),
-- ID 15
(N'Tủ lạnh Samsung Inverter 380L', 14500000, 12000000, 25, N'Hai dàn lạnh độc lập Twin Cooling Plus, ngăn đông mềm.', 'samsung_380l.jpg', 4, 2),
-- ID 16
(N'Tủ lạnh LG Side By Side 600L', 25000000, 21500000, 15, N'Cửa phụ Door-in-Door tiện lợi, lấy nước ngoài kháng khuẩn.', 'lg_sidebyside.jpg', 4, 4),

-- === MÁY GIẶT (4 sản phẩm) ===
-- ID 17
(N'Máy giặt LG AI DD 9kg', 10500000, 8900000, 35, N'Cảm biến AI bảo vệ sợi vải, giặt hơi nước diệt khuẩn.', 'lg_aidd.jpg', 5, 4),
-- ID 18
(N'Máy giặt Samsung AddWash 10kg', 12900000, 10500000, 20, N'Cửa phụ thêm đồ khi giặt, công nghệ EcoBubble tạo bong bóng.', 'samsung_addwash.jpg', 5, 2),
-- ID 19
(N'Máy giặt LG Inverter 11kg', 14200000, 12800000, 15, N'Động cơ truyền động trực tiếp bền bỉ, TurboWash giặt nhanh.', 'lg_11kg.jpg', 5, 4),
-- ID 20
(N'Máy giặt Samsung cửa trên 9kg', 6500000, 5200000, 50, N'Mâm giặt Wobble chống xoắn rối, hộp đánh tan bột giặt.', 'samsung_topload.jpg', 5, 2);
GO

-- 6. Thêm dữ liệu THÔNG SỐ KỸ THUẬT
-- ID sản phẩm tự tăng bắt đầu từ 1
INSERT INTO thong_so_ky_thuat (id_san_pham, ten_thong_so, gia_tri) VALUES 
-- Thông số cho iPhone (ID=1)
(1, N'Màn hình', N'6.7 inch OLED'),
(1, N'RAM', N'8GB'),
(1, N'Bộ nhớ trong', N'256GB'),
-- Thông số cho Dell XPS (ID=3)
(3, N'CPU', N'Intel Core i7 1360P'),
(3, N'RAM', N'16GB'),
(3, N'Ổ cứng', N'512GB SSD'),
-- Thông số cho Tủ lạnh LG (ID=4)
(4, N'Dung tích', N'635 Lít'),
(4, N'Công nghệ', N'Inverter'),
-- iPhone 13 (ID 5)
(5, N'Màn hình', N'6.1 inch OLED'), (5, N'Chip', N'Apple A15'), (5, N'Pin', N'3240 mAh'),
-- Z Flip 5 (ID 6)
(6, N'Màn hình', N'6.7 inch & 3.4 inch'), (6, N'Chip', N'Snapdragon 8 Gen 2'), (6, N'RAM', N'8 GB'),
-- Xiaomi 13T (ID 7)
(7, N'Màn hình', N'144Hz AMOLED'), (7, N'Sạc nhanh', N'120W'), (7, N'Camera', N'Leica 50MP'),
-- Sony Xperia (ID 8)
(8, N'Màn hình', N'4K HDR OLED'), (8, N'Âm thanh', N'Hi-Res Audio'), (8, N'Chống nước', N'IP65/68'),

-- Macbook Air M2 (ID 9)
(9, N'CPU', N'Apple M2'), (9, N'RAM', N'8GB'), (9, N'SSD', N'256GB'),
-- Asus TUF (ID 10)
(10, N'CPU', N'Intel Core i5 11400H'), (10, N'VGA', N'RTX 3050 4GB'), (10, N'Màn hình', N'144Hz'),
-- Dell Vostro (ID 11)
(11, N'CPU', N'Intel Core i5 1135G7'), (11, N'RAM', N'8GB'), (11, N'Trọng lượng', N'1.69 kg'),
-- Asus Zenbook (ID 12)
(12, N'Màn hình', N'2.8K OLED'), (12, N'CPU', N'Intel Core i5 1240P'), (12, N'Vỏ', N'Kim loại nguyên khối'),

-- Tủ lạnh Samsung Bespoke (ID 13)
(13, N'Dung tích', N'323 Lít'), (13, N'Kiểu tủ', N'Ngăn đá dưới'), (13, N'Công nghệ', N'Bespoke linh hoạt'),
-- Tủ lạnh LG 315L (ID 14)
(14, N'Dung tích', N'315 Lít'), (14, N'Công nghệ', N'Smart Inverter'), (14, N'Tiện ích', N'Lấy nước ngoài'),
-- Tủ lạnh Samsung 380L (ID 15)
(15, N'Dung tích', N'380 Lít'), (15, N'Công nghệ', N'Twin Cooling Plus'), (15, N'Ngăn đông', N'Ngăn đông mềm -1 độ'),
-- Tủ lạnh LG Side by Side (ID 16)
(16, N'Dung tích', N'601 Lít'), (16, N'Công nghệ', N'Linear Inverter'), (16, N'Tiện ích', N'Door-in-Door'),

-- Máy giặt LG AI (ID 17)
(17, N'Khối lượng', N'9 Kg'), (17, N'Động cơ', N'Truyền động trực tiếp'), (17, N'Công nghệ', N'AI DD bảo vệ vải'),
-- Máy giặt Samsung AddWash (ID 18)
(18, N'Khối lượng', N'10 Kg'), (18, N'Tốc độ quay', N'1400 vòng/phút'), (18, N'Tiện ích', N'Cửa phụ AddWash'),
-- Máy giặt LG 11kg (ID 19)
(19, N'Khối lượng', N'11 Kg'), (19, N'Công nghệ', N'TurboWash 360'), (19, N'Giặt hơi nước', N'Steam+'),
-- Máy giặt Samsung Cửa trên (ID 20)
(20, N'Khối lượng', N'9 Kg'), (20, N'Lồng giặt', N'Kim cương'), (20, N'Công nghệ', N'Wobble chống xoắn');
GO

-- 7. Thêm dữ liệu ĐƠN HÀNG
-- Vì id_don_hang là VARCHAR nên ta tự đặt mã (VD: DH001)
-- id_nguoi_dung lấy từ bảng nguoi_dung (U03, U04)
INSERT INTO don_hang (id_don_hang, id_nguoi_dung, ngay_dat_hang, tong_tien, trang_thai_don_hang, dia_chi_giao_hang, so_dien_thoai_nhan, ghi_chu) VALUES 
('DH001', 'U03', GETDATE(), 33990000, N'Đã giao', N'123 Lê Lợi, TP.HCM', '0903333333', N'Giao giờ hành chính'),
('DH002', 'U04', GETDATE(), 67000000, N'Chờ xử lý', N'456 Ninh Kiều, Cần Thơ', '0904444444', N'Gọi trước khi giao');
GO

-- 8. Thêm dữ liệu CHI TIẾT ĐƠN HÀNG
-- Liên kết Đơn hàng với Sản phẩm
INSERT INTO chi_tiet_don_hang (id_don_hang, id_san_pham, so_luong, don_gia) VALUES 
-- Đơn DH001 mua 1 cái iPhone
('DH001', 1, 1, 33990000),
-- Đơn DH002 mua 1 cái Laptop Dell và 1 cái Tủ lạnh
('DH002', 3, 1, 45000000),
('DH002', 4, 1, 22000000);
GO

USE BANHANG
GO

CREATE PROCEDURE sp_DangKyTaiKhoan
    @TaiKhoan VARCHAR(50),
    @MatKhau VARCHAR(255), -- Lưu ý: Nên hash mật khẩu trước khi truyền vào đây
    @HoTen NVARCHAR(100),
    @Email VARCHAR(100),
    @SoDienThoai VARCHAR(15),
    @DiaChi NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 1. KIỂM TRA TÀI KHOẢN VÀ EMAIL ĐÃ TỒN TẠI CHƯA
    IF EXISTS (SELECT 1 FROM nguoi_dung WHERE tai_khoan = @TaiKhoan)
    BEGIN
        SELECT -1 AS KetQua, N'Tên tài khoản đã tồn tại.' AS ThongBao;
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM nguoi_dung WHERE email = @Email)
    BEGIN
        SELECT -2 AS KetQua, N'Email này đã được sử dụng.' AS ThongBao;
        RETURN;
    END

    -- 2. TỰ ĐỘNG SINH MÃ NGƯỜI DÙNG (Format: U + số)
    DECLARE @MaxID INT;
    DECLARE @NewIDString VARCHAR(10);

    -- Lấy số lớn nhất hiện tại từ chuỗi 'U01', 'U02'... (Cắt bỏ chữ 'U' rồi chuyển sang số)
    SELECT @MaxID = MAX(CAST(SUBSTRING(id_nguoi_dung, 2, LEN(id_nguoi_dung)) AS INT)) 
    FROM nguoi_dung 
    WHERE id_nguoi_dung LIKE 'U%';

    -- Nếu chưa có ai, bắt đầu là 1, ngược lại cộng thêm 1
    IF @MaxID IS NULL SET @MaxID = 0;
    
    -- Tạo mã mới (Ví dụ: U05) - Dùng RIGHT để thêm số 0 đằng trước nếu cần
    SET @NewIDString = 'U' + RIGHT('0' + CAST(@MaxID + 1 AS VARCHAR(10)), 2);

    -- 3. THIẾT LẬP CÁC GIÁ TRỊ MẶC ĐỊNH
    DECLARE @IdVaiTroKhachHang INT = 3; -- ID 3 là Khách hàng (theo data mẫu của bạn)
    DECLARE @AnhDaiDienMacDinh NVARCHAR(100) = 'default_user.jpg';

    -- 4. THÊM VÀO BẢNG NGƯỜI DÙNG
    BEGIN TRY
        INSERT INTO nguoi_dung (
            id_nguoi_dung, 
            tai_khoan, 
            mat_khau, 
            ho_ten, 
            email, 
            so_dien_thoai, 
            dia_chi, 
            id_vai_tro, 
            ngay_tao, 
            anh_dai_dien
        )
        VALUES (
            @NewIDString, 
            @TaiKhoan, 
            @MatKhau, 
            @HoTen, 
            @Email, 
            @SoDienThoai, 
            @DiaChi, 
            @IdVaiTroKhachHang, 
            GETDATE(), 
            @AnhDaiDienMacDinh
        );

        -- Trả về kết quả thành công
        SELECT 1 AS KetQua, 
               N'Đăng ký thành công!' AS ThongBao, 
               @NewIDString AS IdNguoiDungMoi;
    END TRY
    BEGIN CATCH
        -- Báo lỗi hệ thống nếu có
        SELECT -99 AS KetQua, N'Lỗi hệ thống: ' + ERROR_MESSAGE() AS ThongBao;
    END CATCH
END;
GO

USE BANHANG
GO




-- Sửa đổi thủ tục (Dùng ALTER thay vì CREATE)
ALTER PROCEDURE sp_DangKyTaiKhoan
    @TaiKhoan VARCHAR(50),
    @MatKhau VARCHAR(255),
    @HoTen NVARCHAR(100), -- Vẫn nhận tham số này (từ C# truyền xuống "Thành viên mới")
    @Email VARCHAR(100),
    @SoDienThoai VARCHAR(15),
    @DiaChi NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 1. KIỂM TRA TÀI KHOẢN
    IF EXISTS (SELECT 1 FROM nguoi_dung WHERE tai_khoan = @TaiKhoan)
    BEGIN
        SELECT -1 AS KetQua, N'Tên tài khoản đã tồn tại.' AS ThongBao;
        RETURN;
    END

    -- 2. KIỂM TRA EMAIL
    IF EXISTS (SELECT 1 FROM nguoi_dung WHERE email = @Email)
    BEGIN
        SELECT -2 AS KetQua, N'Email này đã được sử dụng.' AS ThongBao;
        RETURN;
    END

    -- 3. [MỚI] KIỂM TRA SỐ ĐIỆN THOẠI
    -- Vì SĐT giờ là bắt buộc và quan trọng, không được để trùng
    IF EXISTS (SELECT 1 FROM nguoi_dung WHERE so_dien_thoai = @SoDienThoai)
    BEGIN
        SELECT -3 AS KetQua, N'Số điện thoại này đã được đăng ký bởi người khác.' AS ThongBao;
        RETURN;
    END

    -- 4. LOGIC XỬ LÝ HỌ TÊN (Phòng hờ trường hợp C# quên truyền hoặc truyền rỗng)
    -- Nếu HoTen rỗng, hệ thống tự lấy Tài khoản hoặc SĐT làm tên hiển thị
    IF @HoTen IS NULL OR @HoTen = ''
    BEGIN
        SET @HoTen = @TaiKhoan;
    END

    -- 5. TỰ ĐỘNG SINH MÃ NGƯỜI DÙNG (Giữ nguyên)
    DECLARE @MaxID INT;
    DECLARE @NewIDString VARCHAR(10);

    SELECT @MaxID = MAX(CAST(SUBSTRING(id_nguoi_dung, 2, LEN(id_nguoi_dung)) AS INT)) 
    FROM nguoi_dung 
    WHERE id_nguoi_dung LIKE 'U%';

    IF @MaxID IS NULL SET @MaxID = 0;
    SET @NewIDString = 'U' + RIGHT('0' + CAST(@MaxID + 1 AS VARCHAR(10)), 2);

    -- 6. THÊM VÀO BẢNG NGƯỜI DÙNG
    DECLARE @IdVaiTroKhachHang INT = 3; 
    DECLARE @AnhDaiDienMacDinh NVARCHAR(100) = 'default_user.jpg';

    BEGIN TRY
        INSERT INTO nguoi_dung (
            id_nguoi_dung, tai_khoan, mat_khau, ho_ten, email, 
            so_dien_thoai, dia_chi, id_vai_tro, ngay_tao, anh_dai_dien
        )
        VALUES (
            @NewIDString, @TaiKhoan, @MatKhau, @HoTen, @Email, 
            @SoDienThoai, @DiaChi, @IdVaiTroKhachHang, GETDATE(), @AnhDaiDienMacDinh
        );

        -- Trả về thành công
        SELECT 1 AS KetQua, 
               N'Đăng ký thành công!' AS ThongBao, 
               @NewIDString AS IdNguoiDungMoi;
    END TRY
    BEGIN CATCH
        SELECT -99 AS KetQua, N'Lỗi hệ thống: ' + ERROR_MESSAGE() AS ThongBao;
    END CATCH
END;
GO

UPDATE nguoi_dung 
SET mat_khau = '123456' 
WHERE id_vai_tro = 3;