require_relative 'schema_modifier'

module EZ
  class DomainModeler

    DEFAULT_VALUE_REGEXES = [/\s*\((.+)?\)/, /\s+(.+)?\s*/, /,\s*default:\s*(.+)?\s*/]

    attr_reader :spec

    def initialize
      begin
        load_model_specs
      rescue => e
        puts e
      end
    end

    def self.generate_models_yml
      filename = Rails.root + "db/models.yml"
      unless File.exist?(filename)
        File.open(filename, "w") do |f|
          f.puts <<-EOS
  # Example table for a typical Book model.
  #
  Book
    title: string
    price: integer
    author: string
    summary: text
    hardcover: boolean
  #
  # Indent consistently!  Follow the above syntax exactly.
  # Typical column choices are: string, text, integer, boolean, date, and datetime.
  #
  # Default column values can be specified like this:
  #    price: integer(0)
  #
  # Have fun!

  EOS
        end
      end
    end

    def self.update_tables(silent = false)
      self.new.update_tables(silent)
    end

    def update_tables(silent = false)
      SchemaModifier.migrate(@spec, silent)

      rescue => e
        puts e.message unless silent
        puts e.backtrace.first unless silent
    end

    def load_model_specs_from_string(s)

      # Append missing colons
      s.gsub!(/^((\s|\-)*\w[^\:]+?)$/, '\1:')

      # Replace ", default:" syntax so YAML doesn't try to parse it
      s.gsub!(/,?\s*(default)?:?\s(\S)\s*$/, '(\2)')

      # For backward compatibility with old array syntax
      s.gsub!(/^(\s*)\-\s*/, '\1')

      @spec = YAML.load(s)
      parse_model_spec

      # puts "@spec:"
      # puts @spec.inspect
      # puts "-" * 10
    end

    def load_model_specs(filename = "db/models.yml")
      load_model_specs_from_string(IO.read(filename))
    end

    def parse_model_spec
      @spec ||= {}
      @spec.each do |model, columns|

        if !columns.is_a?(Hash)
          raise "Could not understand models.yml while parsing model: #{model}"
        end

        columns.each do |column_name, column_type|
          interpret_column_spec column_name, column_type, model
        end
      end

    end

    def interpret_column_spec(column_name, column_type, model)
      column_type ||= begin
        if column_name =~ /_id|_count$/
          'integer'
        elsif column_name =~ /_at$/
          'datetime'
        elsif column_name =~ /_on$/
          'date'
        elsif column_name =~ /\?$/
          'boolean'
        else
          'string'
        end
      end

      default_column_value = (column_type == 'boolean' ? true : nil)
      DEFAULT_VALUE_REGEXES.each { |r| default_column_value = $1 if column_type.sub!(r, '') }
      default_column_value = default_column_value.to_i if column_type == 'integer'
      default_column_value = default_column_value.to_f if column_type == 'float'

      @spec[model][column_name] = { type: column_type, default: default_column_value}
    end
  end

end
