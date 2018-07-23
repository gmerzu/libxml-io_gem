require 'libxml/io/version'

begin
  RUBY_VERSION =~ /(\d+.\d+)/
  require "#{Regexp.last_match(1)}/libxml_io"
rescue LoadError
  require 'libxml_io'
end

module LibXML
  module IO
  end
end
