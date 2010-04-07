Project.configure do |project|
  project.email_notifier.emails = ["scott@butlerpress.com", "al.pendergrass@gmail.com", "ryan@cyclocrazed.com"]
  if RUBY_PLATFORM[/mswin|mingw32/]
    project.build_command = "ruby script\\cruise_build.rb #{project.name}"
  else
    project.build_command = "./script/cruise_build.rb #{project.name}"
  end
end
