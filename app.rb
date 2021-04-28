require 'bundler'
Bundler.require

require 'dotenv'
Dotenv.load('.env')

$:.unshift File.expand_path('./../lib', __FILE__)
require 'app/scrapping'
#binding.pry

scrapping = Scrapping.new()

#Launch scrapping
#scrapping.get_townhall_urls

#Save in JSON file
#scrapping.save_as_JSON("emails.json")


#Save in Google Spreadsheet file
scrapping.save_as_spreadsheet(("1S47m351U2pWWFhLN4wEXCmbTzhtguH6mqoNgGpoWr-k"))

#Save in CSV file
scrapping.save_as_csv