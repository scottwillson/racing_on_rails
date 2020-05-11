# frozen_string_literal: true

module Assertions
  extend ActiveSupport::Concern

  def self.download_directory
    Rails.root.join("tmp/capybara/downloads")
  end

  def assert_login_page
    assert_current_path "/person_session/new"
  end

  def assert_page_has_content(text)
    raise "Expected '#{text}' in page source" unless page.has_content?(text)
  end

  def assert_page_has_no_content(text)
    raise "Did not expect '#{text}' in html" unless page.has_no_content?(text)
  end

  def assert_table(table_id, row, column, expected)
    assert page.has_table?(table_id), "Expected table with id '#{table_id}'"
    within find(:xpath, "//table[@id='#{table_id}']//tr[#{row}]/td[#{column}]") do
      assert page.has_content?(expected), -> {
        "Expected '#{expected}' in row #{row} column #{column} of table #{table_id} in table ID #{table_id}, but was #{text}"
      }
    end
  end

  def assert_download(link_id, filename)
    raise ArgumentError if filename.blank? || (filename.respond_to?(:empty?) && filename.empty?)

    make_download_directory
    remove_download filename

    download link_id, filename
  end

  def download(link_id, filename)
    puts "download(#{link_id}, #{filename})"
    click_on link_id
    begin
      Timeout.timeout(10) do
        sleep 0.25 while Dir.glob("#{Assertions.download_directory}/#{filename}").empty?
      end
    rescue Timeout::Error
      puts "Timeout::Error"
      files = Dir.entries(Assertions.download_directory).join(", ")
      raise(
        Timeout::Error,
        "Did not find '#{filename}' in #{Assertions.download_directory} within seconds 10 seconds. Found: #{files}"
      )
    end
  end

  def make_download_directory
    puts "make_download_directory exists? #{Dir.exist?(Assertions.download_directory)}"
    FileUtils.mkdir_p Assertions.download_directory unless Dir.exist?(Assertions.download_directory)
  end

  def remove_download(filename)
    puts "FileUtils.rm_f #{Assertions.download_directory}/#{filename}"
    FileUtils.rm_f "#{Assertions.download_directory}/#{filename}"
  end
end
