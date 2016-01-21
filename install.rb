#!/usr/bin/env ruby

require 'fileutils'

def create_symlink(source, destination)
  notice "ln -sF #{source} #{destination}"
  FileUtils.ln_sf(source, destination)
end

def heading(message)
  puts "\n\n-> #{message}\n\n"
end

def notice(message)
  puts message
end

SUBL_FILES = ["Preferences.sublime-settings", "Default (OSX).sublime-keymap", "Maguire.tmTheme"]
SUBL_PATH = ["Library", "Application Support", "Sublime Text 2", "Packages", "User"]

heading "Adding symlinks for config files in home directory"
Dir.glob("dot_files/.*").each do |file_path|

  # Exclude "." and ".."
  next if file_path.chars.last == "."

  source      = File.join(FileUtils.pwd, file_path)
  filename    = file_path.split("/").last
  destination = File.expand_path("~/#{filename}")

  create_symlink(source, destination)

end

heading "Add symlink for sublime text 2 user preferences"

SUBL_FILES.each do |filename|

  source      = File.join(FileUtils.pwd, "subl", filename)
  destination = File.join(File.expand_path("~/"), SUBL_PATH, filename)

  create_symlink(source, destination)

end