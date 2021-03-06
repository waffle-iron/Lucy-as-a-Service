
def xkcd221
	4 # chosen by fair dice roll.
	  # guaranteed to be random
end

def iou
	"Not implemented"

	# TODO
	# Store a hash of Lucy's usernames on each Slack instance
	# If user is Lucy, then she can say, e.g.:
	# /laas iou @dave 3.00 GBP <reason>
	#
	# No special command to clear an IOU, just:
	# /lass iou @dave 0.00 GBP
	#
	# Then if @dave runs the command
	# /laas iou
	#
	# then it should secret_message:
	# @lucy owes you 3.00 GBP for <reason>
end

def summon
	summon_item = params['text'].sub(/summon */, "")

	# Special summons
	# TODO: Store in DB?
	case summon_item.strip
	when "ghosts"
		summon_item = "blinky pinky inky clyde"
	when "mexican wave"
		summon_item = "parrotwave1 parrotwave2 parrotwave3 parrotwave4 parrotwave5 parrotwave6 parrotwave7 parrotwave8 parrotwave9"
	end

	# TODO: Use slack emoji API to see if such an emoji exists
	if summon_item != ""
		summon_item.split.map{ |i| ":#{i}:" }.join( " " )
	end
end

# TODO: Store these in a DB (DONE), along with how often they have been quoted
# Slightly favour quotes which are newer?
# Favour quotes which have higher scores (add some sort of liking mechanism later?)
# Manage quotes with LaaS command?
# Enable team-specific (and maybe even channel specific?) quotes. If channel-specific quotes exist, use those. Else team. Else default.


# TODO: if user requests a quote with a username, then 
def quote
	quote_filter = params['text'].sub(/quote */, "").strip
	quote_filter = nil if quote_filter == ""

	abstract_quote "default", quote_filter
end

def red_dwarf_quote
	abstract_quote "red_dwarf"
end

def abstract_quote( list="default", filter=nil )
	quotes = $redis.smembers( "laas:quotes:#{list}" )

	if filter

		logger.debug "Filter:"
		logger.debug filter.inspect

		quotes.select! do |quote|
			logger.debug quote
			if quote.upcase.include? filter.upcase
				logger.debug "Match"
			end
		end

		if quotes.nil? || quotes == "" || quotes.empty?
			return slack_secret_message "No quotes match your filter"
		end
	end

	if quotes.nil? || quotes == "" || quotes.empty?
		return slack_secret_message "No #{list} quotes in DB (yet)"
	else
		slack_message slack_parse( params['team_id'], quotes.sample )
	end

end


def big_text
	emoji = params['text'].split[1].to_s
	word  = params['text'].split[2].to_s

	unless word && emoji
		slack_secret_message "Insufficient parameters. Call with /laas big_text <emoji> <word>"
	end

# TODO: store font in external file(s)
font = {
'A' =>
"XXXXX
X   X
XXXXX
X   X
X   X",
'B' =>
"XXXX 
X   X
XXXX 
X   X
XXXX ",
'C' =>
"XXXXX
X    
X    
X    
XXXXX",
'D' =>
"XXXX 
X   X
X   X
X   X
XXXX ",
'E' =>
"XXXXX
X    
XXXXX
X    
XXXXX",
'F' =>
"XXXXX
X    
XXX  
X    
X    ",
'G' =>
"XXXXX
X    
X  XX
X   X
XXXXX",
'H' =>
"X   X
X   X
XXXXX
X   X
X   X",
'I' =>
"XXXXX
  X  
  X  
  X  
XXXXX",
'J' =>
"XXXXX
  X  
  X  
  X  
XX   ",
'K' =>
"X   X
X  X 
XXX  
X  X 
X   X",
'L' =>
"X    
X    
X    
X    
XXXXX",
'M' =>
"XXXXX
X X X
X X X
X   X
X   X",
'N' =>
"X   X
XX  X
X X X
X  XX
X   X",
'O' =>
"XXXXX
X   X
X   X
X   X
XXXXX",
'P' =>
"XXXXX
X   X
XXXXX
X    
X    ",
'Q' =>
"XXXXX
X   X
X   X
X  X 
XXX X",
'R' =>
"XXXX 
X   X
XXXX 
X  X 
X   X",
'S' =>
"XXXXX
X    
XXXXX
    X
XXXXX",
'T' =>
"XXXXX
  X  
  X  
  X  
  X  ",
'U' =>
"X   X
X   X
X   X
X   X
XXXXX",
'V' =>
"X   X
X   X
 X X 
 X X 
  X  ",
'W' =>
"X   X
X   X
X X X
X X X
XXXXX",
'X' =>
"X   X
 X X 
  X  
 X X 
X   X",
'Y' =>
"X   X
 X X 
  X  
  X  
  X  ",
'Z' =>
"XXXXX
   X 
  X  
 X   
XXXXX"
}

	rows = ["","","","",""]
	message = ""

	word.scan(/\w/).each do |letter|
		# TODO: Discard unsupported letters, or secret_message an error
		row = font[letter.upcase].split("\n")
		(0..4).each do |i|
			rows[i] += " " + row[i]
		end
	end

	rows.each do |row|
		row = row[1..-1]
		if emoji != nil
			row.gsub! "X", ":#{emoji}:"
			row.gsub! " ", ":blank:"
		end
		message += row + "\n"
	end

	slack_message message
end


def clear
	lines = (params['text'].split[1] || 100).to_i

	message = "Clearing #{lines} lines..."

	(1..lines).each do |i|
		message += "\n"
	end

	message += "Better?"

	slack_secret_message message

end

def what_is_laas
	l_words = $redis.smembers( "laas:quotes:laas" )

	if l_words.nil? || l_words == ""
		return "Nobody knows what LaaS means!"
	end

	l_words.sample + " as a Service, at your service :slightly_smiling_face:"
end

def donut
	slack_message "<@#{params['user_name']}|#{params['user_name']}> is buying donuts for everybody! :donut:"
end

def version
	slack_message "#{what_is_laas}\n\nVersion: #{ENV['HEROKU_RELEASE_VERSION']}\n#{ENV['HEROKU_SLUG_DESCRIPTION']}\nhttps://github.com/lucymhdavies/Lucy-as-a-Service/commit/#{ENV['HEROKU_SLUG_COMMIT']}"
end
