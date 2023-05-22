class UsageParser
  class << self
    def parse(input)
      return [string_parse(input)] if input.kind_of?(String)
      return array_parse(input) if input.kind_of?(Array)
      raise StandardError("Invalid parse input")
    end

    def string_parse(input)
      input_parts = input.split(',')
      id = input_parts.first
      if id.end_with?('4')
        validated_input = extended_parse_validator(input_parts)
      elsif id.end_with?('6')
        validated_input = hex_parse_validator(input_parts)
      else
        validated_input = basic_parse_validator(input_parts)
      end
      return output(validated_input)
    end

    def array_parse(input)
      result = input.map do |usage_string|
        string_parse(usage_string)
      end
    end

    def output(parse_result)
      return {
        id: parse_result[:id],
        dmcc: parse_result[:dmcc],
        mnc: parse_result[:mnc],
        bytes_used: parse_result[:bytes_used],
        cellid: parse_result[:cellid],
        ip:  parse_result[:ip],
      }
    end

    def basic_parse_validator(input_parts)
      raise StandardError("Invalid number of params for basic parse. Expected: 2 Received: #{input_parts.length}") if input_parts.length != 2
      id, bytes_used = input_parts
      raise StandardError("ID is not an integer") unless id !~ /\D/
      raise StandardError("Bytes used is not an integer") unless bytes_used !~ /\D/
      return { id: id.to_i, bytes_used: bytes_used.to_i }
    end

    def extended_parse_validator(input_parts)
      raise StandardError("Invalid number of params for extended parse. Expected: 5 Received: #{input_parts.length}") if input_parts.length != 5
      id, dmcc, mnc, bytes_used, cellid = input_parts
      raise StandardError("ID is not an integer") unless id !~ /\D/
      raise StandardError("mnc is not an integer") unless mnc !~ /\D/
      raise StandardError("Bytes used is not an integer") unless bytes_used !~ /\D/
      raise StandardError("cellid is not an integer") unless cellid !~ /\D/
      return {id: id.to_i, dmcc: dmcc, mnc: mnc.to_i, bytes_used: bytes_used.to_i, cellid: cellid.to_i }
    end

    def hex_parse_validator(input_parts)
      raise StandardError("Invalid number of params for hexadecimal parse. Expected: 2 Received: #{input_parts.length}") if input_parts.length != 2
      id, hex = input_parts
      raise StandardError("ID is not an integer") unless id !~ /\D/
      raise StandardError("Invalid hexadecimal") if hex.length != 24
      mnc = hex[0..3].to_i(16)
      bytes_used = hex[4..7].to_i(16)
      cellid = hex[8..15].to_i(16)
      ip = ip_parse(hex[16..-1])
      return { id: id.to_i, mnc: mnc, bytes_used: bytes_used, cellid: cellid, ip: ip }
    end

    def ip_parse(hex_string)
      bytes = hex_string.chars.each_slice(2).map(&:join)
      return bytes.map { |byte| byte.to_i(16) }.join('.')
    end
  end
end
