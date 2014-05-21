require File.expand_path(File.dirname(__FILE__) + '/../samples_config')

s3 = AWS::S3.new

output = s3.buckets.collect{|bucket|bucket.objects['key']}

output.each do |obj|
  puts obj.key
end

def s3_filecount(current, depth)
  
end



#base func :specify depth level and root/seed with options hash
#	:sums up total count for nodes
def s3_explorer(depth=3)
  s3 = AWS::S3.new(:region => "us-east-1")
  regional_hash = s3.buckets.group_by{|b| b.location_constraint or "us-east-1"}

  regional_hash.each_pair do |region, buckets|
    s3 = AWS::S3.new(region: region)

    buckets.each do |bucket|
      tree = s3.buckets[bucket.name].as_tree
      branch = tree.children.select(&:branch?).collect(&:prefix)
    end
  end

end


#function :finds all then files within a "seed" folder
def find_fileinfo(bucket)
  byte_size, counter = 0,0

  if bucket.exists?
    bucket.objects.each do |obj|
      (byte_size += obj.content_length and counter +=1) if obj.content_length > 0  
    end
  else puts "Bucket:#{bucket} does not exist"; end
  return {size: byte_size, counter: counter}
end
