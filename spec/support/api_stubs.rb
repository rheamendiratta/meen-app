require "webmock/rspec"

# Block all real outgoing HTTP in tests; stubs for the Anthropic API
# will live in individual spec files or shared contexts as needed.
WebMock.disable_net_connect!(allow_localhost: true)
