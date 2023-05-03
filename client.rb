require 'net/http'
require 'uri'
require 'json'
require 'byebug'

class Client
    def initialize
        @domain = 'http://localhost:8000/'
    end

    def get(endpoint, body)
        uri = build_uri(endpoint)
        response = Net::HTTP.get_response(uri)
        JSON.parse(response.body)
    end

    def post(endpoint, body)
        uri = build_uri(endpoint)
        request = Net::HTTP::Post.new(uri)
        request.body = body.to_json
        request['Content-Type'] = 'application/json'
        response = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(request) }
        if !response.body.empty?
            JSON.parse(response.body)
        end
    end

    private

    def build_uri(endpoint)
        URI.parse(@domain + endpoint)
    end
end