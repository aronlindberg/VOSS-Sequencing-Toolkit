new_file = File.new('joined.csv', 'w')

headers = File.open('headers.csv', 'r')
while (line = headers.gets)
new_file.write(line)
end
file_to_append_to = File.open('file.csv', 'r')
  while (line = file_to_append_to.gets)
  new_file.write(line)
  end

new_file.close
