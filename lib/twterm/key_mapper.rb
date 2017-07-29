require 'toml'
require 'singleton'

require 'twterm/app'
require 'twterm/key_mapper/abstract_key_mapper'
require 'twterm/key_mapper/app_key_mapper'
require 'twterm/key_mapper/cursor_key_mapper'
require 'twterm/key_mapper/general_key_mapper.rb'
require 'twterm/key_mapper/no_such_command'
require 'twterm/key_mapper/no_such_key'
require 'twterm/key_mapper/status_key_mapper.rb'
require 'twterm/key_mapper/tab_key_mapper'

module Twterm
  class KeyMapper
    include Singleton

    MAPPERS = {
      app: AppKeyMapper,
      cursor: CursorKeyMapper,
      general: GeneralKeyMapper,
      status: StatusKeyMapper,
      tab: TabKeyMapper,
    }.freeze

    def initialize
      create_default_dict_file! unless dict_file_exists?
      load_dict_file!
    end

    def [](category, kind)
      (@mappings[category] || {})[kind]
    end

    def as_string(category, kind)
      key = self[category, kind]

      case key
      when '!'..'}' then key
      when Curses::Key::F1 then 'F1'
      when Curses::Key::F2 then 'F2'
      when Curses::Key::F3 then 'F3'
      when Curses::Key::F4 then 'F4'
      when Curses::Key::F5 then 'F5'
      when Curses::Key::F6 then 'F6'
      when Curses::Key::F7 then 'F7'
      when Curses::Key::F8 then 'F8'
      when Curses::Key::F9 then 'F9'
      when Curses::Key::F10 then 'F10'
      when Curses::Key::F11 then 'F11'
      when Curses::Key::F12 then 'F12'
      when 1..26 then "^#{(key + 'A'.ord - 1).chr}"
      else ''
      end
    end

    private

    def assign_mappings!(dict)
      @mappings = MAPPERS
        .map { |c, m| { c => m.new(dict[c]) } }
        .reduce({}) { |acc, x| acc.merge(x) }
    rescue NoSuchCommand => e
      warn "Unrecognized command detected: #{e.full_command}"
      warn 'Make sure you have specified the correct command'
      warn "Your key assignments are defined in #{dict_file_path}"

      exit
    rescue NoSuchKey => e
      warn "Unrecognized key detected: #{e.key}"
      warn 'Make sure you have specified the correct key'
      warn "Your key assignments are defined in #{dict_file_path}"

      exit
    end

    def create_default_dict_file!
      dict = TOML.dump(default_mappings).gsub("\n[", "\n\n[")
      File.open(dict_file_path, 'w', 0644) { |f| f.write(dict) }
    end

    def default_mappings
      MAPPERS.map { |key, klass| [key, klass::DEFAULT_MAPPINGS] }.to_h
    end

    def dict_file_exists?
      File.exist?(dict_file_path)
    end

    def dict_file_path
      "#{App::DATA_DIR}/keys.toml".freeze
    end

    def getc
      system('stty raw -echo')
      STDIN.getc
    ensure
      system('stty -raw echo')
    end

    def load_dict_file!
      dict = TOML.load_file(dict_file_path, symbolize_keys: true)
    rescue TOML::ParseError, TOML::ValueOverwriteError => e
      first_line =
        case e
        when TOML::ParseError
          "Your key assignments dictionary file (#{dict_file_path}) could not be parsed"
        when TOML::ValueOverwriteError
          "Command `#{e.key}` is declared more than once"
        end

      warn <<-EOS
#{first_line}
Falling back to the default key assignments

Check the syntax and edit the file manually,
or remove it and launch twterm again to restore

Press any key to continue
      EOS

      getc
    ensure
      assign_mappings!(dict || default_mappings)
    end
  end
end
