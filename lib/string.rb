# Add to_excel to strip out CSV-invalid characters
class String
  def to_excel
    gsub(/[\t\n\r]/, " ")
  end
end