require "CSV"
filename = "data/births.csv"
count = %x{wc -l #{filename}}.split.first.to_i

require 'progress_bar'
bar = ProgressBar.new(count)

  CSV.foreach(filename, :headers => true) do |row|
    who = row["NAME_FULL_DISPLAY"]

    person = Person.create({
      NAME_FULL_DISPLAY: who,
      birth_year: row["YEAR"].to_i || ROW["REG_YEAR"].to_i,
      births: row.to_h
      })
    bar.increment!
  end
