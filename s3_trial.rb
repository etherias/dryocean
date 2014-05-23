require File.expand_path(File.dirname(__FILE__) + '/../samples_config')

(bucket_name, file_name) = ARGV
unless bucket_name && file_name
  puts "Usage: upload_file.rb <BUCKET_NAME> <FILE_NAME>"
  exit 1
end

s3 = AWS::S3.new

bucket = s3.buckets.create(bucket_name)
basename = File.basename(file_name)
