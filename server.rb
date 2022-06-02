require 'socket'
require 'timeout'

class Server
	def initialize( socket_address, socket_port )
		@server_socket = TCPServer.open socket_address, socket_port
		@connections_details, @connected_clients = Hash.new
		@connections_details[:server] = @server_socket
		@connections_details[:clients] = @connected_clients
		@max_conn_size, @time_limit = 2, 15
		puts 'Started server..'
		run
	end

	def run
		loop {
			Thread.start @server_socket.accept do |conn|
				begin
					conn_name = conn.gets.chomp.to_sym
					if @connections_details[:clients][conn_name].nil? # avoid connection if user exits
						if @connections_details[:clients].size < @max_conn_size
							puts "Connection established #{ conn_name } => #{ conn }"
							@connections_details[:clients][conn_name] = conn
							conn.puts "Connection established successfully #{ conn_name }"
							establish_chatting conn_name, conn
						else
							error_puts "Connection canceled - server is full", conn
							disconn_client conn, 1
						end
					else
						error_puts "This username already exist", conn
						disconn_client conn, 1
					end
				rescue Errno::ECONNRESET => err_conn_reset
					error_puts "Some trouble in connection: #{ err_conn_reset.message }"
				end
			end
		}.join
	end

	def establish_chatting( username, connection )
		begin
			loop do
				begin
					Timeout::timeout @time_limit do
						message = connection.gets
						unless message.nil?
							if message.chomp.start_with? '::'
								command_parser message.chomp, connection
							else
								( @connections_details[:clients] ).keys.each do | client |
									@connections_details[:clients][client].puts "#{ username } : #{ message.chomp }" if client != username
								end
							end
						end
					end
				rescue Timeout::Error
					disconn_client connection, 2, username
				end
			end
		rescue Errno::ECONNRESET => err_conn_reset
			error_puts "Some trouble in connection: #{ err_conn_reset.message }"
			del_client username
		end
	end

	def command_parser( command, client, message = '')
		case command
			when '::help'
				message = "Supported several commands:\n\t::count\t\tDisplays count of dialers\n\t::dialers\tDisplays nicknames of dialers\n\t::limit\t\tDisplays max connection count of dialers\n\t::timeout\tDisplays idle time"
			when '::count' message = "#{ @connections_details[:clients].size }"
			when '::dialers'
				( @connections_details[:clients] ).keys.each { | client | message += "#{ client }\n" }
			when '::limit' message = "Max connection count is #{ @max_conn_size }"
			when '::timeout' message = "The idle time should not exceed #{ @time_limit } seconds"
			else message = "\e[31mUnkown command\e[0m"
		end
		client.puts message
	end

	def disconn_client( client, operation, username = nil )
		case operation
			when 1 client.puts '::quit'
			when 2
				error_puts "You were disconnected due to idle", client
				client.puts '::close'
				del_client username
			else error_puts 'Unknown operation of disconnection'
		end
	end

	def del_client( username )
		@connections_details[:clients].delete username
		( @connections_details[:clients] ).keys.each { | client |
			@connections_details[:clients][client].puts "\e[31m#{ username } disconnected" }
		puts "#{ username } was manually disconnected"
	end

	def error_puts( message, client = nil )
		if client.nil? puts "\e[31m#{ message }\e[0m"
		else client.puts "\e[31m#{ message }\e[0m"
		end
	end
end

Server.new "localhost", 8080