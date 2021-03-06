class AbstractFormBuilder
  attr_accessor :template, :object

  def initialize(template, object)
    @template = template
    @object   = build_object(object)
    raise "FormBuilder template must be initialized!" unless template
    raise "FormBuilder object must be not be nil value. If there's no object, use a symbol instead! (i.e :user)" unless object
  end

  # f.error_messages
  def error_messages(options={})
    @template.error_messages_for(@object, options)
  end

  # f.label :username, :caption => "Nickname"
  def label(field, options={})
    options.reverse_merge!(:caption => "#{field.to_s.titleize}: ")
    @template.label_tag(field_id(field), options)
  end

  # f.hidden_field :session_id, :value => "45"
  def hidden_field(field, options={})
    options.reverse_merge!(:value => field_value(field), :id => field_id(field))
    @template.hidden_field_tag field_name(field), options
  end

  # f.text_field :username, :value => "(blank)", :id => 'username'
  def text_field(field, options={})
    options.reverse_merge!(:value => field_value(field), :id => field_id(field))
    @template.text_field_tag field_name(field), options
  end

  def input_field(field, options = {})
    options.reverse_merge!(:value => field_value(field), :id => field_id(field), :name => field_name(field))
    input_type = options.delete(:type) || :text
    @template.input_tag input_type.to_sym, options
  end

  # f.text_area :summary, :value => "(enter summary)", :id => 'summary'
  def text_area(field, options={})
    options.reverse_merge!(:value => field_value(field), :id => field_id(field))
    @template.text_area_tag field_name(field), options
  end

  # f.password_field :password, :id => 'password'
  def password_field(field, options={})
    options.reverse_merge!(:value => field_value(field), :id => field_id(field))
    @template.password_field_tag field_name(field), options
  end

  # f.select :color, :options => ['red', 'green'], :include_blank => true
  # f.select :color, :collection => @colors, :fields => [:name, :id]
  def select(field, options={})
    options.reverse_merge!(:id => field_id(field), :selected => field_value(field))
    puts "options" + options.to_json
    @template.select_tag field_name(field), options
  end

  # f.check_box :remember_me, :value => 'true', :uncheck_value => '0'
  def check_box(field, options={})
    unchecked_value = options.delete(:uncheck_value) || '0'
    options.reverse_merge!(:id => field_id(field), :value => '1')
    options.merge!(:checked => true) if values_matches_field?(field, options[:value])
    html = hidden_field(field, :value => unchecked_value, :id => nil)
    html << @template.check_box_tag(field_name(field), options)
  end

  # f.radio_button :gender, :value => 'male'
  def radio_button(field, options={})
    options.reverse_merge!(:id => field_id(field, options[:value]))
    options.merge!(:checked => true) if values_matches_field?(field, options[:value])
    @template.radio_button_tag field_name(field), options
  end

  # f.file_field :photo, :class => 'avatar'
  def file_field(field, options={})
    options.reverse_merge!(:id => field_id(field))
    @template.file_field_tag field_name(field), options
  end

  # f.submit "Update", :class => 'large'
  def submit(caption="Submit", options={})
    @template.submit_tag caption, options
  end

  # f.simage_submitubmit "buttons/submit.png", :class => 'large'
  def image_submit(source, options={})
    @template.image_submit_tag source, options
  end

  protected

  # Returns the known field types for a formbuilder
  def self.field_types
    [:hidden_field, :text_field, :text_area, :password_field, :file_field, :radio_button, :check_box, :select]
  end

  # Returns the object's models name
  #   => user_assignment
  def object_name
    object.is_a?(Symbol) ? object : object.class.to_s.underscore.gsub('/', '-')
  end

  # Returns true if the value matches the value in the field
  # field_has_value?(:gender, 'male')
  def values_matches_field?(field, value)
    value.present? && (field_value(field).to_s == value.to_s || field_value(field).to_s == 'true')
  end

  # Returns the value for the object's field
  # field_value(:username) => "Joey"
  def field_value(field)
    @object && @object.respond_to?(field) ? @object.send(field) : ""
  end

  # Returns the name for the given field
  # field_name(:username) => "user[username]"
  def field_name(field)
    "#{object_name}[#{field}]"
  end

  # Returns the id for the given field
  # field_id(:username) => "user_username"
  # field_id(:gender, :male) => "user_gender_male"
  def field_id(field, value=nil)
    value.blank? ? "#{object_name}_#{field}" : "#{object_name}_#{field}_#{value}"
  end

  # explicit_object is either a symbol or a record
  # Returns a new record of the type specified in the object
  def build_object(object_or_symbol)
    object_or_symbol.is_a?(Symbol) ? object_class(object_or_symbol).new : object_or_symbol
  end

  # Returns the class type for the given object
  def object_class(explicit_object)
    explicit_object.is_a?(Symbol) ? explicit_object.to_s.classify.constantize : explicit_object.class
  end
end
