require "./tempfile_test.rb"
require "zip"

=begin
folder = "./" # current folder
input_filename = "test_text_file.txt"
zipfile_name = FileNameUtility::tempfile_name

Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
  zipfile.add(input_filename, folder + input_filename)
  p zipfile
end
=end

class ProjectZipGenerator

  def initialize(input_dir_name = ".")
    @input_dir_name = input_dir_name
    @output_file_name = FileNameUtility::tempfile_name
    @zip_io = Zip::File.open(@output_file_name, Zip::File::CREATE)
  end

  def write
    entries = dir_content(@input_dir_name)
    write_entries(entries, "")
  ensure
    @zip_io.close()
    #FileUtils.rm_f @output_file_name
    # FileUtils.mv(@output_file_name, "/Users/gt/Desktop/test_zip.zip")
    @output_file_name
  end

  private
  def write_entries(entries, path)
    entries.each do |entry|
      # need relative local file path to use in new zip file too
      zip_file_path = (path == "" ? entry : File.join(path, entry)) # maybe without if/else

      # need full file path to use in copy/paste
      disk_file_path = File.join(@input_dir_name, zip_file_path)
      if File.directory?(disk_file_path)
        @zip_io.mkdir(zip_file_path)
        sub_dir = dir_content(disk_file_path)
        write_entries(sub_dir, zip_file_path)
      else
        @zip_io.add(zip_file_path, disk_file_path);
      end
    end
  end

  def dir_content(full_path)
    content = Dir.entries(full_path)
    content.delete("..");
    content.delete(".")
    content
  end
end

test_generator = ProjectZipGenerator.new("/Users/gt/Desktop/TestProject")
test_generator.write
#FileUtils.rm zipfile_name
