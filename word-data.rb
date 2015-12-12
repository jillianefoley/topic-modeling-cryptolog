require 'gruff'
require 'active_support/inflector'

class TopicModel
	attr_reader :data_matrix

	# Set up constants
	NUM_TOPICS = 11
	DATA_FOLDER_NAME = 'dtm'
	VOCAB_FILENAME = 'ocr-text.vocab'
	GRAPH_COLORS = %w(
		#FFB300,
	  #803E75,
	  #FF6800,
	  #A6BDD7,
	  #C10020,
	  #CEA262,
	  #817066,
	  #007D34,
	  #F6768E,
	  #00538A,
	  #53377A,
	  #B32851,
	  #F4C800,
	  #7F180D,
	  #93AA00,
	  #593315,
	  #F13A13,
	  #232C16)
	TIME_SLICE_LABELS = {0 => '1974',
		2 => '1978',
		4 => '1982',
		6 => '1986',
		8 => '1992',
		10 => '1996'}
	TOPIC_LABELS = { 0 => 'PROGRAMMING',
		1 => 'DISPLAYS',
		2 => 'SECURITY',
		3 => 'COMMUNICATIONS',
		4 => 'HR',
		5 => 'NATIONAL SECURITY',
		6 => 'MATH',
		7 => 'TRAFFIC ANALYSIS',
		8 => 'CRYPTOLOG',
		9 => 'ENCRYPTION',
		10 =>'COMINT'}

	def initialize
		# Create the vocabulary index
		vocab_dictionary = {}
		vocab_index = 0
		File.foreach(VOCAB_FILENAME) do |line|
		  vocab_dictionary[vocab_index] = line.strip
		  vocab_index += 1
		end

		# Create the matrix of likelihood of each word in each topic in each time slice
		@data_matrix = {}
		(0..NUM_TOPICS-1).each do |topic_number|
		  topic_index = "%03d" % topic_number
		  @data_matrix[topic_number] = {}
		  current_topic_matrix = @data_matrix[topic_number]
		  word_index = 0

		  filename = "#{DATA_FOLDER_NAME}/lda-seqtopic-#{topic_index}-var-e-log-prob.dat"
		  File.foreach(filename) do |line|
		    word = vocab_dictionary[word_index] || "word_#{word_index}"
		    current_topic_matrix[word] ||= []
		    current_topic_matrix[word] << line.strip.to_f
		    word_index += 1 if current_topic_matrix[word].count == 11
		  end
		end
	end

	# Consolidate common graph properties
	def self.default_graph
		g = Gruff::Line.new(800)
		g.hide_dots = true
		g.theme = { :colors => GRAPH_COLORS, :marker_color => 'grey', :background_colors => 'transparent'}
		g.y_axis_label = 'Likelihood'
		g.x_axis_label = 'Year'
		g.legend_font_size = 15
		g.legend_box_size = 15
		g.title_font_size = 20
		g.left_margin = 0
		g.labels = TIME_SLICE_LABELS
		g
	end

	# Graph a single word across time slices and topics
	def make_word_graph(target_word)
		graph = TopicModel.default_graph
		graph.title = "Likelihood of term '#{target_word}' over time slices"
		graph.legend_font_size = 12
		graph.legend_box_size = 10
		topic = 0
		(0..NUM_TOPICS-1).each do |topic_number|
			return unless @data_matrix[topic_number][target_word]
			word_data = @data_matrix[topic_number][target_word].map{|x| Math.exp(x)}
			plural = target_word.pluralize
			if @data_matrix[topic_number][plural]
				plural_word_data = @data_matrix[topic_number][plural].map{|x| Math.exp(x)}
				word_data = [word_data, plural_word_data].transpose.map {|prob_pair| prob_pair.inject(:+) }
			end

			graph.data(TOPIC_LABELS[topic_number], word_data.map{|data| data.round(4)})
		end

		graph.write("#{target_word}_likelihood.png")
	end

	# Graph a collection of words within a single topic across time
	def make_comparison_graph(title, target_words, topic_number)
		graph = TopicModel.default_graph
		graph.title = "Selected terms in topic #{TOPIC_LABELS[topic_number]} over time slices"
		topic = 0
		target_words.each do |word|
			next unless @data_matrix[topic_number][word]
			word_data = @data_matrix[topic_number][word].map{|x| Math.exp(x)}
			plural = word.pluralize
			if @data_matrix[topic_number][plural]
				plural_word_data = @data_matrix[topic_number][plural].map{|x| Math.exp(x)}
				word_data = [word_data, plural_word_data].transpose.map {|prob_pair| prob_pair.inject(:+) }
			end

			graph.data(word, word_data.map{|data| data.round(4)})
		end

		graph.write("#{title}_#{TOPIC_LABELS[topic_number]}_likelihood.png")
	end

	# Print the likelihoods for a specific word across each topic, averaged over time
	def print_likelihoods(word)
		plural = word.pluralize
		(0..NUM_TOPICS-1).each do |topic_number|
			word_data = @data_matrix[topic_number][word].map{|x| Math.exp(x)}
			if @data_matrix[topic_number][plural]
				plural_word_data = @data_matrix[topic_number][plural].map{|x| Math.exp(x)}
				word_data = [word_data, plural_word_data].transpose.map {|prob_pair| prob_pair.inject(:+) }
			end
			puts "Average likelihood for '#{word}' in topic #{topic_number}: " + (word_data.inject(:+).to_f.round(4)/word_data.size.to_f).to_s
		end
	end
end

model = TopicModel.new

model.make_word_graph('computer')
model.make_word_graph('security')

model.make_comparison_graph('programming', ['computer', 'software', 'command', 'screen', 'terminal', 'file'], 0)
model.make_comparison_graph('interfaces', ['computer', 'graphic', 'display', 'menu', 'processor', 'color', 'device'], 1)
model.make_comparison_graph('personal_computing', ['expert', 'user', 'personal'], 0)
model.make_comparison_graph('professionalization', ['career', 'promotion', 'personnel', 'training', 'program', 'development'], 4)
model.make_comparison_graph('secrecy', ['classified', 'security', 'secure', 'classification'], 2)

