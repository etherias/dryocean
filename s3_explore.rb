class Node < Struct.new(:counter, :size, :objects); end
require 'csv'
require 'json'

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
  
  output = s3_structure.to_json
  puts output
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
    
    puts "bucket structure: #{buc.name}:  #{structure[buc.name]}"
    if structure[buc.name].objects
      structure[buc.name].objects.each_value do |v|
        structure[buc.name].counter += v.counter
        structure[buc.name].size += v.size
      end
    end
    
    #structure[buc.name].counter += 
    #structure[buc.name].size +=
  end
  
  return structure
end

#Function: cycle through branches and generates structure
#Input: branches, bucket, s3
#Output: (hash) of branch's {objectname => Node(?,?,branch)}
def s3_branch_build(branches, bucket, s3, continue = true)
  bstruct = {}
  puts "Entering s3_branch_build for bucket #{bucket.name} and branches #{branches}"
  
  unless branches #empty branch
    puts "Empty branch: terminating branch search"
    return nil
  end
  
  branches.each do |b|
    puts "entered s3_branch_build .each loop for branch #{b.prefix}"
    object = s3_object_info(b, bucket)
    bstruct[b.prefix] = Node.new(object.counter, object.size, continue ? s3_branch_build(object.objects, bucket, s3, false) : s3_branchnode_info(object.objects, bucket))

    puts "branch structure for #{b.prefix}: #{bstruct[b.prefix].objects}"
    if bstruct[b.prefix].objects #if NOT nil in objects
      if bstruct[b.prefix].objects.is_a? Node
        puts "1.1: the bstruct is holding object: #{bstruct[b.prefix].objects}"
        bstruct[b.prefix].size += bstruct[b.prefix].objects.size
        bstruct[b.prefix].counter += bstruct[b.prefix].objects.counter
        puts "1.2: the bstruct is holding object: #{bstruct[b.prefix].objects}"
        puts "1.3:from #{bstruct[b.prefix]} added #{bstruct[b.prefix].objects.size} as size and #{bstruct[b.prefix].objects.counter} as counter}"
      else
        bstruct[b.prefix].objects.each_pair do |branch, struct|
          puts "struct: #{struct}"
          if struct.objects == nil
            bstruct[b.prefix].size += struct.size
            bstruct[b.prefix].counter += struct.counter
            puts "2:from #{bstruct[b.prefix]} added #{struct.size} as size and #{struct.counter} as counter}"
          else
            bstruct[b.prefix].size += struct.size
            bstruct[b.prefix].counter += struct.counter
            puts "3:from #{bstruct[b.prefix]} added #{struct.size} as size and #{struct.counter} as counter}"
          end #if
        end #do
      end #if
    end #if
    puts "exit s3_branch_build .each loop for branch #{b.prefix}"
  end #branches.each
  
  return bstruct
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

#function: write contents of Structure to csv file
#input: completed Structure containing hash/struct
#output: writing to csv
def struct_to_csv(structure)
  restructured = {}
  #Set the CSV headers: Prefix,Level,Counter,Size
  csv_output = "Prefix,Depth,Counter,Size\n"
  structure.each{|region| region.each_pair{|bucket, content| restructured[bucket] = content}}
  
  restructured.each_pair do |bucket, struct|
    #Print the bucket and also the stats after getting them
    csv_output << "#{bucket},1,#{struct.counter},#{struct.size}\n"
    if struct.objects then
      struct.objects.each_pair do |prefix2, struct2|
        csv_output << "#{prefix2},2,#{struct2.counter},#{struct2.size}\n"
        
        if struct2.objects then
          struct2.objects.each_pair do |prefix3, struct3|
           csv_output << "#{prefix3},3,#{struct3.counter},#{struct3.size}\n"
          end #struct objects each 3
        end #if struct3.objects 
      end#struct objects each 2
    end #if struct.objects
  end#restructured each end
  
  File.open("result.csv",'w'){|f|f.write(csv_output)}
  puts "Results has been outputted under name result.csv"
end #class end
