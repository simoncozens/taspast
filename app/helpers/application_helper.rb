module ApplicationHelper
  def personlink(name)
    return link_to(name,people_path(NAME_FULL_DISPLAY: name))
  end

  def shiplink(name,dep_arr)
    key = "departures.SHIP"
    if dep_arr == "arr"
      key = "arrivals.SHIP"
    end
    return link_to(name,people_path(key => name))
  end
end
