require_relative 'sompadata_pb'

# The protobuf thing crashes if trying to subclass
class SensorReport
  API_KEY = ENV['REPORT_API_KEY'] || raise("REPORT_API_KEY missing")
  REQUEST_URI = "/lampotila/lampotila2.php/save/#{API_KEY}?%<sensor_id>=%<temperature>f"

  def send_to_www_api
    report_id = translate_sensor_id
    return "No reporting for #{inspect}" if report_id.nil? || f.to_i < -50

    Net::HTTP.start('www.sompasauna.fi', 443, use_ssl: true) do |http|
      http.request(
        Net::HTTP::Get.new(
          REQUEST_URI % { sensor_id: report_id, temperature: f }
        )
      )
    end.read_body
  rescue => ex
    ex
  end

  private

  def http
    @http ||= Net::HTTP.new('www.sompasauna.fi', 443).tap { |http| http.use_ssl = true}
  end

  def translate_sensor_id
    case device_id
    when 1
      case sensor_id
      when 1 then 'tem3'
      else
        nil
      end
    else
      nil
    end
  end
end

require 'zlib'

module SensorAPI
  module Protocol
    module MultiSensorReport
      def decode_multi(msg)
        reports = []
        idx = 0
        until idx >= msg.size
          doc_bytes = msg.bytes[idx]
          idx += 1
          begin
            report = SensorReport.decode(msg[idx, doc_bytes])
            if block_given?
              yield report
            else
              reports << report
            end
          rescue StandardError => ex
            puts "Error decoding message: #{ex.class.name} : #{ex.message}}\n#{ex.backtrace.join("\n  ")}"
          end
          idx += doc_bytes
        end
        block_given? ? nil : reports
      end
      module_function :decode_multi
    end

    module Encryption
      raise "PASSPHRASE missing" unless ENV['PASSPHRASE']
      PASSPHRASE = ENV['PASSPHRASE'].bytes.freeze
      PP_SIZE = PASSPHRASE.size
      raise "PASSPHRASE2 missing" unless ENV['PASSPHRASE2']
      PASSPHRASE2 = ENV['PASSPHRASE2'].freeze

      def xor(bytes)
        bytes.each_with_object(+'').with_index { |(b, o), i| o << (b ^ PASSPHRASE[i % PP_SIZE]).chr }
      end
      module_function :xor

      def silly_encrypt(msg)
        xorred = xor(msg.bytes)
        padded = "#{xorred}#{PASSPHRASE2}"
        xorred + [Zlib.crc32(padded)].pack('N')
      end
      module_function :silly_encrypt

      def silly_decrypt(msg)
        without_crc, crc_bytes = msg.bytes.each_slice(msg.bytesize - 4).to_a
        crc = crc_bytes.pack('C*').unpack('N').first
        padded_crc = Zlib.crc32("#{without_crc.pack('C*')}#{PASSPHRASE2}")
        puts crc.inspect
        puts padded_crc.inspect
        crc == padded_crc ? xor(without_crc) : nil
      end
      module_function :silly_decrypt
    end
  end
end
