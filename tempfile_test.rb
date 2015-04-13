require 'tmp_file'

module FileNameUtility
  PATH = "/tmp"
  def random_filename(extension = 'zip')
    "#{SecureRandom.urlsafe_base64}.#{extension}"
  end

  def tempfile_name(extension = 'zip')
    "#{PATH}/#{random_filename(extension)}"
  end

end

#filename = "#{path}/#{random_filename}"
=begin
include FileNameUtility
filename = tempfile_name
File.open(filename, 'wb') do |file|
  file.write("random data")

  p "file path = #{file.path}"
  p "file content : #{file}"
end
FileUtils.rm_f filename
=end
