using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebBanHang.Models; // Thay bằng namespace của bạn
using System.Data.Entity; // Cần cái này để dùng .Include

namespace WebBanHang.Controllers
{
    public class QuanLyTaiKhoanController : Controller
    {
        private BANHANGEntities db = new BANHANGEntities();

        // 1. DANH SÁCH TÀI KHOẢN
        public ActionResult Index()
        {
            // Lấy danh sách người dùng, kèm theo thông tin vai trò (Include)
            // Sắp xếp ID vai trò để Admin hiện lên đầu
            var danhSach = db.nguoi_dung.Include("vai_tro").OrderBy(n => n.id_vai_tro).ToList();
            return View(danhSach);
        }

        // 2. TRANG CẤP QUYỀN (HIỆN FORM)
        public ActionResult PhanQuyen(string id)
        {
            // Tìm tài khoản theo ID
            var taiKhoan = db.nguoi_dung.Find(id);
            if (taiKhoan == null)
            {
                return HttpNotFound();
            }

            // Lấy danh sách các quyền (Admin, Nhân viên, Khách...) để đổ vào Dropdown
            // Value là id_vai_tro, Text là ten_vai_tro
            ViewBag.DanhSachQuyen = new SelectList(db.vai_tro.ToList(), "id_vai_tro", "ten_vai_tro", taiKhoan.id_vai_tro);

            return View(taiKhoan);
        }

        // 3. XỬ LÝ CẤP QUYỀN (LƯU VÀO DB)
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult PhanQuyen(string id, int id_vai_tro)
        {
            var taiKhoan = db.nguoi_dung.Find(id);
            if (taiKhoan != null)
            {
                // Cập nhật vai trò mới
                taiKhoan.id_vai_tro = id_vai_tro;
                db.SaveChanges();
            }
            return RedirectToAction("Index");
        }

        // 4. XÓA TÀI KHOẢN (Nếu cần)
        public ActionResult XoaTaiKhoan(string id)
        {
            var taiKhoan = db.nguoi_dung.Find(id);
            if (taiKhoan != null)
            {
                // Lưu ý: Nếu user đã có đơn hàng thì không xóa được (do dính khóa ngoại)
                // Tốt nhất là chuyển vai trò thành 'Bị khóa' thay vì xóa hẳn.
                try
                {
                    db.nguoi_dung.Remove(taiKhoan);
                    db.SaveChanges();
                }
                catch
                {
                    // Nếu lỗi thì thôi, quay về
                }
            }
            return RedirectToAction("Index");
        }
    }
}