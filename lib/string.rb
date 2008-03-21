class String
  def to_excel
    gsub(/[\t\n\r]/, " ")
  end
end