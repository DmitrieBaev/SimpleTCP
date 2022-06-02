require 'socket'

class Client
	def initialize( socket )
		@socket = socket
		@request_object = send_request
		@response_object = listen_response
		@request_object.join
		@response_object.join
	end

	def send_request
		puts 'Please enter your username to establish a connection:'
		begin
			Thread.new do
				loop do
					message = gets.chomp
					@socket.puts message
				end
			end
		rescue IOError => err_io
			puts err_io.message
			@socket.close
		end
	end

	def listen_response
		begin
			Thread.new do
				loop do
					response = @socket.gets.chomp
					if response.eql? '::quit' or response.eql? '::close'
						@socket.close
					else
						puts "#{ response }"
					end
				end
			end
		rescue IOError => err_io
			puts err_io.message
			@socket.close
		end
	end
end

Client.new TCPSocket.open 'localhost', 8080