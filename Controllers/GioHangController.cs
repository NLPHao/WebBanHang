using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebBanHang.Models;

namespace WebBanHang.Controllers
{
    public class GioHangController : Controller
    {
        private BANHANGEntities db = new BANHANGEntities();

        // 1. LẤY GIỎ HÀNG TỪ SESSION
        public List<GioHang> LayGioHang()
        {
            List<GioHang> lstGioHang = Session["GioHang"] as List<GioHang>;
            if (lstGioHang == null)
            {
                // Nếu chưa có giỏ hàng thì khởi tạo list mới
                lstGioHang = new List<GioHang>();
                Session["GioHang"] = lstGioHang;
            }
            return lstGioHang;
        }

        // 2. THÊM VÀO GIỎ HÀNG
        // 1. SỬA HÀM THÊM GIỎ HÀNG (Thêm dòng TempData)
        // Thêm tham số "int? soLuong" vào hàm
        public ActionResult ThemGioHang(int iMaSP, string strURL, int? soLuong)
        {
            // 1. Lấy giỏ hàng
            List<GioHang> lstGioHang = LayGioHang();

            // 2. Xử lý số lượng: Nếu form không gửi lên (null) hoặc gửi bằng 0 thì mặc định là 1
            int slThem = 1;
            if (soLuong != null && soLuong > 0)
            {
                slThem = soLuong.Value;
            }

            // 3. Tìm sản phẩm trong giỏ
            GioHang sanPham = lstGioHang.Find(n => n.iMaSP == iMaSP);

            if (sanPham == null)
            {
                // Nếu chưa có thì tạo mới và gán số lượng
                sanPham = new GioHang(iMaSP);
                sanPham.iSoLuong = slThem; // <-- Gán đúng số lượng khách chọn
                lstGioHang.Add(sanPham);
            }
            else
            {
                // Nếu có rồi thì cộng thêm số lượng khách vừa chọn
                sanPham.iSoLuong += slThem; // <-- Cộng thêm
            }

            TempData["ThongBao"] = "Thêm vào giỏ hàng thành công!";
            return Redirect(strURL);
        }

        // 2. THÊM HÀM XÓA SẢN PHẨM (Copy đoạn này vào Controller)
        public ActionResult XoaGioHang(int iMaSP)
        {
            // Lấy giỏ hàng
            List<GioHang> lstGioHang = LayGioHang();

            // Tìm sản phẩm cần xóa
            GioHang sanPham = lstGioHang.SingleOrDefault(n => n.iMaSP == iMaSP);

            // Nếu có thì xóa
            if (sanPham != null)
            {
                lstGioHang.Remove(sanPham);
            }

            // Nếu giỏ hàng trống thì về trang chủ
            if (lstGioHang.Count == 0)
            {
                return RedirectToAction("Index", "San_Pham");
            }

            return RedirectToAction("GioHang");
        }

        // 3. (Tùy chọn) XÓA TẤT CẢ
        public ActionResult XoaTatCaGioHang()
        {
            List<GioHang> lstGioHang = LayGioHang();
            lstGioHang.Clear();
            return RedirectToAction("Index", "San_Pham");
        }

        // 3. TRANG GIỎ HÀNG
        public ActionResult GioHang()
        {
            List<GioHang> lstGioHang = LayGioHang();
            if (lstGioHang.Count == 0)
            {
                return RedirectToAction("Index", "San_Pham");
            }
            ViewBag.TongSoLuong = lstGioHang.Sum(n => n.iSoLuong);
            ViewBag.TongTien = lstGioHang.Sum(n => n.dThanhTien);
            return View(lstGioHang);
        }

        // 4. CHỨC NĂNG ĐẶT HÀNG (Hiển thị form)
        [HttpGet]
        public ActionResult DatHang()
        {
            // Kiểm tra đăng nhập
            if (Session["TaiKhoan"] == null || Session["TaiKhoan"].ToString() == "")
            {
                return RedirectToAction("DangNhap", "DangNhap");
            }

            // Kiểm tra giỏ hàng có trống không
            if (Session["GioHang"] == null)
            {
                return RedirectToAction("Index", "San_Pham");
            }

            List<GioHang> lstGioHang = LayGioHang();
            ViewBag.TongSoLuong = lstGioHang.Sum(n => n.iSoLuong);
            ViewBag.TongTien = lstGioHang.Sum(n => n.dThanhTien);

            return View(lstGioHang);
        }

        // 5. CHỨC NĂNG ĐẶT HÀNG (Lưu vào DB)
        [HttpPost]
        [ValidateAntiForgeryToken] // Thêm cái này để bảo mật form
        public ActionResult DatHang(FormCollection f)
        {
            // 1. Kiểm tra lại session giỏ hàng và tài khoản
            if (Session["TaiKhoan"] == null || Session["GioHang"] == null)
            {
                return RedirectToAction("Index", "San_Pham");
            }

            try
            {
                // 2. Lấy dữ liệu cần thiết
                don_hang ddh = new don_hang();
                nguoi_dung kh = (nguoi_dung)Session["TaiKhoan"];
                List<GioHang> gh = LayGioHang();

                // 3. Tạo thông tin đơn hàng
                // Sinh mã đơn hàng: DH + NămThángNgàyGiờPhútGiây (Ví dụ: DH20240101123000)
                ddh.id_don_hang = "DH" + DateTime.Now.ToString("yyyyMMddHHmmss");
                ddh.id_nguoi_dung = kh.id_nguoi_dung;
                ddh.ngay_dat_hang = DateTime.Now;

                // Lấy thông tin người nhận từ Form
                ddh.dia_chi_giao_hang = f["DiaChiNhan"];
                ddh.so_dien_thoai_nhan = f["SDTNhan"];
                ddh.ghi_chu = f["GhiChu"];

                // QUAN TRỌNG: Đặt trạng thái là "Chờ xử lý" để Admin thấy và duyệt
                ddh.trang_thai_don_hang = "Chờ xử lý";

                // Tính tổng tiền
                ddh.tong_tien = (decimal)gh.Sum(n => n.dThanhTien);

                // 4. Lưu Đơn Hàng vào Database
                db.don_hang.Add(ddh);
                db.SaveChanges(); // Lưu xong dòng này mới có mã đơn hàng để lưu chi tiết

                // 5. Lưu Chi Tiết Đơn Hàng
                foreach (var item in gh)
                {
                    chi_tiet_don_hang ct = new chi_tiet_don_hang();
                    ct.id_don_hang = ddh.id_don_hang; // Lấy mã vừa tạo ở trên
                    ct.id_san_pham = item.iMaSP;
                    ct.so_luong = item.iSoLuong;
                    ct.don_gia = (decimal)item.dDonGia;

                    db.chi_tiet_don_hang.Add(ct);
                }
                db.SaveChanges(); // Lưu tất cả chi tiết

                // 6. Xử lý sau khi thành công
                Session["GioHang"] = null; // Xóa sạch giỏ hàng

                // Tạo thông báo Toast (Đã cài đặt ở Layout)
                TempData["ThongBao"] = "Đặt hàng thành công! Đơn hàng đang chờ duyệt.";

                // CHUYỂN HƯỚNG VỀ TRANG CHỦ (Theo yêu cầu của bạn)
                return RedirectToAction("Index", "San_Pham");
            }
            catch (Exception ex)
            {
                // Nếu lỗi thì hiện thông báo và ở lại trang đặt hàng
                ViewBag.ThongBaoLoi = "Lỗi khi lưu đơn hàng: " + ex.Message;
                return View(LayGioHang());
            }
        }

        public ActionResult XacNhanDonHang()
        {
            return View();
        }
    }
}