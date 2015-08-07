$stderr.write_proc = Proc.new do |s|
  `new Stderr().write(s)`
end
