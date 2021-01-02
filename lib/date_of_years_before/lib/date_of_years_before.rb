# frozen_string_literal: true

require 'date'

def date_of_years_before(years, date)
  cwyear = date.cwyear - years
  cweek = date.cweek
  cwday = date.cwday
  last_date = Date.new(cwyear, 12, 28)
  return Date.commercial(cwyear + 1, 1, cwday) if last_date.cweek < cweek

  Date.commercial(cwyear, cweek, cwday)
end
