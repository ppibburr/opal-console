$stdout.write_proc = Proc.new do |s|
  `new Stdout().write(s)`
end
