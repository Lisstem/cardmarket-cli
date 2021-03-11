# frozen_string_literal: true

##
# Makes a class unique
module Unique
  def uniq_attr(symbol, options = {})
    options = { hash: true, plural: "#{symbol}s", index: :id }.merge! options
    def_brackets(options[:plural], options[:hash])
    def_add(options[:plural], options[:hash], options[:index])
    def_reader(options[:plural], options[:hash])
  end

  private

  def def_reader(plural, hash)
    return if respond_to? plural.to_s.to_sym
    
    define_method plural.to_s do
      instance_variable_set("@#{plural}", hash ? {} : []) unless instance_variable_defined? "@#{plural}"
      instance_variable_get("@#{plural}").dup
    end
  end
  
  def def_brackets(plural, hash)
    return if respond_to? :[]
    
    define_method :[] do |id|
      instance_variable_set("@#{plural}", hash ? {} : []) unless instance_variable_defined? "@#{plural}"
      instance_variable_get("@#{plural}")[id]
    end
  end

  def def_add(plural, hash, index)
    define_method :add do |item|
      instance_variable_set("@#{plural}", hash ? {} : []) unless instance_variable_defined? "@#{plural}"
      if hash
        instance_variable_get("@#{plural}")[item.send(index)] = item
      else
        instance_variable_get("@#{plural}") << item
      end
    end
    private :add
  end
end
