require 'irb/completion'
require 'pp'
IRB.conf[:AUTO_INDENT] = true
IRB.conf[:USE_READLINE] = true

def cls
  system('cls')
end

puts "IRB Configuration is Loaded"
