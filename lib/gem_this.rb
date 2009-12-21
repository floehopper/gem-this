require 'erb'
require 'etc'

class GemThis
  SUMMARY = "Creates a Rakefile suitable for turning the current project into a gem."
  DEBUG_MESSAGE = "debug, only prints out the generated Rakefile."

  attr_reader :name, :debug

  def initialize(name, debug)
    @name = name
    @debug = debug
  end

  def create_rakefile
    template = ERB.new File.read(File.join(File.dirname(__FILE__), '..', 'Rakefile.erb')), nil, '<>'
    rakefile = template.result(binding)

    if debug
      puts rakefile
    else
      if File.exist?('Rakefile')
        puts "Appended to existing Rakefile"
        File.open('Rakefile', 'a') { |f| 2.times { f.puts }; f.write rakefile }
      else
        puts "Writing new Rakefile"
        File.open('Rakefile', 'w') { |f| f.write rakefile }
      end
      add_to_gitignore if using_git?
    end
    unless has_lib_directory?
      puts "You don't see to have a lib directory - please edit the Rakefile to set where your code is."
      false
    end
  end

  private

  def author_name
    Etc.getpwnam(ENV['USER']).gecos rescue ENV['USER'] # for Windows
  end

  def author_email
    "youremail@example.com"
  end

  def author_url
    "http://yoursite.example.com"
  end

  def using_rspec?
    File.directory?('spec')
  end

  def using_test_unit?
    File.directory?('test')
  end

  def has_executables?
    File.directory?('bin')
  end

  def has_lib_directory?
    File.directory?("lib")
  end

  def dirs_to_include_glob
    dirs = %w(bin test spec lib).select { |d| File.directory?(d) }
    if dirs.any?
      dirs.join(",") + "/**/*"
    else
      "**/*"
    end
  end

  def readme
    Dir['*'].find { |f| f =~ /readme/i }
  end

  def files_in_root
    Dir['*'].reject { |f| File.directory?(f) }.join(" ")
  end

  def using_git?
    File.exist?(".git")
  end

  def add_to_gitignore
    return unless File.exist?(".gitignore")
    ignores = File.readlines(".gitignore")
    ignores += ["pkg", "rdoc"]
    File.open(".gitignore", "w") { |f| f.write ignores.map { |l| l.strip }.uniq.join("\n") }
  end
end