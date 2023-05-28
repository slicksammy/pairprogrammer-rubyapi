require 'net/http'
require 'uri'
require 'json'
require_relative '../configuration'

module PairProgrammer
    module Api
        class Client
            def initialize
                @api_key = PairProgrammer::Configuration.api_key
                raise "Missing api key" if @api_key.nil?

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
                request['Pairprogrammer-Api-Key'] = @api_key

                # Make the HTTP GET request and handle the response
                response = http.request(request)
                handle_response(response)
            end

            def post(endpoint, body)
                uri = URI.parse(@domain + endpoint)
                request = Net::HTTP::Post.new(uri)
                request.body = body.to_json
                request['Content-Type'] = 'application/json'
                request['Pairprogrammer-Api-Key'] = @api_key
            
                # Create a new instance of Net::HTTP for the specified URI
                http = Net::HTTP.new(uri.host, uri.port)
            
                # Use SSL if the URI scheme is HTTPS
                http.use_ssl = true if uri.scheme == 'https'
            
                # Set the open_timeout and read_timeout values (in seconds)
                # http.open_timeout = 5 # Timeout for opening the connection
                http.read_timeout = 300 # Timeout for reading the response
            
                # Make the HTTP POST request and handle the response
                response = http.request(request)
                handle_response(response)
            end

            private

            def handle_response(response)
                if response.code.to_i.between?(200, 299)
                    JSON.parse(response.body) if !response.body.empty?
                else
                    raise "Error processing your request #{response.body}"
                end
            end
        end
    end
end