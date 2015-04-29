require "zip"
require "securerandom"
require "yaml"
require "nokogiri"
require "Find"

module Metadata

  class SfdcDirectoryService

    public

    def initialize(args = {})
      @args = args
      @output_file_name = tempfile_name("zip")
      @files_to_exclude = Set.new()
      @snippets_to_exclude = {}
      find_source_dir
      prepare_files_to_exclude
      prepare_xml_nodes_to_exclude
    end

    # copy files from original directory to be xml_filtered later
    # Create zip file with contents of force.com project
    # Return absolute path to the file
    def write
      begin
        @zip_io = Zip::File.open(@output_file_name, Zip::File::CREATE)
        raise "package.xml NOT FOUND" unless verify_package_xml

        tmpdir = Dir.mktmpdir
        FileUtils.cp_r(@input_dir_name, tmpdir)
        @input_dir_name = tmpdir.to_s + "/src"

        entries = dir_content(@input_dir_name)
        write_entries(entries, "")
      ensure
        @zip_io.close # close before deleting tmpdir, or NOT_FOUND exception
        FileUtils.remove_entry(tmpdir)
      end

      # FileUtils.cp_r(@output_file_name, "/Users/gt/Desktop/temp.zip")
      return @output_file_name
    end

    private

    def find_source_dir
      raise Exception unless Dir.exists?(@args[:source])
      @input_dir_name = ""
      Find.find(@args[:source]) do |entry|
        if entry.end_with?("src") && File.directory?(entry)
          @input_dir_name = entry
          break
        end
      end
      raise Exception if @input_dir_name.empty?
    end

    def prepare_files_to_exclude()
      exclude_filename = @args[:exclude_components]
      if exclude_filename.nil? || exclude_filename.empty? || not(File.exists?(exclude_filename))
        exclude_filename = File.expand_path("../exclude_components.yml", __FILE__)
      end

      @files_to_exclude = Set.new()
      YAML.load_file(exclude_filename).each do |name|
        @files_to_exclude.add(name.to_s.downcase)
      end
    end

    def prepare_xml_nodes_to_exclude()
      exclude_filename = @args[:exclude_xml]
      if exclude_filename.nil? || exclude_filename.empty? || not(File.exists?(exclude_filename))
        exclude_filename = File.expand_path("../exclude_xml_nodes.yml", __FILE__)
      end

      @snippets_to_exclude = YAML.load_file(exclude_filename)
      # YAML.load_file(exclude_filename).each do |suffix, expressions|
      #   @snippets_to_exclude[key] << value
      #   pp "=== #{key} => #{value}"
      #   expressions.each do |exp, flag|
      #     pp "=== exp => #{exp}"
      #     pp "=== exp => #{flag}"
      #   end
      # end
      # pp "====== snippets => #{@snippets_to_exclude} ==== #{@snippets_to_exclude.class}"
    end

    # Opens file. Removes all bad xml snippets. Rewrites results back into original file
    def filter_xml(filename)
      doc = Nokogiri::XML(File.read(filename))
      # if (filename.end_with?("package.xml"))
      #   p "======= errors of package.xml => #{doc.errors}"
      # end
      file_modified = false
      @snippets_to_exclude.each do |suffix, expressions|
        next unless filename.end_with?(suffix.to_s)
        # p "==== processing suffix = #{suffix} vs #{filename}"
        # p "==== processing snippets = #{snippets}"
        expressions.each do |search_string, should_remove_parent|
          # pp "==== processing snippet = #{search_string}"
          nodes = doc.search(search_string.to_s)
          unless nodes.empty?
            file_modified = true
            nodes.each do |n|
              parent = n.parent
              n.remove unless should_remove_parent
              parent.remove if should_remove_parent # || parent.content.strip.empty?
            end
          end
        end
      end
      File.open(filename, "w") do |file|
        file.print(doc.to_xml)
      end if file_modified
      # if (filename.end_with?("Admin.profile"))
      #   FileUtils.cp(filename, "/Users/gt/Desktop/testAdmin.profile")
      # end
    end

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
          filter_xml(disk_file_path)
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
        p "package.xml FOUND"
        return true
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
