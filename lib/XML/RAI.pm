# Copyright (c) 2003-4 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::RAI - RSS Abstraction Interface. 
# 

package XML::RAI;

use strict;

use vars qw($VERSION $Shared_map);
$VERSION = 0.1;

BEGIN {
    $Shared_map = { # shared channel and item mappings
        title=>['title','dc:title'],
        'link'=>['link','@rdf:about','guid[@isPermalink="true"]'],
        description=>['description','dc:description','dcterms:abstract'],
        subject=>['dc:subject','category'],
        language=>['dc:language','/channel/dc:language','/channel/language','/channel/rss091:language'],
        publisher=>['dc:publisher','/channel/dc:publisher','/channel/managingEditor'],
        contributor=>['dc:contributor'],
        issued=>['dc:date','pubDate','rss091:pubDate','/channel/lastBuildDate','/channel/rss091:lastBuildDate'],
        modified=>['dcterms:modified'],
        source=>['dc:source','source','/channel/title'],
        rights=>['dc:rights','/channel/copyright','/channel/creativeCommons:license','/channel/rss091:copyright'],
        type=>['dc:type'],
        'format'=>['dc:format'],
        relation=>['dc:relation'],
        coverage=>['dc:coverage'],
        valid=>['dcterms:valid'],
        creator=>['dc:creator'],
        identifier=>['dc:identifier']
    };
}

use XML::RSS::Parser 2.1;
use XML::RAI::Channel;
use XML::RAI::Item;
use XML::RAI::Image;

my $parser;

sub new { 
    my($class,$method,$r)=@_;
    my $p = $parser ? $parser : XML::RSS::Parser->new(); 
    my $self = bless { }, $class;
    my $doc = $p->$method($r);
    $self->{__doc} = $doc;
    $self->{__channel} = XML::RAI::Channel->new($doc->channel);
    $self->{__items} = [ 
        map { XML::RAI::Item->new($_,$self->{__channel}) }
            $doc->items ];
    $self->{__image} = XML::RAI::Image->new($doc->image,$self->{__channel})
        if $doc->image;
    $self;
}

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

XML::RAI - RSS Abstraction Interface. An OO interface to XML::RSS::Parser 
trees that abstracts the user from handling namespaces, overlapping 
and alternate tag mappings that is common in the RSS space.

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
             <pubDate>2004-01-18T14:09:03-05:00</pubDate>
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
    print $item->content."\n\n";
 }

=head1 DESCRIPTION

The RSS Abstraction Interface, or RAI (said "ray"), provides an 
object-oriented  interface to XML::RSS::Parser trees that abstracts 
the user from handling namespaces, overlapping and alternate tag 
mappings.

It's rather well known that, while popular, the RSS syntax is a bit 
of a mess. Anyone who has attempted to write software that consumes 
RSS feeds "in the wild" can attest to the headaches in handling the 
many formats and interpretations that are in use. (For instance, 
in "The myth of RSS compatibility" 
L<http://diveintomark.org/archives/2004/02/04/incompatible-rss> 
Mark Pilgrim identifies 9 different versions of RSS (there are 
10 actually**) and that is not without going into tags with overlapping 
purposes. Even the acronym RSS has multiple though similar meanings.

The L<XML::RSS::Parser> attempts to help developers cope with these
issues through a liberal interpretation of what is RSS and routines 
to normalize the parse tree into a more common and manageable form.

RAI takes this one step further. Its intent is to give a developer 
the means to not have to care about what tags the feed uses to 
present its meta data. 

RAI provides a single simplified interface that maps one method call 
to various overlapping and alternate tags used in RSS feeds. The 
interface also abstracts developers from needing to deal with 
namespaces. Method names are based on Dublin Core terminology.

** - When initially released, RSS 2.0 had a namespace. When it was 
reported a few days later that some XSLT-based systems were breaking
because of the change in the RSS namespace from "" (none) to 
http://backend.userland.com/rss2, the namespace was removed, but
the version number was not incremented making it incompatible with 
itself. L<http://groups.yahoo.com/group/rss-dev/message/4113> This 
version was not counted in Mark's post.

=head1 DEPENDENCIES

L<XML::RSS::Parser>

=head1 TO DO

=item * Expand and refine mappings.

=item * Timestamp conversion/normalization functionality.

=item * Serialization module(s).

=head1 LICENSE

The software is released under the Artistic License. The terms of the 
Artistic License are described at L<http://www.perl.com/language/misc/Artistic.html>.

=head1 AUTHOR & COPYRIGHT

Except where otherwise noted, XML::RAI is Copyright 2003-4, 
Timothy Appnel, cpan@timaoutloud.org. All rights reserved.

=cut

=end