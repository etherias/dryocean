class Node < Struct.new(:counter, :size, :objects); end

#Function: Driver class
#Input: (int) depth level
#Output: (hash) S3 info
def s3_explorer(depth = 3)
  #-> structure = first level bucket via s3_generate_bucket
  s3 = AWS::S3.new(region: "us-east-1")
  regional_hash = s3.buckets.group_by{|b| b.location_constraint or  "us-east-1"}
  
  regional_hash.each_pair do |region, buckets| #through each region
    s3 = AWS::S3.new(region: region)
    puts "Switching to Region: #{s3.config.region}"
    structure = s3_generate_branches(buckets, s3)
    puts structure
  end
end

#Function: generate first level of buckets
#Input:bucket, s3
#Output: (hash) of {bucketname => Node(?,?,branch)}
def s3_generate_branches(buckets, s3)  
  structure = {}
  buckets.each do |buc|
    bucket = s3.buckets[buc.name] #So it doesnt have to make again for further
    
    objects = bucket.as_tree.children.group_by(&:branch?)
    branches = s3_branch_build(objects[true], bucket, s3)
    counter = objects[false].length
    size = objects[false].inject(0){|sum, file| sum += s3.buckets[buc.name].objects[file.key].content_length}
    structure[buc.name] = Node.new(counter, size, branches)
  end
  
  return structure
end

#Function: cycle through branches and generates structure
#Input: branches, bucket, s3
#Output: (hash) of branch's {objectname => Node(?,?,branch)}
def s3_branch_build(branches, bucket, s3)
  branch_structure = {}
  branches.each do |branch|
    bucket.objects.with_prefix(b)
  
    branch_structure[branch.prefix] = Node.new(counter, size, branches) #branches?
  end
end
