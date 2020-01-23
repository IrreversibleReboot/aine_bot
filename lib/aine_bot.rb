require 'twitter'
require 'logger'
require 'pathname'
require 'terminal-table'

class AineBot

	def initialize(media_path, consumer_key, consumer_secret, access_token, access_token_secret)
		
		@client = Twitter::REST::Client.new do |config|
			config.consumer_key			= consumer_key
			config.consumer_secret		= consumer_secret
			config.access_token 		= access_token
			config.access_token_secret 	= access_token_secret
		end

		@media_formats = ['.jpg', '.mp4', '.gif', '.png']

		@media_path = media_path

		@folder_list = Pathname.new(@media_path).children.sort.select { |c| c.directory? }

		@logger = Logger.new('bot.log')

	end


	def get_post_message(folder_name)

		case folder_name.match(/([a-z]+)/)[0]

		when "episode"

			episode_number 	= folder_name.match(/[0-9][0-9]/)[0].to_i
			post_message 	= "#{episode_number}話のあいねちゃん"

		when "opening"
			opening_number 	= folder_name.match(/[0-9]/)[0].to_i
			
			case opening_number
			when 1
				post_message = "OP曲ありがと⇄大丈夫のあいねちゃん"
			
			when 2
				post_message = "OP曲そこにしかないもののあいねちゃん"
			
			when 3
				post_message = "OP曲ひとりじゃない!のあいねちゃん"
			end


		when "ending"

			ending_number = folder_name.match(/[0-9]/)[0].to_i

			case ending_number
			when 1
				post_message = "ED曲Believe itのあいねちゃん"
			
			when 2
				post_message = "ED曲プライドのあいねちゃん"
			
			when 3
				post_message = "ED曲Be starのあいねちゃん"
			end
		

		when "dcd"

			dcd_type = folder_name.match(/(?<=\_)([a-z]+)/)[0]

			case dcd_type
			when 'friends'
				post_message = "データカードダス アイカツフレンズ！のあいねちゃん"
			
			when 'onpa'
				post_message = "データカードダス アイカツオンパレード！のあいねちゃん"
			end			
		end

		return post_message

	end

	def post

		folder = @folder_list.sample(1)[0]
		media_list = Pathname.new(folder).children.select { |file| @media_formats.include?(File.extname(file)) }
		media = media_list.sample(1)[0]

		unless media.nil?
			post_message = get_post_message(folder.basename.to_s)
			@client.update_with_media(post_message, media.open)
			@logger.info "Posted media #{media.basename} from #{folder.basename}"	
		else
			@logger.info "Folder #{folder.basename} was empty!"	
		end
	end

	def get_stats

		table_rows 	= []
		total_files = 0

		@folder_list.each do |folder|
			files = folder.children.select { |file| file.basename.to_s.chr() != "." }
			table_rows << [folder.basename, files.count]
			total_files += files.count
		end

		table = Terminal::Table.new do |t|
			t.title 	= 'Aine Bot Stats'
			t.headings 	= ['Category', 'File count']
			t.rows 		= table_rows
			t 			<< :separator
			t 			<< ['Total', "#{total_files} media files"]
		end

		return table

	end

	def media_path
		@media_path
	end

	def media_path=(media_path)
	  @media_path = media_path
	end

end