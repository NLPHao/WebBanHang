using System;
using System.Collections.Generic;
using System.IO; // Để xử lý file ảnh
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebBanHang.Models; // Đổi namespace theo dự án của bạn

namespace WebBanHang.Controllers
{
    public class QuanLySanPhamController : Controller
    {
        private BANHANGEntities db = new BANHANGEntities();

        // --- 1. HIỂN THỊ DANH SÁCH (READ) ---
        public ActionResult Index()
        {
            // Kiểm tra quyền Admin (Copy từ bài trước)
            if (Session["TaiKhoan"] == null || ((nguoi_dung)Session["TaiKhoan"]).id_vai_tro != 1)
                return RedirectToAction("DangNhap", "DangNhap");

            // Lấy danh sách sản phẩm, sắp xếp mới nhất lên đầu
            var products = db.san_pham.OrderByDescending(s => s.id_san_pham).ToList();
            return View(products);
        }

        // --- 2. THÊM MỚI (CREATE) ---
        [HttpGet]
        public ActionResult Create()
        {
            // Load danh sách Danh mục và Thương hiệu vào Dropdown
            ViewBag.id_danh_muc = new SelectList(db.danh_muc, "id_danh_muc", "ten_danh_muc");
            ViewBag.id_thuong_hieu = new SelectList(db.thuong_hieu, "id_thuong_hieu", "ten_thuong_hieu");
            return View();
        }

        [HttpPost]
        [ValidateInput(false)] // Cho phép nhập HTML trong mô tả
        public ActionResult Create(san_pham model, HttpPostedFileBase hinh_anh)
        {
            if (ModelState.IsValid)
            {
                // Xử lý lưu ảnh
                if (hinh_anh != null && hinh_anh.ContentLength > 0)
                {
                    string filename = Path.GetFileName(hinh_anh.FileName);
                    string path = Path.Combine(Server.MapPath("~/Images/"), filename);
                    hinh_anh.SaveAs(path);
                    model.hinh_anh_dai_dien = filename; // Lưu tên file vào DB
                }

                model.so_luong_ton = 0; // Mặc định kho = 0 nếu chưa nhập
                model.trang_thai = true; // Mặc định đang bán

                db.san_pham.Add(model);
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            // Nếu lỗi thì load lại Dropdown
            ViewBag.id_danh_muc = new SelectList(db.danh_muc, "id_danh_muc", "ten_danh_muc", model.id_danh_muc);
            ViewBag.id_thuong_hieu = new SelectList(db.thuong_hieu, "id_thuong_hieu", "ten_thuong_hieu", model.id_thuong_hieu);
            return View(model);
        }

        // --- 3. CHỈNH SỬA (UPDATE) ---
        [HttpGet]
        public ActionResult Edit(int id)
        {
            var product = db.san_pham.Find(id);
            if (product == null) return HttpNotFound();

            ViewBag.id_danh_muc = new SelectList(db.danh_muc, "id_danh_muc", "ten_danh_muc", product.id_danh_muc);
            ViewBag.id_thuong_hieu = new SelectList(db.thuong_hieu, "id_thuong_hieu", "ten_thuong_hieu", product.id_thuong_hieu);
            return View(product);
        }

        [HttpPost]
        [ValidateInput(false)]
        public ActionResult Edit(san_pham model, HttpPostedFileBase hinh_anh)
        {
            if (ModelState.IsValid)
            {
                var existingProduct = db.san_pham.Find(model.id_san_pham);

                // Cập nhật thông tin thường
                existingProduct.ten_san_pham = model.ten_san_pham;
                existingProduct.gia_ban = model.gia_ban;
                existingProduct.gia_khuyen_mai = model.gia_khuyen_mai;
                existingProduct.so_luong_ton = model.so_luong_ton;
                existingProduct.mo_ta_chi_tiet = model.mo_ta_chi_tiet;
                existingProduct.id_danh_muc = model.id_danh_muc;
                existingProduct.id_thuong_hieu = model.id_thuong_hieu;

                // Kiểm tra nếu có chọn ảnh mới thì thay thế, không thì giữ nguyên ảnh cũ
                if (hinh_anh != null && hinh_anh.ContentLength > 0)
                {
                    string filename = Path.GetFileName(hinh_anh.FileName);
                    string path = Path.Combine(Server.MapPath("~/Images/"), filename);
                    hinh_anh.SaveAs(path);
                    existingProduct.hinh_anh_dai_dien = filename;
                }

                db.SaveChanges(); // Lưu vào DB
                return RedirectToAction("Index");
            }
            // Load lại dropdown nếu lỗi
            ViewBag.id_danh_muc = new SelectList(db.danh_muc, "id_danh_muc", "ten_danh_muc", model.id_danh_muc);
            ViewBag.id_thuong_hieu = new SelectList(db.thuong_hieu, "id_thuong_hieu", "ten_thuong_hieu", model.id_thuong_hieu);
            return View(model);
        }

        // --- 4. XÓA (DELETE) ---
        public ActionResult Delete(int id)
        {
            var product = db.san_pham.Find(id);
            if (product != null)
            {
                db.san_pham.Remove(product);
                db.SaveChanges();
            }
            return RedirectToAction("Index");
        }
    }
}