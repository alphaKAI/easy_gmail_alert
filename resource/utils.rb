#encoding:utf-8
def require_if_exist(file)
	begin
		require file
		return true
	rescue LoadError
		return false
	end
end