-- Tạo cơ sở dữ liệu
CREATE DATABASE QuanLyBenhVien

USE QuanLyBenhVien

-- Tạo bảng Bệnh Nhân
CREATE TABLE BenhNhan (
    MaBenhNhan INT constraint PK_BENHNHAN PRIMARY KEY(MaBenhNhan),
    HoTenBenhNhan NVARCHAR(100) NOT NULL,
    NgaySinh DATE NOT NULL,
    SoDienThoai NVARCHAR(15) NOT NULL,
    DiaChi NVARCHAR(255)
);
-- Tạo bảng Phòng Khám
CREATE TABLE PhongKham (
    MaPhongKham INT constraint PK_PHONGKHAM PRIMARY KEY(MaPhongKham),
    TenPhongKham NVARCHAR(100) NOT NULL,
    LoaiPhongKham NVARCHAR(50) NOT NULL,
    TinhTrangPhongKham NVARCHAR(20) NOT NULL
);

-- Tạo bảng Bác Sĩ
CREATE TABLE BacSi (
    MaBacSi INT constraint PK_BACSI PRIMARY KEY(MaBacSi),
	MaPhongKham INT,
    HoTenBacSi NVARCHAR(100) NOT NULL,
    ChuyenMon NVARCHAR(100)NOT NULL,
    SoDienThoai NVARCHAR(15) NOT NULL,
	CONSTRAINT FK_BACSI_MAPHONGKHAM FOREIGN KEY (MaPhongKham) REFERENCES PhongKham(MaPhongKham)
);

-- Tạo bảng Bệnh Án
CREATE TABLE BenhAn (
    MaBenhAn INT constraint PK_BENHAN PRIMARY KEY(MaBenhAn),
    MaBenhNhan INT,
    MaBacSi INT,
    ChanDoan NVARCHAR(200),
    NgayLapBenhAn DATE NOT NULL,
    CONSTRAINT FK_BENHAN_MABENHNHAN FOREIGN KEY (MaBenhNhan) REFERENCES BenhNhan(MaBenhNhan),
    CONSTRAINT FK_BENHAN_MABACSI FOREIGN KEY (MaBacSi) REFERENCES BacSi(MaBacSi)
);

-- Tạo bảng Đơn Thuốc
CREATE TABLE DonThuoc (
    MaDonThuoc INT constraint PK_DONTHUOC PRIMARY KEY(MaDonThuoc),
    MaBenhAn INT,
    TenThuoc NVARCHAR(100) NOT NULL,
    LieuDung NVARCHAR(50)NOT NULL,
    SoLuong INT NOT NULL,
    constraint FK_DONTHUOC_MABENHAN FOREIGN KEY (MaBenhAn) REFERENCES BenhAn(MaBenhAn)
);

-- Tạo bảng Lịch Khám
CREATE TABLE LichKham (
    MaLichKham INT constraint PK_LICHKHAM PRIMARY KEY(MaLichKham),
    MaBenhNhan INT,
    MaBacSi INT,
    NgayKham DATE NOT NULL,
    GioKham TIME NOT NULL,
    constraint FK_LICHKHAM_MABENHNHAN FOREIGN KEY (MaBenhNhan) REFERENCES BenhNhan(MaBenhNhan),
    constraint FK_LICHKHAM_MABACSI FOREIGN KEY (MaBacSi) REFERENCES BacSi(MaBacSi)
);

-- RÀNG BUỘC

-- Ràng buộc 1: số điện thoại phải có độ dài hợp lý
ALTER TABLE BenhNhan
ADD CONSTRAINT CK_BenhNhan_SoDienThoai CHECK (LEN(SoDienThoai) BETWEEN 10 AND 15);

-- Ràng buộc 2: số điện thoại bệnh nhân không được trùng
ALTER TABLE BenhNhan	
ADD CONSTRAINT UQ_BenhNhan_SoDienThoai UNIQUE (SoDienThoai);

-- Ràng buộc 3: số điện thoại bác sĩ không được trùng
ALTER TABLE BacSi
ADD CONSTRAINT UQ_BacSi_SoDienThoai UNIQUE (SoDienThoai);

-- Ràng buộc 4: chuyên môn bác sĩ thuộc các giá trị quy định
ALTER TABLE BacSi
ADD CONSTRAINT CK_BacSi_ChuyenMon CHECK 
(ChuyenMon IN (N'Nội khoa', N'Ngoại khoa', N'Nhi khoa', N'Tim mạch', N'Da liễu', N'Răng hàm mặt'));

-- Ràng buộc 4: giá trị mặc định cho tình trạng phòng khám
ALTER TABLE PhongKham
ADD CONSTRAINT DF_PhongKham_TinhTrang DEFAULT N'Trống' FOR TinhTrangPhongKham;

-- Ràng buộc 5: tình trạng phòng chỉ thuộc các giá trị cố định
ALTER TABLE PhongKham
ADD CONSTRAINT CK_PhongKham_TinhTrang CHECK (TinhTrangPhongKham IN (N'Trống', N'Đang sử dụng'));

-- Ràng buộc 6: số lượng thuốc phải lớn hơn 0
ALTER TABLE DonThuoc
ADD CONSTRAINT CK_DonThuoc_SoLuong CHECK (SoLuong > 0);

--Ràng buộc 7: kiểm tra lịch khám không trùng lặp thời gian khám của cùng một bác sĩ
ALTER TABLE LichKham
ADD CONSTRAINT UQ_LichKham UNIQUE (MaBacSi, NgayKham, GioKham);


INSERT INTO BenhNhan (MaBenhNhan, HoTenBenhNhan, NgaySinh, SoDienThoai, DiaChi) VALUES
(101, N'Nguyễn Văn An', '1980-05-15', '0123456789', N'123 Nguyễn Trãi, TP.HCM'),
(102, N'Trần Thị Bình', '1990-06-20', '0987654321', N'456 Lê Lai, TP.HCM'),
(103, N'Lê Văn Cường', '1975-10-10', '0123456780', N'789 Võ Văn Kiệt, TP.HCM'),
(104, N'Phạm Thị Giang', '1985-02-28', '0123456781', N'321 Hai Bà Trưng, TP.HCM'),
(105, N'Nguyễn Văn Hùng', '1992-04-05', '0987654322', N'654 Trần Hưng Đạo, TP.HCM'),
(106, N'Hoàng Thị Hương', '2000-12-12', '0123456782', N'987 Lý Tự Trọng, TP.HCM'),
(107, N'Lê Văn Dũng', '1988-03-15', '0123456783', N'159 Nguyễn Đình Chiểu, TP.HCM'),
(108, N'Trần Văn Khải', '1995-07-21', '0987654323', N'753 Võ Thị Sáu, TP.HCM'),
(109, N'Nguyễn Thị Hoa', '1985-03-14', '0901234560', N'456 Nguyễn Đình Chiểu, TP.HCM'),
(110, N'Lê Văn Hòa', '1991-07-22', '0901234561', N'123 Phan Văn Trị, TP.HCM'),
(111, N'Trần Minh Tâm', '1978-11-01', '0901234562', N'789 Nguyễn Thị Minh Khai, TP.HCM'),
(112, N'Hoàng Thị Vân', '1995-06-18', '0901234563', N'654 Điện Biên Phủ, TP.HCM'),
(113, N'Ngô Văn Dũng', '1982-02-05', '0901234564', N'321 Hoàng Văn Thụ, TP.HCM'),
(114, N'Phạm Hồng Hà', '2001-08-25', '0901234565', N'987 Trường Chinh, TP.HCM'),
(115, N'Lê Thị Thu', '1990-12-15', '0901234566', N'159 Nguyễn Huệ, TP.HCM'),
(116, N'Trần Quốc Hùng', '1989-04-17', '0901234567', N'753 Lê Lợi, TP.HCM'),
(117, N'Nguyễn Văn Khoa', '1993-09-11', '0901234568', N'357 Cách Mạng Tháng Tám, TP.HCM'),
(118, N'Lý Thị Mai', '1998-05-20', '0901234569', N'246 Lê Lai, TP.HCM'),
(119, N'Hoàng Văn Bình', '1980-01-01', '0901234570', N'357 Võ Thị Sáu, TP.HCM'),
(120, N'Trần Thị Cẩm', '1984-03-19', '0901234571', N'753 Nam Kỳ Khởi Nghĩa, TP.HCM'),
(121, N'Nguyễn Hải Đăng', '1996-07-24', '0901234572', N'246 Pasteur, TP.HCM'),
(122, N'Lê Hoàng Nam', '2000-10-16', '0901234573', N'159 Tôn Đức Thắng, TP.HCM'),
(123, N'Trần Thị Thanh', '1983-06-05', '0901234574', N'321 Nguyễn Hữu Cảnh, TP.HCM');

INSERT INTO PhongKham (MaPhongKham, TenPhongKham, LoaiPhongKham, TinhTrangPhongKham) VALUES
(301, N'Phòng Khám 1', N'Nội khoa', N'Trống'),
(302, N'Phòng Khám 2', N'Ngoại khoa', N'Đang sử dụng'),
(303, N'Phòng Khám 3', N'Nhi khoa', N'Trống'),
(304, N'Phòng Khám 4', N'Tim mạch', N'Trống'),
(305, N'Phòng Khám 5', N'Da liễu', N'Đang sử dụng'),
(306, N'Phòng Khám 6', N'Răng hàm mặt', N'Trống');

INSERT INTO BacSi (MaBacSi, HoTenBacSi, ChuyenMon, SoDienThoai, MaPhongKham) VALUES
(201, N'Nguyễn Văn Dũng', N'Nội khoa', '0901234567', 301),
(202, N'Trần Thị Hoa', N'Ngoại khoa', '0912345678', 302),
(203, N'Lê Văn Hải', N'Nhi khoa', '0923456789', 303),
(204, N'Phạm Minh Tuấn', N'Tim mạch', '0931234567', 304),
(205, N'Nguyễn Thị Lan', N'Da liễu', '0942345678', 305),
(206, N'Trần Văn Bình', N'Răng hàm mặt', '0953456789', 306),
(207, N'Nguyễn Hoàng Long', N'Nội khoa', '0934567890', 301),
(208, N'Trần Thị Kim Hoa', N'Ngoại khoa', '0934567891', 302),
(209, N'Lê Văn Quang', N'Nhi khoa', '0934567892', 303),
(210, N'Phạm Văn Huy', N'Tim mạch', '0934567893', 304),
(211, N'Nguyễn Thị Hạnh', N'Da liễu', '0934567894', 305),
(212, N'Trần Văn Sơn', N'Răng hàm mặt', '0934567895', 306),
(213, N'Hoàng Thị Hương', N'Nội khoa', '0934567896', 301),
(214, N'Lê Minh Nhật', N'Ngoại khoa', '0934567897', 302),
(215, N'Phạm Quang Tùng', N'Nhi khoa', '0934567898', 303),
(216, N'Ngô Thị Tuyết', N'Tim mạch', '0934567899', 304), 
(217, N'Trần Văn Đức', N'Da liễu', '0934567800', 305),
(218, N'Lê Thị Vân Anh', N'Răng hàm mặt', '0934567801', 306),
(219, N'Nguyễn Hải Nam', N'Nội khoa', '0934567802', 301),
(220, N'Hoàng Minh Đức', N'Ngoại khoa', '0934567803', 302),
(221, N'Lý Văn Tuấn', N'Nhi khoa', '0934567804', 303);

INSERT INTO BenhAn (MaBenhAn, MaBenhNhan, MaBacSi, ChanDoan, NgayLapBenhAn) VALUES
(401, 101, 201, N'Cảm cúm', '2024-01-10'),
(402, 102, 202, N'Gãy xương', '2024-02-15'),
(403, 103, 203, N'Sốt xuất huyết', '2024-03-20'),
(404, 104, 204, N'Huyết áp cao', '2024-04-01'),
(405, 105, 205, N'Viêm da', '2024-05-12'),
(406, 106, 206, N'Sâu răng', '2024-06-20'),
(407, 107, 201, N'Cảm lạnh', '2024-07-15'),
(408, 108, 202, N'Chấn thương thể thao', '2024-08-30'),
(409, 109, 207, N'Viêm phổi', '2024-11-01'),
(410, 110, 208, N'Gãy tay', '2024-11-02'),
(411, 111, 209, N'Sốt cao', '2024-11-03'),
(412, 112, 210, N'Tim đập nhanh', '2024-11-04'),
(413, 113, 211, N'Chàm sữa', '2024-11-05'),
(414, 114, 212, N'Sâu răng', '2024-11-06'),
(415, 115, 213, N'Tra cứu máu', '2024-11-07'),
(416, 116, 210, N'Khám tim', '2024-11-08'),
(417, 117, 215, N'Viêm da', '2024-11-09'),
(418, 118, 212, N'Răng bị sâu', '2024-11-10');


INSERT INTO DonThuoc (MaDonThuoc, MaBenhAn, TenThuoc, LieuDung, SoLuong) VALUES
(501, 401, N'Paracetamol', '500mg', 10),
(502, 402, N'Ibuprofen', '400mg', 5),
(503, 401, N'Dexamethasone', '1mg', 3),
(504, 404, N'Amlodipine', '5mg', 15),
(505, 405, N'Hydrocortisone', '1%', 8),
(506, 402, N'Amoxicillin', '500mg', 12),
(507, 407, N'Antihistamine', '10mg', 20),
(508, 408, N'Pain Relief', '500mg', 10),
(509, 402, N'Paracetamol', '500mg', 12),  
(510, 410, N'Ibuprofen', '400mg', 8),    
(511, 411, N'Dexamethasone', '1mg', 6),
(512, 412, N'Amlodipine', '5mg', 10),
(513, 403, N'Hydrocortisone', '1%', 9),
(514, 414, N'Amoxicillin', '500mg', 14),
(515, 409, N'Antihistamine', '10mg', 22),
(516, 416, N'Pain Relief', '500mg', 11),
(517, 403, N'Paracetamol', '500mg', 15),
(518, 401, N'Ibuprofen', '400mg', 7);

INSERT INTO LichKham (MaLichKham, MaBenhNhan, MaBacSi, NgayKham, GioKham) VALUES
(601, 101, 201, '2024-01-11', '09:00:00'),
(602, 102, 202, '2024-02-16', '10:00:00'),
(603, 103, 203, '2024-03-21', '08:30:00'),
(604, 104, 204, '2024-04-02', '09:30:00'),
(605, 105, 205, '2024-05-13', '11:00:00'),
(606, 106, 206, '2024-06-21', '14:00:00'),
(607, 107, 201, '2024-07-16', '10:15:00'),
(608, 108, 202, '2024-08-31', '16:45:00'),
(609, 109, 207, '2024-12-01', '08:00:00'),
(610, 110, 208, '2024-12-02', '09:30:00'),
(611, 111, 209, '2024-12-03', '10:00:00'),
(612, 112, 210, '2024-12-04', '11:00:00'),
(613, 113, 211, '2024-12-05', '14:00:00'),
(614, 114, 212, '2024-12-06', '15:30:00'),
(615, 115, 213, '2024-12-07', '08:30:00'),
(616, 116, 214, '2024-12-08', '09:00:00'),
(617, 117, 215, '2024-12-09', '10:15:00'),
(618, 118, 216, '2024-12-10', '11:30:00'),
(619, 119, 217, '2024-12-11', '13:45:00'),
(620, 120, 218, '2024-12-12', '08:15:00'),
(621, 121, 219, '2024-12-13', '09:45:00'),
(622, 122, 220, '2024-12-14', '11:00:00'),
(623, 123, 221, '2024-12-15', '14:30:00'),
(624, 109, 208, '2024-12-16', '10:00:00'),
(625, 110, 209, '2024-12-17', '11:00:00'),
(626, 111, 210, '2024-12-18', '15:00:00'),
(627, 112, 211, '2024-12-19', '16:00:00'),
(628, 113, 212, '2024-12-20', '17:00:00');
