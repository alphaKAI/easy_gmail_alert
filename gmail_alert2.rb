#encoding:utf-8
require "gtk2"
require "gmail"
require_relative "./resource/utils.rb"
require_relative "./resource/rsa_tools.rb"
require_if_exist "libnotify"
=begin
	copyleft (C) alphakai @alpha_kai_NET 2012-2013 http://alpha-kai-net.info
	EasyGmailAlert
	前提gemとしてruby-gmailが必要です
	Gmail通知スクリプト
=end

$debug_ == false
class EasyGmailAlert
	def initialize
		Gtk::init

		wel=Gtk::Label.new("ようこそ！EasyGmailAlertへ！")
		file_exist=true
		unless File.exist?("account.txt")
			file_exist=false
		end

		label_=nil
		button_=nil
		unless file_exist
			label_=Gtk::Label.new("アカウントが設定されていないようです さあ設定しましょう！")
			button_=Gtk::Button.new("設定する→")
				button_.signal_connect("clicked"){
				
				init_account
			}
		else
		  id_pass=File.read("account.txt").split("\n")
		  id=id_pass[0]
		  pass=id_pass[1]

		  label_=Gtk::Label.new("アカウントの設定がお済みのようですね！\n下の起動するを押してください！")
		  button_=Gtk::Button.new("起動する→")
			button_.signal_connect("clicked"){
			  if login_gui(id,pass)
				@id=id
				@pass=pass
				#call event loop
			  else
				#puts warnning
			  end
			}
		end

		vbox=Gtk::VBox.new

		vbox.pack_start(wel)
		unless file_exist
			vbox.pack_start(label_)
			vbox.pack_start(button_)
		end

		window=Gtk::Window.new
		window.title="EasyGmailAlert"
		window.set_default_size(400,300)
		
		window.add(vbox)
		window.show_all

		window.signal_connect("destroy"){
			Gtk::main_quit
		}
		Gtk::main
	end

	def load_setting
	
	end
	#ログイン処理(ダイアログ)
	def login_gui(id,pass)
		@gmail=Gmail.new(id,pass)
		dialog_=Gtk::Dialog.new
		label_=nil
		error_status=true
		begin
			@gmail.login

			label_="ログインに成功しました！"
			#set
			@id=id
			@pass=pass
			@gmail.peek=true#読み込んだのを未読にしない
		rescue => error
			label_="ログインに失敗しました！\nパスワードやIDが間違っているかもしれません　再試行してみて下さい！"
			puts e if $debug_
			error_status=false
		end
		
		dialog_.vbox.pack_start(Gtk::Label.new(label_),true,true,30)
		dialog_.show_all
		return error_status
	end
	
	#初期設定 - アカウント設定
	def init_account
		id = Gtk::Entry.new
		pass = Gtk::Entry.new
		id.set_visibility(true)
		pass.set_visibility(false)#hide

		label_wel=Gtk::Label.new("さあ、設定しましょう Nextを押して下さい\n\n")
		label_id=Gtk::Label.new("ID(完全なGmailアドレス)")
		label_pass=Gtk::Label.new("パスワード(伏字になります)")
		button = Gtk::Button.new("Enter")

		vbox=Gtk::VBox.new
		vbox.pack_start(label_wel)
		vbox.pack_start(label_id)
		vbox.pack_start(id)
		vbox.pack_start(label_pass)
		vbox.pack_start(pass)
		vbox.pack_start(button)

		window=Gtk::Window.new
		window.title="EasyGmailAlert"
		window.set_default_size(260,60)
		window.signal_connect("destroy"){
			Gtk::main_quit
		}

		window.add(vbox)
		window.show_all
	
		button.signal_connect("clicked"){
			res=login_gui(id.text,pass.text)
			unless res
				pass.text=""
			else
		 		#idとpassの暗号化処理
				rt=RsaTools.new
				id=rt.encode(id)
				pass=rt.encode(pass)
				File.write("account.txt",id.to_s+"\n"+pass.to_s)
			end
		}
	end
	
	#Main Program
	def check_loop
		
	end

	#Check Mail Box
	def checkmail
		@gmail.inbox.emails(:unread).map{|mail| #Others :all,:read,:unread
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
			@subject=mail.subject
			@date=mail.date
			@from=mail.from
			@to=mail.to
			@cut_body=cut_body
			show_alert()
		}
	end
	
	def show_alert
		if require_if_exists "libnotify"
			show_alert_libnotify
		else
			show_alert_gtk
		end
	end
	
	#通知を表示する for GTK
	def show_alert_gtk
		Gtk::init
		label_subject=Gtk::Label.new(@subject)
		label_date=Gtk::Label.new(@date)
		label_from=Gtk::Label.new(@from)
		label_to=Gtk::Label.new(@to)
		label_cut_body=Gtk::Label.new(@cut_body)

		vbox=Gtk::VBox.new
		vbox.pack_start(label_subject)
		vbox.pack_start(label_date)
		vbox.pack_start(label_from)
		vbox.packs_tart(label_to)
		vbox.pack_start(label_cut_body)
		window=Gtk::Window.new
		window.set_title="You got a mail. #{@subject}"
		window.signal_connect("destroy"){
			Gtk::main_quit
		}
		window.add(vbox)
		window.show_all
		Gtk::main
	end
	
	#通知を表示する for libnotify
	def show_alert_libnotify
		Libnotify.new{|notify|
			notify.summary="You got a mail. #{@subject}"
			notify.body="件名:#{@subject}
			送り主#{@from}
			日時:#{@date}
			送り先:#{@to}
			本文(100文字で読み込みを省略しています):
			#{@cut_body}"
			notify.timeout=5.0
			notify.show!
		}
	end
end
ega=EasyGmailAlert.new
ega.check_loop()