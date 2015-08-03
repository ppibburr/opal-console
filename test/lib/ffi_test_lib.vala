namespace FFITestLib {
	public class SomePointer {
		public int returns_sint32() {
			return (int)69;
		}
		
		public string returns_string() {
			return "foo";
		}
		
		public bool returns_bool() {
			return true;
		}
		
		public int takes_string_returns_sint32(string str) {
			return str.length;
		}
		
		public delegate int b_cb(int a, int b);

		public int invokes_callback_param_returns_sint32(b_cb cb) {
			return cb(9,7);
		}
	}
}
