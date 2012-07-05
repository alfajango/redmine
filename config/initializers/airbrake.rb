filename = File.join(Rails.root, 'config', 'airbrake.yml')

if File.exists?(filename)
  file = ERB.new( File.read(filename) ).result
  yaml = YAML::load(file)[Rails.env]

  Airbrake.configure do |config|
    config.api_key    = yaml['api_key']
    config.host       = yaml['host']
    config.port       = yaml['port']
    config.secure     = yaml['secure'].nil? ? (config.port == 443) : yaml['secure']
  end
end
