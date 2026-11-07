using System.ComponentModel.DataAnnotations;

namespace WebBanHang.Models
{
    public class DangKyViewModel
    {
        [Required(ErrorMessage = "Vui lòng nhập họ và tên")]
        [Display(Name = "Họ và tên")]
        public string HoTen { get; set; } // <--- THÊM MỚI

        [Display(Name = "Tên đăng nhập")]
        [Required(ErrorMessage = "Vui lòng nhập tên tài khoản")]
        public string TaiKhoan { get; set; }

        [Display(Name = "Mật khẩu")]
        [Required(ErrorMessage = "Vui lòng nhập mật khẩu")]
        [MinLength(6, ErrorMessage = "Mật khẩu ít nhất 6 ký tự")]
        public string MatKhau { get; set; }

        [Display(Name = "Xác nhận mật khẩu")]
        [Required(ErrorMessage = "Vui lòng nhập lại mật khẩu")]
        [Compare("MatKhau", ErrorMessage = "Mật khẩu xác nhận không khớp")]
        public string XacNhanMatKhau { get; set; }

        // --- THAY THẾ HỌ TÊN BẰNG SỐ ĐIỆN THOẠI ---
        [Display(Name = "Số điện thoại")]
        [Required(ErrorMessage = "Vui lòng nhập số điện thoại")]
        [RegularExpression(@"^(0[3|5|7|8|9])+([0-9]{8})$", ErrorMessage = "Số điện thoại không đúng định dạng VN")]
        public string SoDienThoai { get; set; }

        [Display(Name = "Email")]
        [Required(ErrorMessage = "Vui lòng nhập Email")]
        [EmailAddress(ErrorMessage = "Email không hợp lệ")]
        public string Email { get; set; }
        public class SpResult
        {
            public int KetQua { get; set; }
            public string ThongBao { get; set; }
        }

        // (Xóa bỏ trường DiaChi trong Model nếu bạn muốn bắt buộc tất cả và không muốn nhập địa chỉ lúc này)
        // Hoặc nếu muốn giữ Địa chỉ nhưng không bắt buộc thì để lại, còn bắt buộc thì thêm [Required]
    }
}