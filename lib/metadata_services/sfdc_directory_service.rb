require "zip"
require "securerandom"

module Metadata

  class SfdcDirectoryService

    def initialize(input_dir_name = ".")
      @input_dir_name = input_dir_name
      @output_file_name = tempfile_name("zip")
      @zip_io = Zip::File.open(@output_file_name, Zip::File::CREATE)
    end

    # Create zip file with contents of force.com project
    # Return absolute path to the file
    def write
      # todo check if package.xml exists
      entries = dir_content(@input_dir_name)
      write_entries(entries, "")
    ensure
      @zip_io.close

      return @output_file_name
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
          @zip_io.add(zip_file_path, disk_file_path)
        end
      end
    end

    # Returns array of files for the specified directory (full_path) without current_dir "." and
    # prev directory ".."
    def dir_content(full_path)
      content = Dir.entries(full_path)
      content.delete("..")
      content.delete(".")
      return content
    end

    # Creates random string to guarantee uniqueness of filename
    # Adds extension to filename
    def random_filename(extension)
      return "#{SecureRandom.urlsafe_base64}.#{extension}"
    end

    # Creates unique filename including path to temporary directory
    # Adds extension to filename. Default is "zip".
    def tempfile_name(extension = "zip")
      return "#{Dir.tmpdir}/#{random_filename(extension)}"
    end
  end # class SfdcDirectoryService
end # module Metadata

# simple test
# test_generator = Metadata::SfdcDirectoryService.new("/Users/gt/Desktop/TestProject")
# test_generator.write
