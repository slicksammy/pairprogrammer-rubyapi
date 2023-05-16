require 'net/http'
require 'uri'
require 'json'
require 'byebug'

class Client
    def initialize
        @domain = 'http://localhost:8000'
    end

    def get(endpoint, query_params={})
        encoded_params = URI.encode_www_form(query_params)
        uri = URI.parse(@domain + endpoint + "?" + encoded_params)

        # Create a new instance of Net::HTTP for the specified URI
        http = Net::HTTP.new(uri.host, uri.port)

        # Use SSL if the URI scheme is HTTPS
        http.use_ssl = true if uri.scheme == 'https'

        # Set the open_timeout and read_timeout values (in seconds)
        # http.open_timeout = 5 # Timeout for opening the connection
        http.read_timeout = 605 # matches openai timeout

        # Create a GET request
        request = Net::HTTP::Get.new(uri)

        # Make the HTTP GET request and handle the response
        response = http.request(request)
        if !response.body.empty?
            JSON.parse(response.body)
        end
    end

    def post(endpoint, body)
        uri = URI.parse(@domain + endpoint)
        request = Net::HTTP::Post.new(uri)
        request.body = body.to_json
        request['Content-Type'] = 'application/json'
      
        # Create a new instance of Net::HTTP for the specified URI
        http = Net::HTTP.new(uri.host, uri.port)
      
        # Use SSL if the URI scheme is HTTPS
        http.use_ssl = true if uri.scheme == 'https'
      
        # Set the open_timeout and read_timeout values (in seconds)
        # http.open_timeout = 5 # Timeout for opening the connection
        http.read_timeout = 300 # Timeout for reading the response
      
        # Make the HTTP POST request and handle the response
        response = http.request(request)
        if !response.body.empty?
          JSON.parse(response.body)
        end
    end
end