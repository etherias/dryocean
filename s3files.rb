require File.expand_path(File.dirname(__FILE__) + '/../samples_config')

class Bucket < Struct.new(:counter, :size, :buckets); end

#base func :specify depth level and root/seed with options hash
#	:sums up total count for nodes
def s3_explorer(depth=3)
  s3 = AWS::S3.new(:region => "us-east-1")
  regional_hash = s3.buckets.group_by{|b| b.location_constraint or "us-east-1"}

  #build hash structure of relationship by creating hash and injecting output of each region
  structure = regional_hash.inject({}) do |result, (region,buckets)| 
    s3 = AWS::S3.new(region: region)
    buckets.each do |buck|      
      result[buck] = s3_build_hash(depth, s3, buck)
    end
  end
end

#Create relationship structure
# INPUT => Bucket; OUTPUT => Bucket object that contains INFO of content under
def s3_build_hash(depth=3, s3, bucket)
  bucket_count and bucket_size = 0
  bucket_content = {}
  
  if depth > 1 then #input bucket=branch? so make sure that it'll work for below
    content = s3.buckets[bucket.name].as_tree.children.group_by(&:branch?) #content[true]=branch; false=files
    
    #accounts for files found within CURRENT bucket (not in further branch)
    bucket_size += content[false].inject(0){|sum,file| sum += bucket.objects[file.key].content_length}
    bucket_count += content[false].length
    
    #for each branch content[true], call s3_build_hash(depth-1, s3, branch)
    bucket_content = content[true].collect{|branch| s3_build_hash(depth-1, s3, branch)}
  else #reached max depth
    return find_pathstats(bucket, branch)
  end
   
  return Bucket.new(bucket_count, bucket_size, bucket_content)
end

#Calculates and sums the totals per node


def find_pathstats(bucket, branch)
  byte_size and counter = 0, 0
  
  files = bucket.objects.with_prefix(branch.prefix).collect(&:content_length)
  files.each{|x|counter += 1 and byte_size += x if x > 0}
  
  return Bucket.new(counter, byte_size, nil)
end

#function :finds all then files within a "seed" folder
def find_fileinfo(bucket)
  byte_size, counter = 0,0

  if bucket.exists?
    bucket.objects.each do |obj|
      (byte_size += obj.content_length and counter +=1) if obj.content_length > 0  
    end
  else puts "Bucket:#{bucket} does not exist"; end
  return Bucket.new(counter, byte_size, nil)
end
