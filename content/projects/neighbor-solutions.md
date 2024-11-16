+++
showInHome = true
toc = false
title = "Neighbor Solutions"
image = "/images/projects/neighbor-solutions.png"
badges = ["Rails", "RAG", "AI"]
links = [
    {icon = "fas fa-globe", url = "https://neighbor.solutions/"}
]
date = "2024-08-02"
+++

In contracting hourly for [Our Technology](https://www.ourtechnology.co/) on Neighbor Solutions, I've been enjoying
working with AI to build unstructured data import and a Retrieval Augmented Generation (RAG) pipeline.


Neighbor Solutions is a brand new CRM built to enable homeless ministries to better care for our unhoused neighbors.
It features a frontend app built using [the Astro javascript framework](astro.build) that displays a local map with
all available resources for homeless people.  The backend built using Ruby on Rails also provides case notes, interaction
tracking, automation, and other tools for service providers to more effectively care for those who come through their doors.
Finally, a closed-loop referral solution enables metrics for defining success by the ultimate outcome of a case, not just
by number of services provided.

I got to jump in as a part-time contractor earlier this year.  I've been kept busy building an importing system for
unstructured data, allowing us to collect data on which resources are available in a given area by scraping PDFs, word
documents, and excel spreadsheets with widely varying formats.  In building this pipeline I've leveraged
[unstructured.io](https://unstructured.io/) for chunking documents, and [Anthropic Claude 3.5](https://www.anthropic.com/)
to pull out structured resource information from the individual chunks of resources.

In the near future I'm excited to extend our importing and chunking systems to build a full-on Retrieval Augmented
Generation (RAG) system.  We plan to use RAG to answer questions about individual cases by semantically matching to
individual case notes stored in the system and feeding those into Claude.  Some questions we think this system can answer
include:
  * What is the best next step for this individual?
  * Who has been the most helpful to the person in the past?
  * Does this person have family or other close relations we can connect them to?
  * Does this person have a history of drug or alcohol use?
  
With the answers to these questions we can also provide automated recommendations to case workers when they encounter
an individual, including recommended referrals for next steps.

One of the challenges we've had in building this system is handling Protected Health Information (PHI).  We have interest
 from medical service providers in using the system, but it must be HIPAA compliant.  Fortunately my experience building a 
[HIPAA Compliant finance app](/projects/healthshare-technology-solutions/) has been very helpful to Our Technology.  We
have put a plan in place to protect PHI very soon.  This plan involves migrating to Amazon Web Services (AWS), ensuring
proper cloud backups and locking down shell access to the production servers.
