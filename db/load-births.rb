require "CSV"
  CSV.foreach("data/births.csv", :headers => true) do |row|
    who = row["NAME_FULL_DISPLAY"]

    person = Person.create({
      NAME_FULL_DISPLAY: who,
      birth_year: row["YEAR"].to_i || ROW["REG_YEAR"].to_i,
      births: row.to_h
      })
  end
