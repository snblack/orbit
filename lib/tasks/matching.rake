namespace :matching do
  desc "Run the matching algorithm to form Pods"
  task run: :environment do
    result = MatchingService.run
    puts result if result.is_a?(String)
  end
end
