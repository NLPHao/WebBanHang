using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebBanHang.Models; // Nhớ đổi tên namespace theo project của bạn
using System.Data.Entity; // Cần cái này để dùng .Include

namespace WebBanHang.Controllers
{
    public class QuanLyDonHangController : Controller
    {
        private BANHANGEntities db = new BANHANGEntities();

        // 1. DANH SÁCH ĐƠN HÀNG
        public ActionResult Index()
        {
            // Lấy danh sách đơn hàng, sắp xếp ngày mới nhất lên đầu
            // .Include("nguoi_dung") để lấy tên khách hàng từ bảng người dùng
            var listDonHang = db.don_hang.Include("nguoi_dung").OrderByDescending(n => n.ngay_dat_hang).ToList();
            return View(listDonHang);
        }

        // 2. XEM CHI TIẾT ĐƠN HÀNG
        public ActionResult ChiTiet(string id)
        {
            // Lấy đơn hàng theo ID
            var donHang = db.don_hang.Include("nguoi_dung").FirstOrDefault(n => n.id_don_hang == id);

            if (donHang == null)
            {
                return HttpNotFound();
            }

            // Lấy danh sách sản phẩm trong đơn hàng đó
            // .Include("san_pham") để lấy tên và ảnh sản phẩm
            var chiTiet = db.chi_tiet_don_hang.Include("san_pham").Where(n => n.id_don_hang == id).ToList();

            // Truyền danh sách chi tiết sang View, còn thông tin đơn hàng thì bỏ vào ViewBag
            ViewBag.DonHang = donHang;
            return View(chiTiet);
        }

        // 3. DUYỆT ĐƠN HÀNG (Chuyển sang Đã giao/Đang giao)
        // ... (Các đoạn code cũ giữ nguyên)

        // 1. DUYỆT ĐƠN (Chờ xử lý -> Đã xác nhận)
        public ActionResult DuyetDon(string id)
        {
            var donHang = db.don_hang.Find(id);
            if (donHang != null)
            {
                donHang.trang_thai_don_hang = "Đã xác nhận"; // Chuyển sang đã xác nhận
                db.SaveChanges();
            }
            return RedirectToAction("Index");
        }

        // 2. XÁC NHẬN GIAO HÀNG (Đã xác nhận -> Đã giao)
        public ActionResult XacNhanGiaoHang(string id)
        {
            var donHang = db.don_hang.Find(id);
            if (donHang != null)
            {
                donHang.trang_thai_don_hang = "Đã giao"; // Chuyển sang đã giao
                db.SaveChanges();
            }
            return RedirectToAction("Index");
        }

        // 3. HỦY ĐƠN (Giữ nguyên)
        public ActionResult HuyDon(string id)
        {
            var donHang = db.don_hang.Find(id);
            if (donHang != null)
            {
                donHang.trang_thai_don_hang = "Đã hủy";
                db.SaveChanges();
            }
            return RedirectToAction("Index");
        }
    }
}