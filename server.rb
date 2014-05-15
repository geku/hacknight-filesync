require 'socket'
require 'json'
require 'fileutils'

$root_folder = './test'

def write_at(filepath, line, data)
  File.open(filepath, 'r+') do |f|
    while (line-=1) >= 0            # read up to the line you want to write after
      f.readline
    end
    pos_before = f.pos              # save your position in the file
    f.readline unless f.eof?
    rest = f.read                   # save the rest of the file
    f.seek(pos_before)              # go back to the old position
    puts "writing: #{data}"
    output = data + (rest || '') 
    f.write(output)                 # write new data & rest of file
    f.truncate(pos_before + output.size)
  end
end


def handle_change(client, payload)
  filepath = payload['filepath']
  line     = payload['line'].to_i
  change   = payload['change']

  full_path = File.join($root_folder, filepath)
  FileUtils.touch(full_path) if !File.exists?(full_path)
  write_at(full_path, line, change)

  send(client, 'COMMIT', {'line' => line, 'state' => 'written'})
end

def send(client, command, payload)
  puts "===> #{command}: #{payload.inspect}"
  client.puts({'command' => command, 'payload' => payload}.to_json)
end

server = TCPServer.new 2000 # Server bind to port 2000
loop do
  client = server.accept    # Wait for a client to connect
  
  while inst = client.gets do
    begin
      instruction = JSON.parse(inst)
    rescue JSON::ParserError => ex
      send(client, 'ERROR', "Invalid instruction sent")
      next
    end

    cmd     = instruction['command'].upcase
    payload = instruction['payload']

    puts "<=== #{cmd}: #{payload.inspect}"

    case cmd
    when 'QUIT'
      send(client, 'LOG', 'Received quit. Bye bye')
      client.close
      break
    when 'SYNC'

    when 'CHANGE'
      handle_change(client, payload)
    else
      # ignore command
      send(client, 'ERROR', "Unknown command '#{cmd}'")
    end

  end
end


