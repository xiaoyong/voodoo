require 'benchmark'
require 'json'
require 'mime/types'

set :haml, :format => :html5

get '/' do
  @is_home = true
  @params_json = '{"category":"all","keyword":"","share":"on","student":"on","intprog":"on"}' # Default search settings
  haml :index
end

post '/search' do
  @params_json = params.to_json
  # All post form data are stored in params

  cmd = "/usr/bin/locate -l 5000 -d "
  db_candidates = %w(share student extprog intprog ports)
  databases = db_candidates.select { |db| params[db] }
  cmd += databases.map { |db| "../data/locate/picb_#{db}.db" }.join(":")

  cmd += " -i" unless params["case"]
  cmd += " --regex" if params["regexp"] || params["category"] != "all"

  keyword = params["keyword"].strip
  if !params["regexp"] && keyword !~ /\*/ && keyword =~ /\s/
    if params["category"] == "all" 
      keyword.gsub!(/\s+/, "*")
      keyword = "*" + keyword + "*"
    elsif params["category"] != "all"
      keyword.gsub!(/\s+/, '.*')
    end
  end

  if params["category"] != "all"
    keyword += '.*\.(' + (params["category"] == "application" ? "app|" : "") + MIME::Types[/^#{params["category"]}/, :complete => true].map { |t| t.extensions.join("|") }.join("|") + ')$'
  end

  cmd += " '" + keyword + "'"
  File.open("../data/log/voodoo.log", "a") do |f|
    f.puts Time.now.getlocal("+08:00").strftime("%Y-%m-%d %H:%M:%S %:z") + " " + params.to_json
    puts cmd
  end

  @time_cost = Benchmark.realtime { @results = `#{cmd}`.split(/\n/) }

  # Gather extra information
  # Database last update time
  @db_update = File.mtime("../data/locate/picb_student.db").getlocal("+08:00").strftime("%Y-%m-%d %H:%M:%S %:z")
  # Voodoo search count
  @search_count = ordinalize(`wc -l ../data/log/voodoo.log`.split.first.to_i)

  haml :search
end

get '/test' do
  haml :test
end

# Picked from Module ActiveSupport
# File lib/active_support/inflector.rb, line 295
def ordinalize(number)
  if (11..13).include?(number.to_i % 100)
    "#{number}th"
  else
    case number.to_i % 10
      when 1; "#{number}st"
      when 2; "#{number}nd"
      when 3; "#{number}rd"
      else    "#{number}th"
    end
  end
end
