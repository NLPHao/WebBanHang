using System;
using System.Linq;

namespace WebBanHang.Models
{
    public class GioHang
    {
        // Dùng biến db để truy vấn thông tin sản phẩm
        private BANHANGEntities db = new BANHANGEntities();

        public int iMaSP { get; set; }
        public string sTenSP { get; set; }
        public string sAnh { get; set; }
        public double dDonGia { get; set; }
        public int iSoLuong { get; set; }

        // Tính thành tiền = Số lượng * Đơn giá
        public double dThanhTien
        {
            get { return iSoLuong * dDonGia; }
        }

        // Hàm tạo cho giỏ hàng (Lấy thông tin từ DB dựa vào ID)
        public GioHang(int MaSP)
        {
            iMaSP = MaSP;
            san_pham sp = db.san_pham.Single(n => n.id_san_pham == iMaSP);
            sTenSP = sp.ten_san_pham;
            sAnh = sp.hinh_anh_dai_dien;
            // Nếu có giá khuyến mãi thì lấy, không thì lấy giá bán
            dDonGia = double.Parse((sp.gia_khuyen_mai ?? sp.gia_ban).ToString());
            iSoLuong = 1;
        }
    }
}