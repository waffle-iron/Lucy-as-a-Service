def admin
	case params['text'].chomp
	when "admin db"
		slack_secret_message redis_link
	else
		slack_secret_message "I don't know what to do with: #{params['text'].chomp}"
	end
end

def redis_link
	r = $redis.get( "laas:config:redsmin" )

	if r.nil? || r == ""
		return "Sorry. Don't know the DB URL :disappointed:"
	end

	r

end

def say_message
	unless user_is_admin?( params['team_id'], params['user_id'] )
		return slack_secret_message "These commands are for admins only!"
	end

	task = Thread.new {
		message_text = params['text'].sub(/say */, "")
		post_data = slack_message message_text
		RestClient.post(params['response_url'], post_data )
	}

	slack_secret_message " "
end
