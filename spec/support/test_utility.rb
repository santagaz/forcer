module Forcer
  module TestUtility
    # suppress standard output to console
    def suppress_output_for_test
      RSpec.configure do |config|
        config.before(:all) do
          disable_output
        end
        config.after(:all) do
          enable_output
        end
      end
    end

    def disable_output
      unless defined? @@original_stderr
        @@original_stderr = $stderr
        @@original_stdout = $stdout
      end

      # Redirect stderr and stdout
      $stderr = File.open(File::NULL, "w")
      $stdout = File.open(File::NULL, "w")
    end

    def enable_output
      if defined @@original_stderr
        $stderr = @@original_stderr
        $stdout = @@original_stdout
      end
    end
  end
end