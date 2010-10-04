require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class MailingListMailerTest < ActionMailer::TestCase
  def test_post
    obra_chat = mailing_lists(:obra_chat)
    @expected.subject = "For Sale"
    @expected.from = "Molly <molly@veloshop.com>"
    @expected.to = obra_chat.name
    RacingAssociation.current.now = Time.zone.now
    @expected.date = RacingAssociation.current.now
    @expected.body = read_fixture("post")

    post = Post.new
    post.mailing_list = obra_chat
    post.from_email_address = 'molly@veloshop.com'
    post.from_name = 'Molly'
    post.subject = "For Sale"
    post.body = @expected.body
    post.date = RacingAssociation.current.now
    post_email = MailingListMailer.create_post(post)
    assert_equal(@expected.encoded, post_email.encoded)
  end
  
  def test_post_private_reply
    obra_chat = mailing_lists(:obra_chat)
    @expected.subject = "For Sale"
    @expected.from = "Molly <molly@veloshop.com>"
    @expected.to = "Scout <scout@butlerpress.com>"
    @expected.date = Time.zone.now
    @expected.body = read_fixture("reply")

    post = Post.new
    post.from_email_address = 'molly@veloshop.com'
    post.from_name = 'Molly'
    post.subject = "For Sale"
    post.body = @expected.body
    post.date = Time.zone.now
    post_email = MailingListMailer.create_private_reply(post, "Scout <scout@butlerpress.com>")
    assert_equal(@expected.encoded, post_email.encoded)
  end
  
  def test_receive_simple
    assert_equal(1, Post.count, "Posts in database")
  
    subject = "Test Email"
    from = "scott@yahoo.com"
    date = Time.zone.now
    body = "Some message for the mailing list"
    email = TMail::Mail.new
    email.set_content_type "text", "plain", { "charset" => 'utf-8' }
    email.subject = subject
    email.from = from
    email.date = date
    email.body = body
    obra_chat = mailing_lists(:obra_chat)
    email.to = obra_chat.name
    
    MailingListMailer.receive(email.encoded)
    
    posts = Post.find(:all, :order => "date")
    assert_equal(2, posts.size, "New post in DB")
    post_from_db = posts.last
    assert_equal(subject, post_from_db.subject, "Subject")
    assert_equal(from, post_from_db.sender, "from")
    assert_equal_dates(date, post_from_db.date, "date")
    assert_equal("Some message for the mailing list", post_from_db.body, "body")
    assert_equal(obra_chat, post_from_db.mailing_list, "mailing_list")
  end
  
  def test_receive
    assert_equal(1, Post.count, "Posts in database")
  
    MailingListMailer.receive(email_to_archive)
    
    posts = Post.find(:all, :order => "date")
    assert_equal(2, posts.size, "New post in DB")
    post_from_db = posts.last
    assert_equal("[Fwd:  For the Archives]", post_from_db.subject, "Subject")
    assert_equal("Scott Willson <scott.willson@gmail.com>", post_from_db.sender, "from")
    assert_equal_dates("Mon Jan 23 15:52:25 PST 2006", post_from_db.date, "Post date", "%a %b %d %H:%M:%S PST %Y")
    assert_equal(mailing_lists(:obra_chat), post_from_db.mailing_list, "mailing_list")
    assert(post_from_db.body["Too bad it doesn't work"], "body")
  end
  
  def test_receive_rich_text
    assert_equal(1, Post.count, "Posts in database")
  
    MailingListMailer.receive(rich_email_text)
    
    posts = Post.find(:all, :order => "date")
    assert_equal(2, posts.size, "New post in DB")
    post_from_db = posts.last
    assert_equal("Rich Text", post_from_db.subject, "Subject")
    assert_equal("Scott Willson <scott.willson@gmail.com>", post_from_db.sender, "from")
    assert_equal("Sat Jan 28 07:02:18 PST 2006", post_from_db.date.strftime("%a %b %d %I:%M:%S PST %Y"), "date")
    assert_equal(mailing_lists(:obra_chat), post_from_db.mailing_list, "mailing_list")
    expected_body = %Q{Rich text message with some formatting and a small attachment.

Check it out: http://www.google.com/\n\n\357\277\274\n}
    assert_equal(expected_body, post_from_db.body, "body")
  end
  
  def test_receive_outlook
    assert_equal(1, Post.count, "Posts in database")
  
    MailingListMailer.receive(outlook_email)
    
    posts = Post.find(:all, :order => "date")
    assert_equal(2, posts.size, "New post in DB")
    post_from_db = posts.last
    assert_equal("Stinky Outlook Email", post_from_db.subject, "Subject")
    assert_equal("Scott Willson <scott.willson@gmail.com>", post_from_db.sender, "from")
    assert_equal("Sat Jan 28 07:28:31 PST 2006", post_from_db.date.strftime("%a %b %d %I:%M:%S PST %Y"), "date")
    assert_equal(mailing_lists(:obra_chat), post_from_db.mailing_list, "mailing_list")
    expected_body = %Q{Hey, this is from Bloodhound in the basement.

http://RacingAssociation.current.static_host

I am the lonely, forgotten computer.

  1.. Where are my friends?
  Slugger
  2.. Lizard

Still loyal:
  Pavilion
}
    assert_equal(expected_body, post_from_db.body, "body")
  end
  
  def test_receive_html
    assert_equal(1, Post.count, "Posts in database")
  
    MailingListMailer.receive(html_email)
    
    posts = Post.find(:all, :order => "date")
    assert_equal(2, posts.size, "New post in DB")
    post_from_db = posts.last
    assert_equal("Thunderbird HTML", post_from_db.subject, "Subject")
    assert_equal("Scott Willson <scott.willson@gmail.com>", post_from_db.sender, "from")
    assert_equal("Sat Jan 28 10:19:04 PST 2006", post_from_db.date.strftime("%a %b %d %I:%M:%S PST %Y"), "date")
    assert_equal(mailing_lists(:obra_chat), post_from_db.mailing_list, "mailing_list")
    expected_body = %Q{<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" text="#000000">
<h3>Race Results</h3>
<table border="1" cellpadding="2" cellspacing="2" width="100%">
  <tbody>
    <tr>
      <td valign="top"><b>Place<br>
      </b></td>
      <td valign="top"><b>Person<br>
      </b></td>
    </tr>
    <tr>
      <td valign="top">1<br>
      </td>
      <td valign="top">Ian Leitheiser<br>
      </td>
    </tr>
    <tr>
      <td valign="top">2<br>
      </td>
      <td valign="top">Kevin Condron<br>
      </td>
    </tr>
  </tbody>
</table>
<br>
</body>
</html>

}
    assert_equal(expected_body, post_from_db.body, "body")
  end
  
  
  private
    
    def email_to_archive
      return %Q{From scott.willson@gmail.com  Mon Jan 23 15:52:43 2006
Return-Path: <scott.willson@gmail.com>
X-Original-To: obra@list.obra.org
Delivered-To: obra@list.obra.org
Received: from localhost (localhost [127.0.0.1])
        by list.obra.org (Postfix) with ESMTP id 1165A106A0
        for <obra@list.obra.org>; Mon, 23 Jan 2006 15:52:43 -0800 (PST)
Received: from list.obra.org ([127.0.0.1])
        by localhost (lizard.obra.org [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id 09182-02 for <obra@list.obra.org>;
        Mon, 23 Jan 2006 15:52:41 -0800 (PST)
Received: from mail.cheryljwillson.com (cheryljwillson.com [71.36.251.213])
        by list.obra.org (Postfix) with ESMTP id 0B60610637
        for <obra@list.obra.org>; Mon, 23 Jan 2006 15:52:41 -0800 (PST)
Received: from localhost (localhost [127.0.0.1])
        by mail.cheryljwillson.com (Postfix) with ESMTP id E5B73443ED
        for <obra@list.obra.org>; Mon, 23 Jan 2006 15:52:25 -0800 (PST)
Received: from webgateway0.cnf.com (webgateway0.cnf.com [63.230.177.28]) 
        by www.cheryljwillson.com (IMP) with HTTP 
        for <sw@localhost>; Mon, 23 Jan 2006 15:52:25 -0800
Message-ID: <1138060345.43d56c39bb9c3@www.cheryljwillson.com>
Date: Mon, 23 Jan 2006 15:52:25 -0800
From: Scott Willson <scott.willson@gmail.com>
To: obra@list.obra.org
References: <43D56B2E.4080607@cheryljwillson.com>
In-Reply-To: <43D56B2E.4080607@cheryljwillson.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Person-Agent: Internet Messaging Program (IMP) 3.2.2
X-Originating-IP: 63.230.177.28
X-Virus-Scanned: amavisd-new at obra.org
Subject: [OBRA Chat] [Fwd:  For the Archives]
X-BeenThere: obra@list.obra.org
X-Mailman-Version: 2.1.6
Precedence: list
List-Id: Oregon Bicycle Racing Association <obra.list.obra.org>
List-Unsubscribe: <http://list.obra.org/mailman/listinfo/obra>,
        <mailto:obra-request@list.obra.org?subject=unsubscribe>
List-Archive: <http://list.obra.org/mailing_lists/obra/posts>
List-Post: <mailto:obra@list.obra.org>
List-Help: <mailto:obra-request@list.obra.org?subject=help>
List-Subscribe: <http://list.obra.org/mailman/listinfo/obra>,
        <mailto:obra-request@list.obra.org?subject=subscribe>
X-List-Received-Date: Mon, 23 Jan 2006 23:52:43 -0000

Too bad it doesn't work!

Quoting Cheryl Willson <cjw@cheryljwillson.com>:

> fascinating
> 

      
      }
  end
  
  def rich_email_text
    %Q{Return-Path: <obra-bounces@list.obra.org>
X-Original-To: scott.willson@gmail.com
Delivered-To: scott.willson@gmail.com
Received: from list.obra.org (list.obra.org [69.30.32.118])
	by mail.cheryljwillson.com (Postfix) with ESMTP id 63D0E42058
	for <scott.willson@gmail.com>; Sat, 28 Jan 2006 07:01:58 -0800 (PST)
Received: from localhost (localhost [127.0.0.1])
	by list.obra.org (Postfix) with ESMTP id EC68310663;
	Sat, 28 Jan 2006 07:02:31 -0800 (PST)
Received: from list.obra.org ([127.0.0.1])
 by localhost (lizard.obra.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 19838-06; Sat, 28 Jan 2006 07:02:30 -0800 (PST)
Received: from lizard.obra.org (localhost [127.0.0.1])
	by list.obra.org (Postfix) with ESMTP id D3F25145A5;
	Sat, 28 Jan 2006 07:02:30 -0800 (PST)
X-Original-To: obra@list.obra.org
Delivered-To: obra@list.obra.org
Received: from localhost (localhost [127.0.0.1])
	by list.obra.org (Postfix) with ESMTP id 56EAA1599E
	for <obra@list.obra.org>; Sat, 28 Jan 2006 07:02:29 -0800 (PST)
Received: from list.obra.org ([127.0.0.1])
	by localhost (lizard.obra.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 19831-06 for <obra@list.obra.org>;
	Sat, 28 Jan 2006 07:02:27 -0800 (PST)
Received: from mail.cheryljwillson.com (cheryljwillson.com [71.36.251.213])
	by list.obra.org (Postfix) with ESMTP id 5BC7010663
	for <obra@list.obra.org>; Sat, 28 Jan 2006 07:02:27 -0800 (PST)
Received: from [192.168.1.100] (cheryljwillson.com [71.36.251.213])
	by mail.cheryljwillson.com (Postfix) with ESMTP id 15BC94215C
	for <obra@list.obra.org>; Sat, 28 Jan 2006 07:01:52 -0800 (PST)
Mime-Version: 1.0 (Apple Message framework v746.2)
To: obra@list.obra.org
Message-Id: <CB0870E9-7054-4576-86A4-BE6A577F6DFE@butlerpress.com>
From: Scott Willson <scott.willson@gmail.com>
Date: Sat, 28 Jan 2006 07:02:18 -0800
X-Mailer: Apple Mail (2.746.2)
X-Virus-Scanned: amavisd-new at obra.org
Subject: [OBRA Chat] Rich Text
X-BeenThere: obra@list.obra.org
X-Mailman-Version: 2.1.6
Precedence: list
List-Id: Oregon Bicycle Racing Association <obra.list.obra.org>
List-Unsubscribe: <http://list.obra.org/mailman/listinfo/obra>,
	<mailto:obra-request@list.obra.org?subject=unsubscribe>
List-Archive: <http://list.obra.org/mailing_lists/obra/posts>
List-Post: <mailto:obra@list.obra.org>
List-Help: <mailto:obra-request@list.obra.org?subject=help>
List-Subscribe: <http://list.obra.org/mailman/listinfo/obra>,
	<mailto:obra-request@list.obra.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============3071752892523701611=="
Sender: obra-bounces@list.obra.org
Errors-To: obra-bounces@list.obra.org
X-Virus-Scanned: amavisd-new at obra.org
X-Spam-Checker-Version: SpamAssassin 3.0.4 (2005-06-05) on 
	pavilion.cheryljwillson.com
X-Spam-Level: 
X-Spam-Status: No, score=-1.6 required=5.0 tests=AWL,BAYES_00,HTML_80_90,
	HTML_IMAGE_ONLY_08,HTML_MESSAGE autolearn=no version=3.0.4


--===============3071752892523701611==
Content-Type: multipart/alternative; boundary=Apple-Mail-1--907934883


--Apple-Mail-1--907934883
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=UTF-8;
	format=flowed

Rich text message with some formatting and a small attachment.

Check it out: http://www.google.com/

=EF=BF=BC=

--Apple-Mail-1--907934883
Content-Type: multipart/related;
	type="text/html";
	boundary=Apple-Mail-2--907934882


--Apple-Mail-2--907934882
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=ISO-8859-1

<HTML><BODY style=3D"word-wrap: break-word; -khtml-nbsp-mode: space; =
-khtml-line-break: after-white-space; "><SPAN =
class=3D"Apple-style-span">Rich text message with <I>some</I> formatting =
and a <FONT class=3D"Apple-style-span" face=3D"Geneva" size=3D"1"><SPAN =
class=3D"Apple-style-span" style=3D"font-size: 9px;">small</SPAN></FONT> =
attachment.<DIV><BR class=3D"khtml-block-placeholder"></DIV><DIV><SPAN =
class=3D"Apple-style-span"><FONT class=3D"Apple-style-span" =
color=3D"#17FF75"><B>Check it out</B></FONT>:=A0<A =
href=3D"http://www.google.com">http://www.google.com</A>/</SPAN></DIV><DIV=
><BR class=3D"khtml-block-placeholder"></DIV><DIV><IMG =
src=3D"cid:D95970D3-6194-410C-88D0-C87FE55B1657@local"></DIV></SPAN></BODY=
></HTML>=

--Apple-Mail-2--907934882
Content-Transfer-Encoding: base64
Content-Id: <D95970D3-6194-410C-88D0-C87FE55B1657@local>
Content-Type: image/gif;
	x-unix-mode=0666;
	name="mozart_res.gif"
Content-Disposition: inline;
	filename=mozart_res.gif

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
3MEeXBEBAQA7

--Apple-Mail-2--907934882--

--Apple-Mail-1--907934883--

--===============3071752892523701611==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
obra mailing list
obra@list.obra.org
http://list.obra.org/mailman/listinfo/obra

--===============3071752892523701611==--
}
  end
  
  def outlook_email
    %Q{Return-Path: <obra-bounces@list.obra.org>
X-Original-To: scott.willson@gmail.com
Delivered-To: scott.willson@gmail.com
Received: from list.obra.org (list.obra.org [69.30.32.118])
	by mail.cheryljwillson.com (Postfix) with ESMTP id B22A1143E3
	for <scott.willson@gmail.com>; Sat, 28 Jan 2006 07:24:38 -0800 (PST)
Received: from localhost (localhost [127.0.0.1])
	by list.obra.org (Postfix) with ESMTP id 59480145A5;
	Sat, 28 Jan 2006 07:25:12 -0800 (PST)
Received: from list.obra.org ([127.0.0.1])
 by localhost (lizard.obra.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 19838-07; Sat, 28 Jan 2006 07:25:11 -0800 (PST)
Received: from lizard.obra.org (localhost [127.0.0.1])
	by list.obra.org (Postfix) with ESMTP id 26D0110663;
	Sat, 28 Jan 2006 07:25:11 -0800 (PST)
X-Original-To: obra@list.obra.org
Delivered-To: obra@list.obra.org
Received: from localhost (localhost [127.0.0.1])
	by list.obra.org (Postfix) with ESMTP id 990341452A
	for <obra@list.obra.org>; Sat, 28 Jan 2006 07:25:10 -0800 (PST)
Received: from list.obra.org ([127.0.0.1])
	by localhost (lizard.obra.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 19831-07 for <obra@list.obra.org>;
	Sat, 28 Jan 2006 07:25:08 -0800 (PST)
Received: from mail.cheryljwillson.com (cheryljwillson.com [71.36.251.213])
	by list.obra.org (Postfix) with ESMTP id 458E910663
	for <obra@list.obra.org>; Sat, 28 Jan 2006 07:25:08 -0800 (PST)
Received: from bloodhound (unknown [192.168.1.151])
	by mail.cheryljwillson.com (Postfix) with ESMTP id 3ECBE4DA67
	for <obra@list.obra.org>; Sat, 28 Jan 2006 07:24:31 -0800 (PST)
Message-ID: <000d01c62420$0d11edb0$9701a8c0@bloodhound>
From: "Scott Willson" <scott.willson@gmail.com>
To: <obra@list.obra.org>
Date: Sat, 28 Jan 2006 07:28:31 -0800
MIME-Version: 1.0
X-Priority: 3
X-MSMail-Priority: Normal
X-Mailer: Microsoft Outlook Express 6.00.2800.1437
X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2800.1441
X-Virus-Scanned: amavisd-new at obra.org
Subject: [OBRA Chat] Stinky Outlook Email
X-BeenThere: obra@list.obra.org
X-Mailman-Version: 2.1.6
Precedence: list
List-Id: Oregon Bicycle Racing Association <obra.list.obra.org>
List-Unsubscribe: <http://list.obra.org/mailman/listinfo/obra>,
	<mailto:obra-request@list.obra.org?subject=unsubscribe>
List-Archive: <http://list.obra.org/mailing_lists/obra/posts>
List-Post: <mailto:obra@list.obra.org>
List-Help: <mailto:obra-request@list.obra.org?subject=help>
List-Subscribe: <http://list.obra.org/mailman/listinfo/obra>,
	<mailto:obra-request@list.obra.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============2945624954162623369=="
Sender: obra-bounces@list.obra.org
Errors-To: obra-bounces@list.obra.org
X-Virus-Scanned: amavisd-new at obra.org
X-Spam-Checker-Version: SpamAssassin 3.0.4 (2005-06-05) on 
	pavilion.cheryljwillson.com
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=5.0 tests=AWL,BAYES_00,HTML_80_90,
	HTML_MESSAGE autolearn=ham version=3.0.4

This is a multi-part message in MIME format.

--===============2945624954162623369==
Content-Type: multipart/related;
	type="multipart/alternative";
	boundary="----=_NextPart_000_0006_01C623DC.70B07E70"

This is a multi-part message in MIME format.

------=_NextPart_000_0006_01C623DC.70B07E70
Content-Type: multipart/alternative;
	boundary="----=_NextPart_001_0007_01C623DC.70B07E70"


------=_NextPart_001_0007_01C623DC.70B07E70
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hey, this is from Bloodhound in the basement.

http://RacingAssociation.current.static_host

I am the lonely, forgotten computer.

  1.. Where are my friends?
  Slugger
  2.. Lizard

Still loyal:
  Pavilion
------=_NextPart_001_0007_01C623DC.70B07E70
Content-Type: text/html;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=3DContent-Type content=3D"text/html; =
charset=3Diso-8859-1">
<META content=3D"MSHTML 6.00.2800.1491" name=3DGENERATOR>
<STYLE>BODY {
	MARGIN-TOP: 25px; FONT-SIZE: 10pt; MARGIN-LEFT: 15px; COLOR: #993300; =
FONT-FAMILY: Arial, Helvetica
}
</STYLE>
</HEAD>
<BODY background=3Dcid:000501c6241f$7ecda3f0$9701a8c0@bloodhound>
<DIV><FONT face=3DArial size=3D2>Hey, this is from =
<STRONG>Bloodhound</STRONG> in=20
the <FONT face=3D"Comic Sans MS">basement</FONT>.</FONT></DIV>
<DIV><FONT face=3DArial color=3D#000000 size=3D2></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000><A=20
href=3D"http://RacingAssociation.current.static_host">http://RacingAssociation.current.static_host</A></FONT></DIV>
<DIV><FONT color=3D#000000></FONT>&nbsp;</DIV>
<DIV><FONT face=3DArial size=3D2>I am the lonely, forgotten =
computer.</FONT></DIV>
<DIV>&nbsp;</DIV>
<OL>
  <LI><FONT color=3D#000000>Where are my friends?<BR>Slugger</FONT></LI>
  <LI><FONT color=3D#000000>Lizard</FONT></LI></OL>
<DIV><FONT color=3D#000000></FONT>&nbsp;</DIV>
<DIV><FONT color=3D#000000>Still loyal:</FONT></DIV>
<BLOCKQUOTE dir=3Dltr style=3D"MARGIN-RIGHT: 0px">
  <DIV><FONT =
color=3D#000000>Pavilion</FONT></DIV></BLOCKQUOTE></BODY></HTML>

------=_NextPart_001_0007_01C623DC.70B07E70--

------=_NextPart_000_0006_01C623DC.70B07E70
Content-Type: image/jpeg;
	name="Leaves Bkgrd.jpg"
Content-Transfer-Encoding: base64
Content-ID: <000501c6241f$7ecda3f0$9701a8c0@bloodhound>

/9j/4AAQSkZJRgABAgEASABIAAD/7QZAUGhvdG9zaG9wIDMuMAA4QklNA+0AAAAAABAASAAAAAEA
AQBIAAAAAQABOEJJTQPzAAAAAAAIAAAAAAAAAAA4QklNBAoAAAAAAAEAADhCSU0nEAAAAAAACgAB
AAAAAAAAAAI4QklNA/UAAAAAAEgAL2ZmAAEAbGZmAAYAAAAAAAEAL2ZmAAEAoZmaAAYAAAAAAAEA
MgAAAAEAWgAAAAYAAAAAAAEANQAAAAEALQAAAAYAAAAAAAE4QklNA/gAAAAAAHAAAP//////////
//////////////////8D6AAAAAD/////////////////////////////A+gAAAAA////////////
/////////////////wPoAAAAAP////////////////////////////8D6AAAOEJJTQQIAAAAAAAQ
AAAAAQAAAkAAAAJAAAAAADhCSU0ECQAAAAAEzwAAAAEAAACAAAAAgAAAAYAAAMAAAAAEswAYAAH/
2P/gABBKRklGAAECAQBIAEgAAP/+ACdGaWxlIHdyaXR0ZW4gYnkgQWRvYmUgUGhvdG9zaG9wqCA0
LjAA/+4ADkFkb2JlAGSAAAAAAf/bAIQADAgICAkIDAkJDBELCgsRFQ8MDA8VGBMTFRMTGBEMDAwM
DAwRDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAENCwsNDg0QDg4QFA4ODhQUDg4ODhQRDAwM
DAwREQwMDAwMDBEMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwM/8AAEQgAgACAAwEiAAIRAQMR
Af/dAAQACP/EAT8AAAEFAQEBAQEBAAAAAAAAAAMAAQIEBQYHCAkKCwEAAQUBAQEBAQEAAAAAAAAA
AQACAwQFBgcICQoLEAABBAEDAgQCBQcGCAUDDDMBAAIRAwQhEjEFQVFhEyJxgTIGFJGhsUIjJBVS
wWIzNHKC0UMHJZJT8OHxY3M1FqKygyZEk1RkRcKjdDYX0lXiZfKzhMPTdePzRieUpIW0lcTU5PSl
tcXV5fVWZnaGlqa2xtbm9jdHV2d3h5ent8fX5/cRAAICAQIEBAMEBQYHBwYFNQEAAhEDITESBEFR
YXEiEwUygZEUobFCI8FS0fAzJGLhcoKSQ1MVY3M08SUGFqKygwcmNcLSRJNUoxdkRVU2dGXi8rOE
w9N14/NGlKSFtJXE1OT0pbXF1eX1VmZ2hpamtsbW5vYnN0dXZ3eHl6e3x//aAAwDAQACEQMRAD8A
6/v5hJJLhPYlA/glwklMpKVolP3pp7p++iSldvNKR3+SRS8klK+SU+CRSSUrv5JSOEo7pT2SUpKN
EpMeJSJSUr4pJdkvjykp/9Dr+QkJIShKQT8E9iUEvJJLVJStfmkPw8UvglOsH70lK+PCUd0hwl8U
lK8kvhwEvNL4JKUSkEtOEklKjxS0S58vNIpKUlB+SUa6duUoSU//0evTd0/YjhL569k9iUUkktJ8
0lKSBKR5S5SUrRLVIeSY68d0lL9vimGif+KXkkpWiXhHzS4S1RUoifIJaBKdPJL4oKV5/elOmiXw
SnXQpKf/0uv14SOqQ8PuSPMp7EpLulKRn5JKUkPvT88pu89+ySlJQAl/rCRjg/JJS3h+Cf8AIkkf
E/gkpXKQ8kvuSmPJJStO6RSS/KkpXhPdJKfH5JJKf//T69LjQpf6yl+RPYlf6hLzSB/3JdklK8+3
glz/ABKSUapKVPilx/sSB8PklISUqNP70vxCRSSUrRJKI80vNJSu6RS5S0+SSlJcaH70pCUJKf/U
6/4JDwS+CXKexK+KRMJaz8Eo7JKV3SidTwkkQkpRPyS7pSEklK5SS8+6SSla8pJtDpx5J0lLaJz/
ALwl240SJhJSo1+HZL8qXmlqR8UlP//V67wP4JylH3pTrHfunsSkuPNL8vZLySUrlJNyU6SlJdpS
Snx7d0lK158UvMfclyNO6XCSlHRIJfxSSUpIpJQkpQ1SS1kSkkp//9br5180pHZKUpjT8U9iVyUu
2iXxCWqSldvBJLTsUuP4pKV2SA/2Jo08E6SlTokEuNEklKmEkw5TwOUlK8kkvwKRSUqfx4TpkuNB
80lP/9kAOEJJTQQGAAAAAAAHAAMBAQABAQD//gAnRmlsZSB3cml0dGVuIGJ5IEFkb2JlIFBob3Rv
c2hvcKggNC4wAP/uACFBZG9iZQBkAAAAAAEDABADAgMGAAAAAAAAAAAAAAAA/9sAhAAKBwcHCAcK
CAgKDwoICg8SDQoKDRIUEBASEBAUEQwMDAwMDBEMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwM
AQsMDBUTFSIYGCIUDg4OFBQODg4OFBEMDAwMDBERDAwMDAwMEQwMDAwMDAwMDAwMDAwMDAwMDAwM
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

------=_NextPart_000_0006_01C623DC.70B07E70--


--===============2945624954162623369==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
obra mailing list
obra@list.obra.org
http://list.obra.org/mailman/listinfo/obra

--===============2945624954162623369==--
}
  end
  
  def html_email
    %{Return-Path: <obra-bounces@list.obra.org>
X-Original-To: scott.willson@gmail.com
Delivered-To: scott.willson@gmail.com
Received: from list.obra.org (list.obra.org [69.30.32.118])
	by mail.cheryljwillson.com (Postfix) with ESMTP id 01FB84824D
	for <scott.willson@gmail.com>; Sat, 28 Jan 2006 10:11:15 -0800 (PST)
Received: from localhost (localhost [127.0.0.1])
	by list.obra.org (Postfix) with ESMTP id 3923214796;
	Sat, 28 Jan 2006 10:11:49 -0800 (PST)
Received: from list.obra.org ([127.0.0.1])
 by localhost (lizard.obra.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 19838-08; Sat, 28 Jan 2006 10:11:48 -0800 (PST)
Received: from lizard.obra.org (localhost [127.0.0.1])
	by list.obra.org (Postfix) with ESMTP id 47C981452A;
	Sat, 28 Jan 2006 10:11:48 -0800 (PST)
X-Original-To: obra@list.obra.org
Delivered-To: obra@list.obra.org
Received: from localhost (localhost [127.0.0.1])
	by list.obra.org (Postfix) with ESMTP id E5ECC1452A
	for <obra@list.obra.org>; Sat, 28 Jan 2006 10:11:46 -0800 (PST)
Received: from list.obra.org ([127.0.0.1])
	by localhost (lizard.obra.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 19831-08 for <obra@list.obra.org>;
	Sat, 28 Jan 2006 10:11:42 -0800 (PST)
Received: from mail.cheryljwillson.com (cheryljwillson.com [71.36.251.213])
	by list.obra.org (Postfix) with ESMTP id D1E4B10663
	for <obra@list.obra.org>; Sat, 28 Jan 2006 10:11:42 -0800 (PST)
Received: from [192.168.1.151] (cheryljwillson.com [71.36.251.213])
	by mail.cheryljwillson.com (Postfix) with ESMTP id 33E184824D
	for <obra@list.obra.org>; Sat, 28 Jan 2006 10:11:07 -0800 (PST)
Message-ID: <43DBB598.8070102@butlerpress.com>
Date: Sat, 28 Jan 2006 10:19:04 -0800
From: Scott Willson <scott.willson@gmail.com>
Person-Agent: Mozilla Thunderbird 0.8 (Windows/20040913)
X-Accept-Language: en-us, en
MIME-Version: 1.0
To: obra@list.obra.org
X-Virus-Scanned: amavisd-new at obra.org
Subject: [OBRA Chat] Thunderbird HTML
X-BeenThere: obra@list.obra.org
X-Mailman-Version: 2.1.6
Precedence: list
Reply-To: scott.willson@gmail.com
List-Id: Oregon Bicycle Racing Association <obra.list.obra.org>
List-Unsubscribe: <http://list.obra.org/mailman/listinfo/obra>,
	<mailto:obra-request@list.obra.org?subject=unsubscribe>
List-Archive: <http://list.obra.org/mailing_lists/obra/posts>
List-Post: <mailto:obra@list.obra.org>
List-Help: <mailto:obra-request@list.obra.org?subject=help>
List-Subscribe: <http://list.obra.org/mailman/listinfo/obra>,
	<mailto:obra-request@list.obra.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============0933973879519531489=="
Sender: obra-bounces@list.obra.org
Errors-To: obra-bounces@list.obra.org
X-Virus-Scanned: amavisd-new at obra.org
X-Spam-Checker-Version: SpamAssassin 3.0.4 (2005-06-05) on 
	pavilion.cheryljwillson.com
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=5.0 tests=AWL,BAYES_00,HTML_90_100,
	HTML_MESSAGE,HTML_TAG_EXIST_TBODY autolearn=no version=3.0.4

--===============0933973879519531489==
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" text="#000000">
<h3>Race Results</h3>
<table border="1" cellpadding="2" cellspacing="2" width="100%">
  <tbody>
    <tr>
      <td valign="top"><b>Place<br>
      </b></td>
      <td valign="top"><b>Person<br>
      </b></td>
    </tr>
    <tr>
      <td valign="top">1<br>
      </td>
      <td valign="top">Ian Leitheiser<br>
      </td>
    </tr>
    <tr>
      <td valign="top">2<br>
      </td>
      <td valign="top">Kevin Condron<br>
      </td>
    </tr>
  </tbody>
</table>
<br>
</body>
</html>

--===============0933973879519531489==
}
  end
end
