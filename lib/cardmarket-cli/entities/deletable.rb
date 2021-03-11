# frozen_string_literal: true

##
# marks that an entity can be deleted
module Deletable
  def list_attr(symbol, options = {})
    options = { plural: "#{symbol}s", default: true, suffix: true, add: 'add', delete: 'delete', hash: false }
              .merge!(options)
    def_modifiers(symbol, options[:plural], options)
    def_reader(options[:plural], options[:hash])
    def_brackets(options[:plural], options[:hash]) if options[:default]
    def_clear(options[:plural], options[:hash])
    symbol
  end

  private

  def def_modifiers(symbol, plural, options)
    options = { suffix: true, add: 'add', delete: 'delete', hash: false }.merge! options
    if options[:hash]
      def_add_hash(symbol, plural, options[:add], options[:suffix])
      def_delete_hash(symbol, plural, options[:delete], options[:suffix])
    else
      def_add_array(symbol, plural, options[:add], options[:suffix])
      def_delete_array(symbol, plural, options[:delete], options[:suffix])
    end
  end

  def def_add_hash(symbol, plural, name, suffix)
    define_method "#{name}#{"_#{symbol}" if suffix}" do |params|
      key, value, = params
      instance_variable_set("@#{plural}", {}) unless instance_variable_defined? "@#{plural}"
      instance_variable_set("@deleted_#{plural}", {}) unless instance_variable_defined? "@deleted_#{plural}"
      instance_variable_get("@#{plural}")[key] = value if key
      instance_variable_get("@deleted_#{plural}").delete(key)
      { key => value }
    end
  end

  def def_add_array(symbol, plural, name, suffix)
    define_method "#{name}#{"_#{symbol}" if suffix}" do |value|
      instance_variable_set("@#{plural}", []) unless instance_variable_defined? "@#{plural}"
      instance_variable_set("@deleted_#{plural}", []) unless instance_variable_defined? "@deleted_#{plural}"
      instance_variable_get("@#{plural}") << value if value
      instance_variable_get("@deleted_#{plural}").delete(value)
      value
    end
  end

  def def_delete_hash(symbol, plural, name, suffix)
    define_method "#{name}#{"_#{symbol}" if suffix}" do |key|
      instance_variable_set("@#{plural}", {}) unless instance_variable_defined? "@#{plural}"
      instance_variable_set("@deleted_#{plural}", {}) unless instance_variable_defined? "@deleted_#{plural}"
      deleted = instance_variable_get("@#{plural}").delete(key)
      instance_variable_get("@deleted_#{plural}")[key] = deleted if deleted
      deleted
    end
  end

  def def_delete_array(symbol, plural, name, suffix)
    define_method "#{name}#{"_#{symbol}" if suffix}" do |value|
      instance_variable_set("@#{plural}", []) unless instance_variable_defined? "@#{plural}"
      instance_variable_set("@deleted_#{plural}", []) unless instance_variable_defined? "@deleted_#{plural}"
      deleted = instance_variable_get("@#{plural}").delete(value)
      instance_variable_get("@deleted_#{plural}") << deleted if deleted
      deleted
    end
  end

  def def_reader(plural, hash)
    return if respond_to? plural.to_s.to_sym

    define_method plural.to_s do
      instance_variable_set("@#{plural}", hash ? {} : []) unless instance_variable_defined? "@#{plural}"
      instance_variable_get("@#{plural}").dup
    end

    define_method "deleted_#{plural}" do
      instance_variable_set("@deleted_#{plural}", hash ? {} : []) unless instance_variable_defined? "@deleted_#{plural}"
      instance_variable_get("@deleted_#{plural}").dup
    end
  end

  def def_brackets(plural, hash)
    return if respond_to? :[]

    define_method :[] do |key|
      instance_variable_set("@#{plural}", hash ? {} : []) unless instance_variable_defined? "@#{plural}"
      instance_variable_get("@#{plural}")[key]
    end
  end

  def def_clear(plural, hash)
    define_method :clear do
      instance_variable_set("@#{plural}", hash ? {} : [])
      instance_variable_set("@deleted_#{plural}", hash ? {} : [])
    end
    private :clear
  end
end
