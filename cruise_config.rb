Project.configure do |project|
  project.email_notifier.emails = ["scott.willson@gmail.com", "al.pendergrass@gmail.com"]
  if RUBY_PLATFORM[/mswin|mingw32/]
    project.build_command = "ruby script\\cruise_build.rb #{project.name}"
  else
    project.build_command = "./script/cruise_build.rb #{project.name}"
  end
end
