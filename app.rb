require 'bundler'
Bundler.require

require 'dotenv'
Dotenv.load('config.json')

$:.unshift File.expand_path('./../lib', __FILE__)
require 'app/scrapping'
#binding.pry

def perform
    scrapping = Scrapping.new()

    #0/ Launch scrapping
    #scrapping.get_townhall_urls

    #1/ Save in JSON file
    #scrapping.save_as_JSON("emails.json")

    #2/ Save in Google Spreadsheet file
    scrapping.save_as_spreadsheet(("1S47m351U2pWWFhLN4wEXCmbTzhtguH6mqoNgGpoWr-k"))

    #3/Save in CSV file
    #scrapping.save_as_csv("emails.csv")
end

perform