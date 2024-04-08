begin
  require 'amazing_print'
  AmazingPrint.irb!
rescue LoadError
  # Do nothing
end

# Disable 'mutliline' support due to poor pasting performance
# see https://github.com/ruby/irb/issues/43
IRB.conf[:USE_MULTILINE] = false
