## Heuristics for Coding the GitHub Timeline Manually ##

**To determine actor**

1. Compare column 'repository_owner' (J) with column 'actor' (Z).
2. If they are the same, then actor=repo owner else;
3. Actor=Not repo owner

**To determine activity**
* Look at column 'type' (AO)
Generating= 'PublicEvent', 'CreateEvent', 'GistEvent', 'GollumEvent', 'PullRequestEvent', 'PushEvent', 'DeleteEvent'
Negotiating='PullRequestReviewCommentEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'IssuesEvent'
Transferring='ForkEvent', 'ForkApplyEvent', 'DownloadEvent'
Socializing='FollowEvent', 'WatchEvent', 'MemberEvent', 'TeamAddEvent'

**To determine design object**
* Mostly based on activities
Specification = 'type' = 'PublicEvent', 'CreateEvent', 'ForkEvent', 'ForkApplyEvent', 'WatchEvent', 'MemberEvent', 'TeamAddEvent', 'WatchEvent'
Prototype = 'PullRequestEvent', 'PushEvent', 'DeleteEvent', 'PullRequestReviewCommentEvent', 'CommitCommentEvent', 'IssueCommentEvent', 'IssuesEvent', 'DownloadEvent' 
Knowledge = 'type' = 'GistEvent', 'GollumEvent'

**To determine affordance**
* Mostly based on activities
Transformation = 'type' = 'PullRequestEvent', 'PushEvent', 'DeleteEvent'
Cooperative = 'type' = 'FollowEvent', 'WatchEvent', 'MemberEvent', 'TeamAddEvent', 'DownloadEvent', 'ForkEvent', 'ForkApplyEvent',
Infrastructure = 'type' = 'GistEvent', 'GollumEvent', 'IssuesEvent'
Control = 'type' = 'PublicEvent', 'CreateEvent',
Analysis = 'type' = 'CommitCommentEvent', 'IssueCommentEvent', 'PullRequestReviewCommentEvent', 

**To determine input/output**
* Mostly based on activities
Output = 'type' = 'PublicEvent', 'CreateEvent', 'ForkEvent', 'ForkApplyEvent', 'MemberEvent', 'TeamAddEvent', 'WatchEvent', 'IssuesEvent', 'FollowEvent'
Update = 'type' = 'PullRequestEvent', 'PushEvent', 'DeleteEvent', 'PullRequestReviewCommentEvent', 'CommitCommentEvent', 'IssueCommentEvent',  'GistEvent', 'GollumEvent', 
Input = 'type' = 'DownloadEvent'