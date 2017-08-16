##
# This class provides a standard way of accessing configuration params
# 
# Have it separately, just in case in future I might want to read these from a different location, like a DB. This will ensure compatibility issues.
# 
class Config
	require File.dirname(__FILE__)+"/../../conf/main"
	def initialize()
		@k = $cfg
	end

	##
	# return a value of a +$cfg+ parameter by it's name. +$cfg+ is a global config Hash. The +$cfg+ is then assigned to a public global variable +@k+ that is accessible from every test
	# 
	public
	def get(name)
		# puts "#{@k[name]}"
		return @k[name]
	end

	##
	# set the value of a +$cfg+ parameter by it's name. +$cfg+ is a global config Hash. The +$cfg+ is then assigned to a public global variable +@k+ that is accessible from every test
	# 
	public
	def set(name, val)
		# puts "#{@k[name]}"
		@k[name] = val
	end
end