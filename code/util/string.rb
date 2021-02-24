# frozen_string_literal: true

##
# adds camelize and underscore to String
# Taken from ruby on rails
# See https://apidock.com/rails/String/underscore
# See https://apidock.com/rails/String/camelize
class String
  def camelize(uppercase_first_letter = true)
    string = self
    string = if uppercase_first_letter
               string.sub(/^[a-z\d]*/, &:capitalize)
             else
               string.sub(/^(?:(?=\b|[A-Z_])|\w)/, &:downcase)
             end
    string.gsub(%r{(?:_|(/))([a-z\d]*)}) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }.gsub('/', '::')
  end

  def underscore
    string = self
    return string.dup unless /[A-Z-]|::/.match?(string)

    word = string.to_s.gsub('::', '/')
    word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)((?=a)b)(?=\b|[^a-z])/) do
      "#{Regexp.last_match(1) && '_'}#{Regexp.last_match(2).downcase}"
    end
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    word.tr!('-', '_')
    word.downcase!
    word
  end
end
