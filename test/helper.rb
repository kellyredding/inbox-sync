# this file is automatically required in when you require 'assert' in your tests
# put test helpers here

# add root dir to the load path
$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))


class Assert::Context

  def configured_sync
    InboxSync::Sync.new.configure do
      source.host  'imap.gmail.com'
      source.port  993
      source.ssl   'Yes'
      source.login 'joetest@kellyredding.com', 'joetest1'

      dest.host  'imap.gmail.com'
      dest.port  993
      dest.ssl   'Yes'
      dest.login 'suetest@kellyredding.com', 'suetest1'

      notify.host  'smtp.gmail.com'
      notify.port  587
      notify.tls   'Yes'
      notify.helo  'gmail.com'
      notify.login 'suetest@kellyredding.com', 'suetest1'
      notify.to_addrs 'suetest@kellyredding.com'

      logger Logger.new('log/tests.log')
    end
  end

  TEST_MAIL_DATA = {
    'RFC822' => "Delivered-To: joetest@kellyredding.com\r\nReceived: by 10.114.62.209 with SMTP id a17csp11732lds;\r\n        Thu, 24 May 2012 08:34:46 -0700 (PDT)\r\nReceived: by 10.112.84.65 with SMTP id w1mr13705338lby.40.1337873686521;\r\n        Thu, 24 May 2012 08:34:46 -0700 (PDT)\r\nReturn-Path: <suetest@kellyredding.com>\r\nReceived: from mail-lpp01m010-f67.google.com (mail-lpp01m010-f67.google.com [209.85.215.67])\r\n        by mx.google.com with ESMTPS id a9si2217645lbh.1.2012.05.24.08.34.46\r\n        (version=TLSv1/SSLv3 cipher=OTHER);\r\n        Thu, 24 May 2012 08:34:46 -0700 (PDT)\r\nReceived-SPF: neutral (google.com: 209.85.215.67 is neither permitted nor denied by best guess record for domain of suetest@kellyredding.com) client-ip=209.85.215.67;\r\nAuthentication-Results: mx.google.com; spf=neutral (google.com: 209.85.215.67 is neither permitted nor denied by best guess record for domain of suetest@kellyredding.com) smtp.mail=suetest@kellyredding.com\r\nReceived: by lagv3 with SMTP id v3so751705lag.2\r\n        for <joetest@kellyredding.com>; Thu, 24 May 2012 08:34:44 -0700 (PDT)\r\nX-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;\r\n        d=google.com; s=20120113;\r\n        h=mime-version:x-originating-ip:date:message-id:subject:from:to\r\n         :content-type:x-gm-message-state;\r\n        bh=jC/axn7WeCoH+0tXbYrcmVfGSuJ82WTAoccq2csJ8HA=;\r\n        b=T5W+Ba0za3EsMrBgVM6Z2kJww/GvOIr5JzEMVwNnqJDMgFseumYcHw9f6OGZMuhvtH\r\n         Ok3PCmg8uiDRj1Mm2YiE1O8dhQL7BgBd4UO5zBGcLzUDYHBLor+oSjh8pZOsNgHEJk9H\r\n         dZSn0Af4q8RuCRNCyeD8xJt7rRF1EESAgqdQ35fd1GiTefGyhE1UwGkS/P4BiUga1wUr\r\n         qG2fA7Sbj2XcTyCjvsXqgw/EoOuIgnOqeMHZ5CsCfE0FBhW24cIwAt59FIeTELcsb0QQ\r\n         4w76+RkaS4SxuNCEagsRN6DHnLB7SKqTRF6ZKt6xs/zbkz1Qz3mq4yrhrrYa3pNnK9Ez\r\n         F2ug==\r\nMIME-Version: 1.0\r\nReceived: by 10.112.29.199 with SMTP id m7mr14024566lbh.31.1337873684699; Thu,\r\n 24 May 2012 08:34:44 -0700 (PDT)\r\nReceived: by 10.114.59.80 with HTTP; Thu, 24 May 2012 08:34:44 -0700 (PDT)\r\nX-Originating-IP: [209.133.30.126]\r\nDate: Thu, 24 May 2012 10:34:44 -0500\r\nMessage-ID: <CAA9i=SubBh6kAv=cxgGskY9cmS7gsT4m6YSGGdc417bM+DFk4Q@mail.gmail.com>\r\nSubject: test mail\r\nFrom: Sue Test <suetest@kellyredding.com>\r\nTo: joetest@kellyredding.com\r\nContent-Type: multipart/alternative; boundary=f46d04016b2dbb1bfe04c0c9fd9a\r\nX-Gm-Message-State: ALoCoQkFFPgZHO7zDsv7I5mvZqbwHdNjnyobpEyOYxxXgPySrU+OEAOtZSKX6G3vlddVo15J3A5s\r\n\r\n--f46d04016b2dbb1bfe04c0c9fd9a\r\nContent-Type: text/plain; charset=ISO-8859-1\r\n\r\nThis is a test mail\r\n\r\nWITH MARKUP!!!\r\n\r\n--f46d04016b2dbb1bfe04c0c9fd9a\r\nContent-Type: text/html; charset=ISO-8859-1\r\n\r\nThis is a test mail<div><br></div><div><font class=\"Apple-style-span\" color=\"#ff0000\">WITH MARKUP!!!</font></div>\r\n\r\n--f46d04016b2dbb1bfe04c0c9fd9a--\r\n",
    'INTERNALDATE' => "24-May-2012 15:34:46 +0000"
  }

  def test_mail_item
    InboxSync::MailItem.new(TEST_MAIL_DATA['RFC822'], TEST_MAIL_DATA['INTERNALDATE'])
  end

end
