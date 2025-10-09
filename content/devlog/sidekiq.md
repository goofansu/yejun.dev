---
title: "Sidekiq"
author: ["Yejun Su"]
date: 2024-11-20T08:34:00+08:00
lastmod: 2025-10-09T15:13:39+08:00
tags: ["bib", "job", "ruby"]
draft: false
toc: true
state: "seedling"
---

## Glossaries {#glossaries}

-   Job: A unit of work in your Ruby application.
-   Queue: A list of jobs which are ready to execute right now.
-   Process: A Sidekiq process with one or more threads for executing jobs.


## Job lifecycle {#job-lifecycle}

-   Enqueued: Waiting for being processed.
-   Scheduled: Configured to be run at some point in the future.
-   Busy: Currently being processed.
-   Retries: Will be automatically retried in the future.
-   Dead: Failed all retries. Limited by default to 10,000 jobs or 6 months.


## API {#api}

Creates a job class using command: `rails g sidekiq:job my`

```ruby
class MyJob
  include Sidekiq::Job

  def perform(*args)
    # ...
  end
end
```


### Enqueue a job {#enqueue-a-job}

```ruby
MyJob.perform_async(1, 2, 3) # enqueued and perform later
MyJob.perform_in(5.minutes, 1, 2, 3) # scheduled to perform in 5 minutes
MyJob.perform_at(5.minutes.from_now, 1, 2, 3) # scheduled to perform at 5 minutes from now
```


### Push a job using low-level API {#push-a-job-using-low-level-api}

```ruby
Sidekiq::Client.push('class' => MyJob, 'args' => [1, 2, 3])
```


## Pro API {#pro-api}


### Delete a specific job from queue {#delete-a-specific-job-from-queue}

```ruby
queue = Sidekiq::Queue.new('default')
queue.delete_job(jid)
```


### Delete a kind of jobs from queue {#delete-a-kind-of-jobs-from-queue}

```ruby
queue = Sidekiq::Queue.new('default')
queue.delete_by_class(MyClass)
```


### Pause and resume queue {#pause-and-resume-queue}

```ruby
queue = Sidekiq::Queue.new('default')
queue.pause!
queue.paused? # => true
queue.unpause!
```


## Retry {#retry}

Default max retries: 25.


### Send failed job to the Retries set {#send-failed-job-to-the-retries-set}

```ruby
class MyJob
  include Sidekiq::Job
  sidekiq_options retry: 1
end
```


### Send failed job straight to the Dead set {#send-failed-job-straight-to-the-dead-set}

```ruby
class MyJob
  include Sidekiq::Job
  sidekiq_options retry: 0
end
```


### Discard failed job directly {#discard-failed-job-directly}

```ruby
class MyJob
  include Sidekiq::Job
  sidekiq_options retry: false
end
```


### Set failed job to retry in a different queue {#set-failed-job-to-retry-in-a-different-queue}

```ruby
class MyJob
  include Sidekiq::Job
  sidekiq_options queue: 'default', retry_queue: 'low'
end
```


### Waiting time inreases according to retry count {#waiting-time-inreases-according-to-retry-count}

```ruby
delay = (count**4) + 15
jitter = rand(10) * (count + 1)
retry_at = Time.now.to_f + delay + jitter
```


## References {#references}

-   <https://www.mikeperham.com/2021/04/20/a-tour-of-the-sidekiq-api/>
-   <https://github.com/sidekiq/sidekiq/wiki/Job-Lifecycle>
-   <https://github.com/sidekiq/sidekiq/wiki/Error-Handling>
-   <https://github.com/sidekiq/sidekiq/wiki/Pro-API>
