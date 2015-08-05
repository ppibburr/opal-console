namespace FFITestLib {
	public class SomePointer {
		public void takes_out_param(out int p) {
			p = 66;
		}
		
		public void takes_out_param2(out string p) {
			p = "worksuperfuckinglongstringstringstringsuperfuclinglongsuperfuckinglongs";
		}	
		
		public void takes_out_param3(out bool p) {
			p = true;
		}
		
		public void takes_out_param4(out SomePointer p) {
			p = this;
		}						
		
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
