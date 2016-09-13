require 'toml'
require 'singleton'

require_relative './app'
require_relative './key_mapper/abstract_key_mapper'
require_relative './key_mapper/app_key_mapper'
require_relative './key_mapper/direct_message_key_mapper'
require_relative './key_mapper/general_key_mapper.rb'
require_relative './key_mapper/status_key_mapper.rb'
require_relative './key_mapper/tab_key_mapper'
require_relative './key_mapper/user_key_mapper'

module Twterm
  class KeyMapper
    include Singleton

    MAPPERS = {
      app: AppKeyMapper,
      direct_message: DirectMessageKeyMapper,
      general: GeneralKeyMapper,
      status: StatusKeyMapper,
      tab: TabKeyMapper,
      user: UserKeyMapper,
    }.freeze

    def initialize
      create_default_dict_file! unless dict_file_exists?
      load_dict_file!
    end

    def [](category, kind)
      (@mappings[category] || {})[kind]
    end

    private

    def assign_mappings!(dict)
      @mappings = MAPPERS
        .map { |c, m| { c => m.new(dict[c]) } }
        .reduce({}) { |acc, x| acc.merge(x) }
    rescue AbstractKeyMapper::NoSuchCommand => e
      command = e.message

      warn "Unrecognized command detected: #{command}"
      warn 'Make sure you have specified the correct command'
      warn "Your key assignments are defined in #{dict_file_path}"

      exit
    rescue AbstractKeyMapper::NoSuchKey => e
      key = e.message

      warn "Unrecognized key detected: #{key}"
      warn 'Make sure you have specified the correct key'
      warn "Your key assignments are defined in #{dict_file_path}"

      exit
    end

    def create_default_dict_file!
      dict = TOML.dump(default_mappings).gsub("\n[", "\n\n[")
      File.open(dict_file_path, 'w', 0644) { |f| f.write(dict) }
    end

    def default_mappings
      {
        app: {
          cheatsheet: '?',
          quit: 'Q',
        },
        direct_message: {
          compose: 'n',
          reply: 'r',
        },
        general: {
          bottom: 'G',
          down: 'j',
          left: 'h',
          right: 'l',
          scroll_down: 'd',
          scroll_up: 'u',
          top: 'g',
          up: 'k',
        },
        status: {
          compose: 'n',
          conversation: 'c',
          destroy: 'D',
          like: 'L',
          open_link: 'o',
          reply: 'r',
          retweet: 'R',
          user: 'U',
        },
        tab: {
          :'1st' => '1',
          :'2nd' => '2',
          :'3rd' => '3',
          :'4th' => '4',
          :'5th' => '5',
          :'6th' => '6',
          :'7th' => '7',
          :'8th' => '8',
          :'9th' => '9',
          close: 'w',
          filter: '/',
          last: '0',
          new: 'N',
          reload: '<C-r>',
          reset_filter: 'q',
        },
        user: {
          direct_message: 'D',
          follow: 'F',
          my_profile: 'P',
          timeline: 't',
          website: 'W',
        }
      }
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
    rescue TOML::ParseError
      warn "Your key assignments dictionary file (#{dict_file_path}) could not be parsed"
      warn 'Falling back to the default key assignments'
      warn ''
      warn 'Check the syntax and edit the file manually,'
      warn 'or remove it and launch twterm again to restore'
      warn ''
      warn 'Press any key to continue'

      getc

      dict = default_mappings
    ensure
      assign_mappings!(dict)
    end
  end
end
