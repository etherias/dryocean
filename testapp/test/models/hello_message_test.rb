require 'test_helper'

class HelloMessageTest < ActiveSupport::TestCase
   test "selecting a message increments view count" do
     HelloMessage.create!(:message => "Test 1")
     HelloMessage.random_message
     assert HelloMessage.first.times_shown == 1
   end
end
