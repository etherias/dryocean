class HelloMessage < ActiveRecord::Base
  def self.random_message
    id = HelloMessage.pluck(:id).sample
    message = HelloMessage.find(id)
    message.times_shown = (message.times_shown || 0) + 1
    message.save

    message
  end
end
