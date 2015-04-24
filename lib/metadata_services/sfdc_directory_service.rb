require "zip"
require "securerandom"
require "yaml"
require "nokogiri"

module Metadata

  class SfdcDirectoryService

    public

    def initialize(input_dir_name = Dir.pwd, exclude_components_filename = "", exclude_xml_nodes_filename = "")
      # todo check if input path is directory
      # @input_dir_name = input_dir_name + "/project/src"
      @input_dir_name = input_dir_name
      @output_file_name = tempfile_name("zip")
      @files_to_exclude = Set.new()
      @snippets_to_exclude = {}

      prepare_files_to_exclude(exclude_components_filename)
      prepare_xml_nodes_to_exclude(exclude_xml_nodes_filename)
    end

    # copy files from original directory to be xml_filtered later
    # Create zip file with contents of force.com project
    # Return absolute path to the file
    def write
      begin
        @zip_io = Zip::File.open(@output_file_name, Zip::File::CREATE)
        verify_package_xml

        tmpdir = Dir.mktmpdir
        FileUtils.cp_r(@input_dir_name + "/project/src", tmpdir)
        @input_dir_name = tmpdir.to_s + "/src"

        entries = dir_content(@input_dir_name)
        write_entries(entries, "")
      ensure
        @zip_io.close # close before deleting tmpdir, or NOT_FOUND exception
        FileUtils.remove_entry(tmpdir)
      end

      return @output_file_name
    end

    private

    def prepare_files_to_exclude(exclude_filename)
      if exclude_filename.empty? || not(File.exists?(exclude_filename))
        exclude_filename = File.expand_path("../exclude_components.yml", __FILE__)
      end

      @files_to_exclude = Set.new()
      YAML.load_file(exclude_filename).each do |name|
        @files_to_exclude.add(name.to_s.downcase)
      end
    end

    def prepare_xml_nodes_to_exclude(exclude_filename)
      if exclude_filename.empty? || not(File.exists?(exclude_filename))
      exclude_filename = File.expand_path("../exclude_xml_nodes.yml", __FILE__)
      end

      @snippets_to_exclude = YAML.load_file(exclude_filename)
      # YAML.load_file(exclude_filename).each do |key, value|
      #   # @snippets_to_exclude[key] << value
      #   pp "=== #{key} => #{value}"
      # end
      # pp "====== snippets => #{@snippets_to_exclude} ==== #{@snippets_to_exclude.class}"
    end

    # def filter_xml(filename)
    #   @snippets_to_exclude.each do |suffix|
    #     next unless filename.end_with(suffix)
    #
    #
    #   end
    # end

    def write_entries(entries, path)
      entries.each do |entry|
        # need relative local file path to use in new zip file too
        zip_file_path = (path == "" ? entry : File.join(path, entry)) # maybe without if/else
        next if @files_to_exclude.include?(zip_file_path.downcase) # avoid if directory/file excluded

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

    # Creates unique filename including path to temporary directory
    # Adds extension to filename. Default is "zip".
    def tempdir_name()
      return "#{Dir.tmpdir}/#{random_filename("")}"
    end

    # check if exists or create if doesn't
    def verify_package_xml
      path = File.join(File.expand_path(@input_dir_name, __FILE__), "package.xml")
      if File.exists?(path)
        return "package.xml FOUND"
      else
        # todo logic to create package.xml. use default file
        return false
      end
    end
  end # class SfdcDirectoryService
end # module Metadata

# simple test
# test_generator = Metadata::SfdcDirectoryService.new("/Users/gt/Desktop/TestProject")
# test_generator.write
