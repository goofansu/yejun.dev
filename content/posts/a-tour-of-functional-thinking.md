---
title: "A tour of functional thinking"
author: ["Yejun Su"]
date: 2022-05-15T00:00:00+08:00
tags: ["programming"]
draft: false
---

There were several server downtime on May 4th and 5th, my colleagues found IOPS
burst in database when school clicking the Pending Emails button, which will
show the incoming emails one by one for school users to match them with specific
students.

As the requests are very slow to response, the users keep clicking the button
again and again, looking forward to get the results, which in turn degraded the
database performance and causing the downtime.


## Background {#background}

After reading the book [Grokking Simplicity](https://www.manning.com/books/grokking-simplicity), I want to use a skill from the
book to learn how Pending Emails works without running the program.

The skill is called [Distinguishing Actions, Calculations and Data](https://livebook.manning.com/book/grokking-simplicity/chapter-3/) (ACD).
Let me start with a brief introduction:

-   Actions are functions with side-effects, they are affected by when and how
    many times the functions are called, so they need our most attention. They are
    normally the real business we want to do, e.g., sending an email, calling an
    API, etc.
-   Calculations are pure functions without any side-effects, they are decisions
    in our system, e.g., decide the user to send an email, calculate cart’s total
    price, etc.
-   Data is facts about events, it can be immutable and safely serialized to be
    transmitted on a wire or stored to disk, e.g. user struct, phone number, etc.

It can be used in all the phases of coding:

1.  Thinking about a problem before coding:
    -   Clarifying problems needs attention (Actions)
    -   What decisions we will need to make (Calculations)
    -   What data we will need to capture (Data)
2.  Coding a solution:
    -   Writing code with immutability in mind. Actions are mutable, Calculations
        and Data are immutable.
    -   A program should have less Actions and more Calculations and Data, in short,
        Data &gt; Calculations &gt; Actions.
3.  Reading code:
    -   Refactor the code to better separate from Actions, Calculations and Data.


## Explore existing code {#explore-existing-code}

With the weapon in hand, I’m going on with confident.
After reading code, a diagram with above categories appears:

{{< figure src="/attachments/20250127T002629--pending-emails-show-old.png" alt="Diagram of current implementation of pending_emails#show" >}}

There are several problems:

1.  There is no Calculations (pure functions without any side-effect).
2.  There are 6 Actions for DB read operations, it reveals some of the reasons for
    database performance degrading.
3.  In the UI, previous_pending, next_pending only requires id for pagination, but
    they return an object with all attributes.

Notice we spot problems **without running any program** yet!


## Coding a solution {#coding-a-solution}

We can fix above problems by:

1.  Selecting only the necessary columns for `pending_email`.
2.  Calculating `previous_pending`, `next_pending` and `total_count` without DB
    operations.

{{< figure src="/attachments/20250127T002602--pending-emails-show.png" alt="Diagram of improved implementation of pending_emails#show" >}}

Three Actions are changed to Calculations using the data from the newly added
Action “Select only id for pending emails from DB”. Remember Calculations are
pure functions, they are safe to call and easy to test, we should prefer
Calculations to Actions. Thus, we can put more attention on Actions as they will
change according to when and how many times they are called, they are not stable
and not easy to test.

After deploying the fix, we verified it works by clicking the button in the same
school, the response is fast and IOPS never burst. See the comparison for your
reference:

-   Before

    {{< figure src="/attachments/20250127T002536--pending-emails-before.png" alt="MySQL IOPS before improvement" >}}

-   After

    {{< figure src="/attachments/20250127T002514--pending-emails-after.png" alt="MySQL IOPS after improvement" >}}


## Conclusion {#conclusion}

By reviewing the performance improvement, I introduced a practical skill (shared
on [Speaker Deck](https://speakerdeck.com/yejun/functional-programming-part-2)) to spot problems in existing code and evolve a solution by
migrating Actions to Calculations. It is really powerful and easy to use.
