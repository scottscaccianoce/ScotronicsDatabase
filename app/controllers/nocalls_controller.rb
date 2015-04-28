class NocallsController < ApplicationController
  
  before_filter :authorize#, :only => [:index, :import, :upload]
  
  def index
    
  end
  
  
  def serverprocessing
    limit = params["length"]
    start = params["start"]
    
    order_clause = ""
    
    if !params['order'].empty?
      order_clause = "ORDER BY "
      params['order'].each do |i, order_hash|
        #SQLITE starts at 1 and not 0 so we add 1 to the order_hash['column] value
        order_clause += "#{order_hash['column'].to_i + 1} #{order_hash['dir']},"
      end
      order_clause.chomp!(',')
    end
    
    
    where_clause = ""
    if !params['search']['value'].empty?
      val = params['search']['value']
      where_clause = " WHERE firstname like \"#{val}%\" OR lastname like \"#{val}%\" OR phone like \"#{val}%\"  "
    end
    
    #results = Front.find(:all, :select => "firstname,lastname,phone1,phone2,phone3,phone4,address,city,state,zipcode,maildate,ppm,fedex,worker1,worker2", :limit => limit, :offset => start).pluck(:firstname)
    #sql = Front.find(:all, :select => "firstname,lastname,phone1,phone2,phone3,phone4,address,city,state,zipcode,maildate,ppm,fedex,worker1,worker2", :limit => limit, :offset => start).to_sql
    
    sql = "SELECT firstname,lastname,phone from nocalls #{where_clause} #{order_clause} LIMIT #{start},#{limit} "
    results = ActiveRecord::Base.connection.execute(sql)


    count_sql = "SELECT count(firstname) as total from nocalls #{where_clause}"
    count_results = ActiveRecord::Base.connection.execute(count_sql)
    filter_total = count_results.first['total']
    
    total = Front.all.count

    
    response = {}
    response['recordsTotal'] = total
    response['recordsFiltered'] = filter_total
    response['data'] = []
    response['data'] = results
    response['draw'] = params['draw']
    
    render json: response.to_json
  end
  
  
  def add
    Nocall.create({firstname: params['firstname'].capitalize, lastname: params['lastname'].capitalize, phone: params['phone'] })
    render text: "success"
  end
  
  
  
  
  def exportnocalls
    
    if session[:current_user_role] != 'admin'
      render text: "DENIED"
    end
    
    order_clause = ""
    
    if !params['order'].empty?
      order_clause = "ORDER BY "
      params['order'].each do |i, order_hash|
        #SQLITE starts at 1 and not 0 so we add 1 to the order_hash['column] value
        order_clause += "#{order_hash['column'].to_i + 1} #{order_hash['dir']},"
      end
      order_clause.chomp!(',')
    end
    
    
    where_clause = ""
    if !params['search'].empty?
      val = params['search']
     where_clause = " WHERE firstname like \"#{val}%\" OR lastname like \"#{val}%\" OR phone like \"#{val}%\"  "
    end
    
    #results = Front.find(:all, :select => "firstname,lastname,phone1,phone2,phone3,phone4,address,city,state,zipcode,maildate,ppm,fedex,worker1,worker2", :limit => limit, :offset => start).pluck(:firstname)
    #sql = Front.find(:all, :select => "firstname,lastname,phone1,phone2,phone3,phone4,address,city,state,zipcode,maildate,ppm,fedex,worker1,worker2", :limit => limit, :offset => start).to_sql
    
    sql = "SELECT firstname,lastname,phone from nocalls #{where_clause} #{order_clause}"
    results = ActiveRecord::Base.connection.execute(sql)

    t = Time.now
    filename = "Export-NoCalls-#{t.month}-#{t.day}-#{t.year}_#{t.hour}#{t.min}#{t.sec}.xlsx"
    
    #write results into an csv file
    path = Rails.root.to_s + "/private/generated/#{filename}"
    
    workbook = RubyXL::Workbook.new
    worksheet = workbook[0]
    worksheet.add_cell(0,0,"First Name")
    worksheet.add_cell(0,1,"Last Name")
    worksheet.add_cell(0,2,"Phone")
    
    rowcounter = 1
    results.each do |row|
      (0..3).each do |x|
        worksheet.add_cell(rowcounter,x,row[x])
      end
      rowcounter +=1
    end
    
    workbook.write(path)
    
    #send back the filename
    
    render text: File.basename(path)
    
  end
  
  
  def upload
      @db_headers = ['firstname','lastname','phone']
      
      t = Time.now
      @generated_filename = "Import-#{t.month}-#{t.day}-#{t.year}_#{t.hour}#{t.min}#{t.sec}.xlsx"
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
  
  
  
  
  def doimport
    
    filename = params['filename']
    skip_first_row = params['skip']
    mapping = params['mapping']
    
    path = Rails.root.to_s + "/private/uploads/#{filename}"
    workbook = RubyXL::Parser.parse(path)
    worksheet = workbook[0] 
    data = worksheet.extract_data
    if skip_first_row
      data.shift
    end
    
    total = 0
    data.each do |row|
      if row.nil?
        next
      end
      
      sql = "INSERT INTO nocalls ("
      mapping.each do |mindex, map|
        sql += "#{map[1]},"
      end
      
      sql += "created_at, updated_at) VALUES ("
      
      mapping.each do |mindex, map|
        puts map.inspect
        cell_index = map[0].to_i
        # special cases for phone and date
        if map[1].match(/phone/)
          #get phone value
          phone = row[cell_index]
          
          line = row[cell_index]
          if line.nil?
            sql += "\"\","
            next
          end
          
          line.to_s.gsub!(/[^0-9]/, '')
          if line.size == 10
            phone1 = line[0,3]
            phone2 = line[3,3]
            phone3 = line[6,4]
            phone = "#{phone1}-#{phone2}-#{phone3}"
            
          end
          
          sql += "\"#{phone}\","
        else
          if row[cell_index].nil?
            sql += "\"\","
          else
            sql += "\"#{safeSQL(row[cell_index])}\","    
          end
        end
        
        
      end
      sql += "date('now'),date('now'));"
      total += 1
      puts sql
      results = ActiveRecord::Base.connection.execute(sql)
    end
    
    msg = "Imported #{total} Rows"
    render text: msg
  end
  
  def safeSQL(d)
    d.to_s.gsub('"','')
  end
  
end
