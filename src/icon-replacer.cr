require "json"
require "option_parser"

alias Replacement = NamedTuple(app: String, icon: String)

VERSION = "0.1.0"
TITLE = "Icon Replacer"

HOME_DIR = `echo $HOME`.chomp

settings_file = ""

OptionParser.parse do |parser|
  parser.banner = "#{TITLE} (#{VERSION})\n\
  Replaces macOS system icons with user specified ones\n\
  Usage: icon-replacer [args]"

  parser.on("-s FILE", "--settings=FILE", "Specifies settings file to load") do |file|
    settings_file = file
  end

  parser.on("-v", "--version", "Show version") do
    puts VERSION
    exit
  end

  parser.on("-h", "--help", "Show help") do
    puts parser
    exit
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

class Exec
  @settings_file = ""
  @replacements = [] of Replacement

  def initialize(settings_file)
    @settings_file = settings_file
  end

  def check_for_fileicon
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

  def choose_file(path = HOME_DIR)
    script = "'tell application (path to frontmost application as text)\n\
set myFile to choose file default location \"#{path}\"\n\
POSIX path of myFile\n\
end'"

    file = `osascript -e #{script}`.chomp
    puts file
    file
  end

  def choose_new_file(name = "untitled.dat", path = HOME_DIR)
    script = "'tell application (path to frontmost application as text)\n\
set myFile to choose file name default name \"#{name}\" default location \"#{path}\"\n\
POSIX path of myFile\n\
end'"

    file = `osascript -e #{script}`.chomp
    puts file
    file
  end

  def load_settings
    if @settings_file.empty?
      puts "Load settings from a file?"
      puts "type Y to load, anything else means N"

      answer = gets

      return if answer != "Y"

      file = choose_file
    else
      exit_unless_file_exists(@settings_file)
      file = @settings_file
    end

    @replacements = Array(Replacement).from_json(File.read(file))
  end

  def exit_unless_file_exists(file)
    unless File.exists?(file)
      puts "\"#{file}\"\ndoes not exist, exiting"
      exit
    end
  end

  def prompt_for_replacement
    puts "Which app file icon do you want to replace?"

    app = choose_file("/Applications")

    exit_unless_file_exists(app)

    puts "Which icon do you want to use?"

    icon = choose_file

    exit_unless_file_exists(icon)

    @replacements << {app: app, icon: icon}
  end

  def prompt_for_more
    puts "add another?"
    puts "type Y to continue, anything else means N"

    answer = gets

    if answer == "Y"
      prompt_for_replacement
      prompt_for_more
    end
  end

  def prompt_for_settings_save
    return unless @settings_file.empty?

    puts "save replacement settings?"
    puts "type Y to continue, anything else means N"

    answer = gets

    if answer == "Y"
      puts "Save to file:"
      puts "ex:"
      puts "/Users/your-user/icon-replacer-settings.dat"

      file = choose_new_file("icon-replacer-settings.dat")

      exit if file.empty?

      File.write(file, @replacements.to_json)
      puts "settings file saved to:\n#{file}"
    end
  end

  def replace
    @replacements.each do |replacement|
      Process.run("fileicon", ["set", replacement[:app], replacement[:icon]])
      puts "#{replacement[:app]} icon replaced"
    end
  end

  def run
    check_for_fileicon
    load_settings

    if @replacements.empty?
      prompt_for_replacement
      prompt_for_more
      prompt_for_settings_save
    end

    replace
  end
end

Exec.new(settings_file).run
