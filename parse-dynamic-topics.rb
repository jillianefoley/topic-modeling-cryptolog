class TopicDataParser
  attr_reader :data_matrix
  # Set up constants
  NUM_TOPICS = 11
  TIME_SLICES = 11
  DATA_FOLDER = 'dtm'
  VOCAB_FILENAME = 'ocr-text.vocab'
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
    vocab_dictionary = {}
    vocab_index = 0
    File.foreach(VOCAB_FILENAME) do |line|
      vocab_dictionary[vocab_index] = line.strip
      vocab_index += 1
    end

    @data_matrix = {}

    (0..NUM_TOPICS-1).each do |topic_number|
      topic_index = "%03d" % topic_number
      @data_matrix[topic_number] = {}
      current_topic_matrix = @data_matrix[topic_number]
      word_index = 0

      filename = "#{DATA_FOLDER}/lda-seqtopic-#{topic_index}-var-e-log-prob.dat"
      File.foreach(filename) do |line|
        word = vocab_dictionary[word_index] || "word_#{word_index}"
        current_topic_matrix[word] ||= []
        current_topic_matrix[word] << line.strip.to_f
        word_index += 1 if current_topic_matrix[word].count == TIME_SLICES
      end
    end
  end

  def print_overall_top_words
    puts "Overall top words per topic"
    top_words = {}
    (0..NUM_TOPICS-1).each do |topic_number|
      top_words[topic_number] ||= {}
      current_topic = @data_matrix[topic_number]
      top_words[topic_number] = current_topic.keys.sort_by{|x| current_topic[x].max}.reverse[0..8]
      puts "#{TOPIC_LABELS[topic_number]}: " + top_words[topic_number].join(', ')
    end
  end

  def print_top_words_per_time_slice
    [0].each do |topic_number|
      puts "******* TOPIC #{TOPIC_LABELS[topic_number]} *****"
      (0..TIME_SLICES-1).each do |time_slice|
        current_topic = @data_matrix[topic_number]
        slice_top = current_topic.keys.sort_by{|x| Math.exp(current_topic[x][time_slice])}.reverse[16..24]
        puts "Time #{time_slice}: " + slice_top.join(', ')
      end
    end
  end
end

parser = TopicDataParser.new
parser.print_overall_top_words
