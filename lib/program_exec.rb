VRbJS.require("getopt")

ARGV.shift;

VERSION = "0.1.0"

OPTIONS = {
  e: "Execute inline ruby script",
  v: "Print version",
  h: "Print this message",
  w: "run in headless WebKit",
  c: "Transpile ruby source to JS",
  j: "Execute inline js",
  "r LIB"    => "require LIB",
  "d TARGET" => "dump the bridge code of an extension TARGET",
  D: "Show debugging messages",
  E: "Force exit after executing script with '-w'",
  "U URL"    => "The url for the webview to open ie, '<http://|file:///>foo/bar.html' (valid with -w)"
}


def usage(msg="");
  puts msg

  puts "opala - A ruby source runner/transpiler via VRbJS in JavaScriptCore\n\n"
  
  puts "Usage:"
  puts "opala [OPTIONs] [PATH|CODE]\n\n"
  
  puts "OPTIONS:"
  OPTIONS.map do |k, v|
    print "-#{k}".ljust(10) + "#{v}\n"
  end
end;

begin
  PROGRAM = Program.new()
  opts = Getopt::Std.getopts("d:vhwcejsr:EDU:")

  $0 = "(file)"
  
  if opts['D']
    VRbJS.set_debug(true)
  end
  
  if !!opts['E'] and !opts['w']
    puts "WARN: -E without -w is useless";
  end
  
  unless opts['v'] or opts['h'] or opts['d'] or (opts['U'] and !opts['w'])
    if opts['c']
      if opts.length != 1
        raise "Too many options passed. -c takes 0 options"
      end
     
      source = PROGRAM.read(ARGV.last)
     
      `Opal.require('opal-parser');`
     
      PROGRAM.write(ARGV.last+".js", `Opal.compile(#{source})`)
    else
      $0 = "(file)"
      parser = true
      if opts['e']
        code = ARGV.last
      elsif opts['j']
        code = ARGV.last
        parser = false
      else
        $0 = ARGV.shift
        
        code = false
        
        ARGV.each do |a|
          PROGRAM.append_argv(a);
        end        
        
        if $0.split(".").last != "rb"
          parser = false
        end
      end
      
      # puts "run(#{code}, #{!!opts['w']}, #{parser}, #{$0});"
      if !opts['r'].is_a?(Array)
        if !!opts['r']
          opts['r'] = [opts['r']]
        else
          opts['r'] = []
        end
      end

      PROGRAM.run(code, !!opts['w'], parser, !!opts['D'], !!opts['E'], $0, opts['r'], opts['U'] || "");
    end
  else
    if opts['v']
      puts VERSION
    elsif opts['h']
      usage()
    
    elsif opts['d']
      puts PROGRAM.dump(opts['d'])
    end
  end
rescue => e
  usage(e)
end
