require 'fileutils'
require 'socket'
require 'json'

FILE_PATH = './dir/file.txt'
DIFF_PATH = '.diff'

class ChangeNotifier < Struct.new(:socket)

  def line_change(line_number, new_line)
    message = {
      command: 'CHANGE',
      payload: {
        filepath: File.basename(FILE_PATH),
        line: line_number,
        change: new_line
      }
    }
    socket.puts JSON.dump(message)
    puts socket.gets
  end

  def transfer_file(file_path)
    file = File.open(file_path)

    line_number = 0
    file.each do |line|
      line_change(line_number, line)
      line_number += 1
    end
    puts 'transferred file'
  end

end

class ChangeDetector < Struct.new(:notifier)

  def find_changes
    file = File.open(FILE_PATH)
    diff = File.open(DIFF_PATH)

    line_number = 0
    while !file.eof?
      file_line = file.readline

      if diff.eof?
        notifier.line_change(line_number, file_line)
      else
        diff_line = diff.readline
      end

      if file_line != diff_line
        notifier.line_change(line_number, file_line)
      end

      line_number += 1
    end

    make_file_snaphot
  end

  def make_file_snaphot
    FileUtils.cp(FILE_PATH, DIFF_PATH)
  end

  def transfer_new_file
    notifier.transfer_file(FILE_PATH)
  end

end

class LoggedSocket < TCPSocket

  def puts(message)
    STDOUT.puts message
    super
  end

end

# socket = FakeSocket.new '192.168.2.170', 2000
socket = LoggedSocket.new '192.168.2.170', 2000
notifier = ChangeNotifier.new(socket)
change_detector = ChangeDetector.new(notifier)

if File.exists?(DIFF_PATH)
  change_detector.find_changes
else
  change_detector.make_file_snaphot
  change_detector.transfer_new_file
end

