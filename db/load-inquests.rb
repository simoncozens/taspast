require "CSV"
filename = "data/inquests.csv"
count = %x{wc -l #{filename}}.split.first.to_i

require 'progress_bar'
bar = ProgressBar.new(count)

CSV.foreach(filename, :headers => true) do |row|
  who = row["NAME_FULL_DISPLAY"]
  birth_year = 0
  p = Person.resolve(who,birth_year)
  p.inquests = row.to_h
  p.save!
  bar.increment!
end
