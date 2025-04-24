--SYNONYM

-- Synonym 1: Tạo Synonym cho bảng BenhNhan
CREATE SYNONYM Syn_BenhNhan FOR BenhNhan;
-- Test
SELECT * FROM Syn_BenhNhan;

-- Synonym 2: Tạo Synonym cho bảng BenhAn
CREATE SYNONYM Syn_BenhAn FOR BenhAn;
-- Test
SELECT * FROM Syn_BenhAn;


--INDEX

-- Index 1: Tạo Index cho cột HoTenBenhNhan trên bảng BenhNhan
CREATE INDEX IDX_BenhNhan_HoTen ON BenhNhan (HoTenBenhNhan);
-- Test
SELECT * 
FROM BenhNhan 
WITH (INDEX(IDX_BenhNhan_HoTen))
WHERE HoTenBenhNhan LIKE N'%Nguyễn%';

-- Index 2: Tạo Index cho cột NgayKham trên bảng LichKham
CREATE INDEX IDX_LichKham_NgayKham ON LichKham (NgayKham);
-- Test
SELECT * 
FROM LichKham 
WITH (INDEX(IDX_LichKham_NgayKham))
WHERE NgayKham BETWEEN '2024-01-01' AND '2024-12-31';


--VIEW

-- View 1: Tạo hiện thị thông tin danh sách bệnh nhân cơ bản
CREATE OR ALTER VIEW View_DanhSachBenhNhan AS
SELECT bn.MaBenhNhan, HoTenBenhNhan, ChanDoan,NgaySinh, SoDienThoai 
FROM BenhNhan bn join BenhAn ba on bn.MaBenhNhan = ba.MaBenhNhan;
-- Test
SELECT * 
FROM View_DanhSachBenhNhan;

-- View 2: Tạo hiển thị thống kê số lượng bệnh án theo bác sĩ
CREATE OR ALTER VIEW View_ThongKeBenhAnTheoBacSi AS
SELECT bs.MaBacSi, HoTenBacSi, COUNT(*) AS SoLuongBenhAn
FROM BenhAn ba join BacSi bs on ba.MaBacSi = bs.MaBacSi
GROUP BY bs.MaBacSi, HoTenBacSi;
-- Test
SELECT * 
FROM View_ThongKeBenhAnTheoBacSi;

-- View 3: Tạo hiển thị danh sách lịch khám đầy đủ thông tin
CREATE OR ALTER VIEW View_LichKhamChiTiet AS
SELECT lk.MaLichKham, bn.HoTenBenhNhan, bs.HoTenBacSi, lk.NgayKham, lk.GioKham
FROM LichKham lk
JOIN BenhNhan bn ON lk.MaBenhNhan = bn.MaBenhNhan
JOIN BacSi bs ON lk.MaBacSi = bs.MaBacSi;
-- Test
SELECT * 
FROM View_LichKhamChiTiet;

-- View 4: Tạo hiện thị danh sách bác sĩ có chuyên môn nội khoa
CREATE OR ALTER VIEW View_BacSiNoiKhoa AS
SELECT MaBacSi, HoTenBacSi, ChuyenMon, SoDienThoai
FROM BacSi
WHERE ChuyenMon = N'Nội khoa';
-- Test
SELECT * 
FROM View_BacSiNoiKhoa;

--View 5: Tạo hiển thị danh sách thống kê thuốc bệnh nhân	
CREATE OR ALTER VIEW View_ThongKeThuocBenhNhan AS
SELECT bn.MaBenhNhan, bn.HoTenBenhNhan, 
COUNT(dt.MaDonThuoc) AS SoLuongDonThuoc, SUM(dt.SoLuong) AS TongSoLuongThuoc
FROM BenhNhan bn
JOIN BenhAn ba ON bn.MaBenhNhan = ba.MaBenhNhan
JOIN DonThuoc dt ON ba.MaBenhAn = dt.MaBenhAn
GROUP BY bn.MaBenhNhan, bn.HoTenBenhNhan;
--Test
SELECT * 
FROM View_ThongKeThuocBenhNhan;

--FUNCTION

-- Function 1: Tạo hàm tính chi phí khám dựa trên chuyên môn của bác sĩ với tham số chuyền vào là mã bác sĩ
CREATE FUNCTION F_TinhChiPhiKham 
(@MaBacSi INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @ChiPhi DECIMAL(10, 2);

    SELECT @ChiPhi = 
        CASE 
            WHEN ChuyenMon = N'Nội khoa' THEN 200000
            WHEN ChuyenMon = N'Ngoại khoa' THEN 300000
            WHEN ChuyenMon = N'Nhi khoa' THEN 250000
            ELSE 150000
        END
    FROM BacSi
    WHERE MaBacSi = @MaBacSi;
    RETURN @ChiPhi;
END;
-- Kiểm thử với bác sĩ chuyên môn "Nội khoa" 
SELECT dbo.F_TinhChiPhiKham(201) AS ChiPhiKhamNoiKhoa;
-- Kiểm thử với bác sĩ chuyên môn "Nhi khoa" 
SELECT dbo.F_TinhChiPhiKham(203) AS ChiPhiKhamNhiKhoa;
-- Kiểm thử với bác sĩ chuyên môn "Răng hàm mặt" 
SELECT dbo.F_TinhChiPhiKham(206) AS ChiPhiKhamRangHamMat;

-- Function 2: Tạo hàm thống kê bác sĩ có nhiều bệnh án nhất và xuất ra bảng các thông tin bác sĩ
CREATE OR ALTER FUNCTION F_BacSiNhieuBenhAn ()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        bs.MaBacSi, 
        bs.HoTenBacSi, 
        COUNT(ba.MaBenhAn) AS SoLuongBenhAn
    FROM BacSi bs
    JOIN BenhAn ba ON bs.MaBacSi = ba.MaBacSi
    GROUP BY bs.MaBacSi, bs.HoTenBacSi
    HAVING COUNT(ba.MaBenhAn) >= ALL(SELECT COUNT(MaBenhAn)
	FROM BenhAn 
	GROUP BY MaBacSi) 
);
-- Test
SELECT * FROM dbo.F_BacSiNhieuBenhAn();


-- STORE PROCEDURE

-- Store Procedure 1: Tính tổng chi phí khám của một bệnh nhân với mã bệnh nhân là tham số truyền vào
CREATE OR ALTER PROC sp_TinhTongChiPhiKham
    @MaBenhNhan INT
AS
BEGIN
    SELECT bn.MaBenhNhan, bn.HoTenBenhNhan, 
           SUM(dbo.F_TinhChiPhiKham(lk.MaBacSi)) AS TongChiPhi
    FROM BenhNhan bn
    JOIN LichKham lk ON bn.MaBenhNhan = lk.MaBenhNhan
    WHERE bn.MaBenhNhan = @MaBenhNhan
    GROUP BY bn.MaBenhNhan, bn.HoTenBenhNhan;
END;
--Test
EXEC sp_TinhTongChiPhiKham 110;


-- Store Procedure 2: Hiển thị lịch khám của bệnh nhân với mã bệnh nhân là tham số truyền vào
CREATE OR ALTER PROC sp_LayLichKhamBenhNhan
    @MaBenhNhan INT
AS
BEGIN
    SELECT bn.MaBenhNhan, HoTenBenhNhan, NgayKham, GioKham
    FROM LichKham lk
    JOIN BenhNhan bn ON lk.MaBenhNhan = bn.MaBenhNhan
    WHERE bn.MaBenhNhan = @MaBenhNhan;
END;

--Test
EXEC sp_LayLichKhamBenhNhan 110;


--Store Procedure 3: Liệt kê các bác sĩ theo chuyên môn với chuyên môn là tham số được truyền vào
CREATE OR ALTER PROC sp_LietKeBacSiTheoChuyenMon
    @ChuyenMon NVARCHAR(100)
AS
BEGIN
	SELECT MaBacSi, HoTenBacSi,ChuyenMon,
		SoDienThoai, MaPhongKham
	FROM BacSi
	WHERE ChuyenMon = @ChuyenMon;
END;
--Test
EXEC sp_LietKeBacSiTheoChuyenMon N'Tim mạch';


--Store Procedure 4: Tính tổng số bệnh nhân đã khám trong một khoảng thời gian với tham số truyền vào ngày bắt đầu và ngày kết thúc
CREATE OR ALTER PROC sp_TinhTongBenhNhanTrongKhoangThoiGian
    @NgayBatDau DATE,
    @NgayKetThuc DATE
AS
BEGIN
    SELECT COUNT(DISTINCT MaBenhNhan) AS TongBenhNhan
    FROM LichKham
    WHERE NgayKham BETWEEN @NgayBatDau AND @NgayKetThuc;
END;
--Test
EXEC sp_TinhTongBenhNhanTrongKhoangThoiGian '2024-01-01','2024-6-30';


-- Store Procedure 5: Thống kê chẩn đoán và đơn thuốc được dùng cho chẩn đoán đó
CREATE OR ALTER PROC sp_LietKeChanDoanVaDonThuoc
AS
BEGIN
    SELECT ba.ChanDoan, dt.TenThuoc,
	dt.LieuDung, dt.SoLuong
    FROM BenhAn ba
    JOIN DonThuoc dt ON ba.MaBenhAn = dt.MaBenhAn
    ORDER BY ba.ChanDoan, dt.TenThuoc;
END;

--Test
EXEC sp_LietKeChanDoanVaDonThuoc;


-- Store Procedure 6: Liệt kê các chẩn đoán theo chuyên môn với chuyên môn là tham số truyền vào
CREATE OR ALTER PROC sp_LietKeChanDoanTheoChuyenMon
    @ChuyenMon NVARCHAR(100)
AS
BEGIN
    SELECT bs.ChuyenMon, ChanDoan
    FROM BenhAn ba
    JOIN BacSi bs ON ba.MaBacSi = bs.MaBacSi
    WHERE bs.ChuyenMon = @ChuyenMon
END;

--Test
EXEC sp_LietKeChanDoanTheoChuyenMon  N'Da liễu';

-- TRIGGER 

-- Trigger 1: Thêm vào bảng BacSi thì mã phòng khám phải phù hợp với chuyên môn bác sĩ
CREATE OR ALTER TRIGGER trg_KiemTraChuyenMonVaPhongKham
ON BacSi
INSTEAD OF INSERT
AS
BEGIN
    BEGIN TRAN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN PhongKham pk ON i.MaPhongKham = pk.MaPhongKham
        WHERE i.ChuyenMon NOT LIKE pk.LoaiPhongKham
    )
    BEGIN
        PRINT N'Chuyên môn không phù hợp với mã phòng khám!';
        ROLLBACK TRAN
        RETURN
    END
	INSERT INTO BacSi (MaBacSi, MaPhongKham, HoTenBacSi, ChuyenMon, SoDienThoai)
    SELECT MaBacSi, MaPhongKham, HoTenBacSi, ChuyenMon, SoDienThoai
    FROM inserted
    COMMIT TRAN
END;
--test
--Không thành công
INSERT INTO BacSi (MaBacSi, HoTenBacSi, ChuyenMon, SoDienThoai, MaPhongKham) VALUES
(299, N'Nguyễn Văn Hải', N'Nội khoa', '0901234999', 306)
--Thành công
INSERT INTO BacSi (MaBacSi, HoTenBacSi, ChuyenMon, SoDienThoai, MaPhongKham) VALUES
(299, N'Nguyễn Văn Hải', N'Nội khoa', '0901234999', 301)


-- Trigger 2: Khi thêm hoặc hay đổi lịch khám kiểm tra giờ của lịch khám phải nằm trong giờ làm việc từ 7:00 sáng đến 18:30 tối
CREATE OR ALTER TRIGGER trg_KiemTraGioLamViecLichKham
ON LichKham
FOR INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE GioKham < '07:00:00' OR GioKham > '18:30:00'
    )
    BEGIN
        PRINT N'Giờ khám phải nằm trong khung giờ làm việc từ 07:00 đến 18:30.'
        ROLLBACK TRAN;
    END
END;

--Test
--Kiểm thử trong giờ làm việc
INSERT INTO LichKham (MaLichKham, MaBenhNhan, MaBacSi, NgayKham, GioKham)
VALUES (699, 101, 201, '2024-12-11', '10:00:00'); 

UPDATE LichKham
SET GioKham = '15:00:00'
WHERE MaLichKham = 610; 

--Kiểm thử ngoài giờ làm việc
INSERT INTO LichKham (MaLichKham, MaBenhNhan, MaBacSi, NgayKham, GioKham)
VALUES (600, 102, 202, '2024-12-01', '19:30:00');

UPDATE LichKham
SET GioKham = '20:00:00'
WHERE MaLichKham = 608; 


-- Trigger 3: Thông báo xóa thành công lịch khám hoặc không tồn tại lịch khám
CREATE OR ALTER TRIGGER trg_ThongBaoXoaLichKhamThanhCong
ON LichKham
FOR DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        PRINT N'Lịch khám đã được xóa thành công.';
    END
    ELSE
    BEGIN
        PRINT N'Không có lịch khám nào bị xóa.';
    END
END;

-- Test

-- Thành công
DELETE FROM LichKham WHERE MaLichKham = 699;

-- Không thành công
DELETE FROM LichKham WHERE MaLichKham = 677;

--USER

-- NHANVIENYTA
-- Tạo nhóm người dùng NhanVienYTa
CREATE ROLE NhanVienYTa;

-- Phân quyền cho nhóm NhanVienYTa
GRANT SELECT, UPDATE ON BenhNhan TO NhanVienYTa;
GRANT SELECT, UPDATE ON LichKham TO NhanVienYTa;

-- Tạo login cho nhân viên y tá
CREATE LOGIN NV_YTa WITH PASSWORD = '123456789', 
DEFAULT_DATABASE= QuanLyBenhVien

-- Tạo người dùng nhân viên y tá
CREATE USER NV_YTa FOR LOGIN NV_YTa;

-- Gán người dùng vào nhóm NhanVienYTa
EXEC sp_addrolemember 'NhanVienYTa', 'NV_YTa';

-- BACSIQUANLY
-- Tạo nhóm người dùng BacSiQL
CREATE ROLE BacSiQL;

-- Phân quyền cho nhóm BacSiQL
GRANT SELECT, DELETE, UPDATE ON BenhNhan TO BacSiQL;
GRANT SELECT, DELETE, UPDATE ON BacSi TO BacSiQL;
GRANT SELECT, DELETE, UPDATE ON BenhAn TO BacSiQL;
GRANT SELECT, DELETE, UPDATE ON LichKham TO BacSiQL;
GRANT SELECT, DELETE, UPDATE ON PhongKham TO BacSiQL;
GRANT SELECT, DELETE, UPDATE ON DonThuoc TO BacSiQL;

-- Tạo login cho bác sĩ
CREATE LOGIN BacSi WITH PASSWORD = '123456789',
DEFAULT_DATABASE= QuanLyBenhVien

-- Tạo người dùng bác sĩ
CREATE USER BacSi FOR LOGIN BacSi;

-- Gán người dùng vào nhóm BacSiQL
EXEC sp_addrolemember 'BacSiQL', 'BacSi';


--NHANVIENBANTHUOC
-- Tạo nhóm người dùng NhanVienBanThuoc
CREATE ROLE NhanVienBanThuoc;

-- Phân quyền cho nhóm NhanVienBanThuoc
GRANT SELECT, UPDATE ON DonThuoc TO NhanVienBanThuoc;

-- Tạo login Nhân viên bán thuốc
CREATE LOGIN NV_BanThuoc WITH PASSWORD = '123456789',
DEFAULT_DATABASE= QuanLyBenhVien

-- Tạo người dùng cho nhân viên bán thuốc
CREATE USER NV_BanThuoc FOR LOGIN NV_BanThuoc;

-- Gán người dùng vào nhóm NhanVienBanThuoc
EXEC sp_addrolemember 'NhanVienBanThuoc', 'NV_BanThuoc';

--TRANSACTION

--Transaction 1: 2.8.2 Tạo thủ tục cập nhật liều dùng, số lượng đơn thuốc trong bảng DonThuoc với tham số truyền vào là 
--mã đơn thuốc, mã bệnh án, liều dùng mới và số lượng mới xác định giao dịch hoàn thành hoặc quay lui khi giao dịch có lỗi

CREATE OR ALTER PROC CapNhatDonThuoc 
@MaDonThuoc INT, @MaBenhAn INT, @LieuDungMoi NVARCHAR(50), @SoLuongMoi INT
AS
BEGIN TRY
	BEGIN TRAN 
		IF EXISTS (SELECT* FROM DonThuoc WHERE MaDonThuoc = @MaDonThuoc AND MaBenhAn = @MaBenhAn)
			BEGIN
				UPDATE DonThuoc
				SET LieuDung = @LieuDungMoi, SoLuong = @SoLuongMoi
				WHERE MaDonThuoc = @MaDonThuoc AND MaBenhAn = @MaBenhAn
				COMMIT TRAN
				PRINT N'Cập nhật thành công!'
			END
		ELSE
			BEGIN
				ROLLBACK TRAN
				PRINT N'Không tìm thấy đơn thuốc để cập nhật!'
			END
END TRY
BEGIN CATCH
	ROLLBACK TRAN
END CATCH
--Test
--Không thành công
EXEC CapNhatDonThuoc 558,495, '700mg', 12
--Thành công
EXEC CapNhatDonThuoc 501,401, '700mg', 12

--Transaction 2: Tạo thủ tục xem phòng khám có những bác sĩ nào xác định giao dịch hoàn thành hoặc quay lui khi giao dịch có lỗi

CREATE OR ALTER PROC XemPhongKham
@MaPhongKham INT
AS
BEGIN TRY
    BEGIN TRAN
        IF EXISTS (SELECT * FROM PhongKham WHERE MaPhongKham = @MaPhongKham)
        BEGIN
            SELECT BacSi.MaBacSi, BacSi.HoTenBacSi, BacSi.ChuyenMon, BacSi.SoDienThoai
            FROM BacSi
            WHERE BacSi.MaPhongKham = @MaPhongKham;
            COMMIT TRAN
        END
        ELSE
        BEGIN
            PRINT N'Không tìm thấy phòng khám!'
			ROLLBACK TRAN
        END
END TRY
BEGIN CATCH
    ROLLBACK TRAN
END CATCH
--Test
--Không thành công
EXEC XemPhongKham 1
--Thành công
EXEC XemPhongKham 302