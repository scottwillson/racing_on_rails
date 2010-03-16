Project.configure do |project|
  project.email_notifier.emails = ["scott@butlerpress.com"]
  # project.email_notifier.emails = ["scott@butlerpress.com", "al.pendergrass@gmail.com", "ryan@cyclocrazed.com"]
  project.build_command = File.expand_path("./script/cruise_build.rb #{project.name}")
end
