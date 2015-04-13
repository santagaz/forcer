require "./tempfile_test.rb"
require "zip"

include FileNameUtility

folder = "./" # current folder
input_filename = "test_text_file.txt"
zipfile_name = tempfile_name

Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
  zipfile.add(input_filename, folder + input_filename)
  p zipfile
end

FileUtils.rm zipfile_name
