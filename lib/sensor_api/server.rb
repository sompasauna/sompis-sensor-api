require 'open-uri'
require 'socket'
require 'logger'
require_relative 'protocol'

module SensorAPI
  class Server

    LISTEN_PORT = ENV['UDP_LISTEN_PORT']&.to_i || raise("UDP_LISTEN_PORT missing")

    def logger
      @logger ||= Logger.new($stdout).tap do |logger|
        logger.level = ENV['DEBUG'].to_s.empty? ? Logger::INFO : Logger::DEBUG
      end
    end

    def listen
      logger.info "Starting to listen on port %d" % LISTEN_PORT
      Socket.udp_server_loop(LISTEN_PORT) do |msg, msg_src|
        logger.debug { "Received message from %s : %s" % [msg_src, msg] }
        unless msg.nil? || (msg.respond_to?(:zero?) && msg.zero?) || (msg.respond_to?(:empty?) && msg.empty?)
          SensorAPI::Protocol::MultiSensorReport.decode_multi(msg) do |report|
            logger.info report.inspect
            #logger.info report.send_to_www_api
          end

          response = {}
          response[:goto_sleep_seconds] = (1..13).cover?(Time.now.hour) ? 300 : 60
          # possible to ask to upgrade firmware from URL:
          # response[:firmware_url] = "http://xyz/fw20171128.bin"
          msg_src.reply(ServerResponse.new(response).to_proto)
        end
      end
    end
  end
end
