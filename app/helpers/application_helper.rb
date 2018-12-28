# frozen_string_literal: true

module ApplicationHelper
  TAB_SIZE = 4
  def count_leading_blank(str)
    count = 0
    (0..str.length - 1).each do |i|
      case str[i]
      when ' ' then
        count += 1
      when '　' then
        count += 2
      when "\t"
        count = ((count + TAB_SIZE) / TAB_SIZE) * TAB_SIZE
      else
        return count
      end
    end
    count
  end
end
