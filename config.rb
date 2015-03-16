module Config
  CONFIG_FILE = "#{ENV['HOME']}/.twterm.yml"

  def [](key)
    @config[key]
  end

  def []=(key, value)
    @config[key] = value
    save
  end

  def load
    unless File.exist? CONFIG_FILE
      @config = {}
      return
    end
    @config = YAML.load(File.read(CONFIG_FILE)) || {}
  end

  private

  def save
    begin
      file = File.open(CONFIG_FILE, 'w', 0600)
      file.write @config.to_yaml
    rescue
      puts 'exception raised'
    ensure
      file.close
    end
  end

  module_function :[], :[]=, :load, :save
end

Config.load
