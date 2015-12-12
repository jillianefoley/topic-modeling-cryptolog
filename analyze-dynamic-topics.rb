require 'gruff'

NUM_TOPICS = 11

class TopicProportions
  attr_reader :data_matrix
  attr_reader :time_slice_proportions_by_topic
  attr_reader :document_proportions_by_topic
  attr_reader :num_topics

  DATA_FOLDER = 'dtm'
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
  TIME_SLICES = [26, 22, 11, 16, 18, 12, 8, 6, 6, 6, 5]
  TIME_SLICE_LABELS = {0 => '1974',
    2 => '1978',
    4 => '1982',
    6 => '1986',
    8 => '1992',
    10 => '1996'}
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

  def initialize(num_topics)
    @num_topics = num_topics
    #Parse file with gammas: row-major form of a matrix doc x topics
    @data_matrix = []
    document_index = 0
    File.foreach("#{DATA_FOLDER}/lda-seq/gam.dat") do |line|
      @data_matrix[document_index] ||= []
      @data_matrix[document_index] << line.strip.to_f
      document_index += 1 if @data_matrix[document_index].count == num_topics
    end

    topic_proportions_by_document = {}
    (0..135).each do |document|
      sum = @data_matrix[document][0..num_topics-1].inject(:+)
      topic_proportions_by_document[document] = []
      (0..num_topics-1).each do |topic|
        proportion = @data_matrix[document][topic]/sum
        topic_proportions_by_document[document][topic] = (proportion*100).round(2)
      end
    end

    @document_proportions_by_topic = {}
    (0..num_topics-1).each do |topic|
      @document_proportions_by_topic[topic] = topic_proportions_by_document.collect{|document, proportions| proportions[topic]}
    end

    topic_proportions_by_time_slice = {}
    doc_number = 0
    (0..TIME_SLICES.length-1).each do |time_slice|
      topic_proportions_by_time_slice[time_slice] = {:total => 0}
      (doc_number..doc_number+TIME_SLICES[time_slice]-1).each do |document|
        topic_proportions_by_time_slice[time_slice][:total] += @data_matrix[document][0..num_topics-1].inject(:+)
        (0..num_topics-1).each do |topic|
          topic_proportions_by_time_slice[time_slice][topic] ||= 0
          topic_proportions_by_time_slice[time_slice][topic] += @data_matrix[document][topic]
        end
      end
      topic_proportions_by_time_slice[time_slice]
    end

    @time_slice_proportions_by_topic = {}
    (0..num_topics-1).each do |topic|
      @time_slice_proportions_by_topic[topic] = topic_proportions_by_time_slice.collect{|time_slice, hash| ((hash[topic]/hash[:total])*100).round(2)}
    end

  end

  # Consolidate common graph properties
  def self.default_graph(graph)
    graph.theme = { :colors => GRAPH_COLORS, :marker_color => 'grey', :background_colors => 'transparent'}
    graph.y_axis_label = 'Proportion'
    graph.x_axis_label = 'Year'
    graph.legend_font_size = 12
    graph.legend_box_size = 10
    graph.title_font_size = 20
    graph.left_margin = 0
    graph.labels = TIME_SLICE_LABELS
    graph
  end

  def make_topic_line_graph(topic_number, proportions_array)
    graph = TopicProportions.default_graph(Gruff::Line.new(800))
    graph.title = "Average proportion per time slice for topic #{TOPIC_LABELS[topic_number]}"
    graph.hide_dots = true
    graph.hide_legend = true
    graph.data(topic_number, proportions_array[topic_number])
    graph.write("topic-#{topic_number}-proportion-graph.png")
  end

  def make_area_graph
    graph = TopicProportions.default_graph(Gruff::StackedArea.new(800))
    graph.title = "Average topic composition per time slice"
    graph.maximum_value = 100
    graph.minimum_value = 0
    (0..num_topics-1).each do |topic|
      graph.data(TOPIC_LABELS[topic], @time_slice_proportions_by_topic[topic])
    end

    graph.write("topic-proportion-graph.png")
  end
end

proportions = TopicProportions.new(NUM_TOPICS)
proportions.make_area_graph
(0..NUM_TOPICS-1).each do |topic|
  proportions.make_topic_line_graph(topic, proportions.time_slice_proportions_by_topic)
end
