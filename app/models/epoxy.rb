require 'timeout'
require 'base64'

class Epoxy

  ENDPOINTS = ["https://safe-inlet-8105.herokuapp.com/payments",
    "https://safe-inlet-8105.herokuapp.com/plans",
    "https://safe-inlet-8105.herokuapp.com/payout",
    "https://safe-inlet-8105.herokuapp.com/feed"]
  
  def get_data(timeout=nil, on_failure, structue)
    concurrency = ENDPOINTS.count > 4 ? 4 : ENDPOINTS.count # just a stub for maximum concurrency
    data = nil

    begin
      Timeout::timeout(timeout) do
        data = Services::GenericServiceClient.new.call_services(ENDPOINTS, concurrency)
      end
    rescue Timeout::Error
      puts "Too slow!!! #{timeout} passed, terminating requests to services."
      return format_data(data, on_failure, structue)
    end
    format_data(data, on_failure, structue)
  end

  def format_data(data, on_failure, structue)
    return_failed = data.blank? || (on_failure == 'fail_any' && data.has_key?('service_response'))
    return Base64.encode64({ service_response: 'failed' }.to_json) if return_failed

    if structue == 'combined'
      data.inject({}){ |h, e| h.merge! e }
    end

    Base64.encode64(data.to_json)
  end
end
