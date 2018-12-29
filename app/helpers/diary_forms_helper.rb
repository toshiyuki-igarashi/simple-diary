module DiaryFormsHelper
  def text_size(size)
    if size.to_i == DiaryForm::SIZE_OF_AREA
      '制限無し'
    else
      size
    end
  end
end
