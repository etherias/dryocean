json.array!(@hello_messages) do |hello_message|
  json.extract! hello_message, :id, :message, :times_shown
  json.url hello_message_url(hello_message, format: :json)
end
