require "zip"
require "securerandom"
require "yaml"
require "nokogiri"
require "find"

module Metadata

  class SfdcDirectoryService

    public

    def initialize(args = {})
      @args = args
      @output_file_name = tempfile_name("zip")
      find_source_dir
    end

    # copy files from original directory to be xml_filtered when creating zip
    # Create zip file with contents of force.com project
    # Return absolute path to the file
    def make_project_zip
      begin
        @zip_io = Zip::File.open(@output_file_name, Zip::File::CREATE)
        raise "package.xml NOT FOUND" unless verify_package_xml

        p "making temporary copy of project folder"
        tmpdir = Dir.mktmpdir
        FileUtils.cp_r(@input_dir_name, tmpdir)
        @input_dir_name = tmpdir.to_s + "/src"

        entries = dir_content(@input_dir_name)
        p "excluding specified components from deployment"
        write_entries(entries, "")
      ensure
        @zip_io.close # close before deleting tmpdir, or NOT_FOUND exception
        FileUtils.remove_entry(tmpdir)
        p "deleted temporary copy of project folder"
      end

      return @output_file_name
    end

    private

    def find_source_dir
      raise Exception unless Dir.exists?(@args[:source])
      @input_dir_name = ""
      Find.find(@args[:source]) do |entry|
        if entry.end_with?("src") && File.directory?(entry)
          @input_dir_name = entry
          p "found 'src' directory"
          break
        end
      end
      raise "'src' directory NOT FOUND" if @input_dir_name.empty?
    end

    def prepare_files_to_exclude
      exclude_filename = @args[:exclude_components]

      # if not specified, load default exclude_components.yml
      if exclude_filename.nil? || !(File.exists?(exclude_filename))
        p "using default exclude_components.yml"
        exclude_filename = File.expand_path("../exclude_components.yml", __FILE__)
      else
        p "using exclude_components.yml from forcer_config"
      end

      @files_to_exclude = Set.new
      YAML.load_file(exclude_filename).each do |name|
        @files_to_exclude.add(name.to_s.downcase)
      end
    end

    def prepare_xml_nodes_to_exclude
      exclude_filename = @args[:exclude_xml]

      # if not specified, load default exclude_xml_nodes.yml
      if exclude_filename.nil? || !(File.exists?(exclude_filename))
        p "using default exclude_xml_nodes.yml"
        exclude_filename = File.expand_path("../exclude_xml_nodes.yml", __FILE__)
      else
        p "using exclude_xml_nodes.yml from forcer_config"
      end

      @snippets_to_exclude = YAML.load_file(exclude_filename)
    end

    # Opens file. Removes all bad xml snippets. Rewrites results back into original file
    def filter_xml(filename)
      prepare_xml_nodes_to_exclude if @snippets_to_exclude.nil?
      doc = Nokogiri::XML(File.read(filename))
      file_modified = false
      @snippets_to_exclude.each do |suffix, expressions|
        next unless filename.end_with?(suffix.to_s)
        expressions.each do |search_string, should_remove_parent|
          nodes = doc.search(search_string.to_s)
          unless nodes.empty?
            file_modified = true
            nodes.each do |n|
              parent = n.parent
              n.remove unless should_remove_parent # remove only node if parent to stay
              parent.remove if should_remove_parent # remove the whole parent node with all children including current node
            end
          end
        end
      end
      File.open(filename, "w") do |file|
        file.print(doc.to_xml)
      end if file_modified
    end

    def write_entries(entries, path)
      entries.each do |entry|
        # need relative local file path to use in new zip file too
        zip_file_path = (path == "" ? entry : File.join(path, entry)) # maybe without if/else
        next if exclude_file?(zip_file_path.downcase)

        # need full file path to use in copy/paste
        disk_file_path = File.join(@input_dir_name, zip_file_path)

        if File.directory?(disk_file_path)
          @zip_io.mkdir(zip_file_path)
          sub_dir = dir_content(disk_file_path)
          write_entries(sub_dir, zip_file_path)
        else
          filter_xml(disk_file_path) unless xml_exclusion_skipped_for?(disk_file_path)
          @zip_io.add(zip_file_path, disk_file_path)
        end
      end
    end

    def exclude_file?(filename)
      raise Exception if (filename.nil? or filename.empty?)
      if (@files_to_exclude.nil? or @files_to_exclude.empty?)
        @files_to_exclude = Set.new()
        prepare_files_to_exclude
      end

      return @files_to_exclude.include?(filename)
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

    # check if destination server is Production
    def is_production
      return (@args[:host].start_with?("https://login") or @args[:host].start_with?("login"))
    end

    # By default for Production it only processes package.xml and other files
    # (objects, profiles, ...) are ignored (xml exclusions are OFF except package.xml). By default
    # for Sandbox all xml exclusion are turned ON. Package.xml exclusions are OK because they allow
    # skip deployment of certain objects/files.
    # To turn ON all xml exclusion for Production, set --forcerExclude to TRUE
    # To turn OFF absolutely all exclusions (package.mxl too), set --skipExclude to TRUE
    def xml_exclusion_skipped_for?(full_filename)
      raise Exception if (full_filename.nil? or full_filename.empty?)
      return true if @args[:skipExclude]

      if full_filename.end_with?("package.xml")
        return false
      else
        return (is_production unless @args[:forceExclude])
      end
    end
  end # class SfdcDirectoryService

end # module Metadata
