require 'benchmark'

set :haml, :format => :html5

get '/' do
  haml :index
end

post '/search' do
  # All post form data are stored in params

  cmd = "/usr/bin/locate -l 5000 -d "
  db_candidates = %w(student share extprog intprog ports)
  databases = db_candidates.select { |db| params[db] }
  cmd += databases.map { |db| "../data/locate/picb_#{db}.db" }.join(":")

  cmd += " -i" unless params["case"]
  cmd += " --regex" if params["regexp"]

  keyword = params["keyword"].strip
  if !params["regexp"] && keyword !~ /\*/ && keyword =~ /\s/
    keyword.gsub!(/\s+/, "*")
    keyword = "*" + keyword + "*"
  end

  cmd += " '" + keyword + "'"
  File.open("../data/log/voodoo.log", "a") do |f|
    f.puts Time.now.to_s + " " + params.to_s 
    puts cmd
  end

  @time_cost = Benchmark.realtime { @results = `#{cmd}`.split(/\n/) }

  # Gather extra information
  # Database last update time
  @db_update = File.mtime("../data/locate/picb_student.db")
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
