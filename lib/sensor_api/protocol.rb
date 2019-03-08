require_relative 'sompadata_pb'

module SensorAPI
  module Protocol
    ServerResponse = ::ServerResponse
    Ping = ::Ping

    class SensorReport < ::SensorReport
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
  end
end
