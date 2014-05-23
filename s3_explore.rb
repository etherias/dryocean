class Node < Struct.new(:counter, :size, :objects); end

#Function: Driver class
#Input: (int) depth level
#Output: (hash) S3 info
def s3_explorer(depth = 3)
  #-> structure = first level bucket via s3_generate_bucket
  s3_structure = []
  s3 = AWS::S3.new(region: "us-east-1")
  regional_hash = s3.buckets.group_by{|b| b.location_constraint or  "us-east-1"}
  
  regional_hash.each_pair do |region, buckets| #through each region
    s3 = AWS::S3.new(region: region)
    puts "Switching to Region: #{s3.config.region}"
    s3_structure << structure = s3_generate_branches(buckets, s3)
  end
  return s3_structure
end

#Function: generate first level of buckets
#Input:bucket, s3
#Output: (hash) of {bucketname => Node(?,?,branch)}
def s3_generate_branches(buckets, s3)  
  puts "entering s3_generate_branches method"
  structure = {}
  buckets.each do |buc|
    puts "entered s3_generate_branches buckets each loop for :buck #{buc.name}"
    bucket = s3.buckets[buc.name] #So it doesnt have to make again for further

    object = s3_object_info(bucket, bucket)
    branches = s3_branch_build(object.objects, bucket, s3) ##Refactor .5!!!!!!!!!!!!!

    structure[buc.name] = Node.new(object.counter, object.size, branches)
  end
  
  return structure
end

#Function: cycle through branches and generates structure
#Input: branches, bucket, s3
#Output: (hash) of branch's {objectname => Node(?,?,branch)}
def s3_branch_build(branches, bucket, s3, continue = true)
  branch_structure = {}
  puts "Entering s3_branch_build for bucket #{bucket.name} and branches #{branches}"
  
  unless branches #empty branch
    puts "Empty branch: terminating branch search"
    return nil
  end
  
  branches.each do |branch|
    puts "entered s3_branch_build .each loop for branch #{branches}"
    object = s3_object_info(branch, bucket)
    branch_structure[branch.prefix] = Node.new(object.counter, object.size, continue ? s3_branch_build(object.objects, bucket, s3, false) : s3_branchnode_info(object.objects, bucket)) #fix up branches parameter
  end
  return branch_structure
end

#function: input object, and then return its info
#input: object (branch/bucket), bucket (s3.buckets[...]))
def s3_object_info(object, bucket)
  objects = object.as_tree.children.group_by(&:branch?)
  
  counter, size = 0, 0
  objects[false].each do |file| 
    puts "test: #{file.key}"
    filesize =  bucket.objects[file.key].content_length
    counter += 1 and size += filesize if (filesize > 0)
  end
  
  return Node.new(counter, size, objects[true])
end

#function: input branch (appears on last level) and return the total size + counter of objects within
#input: branch, bucket
#outout: [counter, size]
def s3_branchnode_info(branch, bucket)
  if branch
    branch.each do |b|
      files = bucket.objects.with_prefix(b.prefix).collect(&:content_length).reject{|x| x==0}
      puts "Branch Prefix: #{b.prefix}"
      bucket.objects.with_prefix(b.prefix).each{|x| puts x.key} #testing.. remove later
      return Node.new(files.length, files.inject(:+), nil)
    end
  else 
    return nil
  end
end
