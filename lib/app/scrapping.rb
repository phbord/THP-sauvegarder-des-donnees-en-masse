class Scrapping
    #attr_accessor :

    def initialize
        @email_url = 'https://www.annuaire-des-mairies.com/'
        @towns = get_connexion_str('https://www.annuaire-des-mairies.com/val-d-oise.html')
    end

    #JSON
    def save_as_JSON(file_name)
        temp_hash = get_townhall_urls()
        File.open("db/#{file_name}","w") do |f|
            f.write(JSON.pretty_generate(temp_hash))
        end
    end

    #Google spreadsheets
    #https://docs.google.com/spreadsheets/d/1S47m351U2pWWFhLN4wEXCmbTzhtguH6mqoNgGpoWr-k/edit#gid=0
    def save_as_spreadsheet(file_url)
        return false unless file_url.is_a? String
        credentials = connection
        credentials.code = authorization_code
        credentials.fetch_access_token!
        session = GoogleDrive::Session.from_credentials(credentials)
        ws = session.spreadsheet_by_key(file_url).worksheets[0]
        dump_all_cells(ws)
    end

    #Google spreadsheets : Connexion
    def connection
        credentials = Google::Auth::UserRefreshCredentials.new(
            client_id: ENV["GOOGLE_CLIENT_ID"],
            client_secret: ENV["GOOGLE_CLIENT_SECRET_CODE"],
            scope: [
                "https://www.googleapis.com/auth/drive",
                "https://spreadsheets.google.com/feeds/",
            ],
            redirect_uri: "http://example.com/redirect",
            additional_parameters: { "access_type" => "offline" }),
        auth_url = credentials.authorization_uri
        return auth_url
    end

    #Google spreadsheets : Vide toutes les cellules
    def dump_all_cells(ws)
        (1..ws.num_rows).each do |row|
            (1..ws.num_cols).each do |col|
            p ws[row, col]
            end
        end
    end

    #CSV
    def save_as_csv
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