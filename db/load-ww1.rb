require "CSV"

filename = "data/ww1.csv"
count = %x{wc -l #{filename}}.split.first.to_i

require 'progress_bar'
bar = ProgressBar.new(count)

CSV.foreach(filename, :headers => true) do |row|
  who = row["NAME_FULL_DISPLAY"]
  p = Person.resolve(who,0,row["YEAR"])
  if not p.ww1
    p.ww1 = []
  end
  p.ww1 << row.to_h
  p.save!
  bar.increment!
end
