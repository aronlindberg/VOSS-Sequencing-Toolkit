=begin
Name: Ruby Github Sequence Coder
Author: Omri Shiv
Description: An automatic translator of github sequence data to clustal sequences for sequence analysis 
Use: Needs an argument, either just the project name, or the author/project
=end

require 'optparse' #for using options in program
require 'sqlite3' #loaded to manipulate the database

@options = {verbose:false, db:'github.sqlite'}
OptionParser.new do |opts|
  opts.banner = "Usage: auto_coder.rb [options]"

  opts.on("-r", "--repository REPOSITORY", "Mandatory repository name") do |v|
    @options[:repository] = v
  end

  opts.on("-a", "--actor ACTOR", "owner name") do |v|
    @options[:actor] = v
  end

  opts.on("-d", "--db LOCATION", "sqlite db location") do |v|
    @options[:db] = v
  end

  opts.on("-v", "--verbose", "verbose log (default: false)") do |v|
    @options[:verbose] = v
  end
end.parse!
raise OptionParser::MissingArgument if @options[:repository].nil?
=begin
This function builds our clustal sequence using the heuristic we defined as follows:
  Actor:
    Own: Specifies that the actor is the repository owner/creator
    Con: Specifies that the actor is a contributor
  Activity:
    Gen: Activity of type generate
    Neg: Activity of type negotiate
    Trn: Activity of type transfer
    Soc: Activity of type socialize
  Design Object:
    Spe: Specification Design Type
    Pro: Prototype Design Type
    Kno: Knowledge Design Type
  Affordance:
    Tra: Transformation Affordance Type
    Cop: Cooperative Affordance Type
    Inf: Infrastructure Affordance Type
    Con: Control Affordance Type
    Ana: Analysis Affordance Type
  Data Flow:
    Out: Output data flow
    Upd: Update data flow
    Inp: Input data flow
=end
def row_to_sequence(row, number)
  seq='' #initialize our empty sequence string
  seq<<">s#{number}\n" #writing sequence number
  case row['actor']#determine actor
  when row['repository_owner']
    seq<<"Own"
  else
    seq<<"Con"
  end
  case row['type'] #determine activity
  when 'PublicEvent', 'CreateEvent', 'GistEvent', 'GollumEvent', 'PullRequestEvent', 'PushEvent', 'DeleteEvent'
    seq<<"Gen"
  when 'PullRequestReviewCommentEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'IssuesEvent'
    seq<<"Neg"
  when 'ForkEvent', 'ForkApplyEvent', 'DownloadEvent'
    seq<<"Trn"
  when 'FollowEvent', 'WatchEvent', 'MemberEvent', 'TeamAddEvent'
    seq<<"Soc"
  end
  case row['type'] #determine design object
  when 'PublicEvent', 'CreateEvent', 'ForkEvent', 'ForkApplyEvent', 'WatchEvent', 'MemberEvent', 'TeamAddEvent', 'WatchEvent'
    seq<<"Spe"
  when 'PullRequestEvent', 'PushEvent', 'DeleteEvent', 'PullRequestReviewCommentEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'IssuesEvent', 'DownloadEvent'
    seq<<"Pro"
  when 'GistEvent', 'GollumEvent'
    seq<<"Kno"
  end
  case row['type'] #determine affordance
  when 'PullRequestEvent', 'PushEvent', 'DeleteEvent'
    seq<<"Tra"
  when 'FollowEvent', 'WatchEvent', 'MemberEvent', 'TeamAddEvent', 'DownloadEvent', 'ForkEvent', 'ForkApplyEvent'
    seq<<"Cop"
  when 'GistEvent', 'GollumEvent', 'IssuesEvent'
    seq<<"Inf"
  when 'PublicEvent', 'CreateEvent'
    seq<<"Con"
  when 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent'
    seq<<"Ana"
  end
  case row['type'] #determine data flow
  when 'PublicEvent', 'CreateEvent', 'ForkEvent', 'ForkApplyEvent', 'MemberEvent', 'TeamAddEvent', 'WatchEvent', 'IssuesEvent', 'FollowEvent'
    seq<<"Out"
  when 'PullRequestEvent', 'PushEvent', 'DeleteEvent', 'PullRequestReviewCommentEvent', 'CommitCommentEvent', 'IssueCommentEvent',  'GistEvent', 'GollumEvent'
    seq<<"Upd"
  when 'DownloadEvent'
    seq<<"Inp"
  end
  seq<<"\n"
  puts seq if @options[:verbose]
  return seq
end

begin
  # load the data
  db = SQLite3::Database.open(@options[:db]) #open database file
  db.results_as_hash = true #allows us to address the array of results as a hash
  n = 0 #iterator for sequence number

  if !@options[:actor].nil? #query for the project with owner
    f = File.new("#{@options[:actor]}_#{@options[:repository]}_seq.txt", 'w') #creating sequence file
    puts "Looking for repo #{@options[:repository]} with owner #{@options[:actor]}... This may take some time...\n"
    db.execute("Select * From events where repository_owner='#{@options[:actor]}' AND repository_name='#{@options[:repository]}'") do |row|
      puts row if @options[:verbose]
      f.puts(row_to_sequence(row, n))
      n += 1
    end
    f.close
  elsif @options[:owner].nil? #query for all projects including original fork of input
    f = File.new("#{@options[:repository]}_seq.txt", 'w') #creating sequence file
    puts "Looking for all projects from repo #{@options[:repository]}... This may take some time...\n"
    rows = db.execute("Select * From events where repository_name='#{@options[:repository]}'") do |row|
      puts row if @options[:verbose]
      f.puts(row_to_sequence(row, n))
      n += 1
    end
    f.close
  end
end