module Sentinel
  module Model
    attr_accessor :id

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      attr_accessor :entity_name, :fields

      # Fetch entity data based on entity Id
      #
      # @param id [Object] The key of the entity
      #
      def find(id)
        result = Sentinel.client.find(entity_name, id)

        klass = new

        klass.id = result.Id
        @fields.keys.each do |k|
          attribute = @fields[k]
          has_alias = attribute[:alias]
          field_name = has_alias ? attribute[:alias] : k

          klass.send("#{field_name}=", result.send(k))
        end

        return klass
      end

      # Create a new SalesForce entity row
      #
      # @param attrs [Hash] set of entity attributes
      #
      def create(attrs)
        Sentinel.client.create(entity_name, attrs)

        return true
      rescue
        return false
      end

      # Update an existing SalesForce entity row
      #
      # @param id [Object] corresponding entity id for updated
      # @param attrs [Hash] set of fields to update
      #
      def update(id, attrs)
        Sentinel.client.update(entity_name, attrs.merge(Id: id))

        return true
      rescue
        return false
      end

      # Declarative set the SalesForce entity model
      #
      # @param sentinel_table [Symbol] sales force entity model name
      #
      def set_sentinel_table sentinel_table
        self.entity_name = sentinel_table
      end

      # Return set of defined SalesForce fields
      def fields
        return @fields if instance_variable_defined?(:@fields) && @fields
        existing = superclass.respond_to?(:fields) ? superclass.fields : {}
        @fields = existing
      end

      # Declare entity fields and aliases
      #
      # @param name [Symbol] The key of the default option in your configuration hash.
      # @param options [Hash] The value your object defaults to. Nil if not provided.
      #
      # @example
      #
      #   class MyModel
      #     include Sentinel::Model
      #
      #     field :Name, alias: :name
      #     field :Email, alias: :email
      #   end
      def field(name, options = {})
        fields[name] = options
      end
    end

    def initialize
      if self.class.entity_name.to_s.empty?
        self.class.entity_name = self.class.name
      end

      self.class.fields.keys.each do |key|
        attribute = self.class.fields[key]
        field_name = attribute[:alias] ? attribute[:alias] : key

        # getter
        self.class.class_eval("def #{field_name};@#{field_name};end")
 
        # setter
        self.class.class_eval("def #{field_name}=(val);@#{field_name}=val;end")
      end
    end

    def save
      if new_record?
        self.class.create(attrs)
      else
        self.class.update(self.id, attrs)
      end
    end

    # Detects if current instance is a new record?
    def new_record?
      self.id.to_s.empty?
    end

    # Normalize fields and generate Hash for #create/#update actions
    def attrs
      response = {}

      self.class.fields.keys.each do |k|
        attribute = self.class.fields[k]
        has_alias = attribute[:alias]

        key_name = has_alias ? k : attribute[:alias]
        response[key_name] = has_alias ? send(attribute[:alias]) : send(k)
      end

      return response
    end
  end
end

