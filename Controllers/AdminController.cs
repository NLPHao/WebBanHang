using System.Linq;
using System.Web.Mvc;
using WebBanHang.Models; // Nhớ đổi tên namespace theo project của bạn

namespace WebBanHang.Controllers
{
    public class AdminController : Controller
    {
        private BANHANGEntities db = new BANHANGEntities();

        // GET: Admin/Index
        public ActionResult Index()
        {
            // 1. KIỂM TRA ĐĂNG NHẬP & QUYỀN ADMIN
            if (Session["TaiKhoan"] == null)
            {
                return RedirectToAction("DangNhap", "DangNhap"); // Chưa đăng nhập
            }

            var user = (nguoi_dung)Session["TaiKhoan"];
            if (user.id_vai_tro != 1)
            {
                return RedirectToAction("Index", "Home"); // Đăng nhập rồi nhưng không phải Admin
            }

            // 2. THỐNG KÊ SỐ LIỆU ĐỂ HIỂN THỊ
            ViewBag.SoLuongSanPham = db.san_pham.Count();
            ViewBag.SoLuongDonHang = db.don_hang.Count();
            ViewBag.SoLuongKhachHang = db.nguoi_dung.Count(u => u.id_vai_tro == 3); // Chỉ đếm khách hàng

            // Tính tổng doanh thu (nếu bảng đơn hàng có dữ liệu)
            var doanhThu = db.don_hang.Sum(d => (decimal?)d.tong_tien);
            ViewBag.TongDoanhThu = doanhThu.HasValue ? doanhThu.Value : 0;

            return View();
        }
    }
}