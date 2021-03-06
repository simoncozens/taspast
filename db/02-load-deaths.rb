require "CSV"
filename = "data/deaths.csv"
count = %x{wc -l #{filename}}.split.first.to_i

require 'progress_bar'
bar = ProgressBar.new(count)

CSV.foreach(filename, :headers => true) do |row|
  who = row["NAME_FULL_DISPLAY"]
  birth_year = 0
  if !row["AGE"].empty?
    y = row["YEAR"] || row["REG_YEAR"]
    if y
      birth_year = y.to_i - row["AGE"].to_i
    end
  end
  p = Person.resolve(who,birth_year, row["YEAR"])
  p.death_year = row["YEAR"].to_i
  p.deaths = row.to_h
  p.save!
  bar.increment!
end
