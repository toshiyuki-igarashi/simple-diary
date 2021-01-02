require 'minitest/autorun'
require 'date_of_years_before'

class DateOfYearsBeforeTest < Minitest::Test
  def test_date_of_years_before
    date0 = Date.new(2021, 1, 1)
    date1 = Date.new(2021, 1, 1)
    assert_equal date1, date0
    date1 = Date.new(2020, 1, 3)
    assert_equal date1, date_of_years_before(1, date0)
    date1 = Date.new(2019, 1, 4)
    assert_equal date1, date_of_years_before(2, date0)

    date0 = Date.new(2020, 12, 31)
    date1 = Date.new(2020, 1, 2)
    assert_equal date1, date_of_years_before(1, date0)
    date1 = Date.new(2019, 1, 3)
    assert_equal date1, date_of_years_before(2, date0)

    date1 = Date.new(2019, 1, 4)
    0.upto(10) do |j|
      date0 = Date.new(2010+j, 12, 28)
      0.upto(7) do |i|
        date = date0 + i
        puts "*** #{date.cwyear} #{date.cweek} #{date.cwday}"
      end
      puts
    end
  end
end
