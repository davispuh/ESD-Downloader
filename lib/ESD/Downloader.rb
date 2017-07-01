require_relative 'Downloader/version'
require 'httparty'
require 'tempfile'
require 'libmspack'

module ESD
    module Downloader
        PRODUCT_URI = 'https://go.microsoft.com/fwlink/?LinkId=841361'

        @@Products = nil

        def self.getProducts()
            if @@Products.nil?
                response = HTTParty.get(PRODUCT_URI)
                if response.code == 200
                    cabFile = Tempfile.new
                    cabFile.write(response.body)
                    cabFile.close
                    decompressor = LibMsPack::CabDecompressor.new
                    cab = decompressor.open(cabFile.path)
                    productsFile = Tempfile.new
                    productsFile.close
                    decompressor.extract(cab.files, productsFile.path)
                    productsFile.open
                    productsXML = productsFile.read
                    @@Products = MultiXml.parse(productsXML)
                    productsFile.close!
                    decompressor.close(cab)
                    decompressor.destroy
                    cabFile.unlink
                else
                    raise "Error: #{response.code} #{response.message}"
                end
            end
            @@Products
        end

        def self.getFiles
            getProducts['MCT']['Catalogs']['Catalog']['PublishedMedia']['Files']['File']
        end

        def self.findFiles(locale = nil, edition = nil, arch = nil)
           files = getFiles
           files.reject! do |f|
               reject = false
               reject = true if locale and !f['LanguageCode'].downcase.start_with?(locale.downcase)
               reject = true if edition and f['Edition'].downcase != edition.downcase
               reject = true if arch and !f['Architecture'].downcase.start_with?(arch.downcase)
               reject
           end
           files
        end
    end
end

