require "option_parser"

module Icon::Replacer
  alias Replacement = NamedTuple(app: String, icon: String)

  VERSION = "0.1.0"
  TITLE = "Icon Replacer"

  banner = "#{TITLE} (#{VERSION})"
  @@replacements = [] of Replacement

  OptionParser.parse do |parser|
    parser.banner = "#{banner}\n\
    Replaces macOS system icons with user specified ones\n\
    Usage: icon-replacer [args]"

    parser.on "-v", "--version", "Show version" do
      puts VERSION
      exit
    end
    parser.on "-h", "--help", "Show help" do
      puts parser
      exit
    end
  end

  def self.check_for_fileicon
    unless Process.find_executable("fileicon")
      puts "fileicon not found!"
      puts "install fileicon from Homebrew?"
      puts "`brew install fileicon`"
      puts "type Y to continue, anything else will exit"
      answer = gets

      if answer == "Y"
        Process.run("brew", ["install", "fileicon"], output: STDOUT)
        puts "installed fileicon"

        unless Process.find_executable("fileicon")
          puts "unable to find fileicon"
          puts "please install it manually via brew or NPM and try again"
          exit
        end
      else
        exit
      end
    end
  end

  def self.exit_unless_file_exists(file)
    unless File.exists?(file)
      puts "\"#{file}\"\ndoes not exist, exiting"
      exit
    end
  end

  def self.prompt_for_replacement
    puts "Which app file icon do you want to replace?"
    puts "use full path, ex:"
    puts "/Applications/Spotify.app"

    app = gets || ""

    exit_unless_file_exists(app)

    puts "Which icon do you want to use?"
    puts "use full path, ex:"
    puts "/Users/your-user/Pictures/icons/smiley.png"

    icon = gets || ""

    exit_unless_file_exists(icon)

    @@replacements << {app: app, icon: icon}
  end

  def self.prompt_for_more
    puts "add another?"
    puts "type Y to continue, anything else means N"

    answer = gets

    if answer == "Y"
      prompt_for_replacement
      prompt_for_more
    end
  end

  def self.replace
    puts "icons replaced"
  end

  check_for_fileicon
  load_settings
  prompt_for_replacement
  prompt_for_more
  replace
end
