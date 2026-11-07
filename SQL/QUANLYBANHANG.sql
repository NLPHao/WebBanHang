CREATE DATABASE BANHANG
GO
USE BANHANG
GO

-- 1. Tạo bảng Vai trò (Quản lý phân quyền: Admin, Nhan vien, Khach hang)
CREATE TABLE vai_tro (
    id_vai_tro INT IDENTITY(1,1) PRIMARY KEY not null,
    ten_vai_tro NVARCHAR(50) NOT NULL, -- Ví dụ: Quan tri vien, Khach hang
    mo_ta NVARCHAR(255)
);

-- 2. Tạo bảng Người dùng (Tài khoản đăng nhập)
-- Liên kết với bảng vai_tro
CREATE TABLE nguoi_dung (
    id_nguoi_dung NVARCHAR(50) PRIMARY KEY not null,
    tai_khoan VARCHAR(50) NOT NULL UNIQUE,
    mat_khau VARCHAR(255) NOT NULL, -- Lưu chuỗi mã hóa hash hoặc text thường
    ho_ten NVARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    so_dien_thoai VARCHAR(15),
    dia_chi NVARCHAR(255),
    id_vai_tro INT NOT NULL,
    ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
    anh_dai_dien NVARCHAR(100),
    FOREIGN KEY (id_vai_tro) REFERENCES vai_tro(id_vai_tro)
);

-- 3. Tạo bảng Danh mục sản phẩm (Ví dụ: Dien thoai, Laptop, Tu lanh)
CREATE TABLE danh_muc (
    id_danh_muc INT IDENTITY(1,1) PRIMARY KEY,
    ten_danh_muc NVARCHAR(100) NOT NULL,
    id_danh_muc_cha INT -- Ví dụ: 'iPhone' thuộc cha là 'Dien thoai'
);

-- 4. Tạo bảng Thương hiệu (Ví dụ: Samsung, Apple, Sony)
CREATE TABLE thuong_hieu (
    id_thuong_hieu INT IDENTITY(1,1) PRIMARY KEY,
    ten_thuong_hieu NVARCHAR(100) NOT NULL,
    hinh_anh_logo NVARCHAR(255)
);

-- 5. Tạo bảng Sản phẩm (Bảng trung tâm)
-- Liên kết với: danh_muc, thuong_hieu
CREATE TABLE san_pham (
    id_san_pham INT IDENTITY(1,1) PRIMARY KEY,
    ten_san_pham NVARCHAR(200) NOT NULL,
    gia_ban DECIMAL(15, 0) NOT NULL, -- Giá tiền VNĐ
    gia_khuyen_mai DECIMAL(15, 0),
    so_luong_ton INT DEFAULT 0,
    mo_ta_chi_tiet NVARCHAR(MAX), -- Dùng MAX cho thoải mái
    hinh_anh_dai_dien NVARCHAR(255),
    id_danh_muc INT NOT NULL,
    id_thuong_hieu INT,
    trang_thai BIT DEFAULT 1, -- 1: Đang bán, 0: Ngừng kinh doanh
    FOREIGN KEY (id_danh_muc) REFERENCES danh_muc(id_danh_muc),
    FOREIGN KEY (id_thuong_hieu) REFERENCES thuong_hieu(id_thuong_hieu)
);

-- 6. Tạo bảng Thông số kỹ thuật (Quan trọng cho điện máy)
-- Giúp phân biệt RAM/CPU (Laptop) với Dung tích/Inverter (Tủ lạnh)
-- Liên kết với: san_pham
CREATE TABLE thong_so_ky_thuat (
    id_thong_so INT IDENTITY(1,1) PRIMARY KEY,
    id_san_pham INT NOT NULL,
    ten_thong_so NVARCHAR(50) NOT NULL, -- Ví dụ: "RAM", "Dung tích"
    gia_tri NVARCHAR(100) NOT NULL,     -- Ví dụ: "8GB", "200 Lít"
    FOREIGN KEY (id_san_pham) REFERENCES san_pham(id_san_pham) ON DELETE CASCADE
);

-- 7. Tạo bảng Đơn hàng
-- Liên kết với: nguoi_dung
CREATE TABLE don_hang (
    id_don_hang NVARCHAR(50) PRIMARY KEY not null,
    id_nguoi_dung NVARCHAR(50) NOT NULL, -- Khách hàng mua
    ngay_dat_hang DATETIME DEFAULT CURRENT_TIMESTAMP,
    tong_tien DECIMAL(15, 0) NOT NULL,
    trang_thai_don_hang NVARCHAR(50) DEFAULT N'Chờ xử lý', -- Cho xu ly, Dang giao, Da giao, Da huy
    dia_chi_giao_hang NVARCHAR(255) NOT NULL,
    so_dien_thoai_nhan VARCHAR(15) NOT NULL,
    ghi_chu NVARCHAR(MAX),
    FOREIGN KEY (id_nguoi_dung) REFERENCES nguoi_dung(id_nguoi_dung)
);

-- 8. Tạo bảng Chi tiết đơn hàng (Lưu sản phẩm trong đơn)
-- Liên kết với: don_hang, san_pham
CREATE TABLE chi_tiet_don_hang (
    id_chi_tiet INT IDENTITY(1,1) PRIMARY KEY,
    id_don_hang NVARCHAR(50) NOT NULL,
    id_san_pham INT NOT NULL,
    so_luong INT NOT NULL,
    don_gia DECIMAL(15, 0) NOT NULL, -- Giá tại thời điểm mua (để tránh giá sp thay đổi sau này)
    FOREIGN KEY (id_don_hang) REFERENCES don_hang(id_don_hang) ON DELETE CASCADE,
    FOREIGN KEY (id_san_pham) REFERENCES san_pham(id_san_pham)
);

GO

-- =============================================
-- INSERT DỮ LIỆU MẪU
-- =============================================

-- 1. Thêm dữ liệu VAI TRÒ
INSERT INTO vai_tro (ten_vai_tro, mo_ta) VALUES 
(N'Quản trị viên', N'Admin hệ thống, toàn quyền quản lý'),
(N'Nhân viên', N'Nhân viên bán hàng, xử lý đơn'),
(N'Khách hàng', N'Người dùng mua sắm');
GO

-- 2. Thêm dữ liệu NGƯỜI DÙNG
INSERT INTO nguoi_dung (id_nguoi_dung, tai_khoan, mat_khau, ho_ten, email, so_dien_thoai, dia_chi, id_vai_tro, anh_dai_dien) VALUES 
('U01', 'admin', '123456', N'Nguyễn Văn Admin', 'admin@shop.com', '0901111111', N'Hà Nội', 1, 'admin.jpg'),
('U02', 'staff01', '123456', N'Trần Thị Nhân Viên', 'staff@shop.com', '0902222222', N'Đà Nẵng', 2, 'staff.jpg'),
('U03', 'khachhangA', '123456', N'Lê Văn Khách', 'khacha@gmail.com', '0903333333', N'TP. Hồ Chí Minh', 3, 'user1.jpg'),
('U04', 'khachhangB', '123456', N'Phạm Thị Mua', 'khachb@gmail.com', '0904444444', N'Cần Thơ', 3, 'user2.jpg');
GO

-- 3. Thêm dữ liệu DANH MỤC
INSERT INTO danh_muc (ten_danh_muc, id_danh_muc_cha) VALUES 
(N'Điện thoại', NULL),      -- ID 1
(N'Laptop', NULL),          -- ID 2
(N'Điện lạnh', NULL),       -- ID 3
(N'Tủ lạnh', 3),            -- ID 4
(N'Máy giặt', 3);           -- ID 5
GO

-- 4. Thêm dữ liệu THƯƠNG HIỆU
INSERT INTO thuong_hieu (ten_thuong_hieu, hinh_anh_logo) VALUES 
(N'Apple', 'logo_apple.png'),
(N'Samsung', 'logo_samsung.png'),
(N'Dell', 'logo_dell.png'),
(N'LG', 'logo_lg.png'),
(N'Sony', 'logo_sony.png'),    -- ID 5
(N'Xiaomi', 'logo_xiaomi.png'), -- ID 6
(N'Asus', 'logo_asus.png');     -- ID 7
GO

-- 5. Thêm dữ liệu SẢN PHẨM
INSERT INTO san_pham (ten_san_pham, gia_ban, gia_khuyen_mai, so_luong_ton, mo_ta_chi_tiet, hinh_anh_dai_dien, id_danh_muc, id_thuong_hieu) VALUES 
-- Điện thoại
(N'iPhone 15 Pro Max 256GB', 34990000, 33990000, 50, N'Màn hình Super Retina XDR, khung Titan, chip A17 Pro mạnh mẽ.', 'iphone15pm.jpg', 1, 1),
(N'Samsung Galaxy S24 Ultra', 31990000, 30000000, 45, N'Tích hợp Galaxy AI, bút S-Pen, camera 200MP.', 's24ultra.jpg', 1, 2),
(N'iPhone 13 128GB', 15990000, 13990000, 100, N'Thiết kế vuông vức, camera chéo độc đáo, chip A15 Bionic.', 'iphone13.jpg', 1, 1),
(N'Samsung Galaxy Z Flip5', 25990000, 19990000, 30, N'Điện thoại gập vỏ sò thời thượng, màn hình phụ Flex Window lớn.', 'zflip5.jpg', 1, 2),
(N'Xiaomi 13T Pro 5G', 16990000, 15490000, 40, N'Camera Leica chuyên nghiệp, màn hình 144Hz siêu mượt.', 'xiaomi13t.jpg', 1, 6),
(N'Sony Xperia 1 V', 29990000, NULL, 15, N'Màn hình 4K OLED tỉ lệ 21:9, cảm biến Exmor T chuẩn điện ảnh.', 'sony_xperia.jpg', 1, 5),

-- Laptop
(N'Laptop Dell XPS 13', 45000000, 42000000, 10, N'Laptop doanh nhân cao cấp, thiết kế mỏng nhẹ, màn hình vô cực.', 'dellxps.jpg', 2, 3), -- Lưu ý: ID danh mục 2 là Laptop, ở đây sửa lại cho đúng logic nếu cần (trong data cũ bạn để là 2)
(N'MacBook Air M2 13 inch', 27990000, 24990000, 50, N'Thiết kế hoàn toàn mới, chip M2 mạnh mẽ, pin 18 tiếng.', 'macairm2.jpg', 2, 1),
(N'Asus TUF Gaming F15', 21990000, 19490000, 25, N'Laptop Gaming bền bỉ chuẩn quân đội, RTX 3050, màn hình 144Hz.', 'asustuf.jpg', 2, 7),
(N'Dell Vostro 3510', 14990000, 11990000, 60, N'Laptop văn phòng bền bỉ, màn hình lớn 15.6 inch, bàn phím số.', 'dellvostro.jpg', 2, 3),
(N'Asus Zenbook 14 OLED', 24990000, 22990000, 20, N'Màn hình OLED 2.8K rực rỡ, thiết kế siêu mỏng nhẹ.', 'zenbook14.jpg', 2, 7),

-- Tủ lạnh
(N'Tủ lạnh LG Inverter', 22000000, 19900000, 20, N'Tủ lạnh Side by Side, công nghệ Door-in-Door, tiết kiệm điện.', 'tulanh_lg.jpg', 4, 4),
(N'Tủ lạnh Samsung Bespoke', 35000000, 32000000, 10, N'Thiết kế linh hoạt, màu sắc tùy chọn, giữ thực phẩm tươi ngon.', 'samsung_bespoke.jpg', 4, 2),
(N'Tủ lạnh LG Inverter 315L', 9900000, 8500000, 40, N'Công nghệ Linear Cooling, luồng khí lạnh đa chiều.', 'lg_315l.jpg', 4, 4),
(N'Tủ lạnh Samsung Inverter 380L', 14500000, 12000000, 25, N'Hai dàn lạnh độc lập Twin Cooling Plus, ngăn đông mềm.', 'samsung_380l.jpg', 4, 2),
(N'Tủ lạnh LG Side By Side 600L', 25000000, 21500000, 15, N'Cửa phụ Door-in-Door tiện lợi, lấy nước ngoài kháng khuẩn.', 'lg_sidebyside.jpg', 4, 4),

-- Máy giặt
(N'Máy giặt LG AI DD 9kg', 10500000, 8900000, 35, N'Cảm biến AI bảo vệ sợi vải, giặt hơi nước diệt khuẩn.', 'lg_aidd.jpg', 5, 4),
(N'Máy giặt Samsung AddWash 10kg', 12900000, 10500000, 20, N'Cửa phụ thêm đồ khi giặt, công nghệ EcoBubble tạo bong bóng.', 'samsung_addwash.jpg', 5, 2),
(N'Máy giặt LG Inverter 11kg', 14200000, 12800000, 15, N'Động cơ truyền động trực tiếp bền bỉ, TurboWash giặt nhanh.', 'lg_11kg.jpg', 5, 4),
(N'Máy giặt Samsung cửa trên 9kg', 6500000, 5200000, 50, N'Mâm giặt Wobble chống xoắn rối, hộp đánh tan bột giặt.', 'samsung_topload.jpg', 5, 2);
GO

-- 6. Thêm dữ liệu THÔNG SỐ KỸ THUẬT
INSERT INTO thong_so_ky_thuat (id_san_pham, ten_thong_so, gia_tri) VALUES 
-- iPhone 15 PM (ID 1)
(1, N'Màn hình', N'6.7 inch OLED'), (1, N'RAM', N'8GB'), (1, N'Bộ nhớ trong', N'256GB'),
-- S24 Ultra (ID 2)
(2, N'Màn hình', N'6.8 inch'), (2, N'RAM', N'12GB'),
-- Dell XPS (ID 7 - Theo thứ tự insert ở trên ID này có thể thay đổi, kiểm tra lại khi chạy)
(7, N'CPU', N'Intel Core i7 1360P'), (7, N'RAM', N'16GB'), (7, N'Ổ cứng', N'512GB SSD'),
-- Tủ lạnh LG (ID 12)
(12, N'Dung tích', N'635 Lít'), (12, N'Công nghệ', N'Inverter');
GO

-- 7. Thêm dữ liệu ĐƠN HÀNG
INSERT INTO don_hang (id_don_hang, id_nguoi_dung, ngay_dat_hang, tong_tien, trang_thai_don_hang, dia_chi_giao_hang, so_dien_thoai_nhan, ghi_chu) VALUES 
('DH001', 'U03', GETDATE(), 33990000, N'Đã giao', N'123 Lê Lợi, TP.HCM', '0903333333', N'Giao giờ hành chính'),
('DH002', 'U04', GETDATE(), 67000000, N'Chờ xử lý', N'456 Ninh Kiều, Cần Thơ', '0904444444', N'Gọi trước khi giao');
GO

-- 8. Thêm dữ liệu CHI TIẾT ĐƠN HÀNG
INSERT INTO chi_tiet_don_hang (id_don_hang, id_san_pham, so_luong, don_gia) VALUES 
('DH001', 1, 1, 33990000), -- Mua iPhone
('DH002', 7, 1, 45000000), -- Mua Dell XPS (Lưu ý ID sản phẩm)
('DH002', 12, 1, 22000000); -- Mua Tủ lạnh
GO

-- =============================================
-- STORED PROCEDURE: ĐĂNG KÝ TÀI KHOẢN (Bản Chuẩn)
-- =============================================
GO
CREATE PROCEDURE sp_DangKyTaiKhoan
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

    -- 3. KIỂM TRA SỐ ĐIỆN THOẠI
    IF EXISTS (SELECT 1 FROM nguoi_dung WHERE so_dien_thoai = @SoDienThoai)
    BEGIN
        SELECT -3 AS KetQua, N'Số điện thoại này đã được đăng ký bởi người khác.' AS ThongBao;
        RETURN;
    END

    -- 4. LOGIC XỬ LÝ HỌ TÊN (Dự phòng)
    IF @HoTen IS NULL OR @HoTen = ''
    BEGIN
        SET @HoTen = @TaiKhoan;
    END

    -- 5. TỰ ĐỘNG SINH MÃ NGƯỜI DÙNG (U + Số)
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

-- Cập nhật mật khẩu mẫu về dạng text thường để test
UPDATE nguoi_dung 
SET mat_khau = '123456' 
WHERE id_vai_tro = 3;
GO

USE BANHANG
GO

-- BƯỚC 1: Dọn dẹp dữ liệu sản phẩm cũ đang bị lỗi font
DELETE FROM chi_tiet_don_hang; -- Xóa chi tiết đơn hàng trước (để tránh lỗi khóa ngoại)
DELETE FROM thong_so_ky_thuat; -- Xóa thông số kỹ thuật
DELETE FROM san_pham;          -- Giờ mới xóa được sản phẩm

-- Reset lại ID sản phẩm về 1 (để khi thêm mới nó bắt đầu từ 1, không nhảy số lung tung)
DBCC CHECKIDENT ('san_pham', RESEED, 0);
DBCC CHECKIDENT ('thong_so_ky_thuat', RESEED, 0);

-- BƯỚC 2: Thêm lại sản phẩm (Code chuẩn có chữ N)
INSERT INTO san_pham (ten_san_pham, gia_ban, gia_khuyen_mai, so_luong_ton, mo_ta_chi_tiet, hinh_anh_dai_dien, id_danh_muc, id_thuong_hieu) VALUES 
-- Điện thoại
(N'iPhone 15 Pro Max 256GB', 34990000, 33990000, 50, N'Màn hình Super Retina XDR, khung Titan.', 'iphone15pm.jpg', 1, 1),
(N'Samsung Galaxy S24 Ultra', 31990000, 30000000, 45, N'Tích hợp Galaxy AI, bút S-Pen.', 's24ultra.jpg', 1, 2),
(N'iPhone 13 128GB', 15990000, 13990000, 100, N'Thiết kế vuông vức, camera chéo.', 'iphone13.jpg', 1, 1),
(N'Samsung Galaxy Z Flip5', 25990000, 19990000, 30, N'Điện thoại gập vỏ sò thời thượng.', 'zflip5.jpg', 1, 2),
(N'Xiaomi 13T Pro 5G', 16990000, 15490000, 40, N'Camera Leica chuyên nghiệp.', 'xiaomi13t.jpg', 1, 6),
(N'Sony Xperia 1 V', 29990000, NULL, 15, N'Màn hình 4K OLED tỉ lệ 21:9.', 'sony_xperia.jpg', 1, 5),

-- Laptop
(N'Laptop Dell XPS 13', 45000000, 42000000, 10, N'Laptop doanh nhân cao cấp.', 'dellxps.jpg', 2, 3),
(N'MacBook Air M2 13 inch', 27990000, 24990000, 50, N'Thiết kế hoàn toàn mới, chip M2.', 'macairm2.jpg', 2, 1),
(N'Asus TUF Gaming F15', 21990000, 19490000, 25, N'Laptop Gaming bền bỉ chuẩn quân đội.', 'asustuf.jpg', 2, 7),
(N'Dell Vostro 3510', 14990000, 11990000, 60, N'Laptop văn phòng bền bỉ.', 'dellvostro.jpg', 2, 3),
(N'Asus Zenbook 14 OLED', 24990000, 22990000, 20, N'Màn hình OLED 2.8K rực rỡ.', 'zenbook14.jpg', 2, 7),

-- Tủ lạnh
(N'Tủ lạnh LG Inverter', 22000000, 19900000, 20, N'Tủ lạnh Side by Side.', 'tulanh_lg.jpg', 4, 4),
(N'Tủ lạnh Samsung Bespoke', 35000000, 32000000, 10, N'Thiết kế linh hoạt, màu sắc tùy chọn.', 'samsung_bespoke.jpg', 4, 2),
(N'Tủ lạnh LG Inverter 315L', 9900000, 8500000, 40, N'Công nghệ Linear Cooling.', 'lg_315l.jpg', 4, 4),
(N'Tủ lạnh Samsung Inverter 380L', 14500000, 12000000, 25, N'Hai dàn lạnh độc lập.', 'samsung_380l.jpg', 4, 2),
(N'Tủ lạnh LG Side By Side 600L', 25000000, 21500000, 15, N'Cửa phụ Door-in-Door tiện lợi.', 'lg_sidebyside.jpg', 4, 4),

-- Máy giặt
(N'Máy giặt LG AI DD 9kg', 10500000, 8900000, 35, N'Cảm biến AI bảo vệ sợi vải.', 'lg_aidd.jpg', 5, 4),
(N'Máy giặt Samsung AddWash 10kg', 12900000, 10500000, 20, N'Cửa phụ thêm đồ khi giặt.', 'samsung_addwash.jpg', 5, 2),
(N'Máy giặt LG Inverter 11kg', 14200000, 12800000, 15, N'Động cơ truyền động trực tiếp.', 'lg_11kg.jpg', 5, 4),
(N'Máy giặt Samsung cửa trên 9kg', 6500000, 5200000, 50, N'Mâm giặt Wobble chống xoắn rối.', 'samsung_topload.jpg', 5, 2);

-- Kiểm tra lại sản phẩm
SELECT ten_san_pham FROM san_pham;

