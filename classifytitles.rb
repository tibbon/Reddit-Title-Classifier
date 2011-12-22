require 'classifier'
require './model.rb'

Submission.each do |submission|
  p submission.title
  p upvotes = submission.ups + 0.0
  p downvotes = submission.downs + 0.0
  if downvotes == 0
    downvotes = 1
  end
  p ratio = upvotes / downvotes
end

10 / 8