class ScrubsController < ApplicationController
  
  def index
    #@fronts = Front.order(created_at: :desc).all
  end
    
  def upload
      @db_headers = ['firstname','lastname','phone']
     
      if !params["fileToUpload"]
        redirect_to request.referer
      else
        t = Time.now
        @generated_filename = "SrubCheck-#{t.month}-#{t.day}-#{t.year}_#{t.hour}#{t.min}#{t.sec}.xlsx"
        uploaded_io = params["fileToUpload"]
        #new_path = Rails.root.join('private', 'uploads', @generated_filename)
        new_path = Rails.root.to_s + "/private/uploads/#{@generated_filename}"
        
        File.open(new_path, 'wb') do |file|
          file.write(uploaded_io.read)
        end

        #Read File and get first row
        workbook = RubyXL::Parser.parse(new_path)
        worksheet = workbook[0] 
        data = worksheet.extract_data
        @xldata = data.first
        @colsize = @xldata.count
      end
  end
  
  
  def doscrub
    
    filename = params['filename']
    mapping = params['mapping']
    t = Time.now
    scrubbed_file = "ScrubbedLeads-#{t.month}-#{t.day}-#{t.year}_#{t.hour}#{t.min}#{t.sec}.xlsx"
    path = Rails.root.to_s + "/private/uploads/#{filename}"
    scrub_path = Rails.root.to_s + "/private/generated/#{scrubbed_file}"
    
    #input file
    workbook = RubyXL::Parser.parse(path)
    worksheet = workbook[0] 
    data = worksheet.extract_data

    
    scrubed_workbook = RubyXL::Workbook.new
    scrub_worksheet = scrubed_workbook[0]
    scrubed_row_index = 0
    
    total = 0 #rows proceessed
    scrubed_total = 0
    
    data.each do |row|
      next if row.nil?
      
      sql = "Select count(*) from nocalls where "
      first_name = nil
      last_name = nil
      mapping.each do |mindex, map|
        cell_index = map[0].to_i
        if map[1] == "phone"
          line = row[cell_index].to_s.gsub(/[^0-9]/, '')
          if line.size == 10
            phone1 = line[0,3]
            phone2 = line[3,3]
            phone3 = line[6,4]
            phone = "#{phone1}-#{phone2}-#{phone3}"
            sql += " phone = \"#{phone}\" OR"
          end
        elsif map[1] == "firstname"
          first_name = "#{row[cell_index]}".capitalize
          next if last_name.nil?
          sql += " ( firstname = \"#{safeSQL(first_name)}\" AND lastname = \"#{safeSQL(last_name)}\") OR"
      
        elsif map[1] == "lastname"
          last_name = "#{row[cell_index]}".capitalize
          next if first_name.nil?
          sql += " ( firstname = \"#{safeSQL(first_name)}\" AND lastname = \"#{safeSQL(last_name)}\") OR"
        end
      end
      sql += " 1 = 0 "
      

      results = ActiveRecord::Base.connection.execute(sql)
      if results.first[0] == 0
        # add row to new file
        i = 0
        row.each do |value|
          scrub_worksheet.add_cell(scrubed_row_index,i,value)
          i += 1
        end
        scrubed_row_index += 1
      else
        scrubed_total += 1
      end
      total += 1
    end
    scrubed_workbook.write(scrub_path)
    
    msg = "<p>Scrubbed #{total} Rows.</p><p>Found #{scrubed_total} leads on NoCall</p>"
    j = {"msg" => msg, "file" => scrubbed_file}
    render json: j.to_json
  end
  
  
  def safeSQL(d)
    d.to_s.gsub('"','')
  end
  
end
