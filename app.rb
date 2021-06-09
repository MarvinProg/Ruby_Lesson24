require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony'

get '/about' do
  erb :about
end

get '/visit' do
  erb :visit
end

#Error?
post '/visit' do
  @username = params[:username]
  @phone = params[:phone]
  @datetime = params[:datetime]
  @barber = params[:barber]
  @color = params[:color]

 hh = { :username => 'Введите имя', 
        :phone => "Введите телефон", 
        :datetime => 'Введите дату и время',
      }

  @error = hh.select {|key,_| params[key] == ""}.values.join(", ")

  if @error != ''
    return erb :visit
  end

  f = File.open './public/users.txt', 'a'
  f.write "Barber: #{@barber}, client: #{@username}, phone: #{@phone}, date and time: #{@datetime}, color: #{@color}.\n"
  f.close

  erb "OK, username is #{@username}, #{@phone}, #{@datetime}, #{@barber}, #{@color}" 

end




post '/contacts' do
  @client_email = params[:client_email]
  @client_message = params[:client_message]

  cc = {:client_email => "You did't enter your email",
        :client_message => "You did't enter your message"}

  @error = cc.select{|key,_| params[key] == ""}.values.join(", ")

  unless @error == ""
    return erb :contacts
  end

   f = File.open './public/contacts.txt', 'a'
  f.write "client email: #{@client_email}\nmessage:\n#{@client_message}\n"
  f.close

  smtp_info =
    begin
      YAML.load_file("./smtpinfo.yml")
    rescue
      @error = "Error: Could not find SMTP info. Please contact the site administrator."
      return erb :contacts
    end


  
  
end









configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

