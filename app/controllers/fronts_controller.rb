
class FrontsController < ApplicationController
  before_filter :authorize#, :only => [:index, :newfront, :createfront, :import, :upload, :edit]
  
  def index
    #@fronts = Front.order(created_at: :desc).all
    
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
      where_clause = " WHERE firstname like \"#{val}%\" OR lastname like \"#{val}%\" OR phone1 like \"#{val}%\" OR email like \"#{val}%\" OR worker1 like \"#{val}%\" OR worker2 like \"#{val}%\" "
    end
    
    #results = Front.find(:all, :select => "firstname,lastname,phone1,phone2,phone3,phone4,address,city,state,zipcode,maildate,ppm,fedex,worker1,worker2", :limit => limit, :offset => start).pluck(:firstname)
    #sql = Front.find(:all, :select => "firstname,lastname,phone1,phone2,phone3,phone4,address,city,state,zipcode,maildate,ppm,fedex,worker1,worker2", :limit => limit, :offset => start).to_sql
    
    sql = "SELECT '<a href=\"/fronts/edit?id=' || id || '\"><i class=\"fa fa-pencil\" style=\"margin-left:10px\"></i></a>' as edit,firstname,lastname,strftime('%m/%d/%Y',maildate) as maildate,phone1,phone2,phone3,phone4,email,
    address,city,state,zipcode,ppm,fedex,worker1,worker2 from fronts #{where_clause} #{order_clause} LIMIT #{start},#{limit} "
    results = ActiveRecord::Base.connection.execute(sql)


    count_sql = "SELECT count(firstname) as total from fronts #{where_clause}"
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
  
  
  def newfront
    
  end
  
  def checkperson
    firstname = params['firstname']
    lastname = params['lastname']
    phone1 = params['phone1']
    output = {}
    sql = "SELECT firstname, lastname, phone1,phone2,phone3,phone4,email,address,city,state,zipcode,ppm,fedex,strftime('%m/%d/%Y',maildate) as maildate,worker1,worker2 from fronts where firstname = \"#{firstname}\" COLLATE NOCASE OR lastname = \"#{lastname}\" COLLATE NOCASE or ( phone1 = \"#{phone1}\" AND phone1 != '--' AND phone1 != '') LIMIT 50"
    fronts_results = ActiveRecord::Base.connection.execute(sql)
    
    sql = "SELECT firstname, lastname, phone from nocalls where (firstname  = \"#{firstname}\" COLLATE NOCASE AND lastname = \"#{lastname}\" COLLATE NOCASE) or ( phone = \"#{phone1}\" AND phone != '--' AND phone != '') LIMIT 50 "
    nocall_results = ActiveRecord::Base.connection.execute(sql)
    
    output['fronts_result'] = fronts_results
    output['nocall_result'] = nocall_results
    
    render json: output.to_json
  end
  
  def createfront
    @firstname = params['firstname']
    @lastname = params['lastname']
    @phone_parts = params['phone1'].split("-")
    @workers = Worker.order(:name).all
  end
  
  def add
    Front.create({firstname: params['firstname'].capitalize,
                    lastname: params['lastname'].capitalize,
                    phone1: params['phone1'],
                    phone2: params['phone2'],
                    phone3: params['phone3'],
                    phone4: params['phone4'],
                    email: params['email'],
                    address: params['address'],
                    city: params['city'],
                    state: params['state'],
                    zipcode: params['zipcode'],
                    maildate: Time.now,
                    ppm: params['ppm'],
                    fedex: params['fedex'],
                    worker1: params['worker1'],
                    worker2: params['worker2'],
                  })
    render text: "success"
  end
  
  def edit
    @front = Front.find(params['id'])
    @phone1_parts = @front.phone1.split("-")
    @phone2_parts = @front.phone2.split("-")
    @phone3_parts = @front.phone3.split("-")
    @phone4_parts = @front.phone4.split("-")
    
    if @phone1_parts.size != 3
      @phone1_parts = ["","",""]
    end
    
    if @phone2_parts.size != 3
      @phone2_parts = ["","",""]
    end
    
    if @phone3_parts.size != 3
      @phone3_parts = ["","",""]
    end
    
    if @phone4_parts.size != 3
      @phone4_parts = ["","",""]
    end
    @workers = Worker.order(:name).all
    
  end
  
  def update
    @front = Front.find(params['id'])
    if !@front.nil?
      @front.firstname = params['firstname']
      @front.lastname = params['lastname']
      @front.phone1 = params['phone1']
      @front.phone2 = params['phone2']
      @front.phone3 = params['phone3']
      @front.phone4 = params['phone4']
      @front.email  = params['email']
      @front.address = params['address']
      
      @front.city = params['city']
      @front.state = params['state']
      @front.zipcode = params['zipcode']
      @front.ppm = params['ppm']
      @front.fedex = params['fedex']
      @front.worker1 = params['worker1']
      @front.worker2 = params['worker2']
      @front.save
    end
    render text: "success"
  end
  
  
  def exportfronts
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
      where_clause = " WHERE firstname like \"#{val}%\" OR lastname like \"#{val}%\" OR phone1 like \"#{val}%\" OR worker1 like \"#{val}%\" OR worker2 like \"#{val}%\" "
    end
    
    #results = Front.find(:all, :select => "firstname,lastname,phone1,phone2,phone3,phone4,address,city,state,zipcode,maildate,ppm,fedex,worker1,worker2", :limit => limit, :offset => start).pluck(:firstname)
    #sql = Front.find(:all, :select => "firstname,lastname,phone1,phone2,phone3,phone4,address,city,state,zipcode,maildate,ppm,fedex,worker1,worker2", :limit => limit, :offset => start).to_sql
    
    sql = "SELECT firstname,lastname,strftime('%m/%d/%Y',maildate) as maildate,phone1,phone2,phone3,phone4,email,address,city,state,zipcode,ppm,fedex,worker1,worker2 from fronts #{where_clause} #{order_clause} "
    results = ActiveRecord::Base.connection.execute(sql)

    t = Time.now
    filename = "Export-#{t.month}-#{t.day}-#{t.year}_#{t.hour}#{t.min}#{t.sec}.xlsx"
    
    #write results into an csv file
    path = Rails.root.to_s + "/private/generated/#{filename}"
    
  workbook = RubyXL::Workbook.new
  worksheet = workbook[0]
  worksheet.add_cell(0,0,"First Name")
  worksheet.add_cell(0,1,"Last Name")
  worksheet.add_cell(0,2,"Date")
  worksheet.add_cell(0,3,"Phone1")
  worksheet.add_cell(0,4,"Phone2")
  worksheet.add_cell(0,5,"Phone3")
  worksheet.add_cell(0,6,"Phone4")
  worksheet.add_cell(0,7,"Email")
  
  worksheet.add_cell(0,8,"Address")
  worksheet.add_cell(0,9,"City")
  worksheet.add_cell(0,10,"State")
  worksheet.add_cell(0,11,"Zipcode")
  worksheet.add_cell(0,12,"PPM")
  worksheet.add_cell(0,13,"Fedex")
  worksheet.add_cell(0,14,"Worker1")
  worksheet.add_cell(0,15,"Worker2")
  
  rowcounter = 1
  results.each do |row|
    (0..15).each do |x|
      worksheet.add_cell(rowcounter,x,row[x])
    end
    rowcounter +=1
  end
  
  
  workbook.write(path)
    
    #send back the filename
    
    render text: File.basename(path)
    
  end
  
  def import
    
  end
    
  
  def upload
      @db_headers = ['firstname','lastname','phone1','phone2','phone3','phone4','email','address','city','state','zipcode','maildate','ppm','fedex','worker1','worker2']
      
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
      
      sql = "INSERT INTO fronts ("
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
        elsif map[1].match(/date/)
          datestring = nil
          line = row[cell_index].to_s
          line.match(/(\d+)\/(\d+)\/(\d+)/) { |m|
            datestring = "\"#{m[3]}-#{m[1]}-#{m[2]}\""
          }
          
          line.match(/(\d+)-(\d+)-(\d+)/) { |m|
            datestring = "\"#{m[0]}\""
          }

          if datestring.nil?
            datestring = "NULL"
          end
          sql += "#{datestring},"
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
