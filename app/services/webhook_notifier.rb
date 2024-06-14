require 'net/http'
require 'uri'
require 'json'
require 'openssl'

class WebhookNotifier
  def self.notify(endpoint, item)
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.scheme == 'https'
    
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = {
      item: {
        id: item.id,
        name: item.name,
        data: item.data,
        updated_at: item.updated_at
      },
      signature: generate_signature(item)
    }.to_json
    
    response = http.request(request)
    Rails.logger.info "Notified #{endpoint}: #{response.code} - #{response.message}"
  end

  def self.generate_signature(item)
    secret = Rails.application.credentials.webhook_secret || 'default_secret'
    OpenSSL::HMAC.hexdigest('SHA256', secret, item.to_json)
  end
end
