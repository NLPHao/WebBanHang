using System;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web.Mvc;
using WebBanHang.Models;

namespace WebBanHang.Controllers
{
    public class DangNhapController : Controller
    {
        private BANHANGEntities db = new BANHANGEntities();

        // --- HÀM HỖ TRỢ: MÃ HÓA PASSWORD (MD5) ---
        // Bạn có thể dùng SHA256 để bảo mật hơn, ở đây dùng MD5 cho đơn giản
      

        // ==========================================
        // PHẦN ĐĂNG KÝ (MỚI THÊM)
        // ==========================================

        [HttpGet]
        public ActionResult DangKy()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        
        public ActionResult DangKy(DangKyViewModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    string diaChi = "";

                    // --- SỬA ĐỔI TỪ ĐÂY ---
                    // Thay <int> thành <KetQuaSP> để hứng đủ cột KetQua và ThongBao
                    var result = db.Database.SqlQuery<KetQuaSP>(
                        "EXEC sp_DangKyTaiKhoan @TaiKhoan, @MatKhau, @HoTen, @Email, @SoDienThoai, @DiaChi",
                        new System.Data.SqlClient.SqlParameter("@TaiKhoan", model.TaiKhoan),
                        new System.Data.SqlClient.SqlParameter("@MatKhau", model.MatKhau),
                        new System.Data.SqlClient.SqlParameter("@HoTen", model.HoTen),
                        new System.Data.SqlClient.SqlParameter("@Email", model.Email),
                        new System.Data.SqlClient.SqlParameter("@SoDienThoai", model.SoDienThoai),
                        new System.Data.SqlClient.SqlParameter("@DiaChi", diaChi)
                    ).FirstOrDefault();

                    if (result != null)
                    {
                        // Kiểm tra kết quả trả về
                        if (result.KetQua == 1)
                        {
                            // Thành công
                            TempData["ThongBaoThanhCong"] = result.ThongBao; // Lấy câu thông báo từ SQL
                            return RedirectToAction("DangNhap");
                        }
                        else
                        {
                            // Thất bại (-1, -2, -3...): Hiện luôn thông báo từ SQL cho tiện
                            ModelState.AddModelError("", result.ThongBao);
                        }
                    }
                    else
                    {
                        ModelState.AddModelError("", "Không nhận được phản hồi từ hệ thống.");
                    }
                    // --- KẾT THÚC SỬA ĐỔI ---
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError("", "Lỗi hệ thống: " + ex.Message);
                }
            }
            return View(model);
        }

        // ==========================================
        // PHẦN ĐĂNG NHẬP (ĐÃ CẬP NHẬT LOGIC HASH)
        // ==========================================
        [HttpGet]
        public ActionResult DangNhap()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DangNhap(LoginViewModel model)
        {
            // Kiểm tra các ràng buộc (trống, độ dài...)
            if (ModelState.IsValid)
            {
                // Tìm tài khoản trong DB
                var user = db.nguoi_dung.SingleOrDefault(k => k.tai_khoan == model.TenDangNhap && k.mat_khau == model.MatKhau);

                if (user != null)
                {
                    // --- ĐĂNG NHẬP THÀNH CÔNG ---
                    Session["TaiKhoan"] = user;
                    Session["TenHienThi"] = user.ho_ten; // Nên lấy họ tên hiển thị cho đẹp

                    // Phân quyền chuyển hướng
                    if (user.id_vai_tro == 1)
                    {
                        return RedirectToAction("Index", "Admin"); // Trang Admin
                    }
                    else
                    {
                        return RedirectToAction("Index", "San_Pham"); // Trang Khách
                    }
                }
                else
                {
                    // --- ĐÂY LÀ ĐOẠN BẠN ĐANG THIẾU ---
                    // Nếu tìm không thấy user (tức là sai tài khoản hoặc mật khẩu)
                    // Gán thông báo lỗi vào ViewBag để hiển thị bên View
                    ViewBag.ThongBao = "Tên đăng nhập hoặc mật khẩu không đúng!";

                    // Hoặc dùng cách chuẩn của Model:
                    ModelState.AddModelError("", "Tên đăng nhập hoặc mật khẩu không đúng!");
                }
            }

            // Trả về View cùng với model để người dùng không phải nhập lại từ đầu
            return View(model);
        }

        public ActionResult DangXuat()
        {
            Session["TaiKhoan"] = null;
            Session["TenHienThi"] = null;
            return RedirectToAction("Index", "san_pham");
        }
        // ... Các code cũ giữ nguyên ...

        // 1. GET: Xem thông tin tài khoản
        public ActionResult ThongTinTaiKhoan()
        {
            // Kiểm tra đã đăng nhập chưa
            if (Session["TaiKhoan"] == null)
            {
                return RedirectToAction("DangNhap");
            }

            // Lấy thông tin user từ Session
            var userSession = (WebBanHang.Models.nguoi_dung)Session["TaiKhoan"];

            // Lấy lại dữ liệu mới nhất từ DB (đề phòng user đã bị sửa đổi)
            var user = db.nguoi_dung.SingleOrDefault(u => u.id_nguoi_dung == userSession.id_nguoi_dung);

            return View(user);
        }

        // 2. GET: Trang Đổi mật khẩu
        public ActionResult DoiMatKhau()
        {
            if (Session["TaiKhoan"] == null)
            {
                return RedirectToAction("DangNhap");
            }
            return View();
        }

        // 3. POST: Xử lý Đổi mật khẩu
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult DoiMatKhau(string matKhauCu, string matKhauMoi, string xacNhanMatKhau)
        {
            if (Session["TaiKhoan"] == null) return RedirectToAction("DangNhap");

            // Lấy user hiện tại
            var userSession = (WebBanHang.Models.nguoi_dung)Session["TaiKhoan"];
            var user = db.nguoi_dung.SingleOrDefault(u => u.id_nguoi_dung == userSession.id_nguoi_dung);

            // Kiểm tra mật khẩu cũ
            if (user.mat_khau != matKhauCu)
            {
                ModelState.AddModelError("", "Mật khẩu cũ không đúng.");
                return View();
            }

            // Kiểm tra mật khẩu mới
            if (matKhauMoi != xacNhanMatKhau)
            {
                ModelState.AddModelError("", "Xác nhận mật khẩu không khớp.");
                return View();
            }

            if (matKhauMoi.Length < 6)
            {
                ModelState.AddModelError("", "Mật khẩu mới phải từ 6 ký tự.");
                return View();
            }

            // Cập nhật mật khẩu mới
            user.mat_khau = matKhauMoi;
            db.SaveChanges(); // Lưu vào CSDL

            ViewBag.ThongBao = "Đổi mật khẩu thành công!";
            return View();
        }
    }
    // Class dùng để hứng kết quả từ Stored Procedure
    public class KetQuaSP
    {
        public int KetQua { get; set; }
        public string ThongBao { get; set; }
    }
}