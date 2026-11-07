using System.ComponentModel.DataAnnotations;

namespace WebBanHang.Models
{
    public class LoginViewModel
    {
        [Required]
        public string TenDangNhap { get; set; }

        [Required]
        public string MatKhau { get; set; }
    }
}