#encoding: utf-8
#  EasyGmailAlert
#  Ver 0.0.2α
#  Language:Ruby
#  作者:α改 @alpha_kai_NET
#  LICENSE:GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
#  Copyright (C) α改 @alpha_kai_NET 2012-2013 http://alpha-kai-net.info
#  ローカルのパスワードのファイルの暗号化めんどくさい・・・ Ω＼ζ°)ﾁｰﾝ
#  必ずgem installでruby-gmailとgtk2をインストールすること!
# 　五分おきに更新する仕様
require "gmail"
require "gtk2"
require "io/console"

def alert(subject,date,from,to,cut_body,counts)

	subject_str=Gtk::Label.new("subject:#{subject}")
		subject_str.set_justify(Gtk::JUSTIFY_LEFT)#LEFT
	date_str=Gtk::Label.new("date:#{date}")
		date_str.set_justify(Gtk::JUSTIFY_LEFT)#LEFT
	from_str=Gtk::Label.new("from:#{from}")
		from_str.set_justify(Gtk::JUSTIFY_LEFT)#LEFT
	to_str=Gtk::Label.new("to:#{to}")
		to_str.set_justify(Gtk::JUSTIFY_LEFT)#LEFT
	cut_body_str=Gtk::Label.new("#{cut_body}")
		cut_body_str.set_justify(Gtk::JUSTIFY_LEFT)#LEFT
	
	closebtn=Gtk::Button.new("Close?")
	closebtn.signal_connect("clicked"){
		Gtk.main_quit
	}
	
	window=Gtk::Window.new
	window.signal_connect("destroy"){
		Gtk.main_quit
	}
	
	window.title="#{counts} subject#{subject} from:#{from} date:#{date}"
	window.set_default_size(260,40)

	vbox = Gtk::VBox.new

	#表示させ
	vbox.pack_start(subject_str)
	vbox.pack_start(from_str)
	vbox.pack_start(date_str)
	vbox.pack_start(to_str)
	vbox.pack_start(cut_body_str)
	vbox.pack_start(closebtn)
	
	window.add(vbox)
	window.show_all

	Gtk.main
end

#File check
if File.exist?("account.txt")==false
	puts "初期設定========="
	puts "アカウントの設定をします"
	puts "GmailのID(完全なGmailのメールアドレス)を入力してください e.g. hogehoge@gmail.com"
	id=STDIN.gets.delete("\n")
	puts "#{id}のパスワードを入力して下さい"
	pass=STDIN.noecho(&:gets).delete("\n")
	
	File.open("account.txt","w"){|file|
		file.write(id+"\n")
		file.write(pass)
	}
end

account_info=File.read("account.txt").split("\n")

USERNAME=account_info[0]
PASSWORD=account_info[1]
DEBUG=false

loop do

gmail = Gmail.new(USERNAME,PASSWORD)
gmail.peek = true#読み込んだのを未読にしない
count=1

mails =  gmail.inbox.emails(:unread).map do |mail| #Others :all,:read,:unread
		
	body="body: " + mail.body.decoded.encode("UTF-8", mail.charset)
	
	i=1#初期化　カット用の文字列用
	cut_body=""#初期化
	body.to_s.split("").each{|str|
		if i <= 100
			cut_body+=str
		else
			break
		end
		i+=1
	}
	puts cut_body if DEBUG
	cut_body += "...(100文字で読み込みを省略しています)"
	
	th=Thread.new do
		alert(mail.subject,mail.date,mail.from,mail.to,cut_body,count)#Call func
	end

	th.join
	
	count+=1#件数
end

gmail.disconnect

sleep(300)#五分おきに更新
end