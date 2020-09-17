require 'csv'
require 'zlib'
require 'json'

require 'yajl'

$files = {}

def read_csv(filename)
  p filename
  CSV(Zlib::GzipReader.new(File.open(filename))).each do |row|
    name = row[1]
    next if name.end_with?('/')

    size = row[2]
    parent = $files
    split = name.split('/')
    split.each.with_index(1) do |part, i|
      # p part, i, split.length
      if i == split.length
        parent[nil] ||= []
        parent[nil] << [part, size.to_i]
      else
        parent[part] ||= {}
        parent = parent[part]
      end
    end
  end
end

def to_a(hash, array)
  array.concat(hash[nil].map { |e| { name: e[0], dsize: e[1] } }) if hash.key?(nil)
  hash.reject { |k, _v| k.nil? }.each do |key, value|
    array << []
    array[-1] << { name: key }
    to_a(value, array[-1])
  end
end

ARGV.each { |name| read_csv(name) }
files_array = [{ name: 'bucket' }]
p 'to_a'
to_a($files, files_array)
# puts JSON.pretty_generate(files_array.first)

p 'write'
File.open('ncdu.json', 'w') do |f|
  Yajl.dump([1, 0, {}, files_array], f)
  # f.write([1, 0, {}, files_array].to_json)
end

#puts JSON.pretty_generate([1, 0, {}, files_array])

