+++
Categories = ["Development"]
Description = ""
Tags = ["Development", "docker"]
date = "2016-09-17T15:33:34+02:00"
title = "Taking Control of My Data"
aliases = [
  "/post/taking_control_of_my_data/",
]

+++

One of my projects during my vacation has been to take back control of my data.  The question of online privacy is a difficult one, because while there's some things you can do to improve your privacy, to really own your data takes a lot of effort and learning.  For most people, hosting their own services is more headache than it's worth.  There's a lot of good privacy-conscious services out there if you're willing to pay, but most people are not willing to pay.  The convenience trumps the privacy concerns, and for me it has been that way for a long time as well.

### Simple steps I took to improve privacy

* One thing I did was to [encrypt my phone](http://www.howtogeek.com/141953/how-to-encrypt-your-android-phone-and-why-you-might-want-to/).  The point of this is to keep my data secure in the case of theft.  The thief will not be able to get personal information about me.  But it's also useful to keep as a habit, especially if I were to ever go to a closed country for ministry purposes.  I don't want the government of any of those countries searching through my phone contacts list.
* Another thing I've done is to uninstall the Facebook app.  That app scans pretty much everything on your phone in order to "assist" you.  For example, it will scan your photos and do facial recognition on them, asking if you want to post them.  I've heard stories where it scans your phone's contacts list, suggesting potential friends if they have a few common phone numbers in their contacts list.
* I also went through my [Google privacy settings](https://myaccount.google.com/privacy) to make sure I'm not giving Google permission to use too much data.  
* I started using [DuckDuckGo](https://duckduckgo.com/about) for my everyday searching, resorting to Google only when I can't find what I'm looking for.  DuckDuckGo doesn't keep statistics about your searches, doesn't keep a search history, and doesn't build a profile on you.

But, I still was using `@google.com` email addresses, and keeping a lot of my data on Google's servers.  So, I wanted to try something else.

### The project

#### Start with email

There's a couple main areas where you should really concentrate if you're serious about privacy.  The first is Email.  If you use Gmail, Google is scanning your emails in order to build a profile of you, that they can leverage so that advertisers can target their messages to you.  Facebook does the same thing based on your likes and messages.  This is where they make a lot of their money.

I switched over to [Fastmail](http://fastmail.com) instead, which is a paid service that doesn't leverage your user data for profit.  It's not the most privacy conscious email provider, but that's ok.  I'm not looking to go completely dark, I'm just searching for a better balance of privacy and security.  Fastmail has a great Android app, and as a plus I can use my own domain name.  So now, you can mail me at <a>gordon<span class="domain">gordonburgett<span style="display:none;">.thisistoconfusespammers</span>.net</span></a>

To use my `gordonburgett.net` domain as my email address, I needed to update the MX records at my domain registrar.  Fortunately Fastmail makes that pretty easy to do.  They gave me all the right values and provided indicators of whether the values were correct or not.  I'm using Amazon Route53 for my DNS settings, they make it pretty easy to get in there and change things too.  There's not too much javascript getting in the way like there is with 1and1.com.

I also installed Mozilla Thunderbird to use as a mail client, which is a little better than the webmail, but I am still leaving all my emails on the server for convenience.  If I ever get paranoid I'm confident I can delete my emails from the server and within a couple weeks it'll be pretty clean.

#### Now Google docs

There's no getting around it, Google Docs is a really amazing collaboration tool.  I was recently in a meeting where we had 10 people all on their cell phones editing a spreadsheet at the same time.  So, it's still useful to keep around for some things, namely business data that I'm not too concerned over the privacy of.  But, for my personal documents, I'd like a solution where the data is in a service that I control and pay for.

I chose to self-host an instance of [OwnCloud](https://owncloud.org/) on my Amazon AWS instance, with data backed up to Amazon S3.  Again, I'm looking for a balance of security and convenience.  There's no place that provides the array of support services that Amazon has, at least for as cheap for one tiny server.  Amazon provides so much in terms of automation that it was really a no brainer, as the #1 thing I care about in self-hosting this is ease of maintenance.

In [a previous post](/post/2016/02_docker-cloud-is-neat/) I set up Docker Cloud to run a load-balancer with SSL termination in front of my blog.  I've played with running other apps behind it too, and so it should be fairly easy to run OwnCloud.  The main thing was to make sure that I'm backing up everything correctly, so I ran a local instance and learned [how to backup a basic installation.](https://doc.owncloud.org/server/9.0/admin_manual/maintenance/backup.html)  I ended up with a script that runs in a separate docker container.  You can check it out here: https://github.com/gburgett/dockerfile/tree/master/owncloud/s3_backup

1. The script first checks the Owncloud installation's `instanceid` against the config file stored in AWS S3.  This is to prevent the  automatic backup process from accidentally overwriting my old data with a fresh install in case the owncloud container dies and is  restarted.  The `instanceid` is generated randomly on startup, if we restore we'll overwrite it with the old `instanceid`.
2. Then the script dumps the sqlite database and uploads it to s3: `sqlite3 $INSTALL_DIR/data/owncloud.db .dump | gzip > /tmp/db/owncloud.bak.gz`
3. Finally it runs s3 sync on the config and the data.  So I have a plaintext copy of all my data in s3.  Again this is OK because I'm going more for convenience here, I can potentially change it later to do encrypted backups.

Restoring is a straightforward reversal of the process.  The `restore.sh` script in that same directory runs the restore.  It won't restore over the same `instanceid`, because I don't want to have an automatic restore process overwrite new data.

I wrote a [backup script](https://github.com/gburgett/blog/blob/master/home/backup.sh) that will be executed by cron on my web server.  Since running cron inside of docker containers is super difficult, I have the backup script running outside as the ubuntu user.  I wanted to make it a bit more generic and not just for owncloud, so what it does is inspect all the running containers and look for environment variables indicating how to backup the container.  For owncloud, I set the `BACKUP_CMD` and `BACKUP_IMAGE` environment variables.  The script reads these, and calls `docker exec` to run the specified image with the specified command in order to do the backup.  It also injects environment variables into the new container from any variables prefixed `BACKUP_ENV_`.  This is how I pass AWS credentials to upload to s3.  The backup script runs every hour, and it's been working great for a few weeks now!

The last thing is to figure out my restore process.  I decided I want to restore anytime I need to restart the OwnCloud docker container, and potentially to restore manually on an as-needed basis.  So, I set that up through a DockerCloud stack.  The stack contains a "restore" container, which runs when the stack starts up then stops when the command finishes.  The container's image is `gordonburgett/owncloud_s3_backup:latest`, and it runs the command `/restore.sh -f s3://gordonburgett.net/backup/owncloud` with volumes_from the owncloud container.  Here's how the stackfile ended up:

```yml
data:
  image: 'debian:jessie'
  volumes:
    - /var/www/html
owncloud:
  environment:
    - 'BACKUP_CMD=/backup.sh s3://gordonburgett.net/backup/owncloud'
    - BACKUP_ENV_AWS_ACCESS_KEY_ID=********
    - BACKUP_ENV_AWS_SECRET_ACCESS_KEY=********
    - 'BACKUP_IMAGE=gordonburgett/owncloud_s3_backup:latest'
    - FORCE_SSL=true
    - "SSL_CERT=-----BEGIN CERTIFICATE-----\\n****\\n-----END CERTIFICATE-----\\n-----BEGIN RSA PRIVATE KEY-----\\n****\\n-----END RSA PRIVATE KEY-----\\n"
    - 'VIRTUAL_HOST=cloud.gordonburgett.net, https://cloud.gordonburgett.net'
  expose:
    - '80'
  image: 'owncloud:9'
  restart: on-failure
  volumes_from:
    - data
restore:
  command: '/restore.sh -f s3://gordonburgett.net/backup/owncloud'
  environment:
    - AWS_ACCESS_KEY_ID=********
    - AWS_SECRET_ACCESS_KEY=********
  image: 'gordonburgett/owncloud_s3_backup:latest'
  volumes_from:
    - data

```

So now, if my server dies, I just have to click "Start" on the whole stack.  DockerCloud takes care of running the data volume container, the OwnCloud container, and the Restore container in the correct order.  As soon as the Restore container stops, I know I can log in to Owncloud at `cloud.gordonburgett.net`.  I shared a simple text file there so you can see! https://cloud.gordonburgett.net/index.php/s/unr0gfCCsNRqf7V

#### Messaging

This is the last thing I did, but it wasn't really worth it just for my own messaging purposes.  The reason is that none of the major messaging players support XMPP anymore.  There is no longer an open messaging standard - if you want to talk to people on WhatsApp, you have to have the WhatsApp app.  Same with Facebook messenger and Google talk.  So, I can really only talk to other XMPP users.

In fact the reason I did it is because I have an app idea, and I want to use XMPP as the backend server.  So as long as I'm making the effort, I might as well register an account for myself.  And in the spirit of taking control of my data, I'll use my own server.

[Ejabberd](https://www.ejabberd.im/) is one of the most highly recommended options, and seemed fairly lightweight, so I went for it.  I found a docker image, `rroemhild/ejabberd`, which seemed pretty good.  It has a lot of configuration options exposed as environment variables, which is perfect.  I ran it locally, and tested backing it up with my backup script.  With that working, I began attempting to set it up on my server.

Going back to DockerCloud, I set up this stackfile:

```yaml
ejabberd:
  environment:
    - BACKUP_CMD=ejabberdctl backup /opt/ejabberd/backup/ejabberd.backup
    - BACKUP_LOCATION=/opt/ejabberd/backup/ejabberd.backup
    - EJABBERD_ADMINS=gordon@gordonburgett.net
    - EJABBERD_AUTH_METHOD=internal
    - |
      EJABBERD_SSLCERT_GORDONBURGETT_NET=-----BEGIN CERTIFICATE-----
      *** This is for gordonburgett.net ***
      -----END CERTIFICATE-----
      -----BEGIN RSA PRIVATE KEY-----
      ***
      -----END RSA PRIVATE KEY-----
    - |
      EJABBERD_SSLCERT_HOST=-----BEGIN CERTIFICATE-----
      *** This is for xmpp.gordonburgett.net ***
      -----END CERTIFICATE-----
      -----BEGIN RSA PRIVATE KEY-----
      ***
      -----END RSA PRIVATE KEY-----
    - ERLANG_NODE=xmpp
    - XMPP_DOMAIN=gordonburgett.net
  hostname: xmpp.gordonburgett.net
  image: 'rroemhild/ejabberd:latest'
  ports:
    - '5222:5222'
    - '5269:5269'
    - '5280:5280'
  volumes_from:
    - ejabberddata
ejabberddata:
  image: 'rroemhild/ejabberd-data:latest'
  volumes:
    - /opt/ejabberd/database
    - /opt/ejabberd/ssl
    - /opt/ejabberd/backup
    - /opt/ejabberd/upload
```

One of the biggest problems was getting the DNS data set up right.  In order for clients to find my server, I have to tell them about it in the DNS records.  That means adding two SRV records:

| DNS records: |     |     |     |     |     |
|:---:|:---:|:---:|:---:|:---:|:---:|
| _xmpp-client._tcp.gordonburgett.net. | SRV | 5 | 0 | 5222 | xmpp.gordonburgett.net |
| _xmpp-server._tcp.gordonburgett.net. | SRV | 5 | 0 | 5222 | xmpp.gordonburgett.net |

![XMPP SRV records in my Route53 DNS config](/images/2016/xmpp_dns_records.png)


![XMPP SRV record details in my Route53 DNS config](/images/2016/xmpp_dns_detail.png)

The second big detail was setting up the SSL certificates.  I finally figured out how to do it (see the above yaml file).  The key is that since I set up the DNS records to point to xmpp.gordonburgett.net, I need an SSL cert for xmpp.gordonburgett.net, which goes in `EJABBERD_SSLCERT_HOST`.  I also need to put my SSL cert for `gordonburgett.net` in `EJABBERD_SSLCERT_GORDONBURGETT_NET`.  Fortunately Letsencrypt makes generating new SSL certs easy and cheap.

One other detail was to make sure the ERLANG_NODE variable is set to the same as the first part of your hostname.  This is a restriction of the Mnesia database, the internal Erlang database.  Probably it wouldn't be a problem if I was using an external MySql server.

The last thing to do was set up my user!  I SSH'd into the server, entered bash in the container and created my user using the `ejabberdctl` tool:

```bash
ubuntu@gordonburgett.net:~$ docker exec -it $id /bin/bash
ejabberd@xmpp$ ejabberdctl register gordon gordonburgett.net pw
```

And now I can connect!  And my server gets a `B` grade from xmpp.net!
<a href='https://xmpp.net/result.php?domain=gordonburgett.net&amp;type=client'><img src='https://xmpp.net/badge.php?domain=gordonburgett.net' alt='xmpp.net score' /></a>

Anyone want to get on XMPP?
