module Twterm
  # @abstract
  class AbstractPersistableConfiguration
    # @param [Hash<Symbol, Object>] configuration A hash object to initialize configuration
    def initialize(configuration = {})
      @configuration = configuration
    end

    # Gets a value associated to the given key.
    # @abstract
    def [](*)
      raise NotImplementedError, '`#[]` method must be implemented'
    end

    # Sets the given value to the given key.
    # @abstract
    def []=(*)
      raise NotImplementedError, '`#[]=` method must be implemented'
    end

    # Returns the default instance for the configuration.
    # @abstract
    def self.default
      raise NotImplementedError, '`.default` method must be implemented'
    end

    # @return [Boolean]
    def self.has_same_structure?
      true
    end

    # @return [self]
    def complete_missing_items!
      traverse(self.class.default.to_h) do |path, default_value|
        value = dig(configuration, path)

        if value.nil? || !(dig!(self.class.structure, path) === value)
          bury!(path, default_value)
        end
      end

      self
    end

    # Converts to a hash object.
    #
    # @abstract
    # @return [Hash] Configuration as a hash
    def to_h
      raise NotImplementedError, '`#to_h` method must be implemented'
    end

    # A tree-like object representing the structure of the configuration.
    # Each node must respond to {#===} method which determines whether a value is acceptable.
    #
    # @abstract
    # @return [Hash] A tree-like hash object
    def self.structure
      raise NotImplementedError, '`.structure` method must be implemented'
    end

    private

    attr_reader :configuration

    def bury!(path, value)
      go = lambda do |hash, rest_path|
        k, *ks = rest_path

        if ks.empty?
          hash[k] = value
        else
          hash[k] = {} unless hash[k].is_a?(Hash)
          go.call(hash[k], ks)
        end
      end

      go.call(configuration, path)

      configuration
    end

    def dig(hash, path)
      k, *ks = path
      ks.empty? ? hash[k] : dig(hash[k], ks)
    rescue NoMethodError
      nil
    end

    def dig!(hash, path)
      k, *ks = path
      ks.empty? ? hash[k] : dig(hash[k], ks)
    rescue NoMethodError
      raise ArgumentError, "path #{path} not found for hash #{hash}"
    end

    # Traverses tree-like {Hash} object and calls the given block on every node with its path
    #
    # @yieldparam [Array<Symbol>] path the path of the current node
    # @yieldparam [Object] v the value of the current node
    # @yieldreturn [void]
    def traverse(tree, &f)
      go = lambda do |subtree, current_path|
        subtree.each do |k, v|
          path = [*current_path, k]

          if v.is_a?(Hash)
            go.call(v, path)
          else
            f.call(path, v)
          end
        end
      end

      go.call(tree, [])
    end
  end
end
