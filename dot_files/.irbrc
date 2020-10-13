begin
  require 'amazing_print'
  AmazingPrint.irb!
rescue LoadError
  # Do nothing
end
