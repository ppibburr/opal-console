# vrbjs
Library to 'embed' ruby in to Vala programs via JavaScriptCore and Opal

Provides an executable to Execute/transpile ruby code from the command line using Opal in JavaScriptCore  

Using the executable
=
```
# transpiles then executes 'file.rb'
vrbjs file.rb

# transpiles 'source.rb' to 'source.rb.js'
vrbjs -c source.rb

# runs 'script.js' without requiring 'opal-parser' (can be required from code) FAST
vrbjs script.js

# transpiles the executes script from the command-line
vrbjs -e "puts 'Hello!'"

# Options
	-e	       Execute inline ruby script
	-v	       Print version
	-h	       Print this message
	-w	       run in headless WebKit
	-c	       Transpile ruby source to JS
	-j	       Execute inline js
	-r LIB     require LIB
	-d TARGET  dump the bridge code of an extension TARGET
	-D         Show debugging messages",
	-E         Force exit after executing script with '-w'
	-U URL     The url for the webview to open ie, '<http://|file:///>foo/bar.html' (valid with -w)

# Usage
vrbjs [options] [file|args]
```

Using the library
=
```vala
void main() {
  var opal = new Opal.Runtime(true);
  
  // Execute some ruby
  var rb = "def foo(i=3); return i*9; end;";
  
  opal.exec(rb);
  
  // Calling a ruby function
  var self = opal.exec("`#{self}`").to_object();
  var method = opal.exec("`#{self}.$foo`").to_object();
  
  //JSCore.Value[]? args = new JSCore.Value?[1];
  //args[0] = new JSCore.Value.number(opal.context, 3);
  
  JSCore.Value e = null;
  unowned JSCore.Value result = method.call_as_function(opal.context, self, null, out e);
  print("%s\n", opal.context.read_string(result)); // => '27'
}
```
