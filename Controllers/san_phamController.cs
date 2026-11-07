using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using WebBanHang.Models;

namespace WebBanHang.Controllers
{
    public class san_phamController : Controller
    {
        private BANHANGEntities db = new BANHANGEntities();

        // GET: san_pham
        // GET: san_pham
        // Thêm tham số searchString vào hàm Index
        // GET: San_Pham
        // Thêm tham số int? id (Dấu ? nghĩa là có thể null - không chọn gì)
        public ActionResult Index(int? id)
        {
            // 1. GỬI DANH SÁCH DANH MỤC SANG VIEW ĐỂ VẼ MENU
            // Nếu không có dòng này, menu sẽ trống trơn hoặc lỗi
            ViewBag.ListDanhMuc = db.danh_muc.ToList();

            // Lưu lại ID hiện tại để tô màu nút Active (Optional)
            ViewBag.IdHienTai = id;

            // 2. LỌC SẢN PHẨM
            if (id == null)
            {
                // Nếu không chọn gì -> Lấy hết
                var allProducts = db.san_pham.OrderByDescending(s => s.id_san_pham).ToList();
                return View(allProducts);
            }
            else
            {
                // Nếu có chọn ID -> Lọc theo ID danh mục
                var filteredProducts = db.san_pham
                                         .Where(s => s.id_danh_muc == id)
                                         .OrderByDescending(s => s.id_san_pham)
                                         .ToList();
                return View(filteredProducts);
            }
        }

        // GET: san_pham/Details/5
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            // QUAN TRỌNG: Thêm .Include("thong_so_ky_thuat") để lấy luôn các thông số kèm theo sản phẩm
            san_pham san_pham = db.san_pham.Include("thong_so_ky_thuat").Include("danh_muc").Include("thuong_hieu").SingleOrDefault(s => s.id_san_pham == id);

            if (san_pham == null)
            {
                return HttpNotFound();
            }
            return View(san_pham);
        }

        // GET: san_pham/Create
        public ActionResult Create()
        {
            ViewBag.id_danh_muc = new SelectList(db.danh_muc, "id_danh_muc", "ten_danh_muc");
            ViewBag.id_thuong_hieu = new SelectList(db.thuong_hieu, "id_thuong_hieu", "ten_thuong_hieu");
            return View();
        }

        // POST: san_pham/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "id_san_pham,ten_san_pham,gia_ban,gia_khuyen_mai,so_luong_ton,mo_ta_chi_tiet,hinh_anh_dai_dien,id_danh_muc,id_thuong_hieu,trang_thai")] san_pham san_pham)
        {
            if (ModelState.IsValid)
            {
                db.san_pham.Add(san_pham);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            ViewBag.id_danh_muc = new SelectList(db.danh_muc, "id_danh_muc", "ten_danh_muc", san_pham.id_danh_muc);
            ViewBag.id_thuong_hieu = new SelectList(db.thuong_hieu, "id_thuong_hieu", "ten_thuong_hieu", san_pham.id_thuong_hieu);
            return View(san_pham);
        }

        // GET: san_pham/Edit/5
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            san_pham san_pham = db.san_pham.Find(id);
            if (san_pham == null)
            {
                return HttpNotFound();
            }
            ViewBag.id_danh_muc = new SelectList(db.danh_muc, "id_danh_muc", "ten_danh_muc", san_pham.id_danh_muc);
            ViewBag.id_thuong_hieu = new SelectList(db.thuong_hieu, "id_thuong_hieu", "ten_thuong_hieu", san_pham.id_thuong_hieu);
            return View(san_pham);
        }

        // POST: san_pham/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "id_san_pham,ten_san_pham,gia_ban,gia_khuyen_mai,so_luong_ton,mo_ta_chi_tiet,hinh_anh_dai_dien,id_danh_muc,id_thuong_hieu,trang_thai")] san_pham san_pham)
        {
            if (ModelState.IsValid)
            {
                db.Entry(san_pham).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.id_danh_muc = new SelectList(db.danh_muc, "id_danh_muc", "ten_danh_muc", san_pham.id_danh_muc);
            ViewBag.id_thuong_hieu = new SelectList(db.thuong_hieu, "id_thuong_hieu", "ten_thuong_hieu", san_pham.id_thuong_hieu);
            return View(san_pham);
        }

        // GET: san_pham/Delete/5
        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            san_pham san_pham = db.san_pham.Find(id);
            if (san_pham == null)
            {
                return HttpNotFound();
            }
            return View(san_pham);
        }

        // POST: san_pham/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            san_pham san_pham = db.san_pham.Find(id);
            db.san_pham.Remove(san_pham);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
