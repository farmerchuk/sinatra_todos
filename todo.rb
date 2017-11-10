require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, "secret"
end

before do
  session[:lists] ||= []
end

def error_for_list_name(list_name)
  if session[:lists].any? { |list| list[:name] == list_name }
    "List name must be unique."
  elsif !(1..100).cover?(list_name.size)
    "List name must be between 1 and 100 characters long."
  end
end

get "/" do
  redirect "/lists"
end

# displays a list of todo lists
get "/lists" do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

# form for creating new todo list
get "/lists/new" do
  erb :new_list, layout: :layout
end

# creates new todo list
post "/lists" do
  list_name = params[:list_name].strip
  error = error_for_list_name(list_name)

  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] << { name: list_name, todos: [] }
    session[:success] = "New Todo list successfully added!"
    redirect "/lists"
  end
end

# displays a single todo list
get "/lists/:id" do
  id = params[:id].to_i
  @list = session[:lists][id]
  erb :list, layout: :layout
end

# edit an existing todo list
get "/lists/:id/edit" do
  id = params[:id].to_i
  @list = session[:lists][id]
  erb :edit_list, layout: :layout
end

# updates an existing todo list
post "/lists/:id" do
  id = params[:id].to_i
  @list = session[:lists][id]
  new_list_name = params[:list_name]
  error = error_for_list_name(new_list_name)

  if error
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    @list[:name] = new_list_name
    session[:success] = "Todo list successfully updated!"
    redirect "/lists/#{id}"
  end
end
