include MongoMapper
include MongoMapper::Document

MongoMapper.config = { Rails.env => { 'uri' => ENV['MONGOHQ_URL'] } }
MongoMapper.connect(Rails.env)
