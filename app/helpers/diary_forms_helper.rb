module DiaryFormsHelper
  def text_size(size)
    if size.to_i == DiaryForm::SIZE_OF_AREA
      nil
    else
      size
    end
  end

  def text_size_to_s(size)
    if size.to_i == DiaryForm::SIZE_OF_AREA
     '制限無し'
    else
      size
    end
  end
end
