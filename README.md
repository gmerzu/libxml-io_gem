# LibXML::IO

The libxml-io gem provides Ruby language bindings for Libxml2 [xmlRegisterInputCallbacks](http://xmlsoft.org/html/libxml-xmlIO.html#xmlRegisterInputCallbacks).
Can be used with any gem using Libxml2 XML toolkit, however this gem was primary designed to use with [Nokogiri](https://github.com/sparklemotion/nokogiri) which doesn't support this feature.
Inspired by part of [Libxml-Ruby](https://github.com/xml4r/libxml-ruby).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'libxml-io'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install libxml-io

## Usage

```ruby
    require 'libxml/io'

    class InputCbc
        def initialize
            @xsd = ['test_common.xsd']
        end

        def match filename
            @xsd.include? filename
        end

        def query filename
            case filename
            when 'test_common.xsd'
                GET_FILE
            end
        end
    end

    LibXML::IO::InputCallbacks.register
    LibXML::IO::InputCallbacks.add_handler InputCbc.new

    INTERACT_WITH_LIBXML

    LibXML::IO::InputCallbacks.clear_handlers
    LibXML::IO::InputCallbacks.pop
```

## License

MIT. See [`LICENSE.md`](LICENSE.md).
