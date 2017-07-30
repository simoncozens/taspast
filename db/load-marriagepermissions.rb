require "CSV"

filename = "data/marriage-permissions.csv"
count = %x{wc -l #{filename}}.split.first.to_i

require 'progress_bar'
bar = ProgressBar.new(count)

CSV.foreach(filename, :headers => true) do |row|
  who = row["NAME_FULL_DISPLAY"]
  p = Person.resolve(who,0,row["YEAR"])
  if not p.marriage_permissions
    p.marriage_permissions = []
  end
  p.marriage_permissions << row.to_h
  p.save!
  bar.increment!
end
