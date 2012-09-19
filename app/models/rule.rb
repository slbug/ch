module Rule
  def self.table_name_prefix
    'rule_'
  end
end

Dir[File.join(File.dirname(__FILE__), 'rule', '*.rb')].each{ |f| require_dependency f }
