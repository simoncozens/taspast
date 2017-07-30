require "CSV"

filename = "data/arrivals.csv"
count = %x{wc -l #{filename}}.split.first.to_i

require 'progress_bar'
bar = ProgressBar.new(count)

CSV.foreach(filename, :headers => true) do |row|
  who = row["NAME_FULL_DISPLAY"]
  p = Person.resolve(who,0,row["YEAR"])
  if not p.arrivals
    p.departures = []
  end
  p.departures << row.to_h
  p.save!
  bar.increment!
end
