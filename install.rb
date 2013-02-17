#!/usr/bin/env ruby

require 'fileutils'

def heading(message)
  puts "-> #{message}\n\n"
end

def notice(message)
  puts message
end

CONFIG_FILES = [".ackrc", ".bash_profile", ".gemrc", ".gitconfig", ".global_gitignore", ".redebugrc"]

heading "Adding symlinks for config files in home directory"

CONFIG_FILES.each do |filename|

  source      = "#{FileUtils.pwd}/#{filename}"
  destination = File.expand_path("~/#{filename}")

  notice "ln -sF #{source} #{destination}"
  FileUtils.ln_sf(source, destination)

end