# Copyright (c) 2004 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::RAI - RSS Abstraction Interface. 
# 

package XML::RAI;

use strict;

use vars qw($VERSION);
$VERSION = 0.3;

use XML::RSS::Parser 2.1;
use XML::RAI::Channel;
use XML::RAI::Item;
use XML::RAI::Image;

use constant W3CDTF => '%Y-%m-%dT%H:%M:%S%z'; # AKA...
use constant RFC8601 => W3CDTF;
use constant RFC822 => '%a, %d %b %G %T %Z';
use constant PASS_THRU => '';

my $parser;

sub new { 
    my $class = shift;
    my $doc;
    unless (ref($_[0]) eq 'XML::RSS::Parser::Feed') {
        my($method,$r)=@_;
        my $p = $parser ? $parser : XML::RSS::Parser->new(); 
        $doc = $p->$method($r);
    } else { $doc = shift; }
    my $self = bless { }, $class;
    $self->{__doc} = $doc;
    $self->{__channel} = XML::RAI::Channel->new($doc->channel,$self);
    $self->{__items} = [ 
        map { XML::RAI::Item->new($_,$self->{__channel}) }
            $doc->items ];
    $self->{__image} = XML::RAI::Image->new($doc->image,$self->{__channel})
        if $doc->image;
    $self->{__timef} = W3CDTF;
    $self;
}

sub time_format { $_[0]->{__timef}=$_[1] if $_[1]; $_[0]->{__timef}; }
sub parse { my $class = shift; $class->new('parse',@_); }
sub parsefile { my $class = shift; $class->new('parsefile',@_); }
sub document { $_[0]->{__doc}; }
sub channel { $_[0]->{__channel}; }
sub items { $_[0]->{__items}; }
sub item_count { $#{$_[0]->{__items}}; }
sub image { $_[0]->{__image}; }

1;

__END__

=begin

=head1 NAME

XML::RAI - RSS Abstraction Interface. An object-oriented layer that
maps overlapping and alternate tags in RSS to one common simplified
interface.

=head1 SYNOPSIS

 #!/usr/bin/perl -w
 use strict;
 use XML::RAI;
 my $doc = <<DOC;
 <?xml version="1.0" encoding="iso-8859-1"?>
 <rss xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns="http://purl.org/rss/1.0/">
     <channel>
         <title>tima thinking outloud</title>
         <link>http://www.timaoutloud.org/</link>
         <description></description>
         <dc:language>en-us</dc:language>
         <item>
             <title>His and Hers Weblogs.</title>
             <description>First it was his and hers Powerbooks. Now 
             its weblogs. There goes the neighborhood.</description>
             <link>http://www.timaoutloud.org/archives/000338.html</link>
             <dc:subject>Musings</dc:subject>
             <dc:creator>tima</dc:creator>
             <dc:date>2004-01-23T12:33:22-05:00</dc:date>
         </item>
         <item>
             <title>Commercial Music Again.</title>
             <description>Last year I made a post about music used 
             in TV commercials that I recognized and have been listening to. 
             For all the posts I made about technology and other bits of sagely
             wisdom the one on commercial music got the most traffic of any 
             each month. I need a new top post. Here are some more tunes that 
             have appeared in commercials.</description>
             <guid isPermalink="true">
               http://www.timaoutloud.org/archives/000337.html
             </guid>
             <category>Musings</category>
             <author>tima</author>
             <pubDate>Sun, 18 Jan 2004 14:09:03 GMT</pubDate>
         </item>
     </channel>
 </rss>
 DOC

 # The above is to demonstrate the value of RAI. It is not any 
 # specific RSS format, nor does it exercise best practices.

 my $rai = XML::RAI->parse($doc);
 print $rai->channel->title."\n\n";
 foreach my $item ( @{$rai->items} ) {
    print $item->title."\n";
    print $item->link."\n";
    print $item->content."\n";
    print $item->issued."\n\n";
 }

=head1 DESCRIPTION

The RSS Abstraction Interface, or RAI (said "ray"), provides an
object-oriented interface to XML::RSS::Parser trees that abstracts
the user from handling namespaces, overlapping and alternate tag
mappings.

It's rather well known that, while popular, the RSS syntax is a bit
of a mess. Anyone who has attempted to write software that consumes
RSS feeds "in the wild" can attest to the headaches in handling the
many formats and interpretations that are in use. For instance, in
"The myth of RSS compatibility"
L<http://diveintomark.org/archives/2004/02/04/incompatible-rss>
Mark Pilgrim identifies 9 different versions of RSS (there are 10
actually**) and that is not without going into tags with
overlapping purposes. Even the acronym RSS has multiple though
similar meanings.

The L<XML::RSS::Parser> attempts to help developers cope with these
issues through a liberal interpretation of what is RSS and routines
to normalize the parse tree into a more common and manageable form.

RAI takes this one step further. Its intent is to give a developer
the means to not have to care about what tags the feed uses to
present its meta data.

RAI provides a single simplified interface that maps one method
call to various overlapping and alternate tags used in RSS feeds.
The interface also abstracts developers from needing to deal with
namespaces. Method names are based on Dublin Core terminology.

** - When initially released, RSS 2.0 had a namespace. When it was
reported a few days later that some XSLT-based systems were
breaking because of the change in the RSS namespace from "" (none)
to http://backend.userland.com/rss2, the namespace was removed, but
the version number was not incremented making it incompatible with
itself. L<http://groups.yahoo.com/group/rss-dev/message/4113> This
version was not counted in Mark's post.

=head1 METHODS

=item XML::RAI->new($rss_tree)

Returns a populated RAI instance based on the 
L<XML::RSS::Parser::Feed> object passed in.

=item XML::RAI->parse($string_or_file_handle)

Passes through the string or file handle to the C<parse> method in
L<XML::RSS::Parser>. Returns a populated RAI instance.

=item XML::RAI->parsefile(FILE_HANDLE)

Passes through the file handle to the C<parsefile> method in
L<XML::RSS::Parser>. Returns a populated RAI instance.

=item $rai->document

Returns the L<XML::RSS::Parser> parse tree being used as the source
for the RAI object

=item $rai->channel

Returns the L<XML::RAI::Channel> object.

=item $rai->items

Returns an array reference containing the L<XML::RAI::Item> objects
for the feed

=item $rai->item_count

Returns the number of items as an integer.

=item $rai->image

Returns the L<XML::RAI::Image> object, if any. (Many feeds do not
have an image block.)

=item $rai->time_format($timef)

Sets the timestamp normalization format. RAI will attempt to parse 

RAI implements a few
constants with common RSS timestamp formatting strings:

 W3CDTF     1999-09-01T22:10:40Z 
 RFC8601    (other name for W3CDTF)
 RFC822     Wed, 01 Sep 1999 22:10:40 GMT 
 PASS_THRU  (does not normalize)

W3CDTF/RFC8601 is the default. For more detail on creating your own
timestamp formats see the manpage for the C<strftime> command.

=head1 DEPENDENCIES

L<XML::RSS::Parser>, L<POSIX>, L<Date::Parse>

=head1 TO DO

=item * Expand and refine mappings.

=item * Serialization module(s).

=item * Implement "greedy" switch were search continues to the end
of the mappings even if one tag exists.

=item * Implement a UNIX constant and functionality for
C<time_format>.

=head1 LICENSE

The software is released under the Artistic License. The terms of
the Artistic License are described at
L<http://www.perl.com/language/misc/Artistic.html>.

=head1 AUTHOR & COPYRIGHT

Except where otherwise noted, XML::RAI is Copyright 2004,
Timothy Appnel, cpan@timaoutloud.org. All rights reserved.

=cut

=end