cmd="gem install "
sudo="sudo "
os=""
if (RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/)
else
	cmd=sudo+cmd
end
puts "check ruby-gmeil"
gmail_check=require "gmail"
p gmail_check
	if gmail_check!=true then
		system("#{cmd} ruby-gmail")
	end
puts "check gtk2"
gtk_check=require "gtk2"
p gtk_check
	if gtk_check!=true then
		system("#{cmd} gtk2")
	end
puts cmd