require 'socket'

server = TCPServer.new 2000 # Server bind to port 2000
loop do
  client = server.accept    # Wait for a client to connect
  
  while command =  client.gets do
    case command[0..2]
    when 'QIT'
      client.puts "LOG received quit"
      client.close
      break
    when 'CNG'
      puts 'received change ' + command[3..-1]
    else
      # ignore command
      client.puts "ERR unknown command"
    end

  end
end


