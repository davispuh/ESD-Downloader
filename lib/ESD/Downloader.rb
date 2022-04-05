require_relative 'Downloader/version'
require 'httparty'
require 'tempfile'
require 'libmspack'

module ESD
    module Downloader

        # https://download.microsoft.com/download/0/d/b/0db6dfde-48c9-4d70-904e-462b46d8a473/products_20211004.cab
        WINDOWS_11_PRODUCT_URI = 'https://download.microsoft.com/download/c/5/4/c541b424-e8a7-437b-8c48-3bc3a42d9422/products.xml'

        WINDOWS_10_PRODUCT_URI = 'https://go.microsoft.com/fwlink/?LinkId=841361'
        WINDOWS_8_PRODUCT_UPGRADE_URI = 'https://wscont.apps.microsoft.com/winstore/OSUpgradeNotification/products.xml'

        @@Products = {}

        def self.getProductsData(productsUri)
            productsData = nil
            response = HTTParty.get(productsUri)
            if response.code == 200
                response.body.delete_prefix!("\xEF\xBB\xBF".force_encoding('ASCII-8BIT')) # Remove BOM
                if response.body[0] == '<'
                    productsData = MultiXml.parse(response.body)
                else
                    productsFile = Tempfile.new
                    productsFile.write(response.body)
                    productsFile.close
                    decompressor = LibMsPack::CabDecompressor.new
                    cab = decompressor.open(productsFile.path)
                    productsFile = Tempfile.new
                    productsFile.close
                    decompressor.extract(cab.files, productsFile.path)
                    productsFile.open
                    productsXML = productsFile.read
                    productsData = MultiXml.parse(productsXML)
                    productsFile.close!
                    decompressor.close(cab)
                    decompressor.destroy
                    productsFile.unlink
                end
            else
                raise "Error: #{response.code} #{response.message}"
            end
            productsData
        end

        def self.getProducts(versions = nil)
            versions = ['10', '11'] unless versions
            @@Products['10'] = self.getProductsData(WINDOWS_10_PRODUCT_URI) if versions.include?('10') && !@@Products.has_key?('10')
            @@Products['11'] = self.getProductsData(WINDOWS_11_PRODUCT_URI) if versions.include?('11') && !@@Products.has_key?('11')
            @@Products
        end

        def self.getAllFiles(versions = nil)
            files = []
            products = self.getProducts(versions)
            products.each do |version, productsData|
                catalog = productsData.dig('MCT', 'Catalogs', 'Catalog')
                catalog = productsData unless catalog
                newFiles = catalog['PublishedMedia']['Files']['File']
                newFiles.map { |file| file['Version'] = version }
                files += newFiles
            end
            files
        end

        def self.findFiles(version = nil, locale = nil, edition = nil, arch = nil)
           files = self.getAllFiles(version ? [version] : nil)
           files.reject! do |f|
               reject = false
               reject = true if version and f['Version'] != version
               reject = true if locale and !f['LanguageCode'].downcase.start_with?(locale.downcase)
               reject = true if edition and f['Edition'].downcase != edition.downcase
               reject = true if arch and !f['Architecture'].downcase.start_with?(arch.downcase)
               reject
           end
           files
        end
    end
end
