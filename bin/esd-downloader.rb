#!/bin/ruby

require_relative '../lib/ESD/Downloader'

require 'optparse'
require 'yaml'
require 'filesize'
require 'progress_bar'
require 'open-uri'
require 'digest/sha1'

def getOptions
    options = { :Command => nil, :Locale => nil, :Edition => nil, :Arch => nil }

    parser = OptionParser.new do |opts|
        opts.banner = "Usage: esd-downloader.rb <command> [options]\nCommands: list and download"

        opts.on('-l','--locale LOCALE', 'Specify locale') do |locale|
            options[:Locale] = locale
        end

        opts.on('-e','--edition EDITION', 'Specify edition') do |edition|
            options[:Edition] = edition
        end

        opts.on('-a','--arch ARCH', 'Specify architecture') do |arch|
            options[:Arch] = arch
        end

        opts.on_tail('-h', '--help', 'Show this message') do
            puts opts
            return false
        end
    end
    begin
        parser.parse!
    rescue OptionParser::ParseError => e
        $stderr.puts(e.message)
        return false
    end

    if ARGV.length > 0
        options[:Command] = ARGV.first.capitalize.to_sym
    else
        $stderr.puts('No command specified!')
        puts parser.help
        return false
    end

    return options
end

def info(file)
    puts '--------------------'
    puts "FileName: #{file['FileName']}"
    puts "LanguageCode: #{file['LanguageCode']}"
    puts "Language: #{file['Language']}"
    puts "Edition: #{file['Edition']}"
    puts "Architecture: #{file['Architecture']}"
    size = Filesize.new(file['Size'])
    puts "Size: #{size.pretty} (#{size.to_i} bytes)"
    puts "SHA1: #{file['Sha1']}"
    puts "URL: #{file['FilePath']}"
    puts "Key: #{file['Key']}"
    puts '--------------------'
end

def verify_download(file)
    puts 'Verifying file hash'
    hash = Digest::SHA1.new
    block_size = Filesize.from('16 MiB')
    File.open(file['FileName']) do |f|
        loop do
          data = f.read(block_size)
          break if data.nil?
          hash.update(data)
        end
        digest = hash.hexdigest.downcase
        if file['Sha1'].downcase == digest
             $stderr.puts("SHA1 matches #{digest}")
            return true
        else
            $stderr.puts("SHA1 doesn't match! Was #{digest} but expected #{file['Sha1']}!")
        end
    end
    return false
end

def download(locale, edition, arch)
    files = ESD::Downloader::findFiles(locale, edition, arch)
    files.each do |file|
        filename = File.basename(file['FileName'], '.*')
        puts "Downloading #{filename}"
        File.write(filename + '.yaml', file.to_yaml)

        progress = nil
        prev_size = 0
        data = open(file['FilePath'],
                    :content_length_proc => lambda { |length|
                        if length and length > 0
                            progress = ProgressBar.new(length)
                        end
                    },
                    :progress_proc => lambda { |size|
                        if progress
                            progress.increment!(size - prev_size)
                            prev_size = size
                        end
                    })
        IO.copy_stream(data, file['FileName'])
        if verify_download(file)
            puts 'Download succesful!'
        else
            puts 'Download failed!'
        end
    end
end

def list(locale, edition, arch)
    files = ESD::Downloader::findFiles(locale, edition, arch)
    files.each do |file|
        info(file)
    end
end

def main
    options = getOptions
    return false unless options

    Signal.trap('INT') do
        puts 'Quiting!'
        exit(1)
    end

    case options[:Command]
    when :List
        list(options[:Locale], options[:Edition], options[:Arch])
    when :Download
        download(options[:Locale], options[:Edition], options[:Arch])
    else
        $stderr.puts("Unknown command '#{options[:Command].to_s}'!")
    end
end

main unless $spec

