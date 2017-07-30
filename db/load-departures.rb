require "CSV"

filename = "data/departures.csv"
count = %x{wc -l #{filename}}.split.first.to_i

require 'progress_bar'
bar = ProgressBar.new(count)

CSV.foreach(filename, :headers => true) do |row|
  who = row["NAME_FULL_DISPLAY"]
  p = Person.resolve(who,0)
  if not p.departures
    p.departures = []
  end
  p.departures << row.to_h
  p.save!
  bar.increment!
end
