module Origin
  module Optional
    def with_fields(fields_def = {})
      fields_def ||= {}
      fields_def.merge!({_id: 1})
      option(fields_def) do |options|
        options.store(:fields,
          fields_def.inject(options[:fields] || {}) do |sub, field_def|
            key, val = field_def
            sub.tap { sub[key] = val }
          end
        )
      end
    end

    def include_text_search_score
      with_fields({score: {"$meta" => "textScore"}})
    end

    def sort_by_text_search_score
      option({}) do |options, query|
        add_sort_option(options, :score, {"$meta" => "textScore"})
      end
    end
  end
end

class Person
  include Mongoid::Document
  paginates_per 50
  field :NAME_FULL_DISPLAY
  field :birth_year
  field :arrivals # Done
  field :bankruptcy
  field :births #done
  field :census
  field :convicts #done
  field :court
  field :deaths #done
  field :departures #done
  field :divorces
  field :health_welfare
  field :hotels_properties
  field :immigration
  field :inquests # done
  field :marriage_permissions
  field :marriages #done
  field :naturalisations
  field :prisoners
  field :wills
  field :ww1 #done

  def self.searchable_fields
    return ["NAME_FULL_DISPLAY", "departures.SHIP"]
  end

  def self.resolve(name,year, critical_year)
    crit = Person.where({NAME_FULL_DISPLAY: name})
    if crit.count == 1
      p = crit.first
      if p.birth_year == 0
        p.birth_year = year
        p.save
      end
      if p.birth_year > critical_year.to_i
        return Person.create({NAME_FULL_DISPLAY: name, birth_year: year})
      end
      return p
    end
    crit = Person.where({NAME_FULL_DISPLAY: name, :birth_year.gte => year-1, :birth_year.lte => year+1})
    if crit.count == 0
      return Person.create({NAME_FULL_DISPLAY: name, birth_year: year})
    end
    if crit.count == 1
      p = crit.first
      if p.birth_year > critical_year.to_i
        return Person.create({NAME_FULL_DISPLAY: name, birth_year: year})
      end
      return crit.first
    end
    if crit.count > 1
      return self.resolve(name,0, critical_year)
    end
  end

  def year_of_birth
    if self.births
      return self.births["PUBDATE"]
    end
    if self.marriages and self.marriages[1]
      marr = self.marriages[1]
      return marr["PUBDATE"].to_i - marr["AGE"].to_i
    end
    if self.deaths
      return self.deaths["PUBDATE"].to_i - self.deaths["AGE"].to_i
    end
    return "?"
  end


  def year_of_death
    if self.deaths
      return self.deaths["PUBDATE"].to_i
    end
    if self.inquests
      return self.inquests["YEAR"].to_i
    end
    return "?"
  end

  def self.search_from_params(params)
    clause = params.slice(*searchable_fields)
    if params["fts"]
      clause[:$text] = { :$search => params["fts"] }

    end
    self.where(clause).include_text_search_score.sort_by_text_search_score.only(
        :NAME_FULL_DISPLAY, :deaths, :marriages, :births
    )
  end

  def name
    self.NAME_FULL_DISPLAY
  end

  def firstname
    self.name.gsub(/.*, /,"")
  end

  gem 'nokogiri'
  require 'open-uri'
  require 'open_uri_redirections'

  def ww1_references
    if self.ww1
      url = self.ww1["REFERENCE_URL"]
      return Hash[url.split("|").map do |pair| k,v=pair.split("=",2);[k,v] end]
    end
    return {}
  end

  def photo
    if self.ww1
      url = self.ww1["REFERENCE_URL"]
      stuff = Hash[url.split("|").map do |pair| k,v=pair.split("=",2);[k,v] end]
      url = stuff["Discovering Anzacs profile"]
      if not url
        return nil
      end
      doc = Nokogiri::HTML(open(url, :allow_redirections => :safe))
      pic = doc.css('.gallery img').first.attr("src")
      if pic
        return URI.join( url, pic )
      end
    end
  end

  def ambiguous
    if birth_year == 0
      return nil
    end
    crit = Person.where({NAME_FULL_DISPLAY: self.name, birth_year: 0})
    if crit.count == 1
      return crit.first
    end
  end
end
