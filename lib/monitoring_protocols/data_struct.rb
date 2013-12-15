
require 'bigdecimal'

class BigDecimal
  def to_msgpack(pack)
    pack.write(to_f)
  end
end

module MonitoringProtocols
  class DataStruct
    
    include Comparable
    
    def initialize(*args)
      merge_data_from!(*args)
    end
    
    ##
    # Merge new data in the structure.
    #
    # @param [Object,Hash] opts_or_obj Source
    # @param [Array] only_fields an array of symbol
    #   specifying which fields to copy
    # @param [Boolean] allow_nil If false nil values from
    #   the source will not be copied in object
    #
    def merge_data_from!(opts_or_obj = {}, only_fields = nil, allow_nil = false)
      keys_left = list_keys(opts_or_obj)
      
      self.class.attributes.select{|attr_name| selected_field?(attr_name, only_fields) }.each do |attr_name|
        v = opts_or_obj.is_a?(Hash) ? (opts_or_obj[attr_name.to_s] || opts_or_obj[attr_name]) : opts_or_obj.send(attr_name)
        if allow_nil || !v.nil?
          send("#{attr_name}=", v)
        end
        
        keys_left.delete(attr_name)
      end
      
      unless keys_left.empty?
        raise ArgumentError, "unknown keys: #{keys_left}"
      end
    end
    
    def list_keys(what)
      if what.respond_to?(:keys)
        what.keys.clone
      else
        []
      end
    end
    
    def selected_field?(field, list)
      list.nil? || list.include?(field.to_sym)
    end
    
    def to_h
      h = {}
      self.class.attributes.each do |attr_name|
        h[attr_name] = send(attr_name)
      end
      h
    end
    
    def to_a
      self.class.attributes.map{|attr_name| send(attr_name) }
    end
    
    def to_msgpack(pack)
      pack.write(to_h)
    end
    
    def <=>(other)
      self.to_a <=> other.to_a
    end


    class <<self
      def properties(*names)
        names.each do |name|
          attr_accessor(name)
          (@attributes ||= []) << name
        end
      end
      
      alias :property :properties

      def attributes
        if (superclass <= DataStruct) && (superclass.attributes)
          superclass.attributes + @attributes
        else
          @attributes
        end
      end
    end

  end
end
