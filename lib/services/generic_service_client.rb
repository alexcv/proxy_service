require "em-synchrony"
require "em-synchrony/em-http"
require 'active_support/core_ext/hash/conversions'

class Services::GenericServiceClient

  def call_services(endpoints, concurrency)
    parse_response(do_call(endpoints, concurrency))
  end

  private
  def do_call(endpoints, concurrency)
    res = nil
    EventMachine.synchrony do
      multi = EventMachine::Synchrony::Multi.new
      endpoints.each_with_index do |endpoint, i|
        multi.add i.to_s, EventMachine::HttpRequest.new(endpoint).aget
      end

      res = multi.perform
      EventMachine.stop
    end
    res.responses
  end

  def parse_response(responses) 
    parsed_responses = []

    responses[:callback].each do |k, v|
      case v.response_header["CONTENT_TYPE"]
      when "application/json"
        parsed_responses << JSON.parse(v.response)
      when "text/xml"
        parsed_responses << Hash.from_xml(Nokogiri::XML.parse(v.response).to_s)
      else
        parsed_responses << { service_response: "failed" }
      end
    end

    responses[:errback].count.times { |i| parsed_responses << { service_response: "failed" } }
    parsed_responses
  end
end
