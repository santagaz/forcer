require 'tmp_file'

path = "/tmp"
def random_filename(extension = 'zip')
  "#{SecureRandom.urlsafe_base64}.#{extension}"
end

filename = "#{path}/#{random_filename}"
File.open(filename, 'wb') do |file|
  file.write("random data")

  p "file path = #{file.path}"
  p "file content : #{file}"
end
FileUtils.rm_f path
