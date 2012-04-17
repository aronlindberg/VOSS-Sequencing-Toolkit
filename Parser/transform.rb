# This is copied from https://github.com/igrigorik/githubarchive.org
# Originally this was intended to upload the data to BigQuery, but I have modified it to just save the file locally 

require 'tempfile' # This is a utility class for managing temporary files. Initially it was used to store data temporarily while it was uploaded to BigQuery, but I don't think it's used any longer since I used the File.new method to save the file locally.
require 'time' # Time is a class for storing dates and times. It is used to somehow store certain ranges of dates/times in the same file I think
require 'zlib' # A compression library, used so that the class Zlib::GzipReader can be used to read the gzipped files.
require 'yajl' # "Yet Another JSON Library", a JSON parser
require 'csv' # A class for interfacing with csv files

def flatmap(h, e, prefix = '') # Defines the function flatmap with the arguments (local variables) h, e & prefix. Only prefix is given a value, which is ''
  e.each do |k,v| # For each value of e, do k & v ???? k & v stand for key-value pair in a hash I think...
    if v.is_a?(Hash) # Specifies a condition, if v is a hash, then...
      flatmap(h, v, prefix+k+"_") # call the function flatmap with the arguments h, v, and prefix+k+_
    else				# otherwise...
      h[prefix+k] = v unless v.is_a? Array 
    end
  end
  h
end

input = ARGV.shift
if input.nil?
  puts "No input file specified"
  exit(1)
end

schema = Yajl::Parser.parse(open('schema.js').read)
headers = schema['configuration']['load']['schema']['fields'].map {|f| f['name']}

begin
  tmp = File.new("Output.csv", "w+")
  js  = Zlib::GzipReader.new(open(input)).read

  Yajl::Parser.parse(js) do |event|
  	r = CSV::Row.new(headers, [])
  	flatmap({}, event).each do |k,v|
      v = (Time.parse(v).utc.strftime('%Y-%m-%d %T') rescue '') if k =~ /_at$/
      if r.include? k
        r[k] = v
      else
 
       puts "Unknown field: #{k}, value: #{v}"
			end
		end 
	tmp << r.to_s
	end
end
