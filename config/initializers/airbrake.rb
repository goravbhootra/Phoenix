Airbrake.configure do |config|
  config.api_key = ENV["AIRBRAKE_API"]
  config.ignore_only = []
end
