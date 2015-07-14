# opal-console
Library to 'embed' ruby in to Vala programs via JavaScriptCore and Opal

Provides an executable to Execute/transpile ruby code from the command line using Opal in JavaScriptCore  

Usage
===
```
# transpiles then executes 'file.rb'
ovala file.rb

# transpiles 'source.rb' to 'source.rb.js'
ovala -c source.rb

# runs 'script.js' without requiring 'opal-parser' (can be required from code) FAST
ovala script.js

# transpiles the executes script from the command-line
ovala -e "puts 'Hello!'"

# Options
-c         transpile
-e         execute inline script
-w         DOM Access via a headless webkit webview

# Usage
ovala [options] [file|args]
```
