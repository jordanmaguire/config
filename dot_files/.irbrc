begin
  require 'awesome_print'
  AwesomePrint.irb!
rescue LoadError
  # Do nothing
end
