# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
config.gem "mongo_mapper"

Bookcuddle::Application.initialize!
