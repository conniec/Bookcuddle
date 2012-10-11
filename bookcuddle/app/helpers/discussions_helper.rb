module DiscussionsHelper
  def formated_update_date(unparsed)
    parsed = unparsed.scan(/[0-9\-\:]*/)
    parsed[0]
  end
end
