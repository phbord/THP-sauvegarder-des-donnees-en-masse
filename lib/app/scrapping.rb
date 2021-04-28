class Scrapping
    #attr_accessor :

    def initialize
        @email_url = 'https://www.annuaire-des-mairies.com/'
        @towns = get_connexion_str('https://www.annuaire-des-mairies.com/val-d-oise.html')
    end

    #JSON
    def save_as_JSON(file_name)
        temp_hash = get_townhall_urls()

        File.new "db/#{file_name}","w"
        File.open("db/#{file_name}","w") do |f|
            f.write(JSON.pretty_generate(temp_hash))
        end
    end

    #CSV
    def save_as_csv(file_name)
        temp_hash = get_townhall_urls()

        File.new "db/#{file_name}","w"
        res = CSV.generate(:col_sep => ",") do |csv|
            temp_hash.each do |h|
                csv << h.keys
                csv << h.values
            end
        end
        File.write("db/#{file_name}", res)
    end

    #Google spreadsheets
    def save_as_spreadsheet(file_url)
        return false unless file_url.is_a? String
        temp_hash = get_townhall_urls()

        ws = connection
        ws = ws.spreadsheet_by_key(file_url).worksheets[0] #read

        ws[1, 1] = "Name"
        ws[1, 2] = "Email"

        row = 2
        temp_hash.each do |h|
            ws[row, 1] = h.keys.inspect.gsub(/\[|\"\]/, "").gsub(/\"/, "")
            ws[row, 2] = h.values.gsub(/\[|\"\]/, "").gsub(/\"/, "")
            row += 1
        end

        ws.save
        ws.reload
    end

    #Google spreadsheets : Connexion
    def connection
        return session = GoogleDrive::Session.from_config("config.json")
    end


    def get_connexion_str(url)
        begin
            client = Nokogiri::HTML(URI.open(url))
        rescue => e
            puts "Exception Message: #{ e.message }"
        end
        #puts client
        return client
    end

    def get_townhall_email(url)
        townhall_email_value = url.css('main section[2] div table tbody tr[4] td[2]').text.downcase
        return false if townhall_email_value.length < 1
        #puts townhall_email_value
        return townhall_email_value
    end

    def get_townhall_urls()
        townhalls_row = @towns.css('a.lientxt')
        return false if townhalls_row.length < 1
        links = []
        townhalls_row.each.with_index { |n,i|
            url_end = n["href"]
            url_end = url_end.slice!(1..url_end.length - 1) if url_end.slice!(0) == '.'
            url_town = "#{@email_url}#{url_end}"
            connexion = get_connexion_str(url_town)
            email = get_townhall_email(connexion)
            #Hash incrementation
            links[i] = {n.text.upcase => email}
        }
        #puts links
        return links
    end
end