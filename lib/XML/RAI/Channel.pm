# Copyright (c) 2004 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::RAI::Channel - An interface to the channel elements of a RSS feed.
# 

package XML::RAI::Channel;

use strict;
use XML::RAI::Object;

use vars qw(@ISA $XMap);
@ISA = qw( XML::RAI::Object );

use XML::RAI;

BEGIN {
    my $channel_map = {
        generator=>['/channel/admin:generatorAgent','/channel/generator'],
        maintainer=>['/channel/admin:errorReportsTo','/channel/webMaster']
    };
    my $xmap = \%{$XML::RAI::Shared_map};
    while (my($k,$v) = each %$channel_map) {
        $xmap->{$k} = [] unless $xmap->{$k};
        push(@{$xmap->{$k}}, @$v);
    }
    $XML::RAI::Channel::XMap = $xmap;
}

1;

__END__

=begin

=head1 NAME

XML::RAI::Channel - An interface to the channel elements of a RSS feed.

=head1 DESCRIPTION

A subclass of L<XML::RAI::Object>, XML::RAI::Channel handles the mapping 
function and retrieval of RSS channel elements.

=head1 METHODS

=item $channel->source

Returns the L<XML::RSS::Parser::Element> that the object is using as 
its source.

=item $channel->parent

Returns the parent of the RAI object.

=head2 META DATA ACCESSORS

These accessor methods attempt to retrieve meta data from the 
source L<XML::RSS::Parser> element by checking a list of potential 
tag names until one returns a value.  They are generally based on 
Dublin Core terminology and RSS elements that are common across 
the many formats. If called in a SCALAR context, the value of the 
first element of the tag being matched is returned. If called in 
an ARRAY context it will return all of the values to the tag being 
matched -- it does not return all of the values for all of the tags 
that have been mapped to the method. (Note that some mappings only 
allow one value to be returned.) Returns C<undef> if nothing could 
be found. 

The following are the tags (listed in XPath notation) mapped to 
each method and the order in which they are checked.

=item $channel->contributor

=over 4

=item dc:contributor

=back

=item $channel->coverage

=over 4

=item dc:coverage

=back

=item $channel->creator

=over 4

=item dc:creator

=back

=item $channel->description

=over 4

=item description

=item dc:description

=item dcterms:abstract

=back

=item $channel->format

=over 4

=item dc:format

=back

=item $channel->generator

=over 4

=item /channel/admin:generatorAgent

=item /channel/generator

=back

=item $channel->identifier

=over 4

=item dc:identifier

=back

=item $channel->issued

=over 4

=item dc:date

=item pubDate

=item rss091:pubDate

=item /channel/lastBuildDate

=item /channel/rss091:lastBuildDate

=back

=item $channel->language

=over 4

=item dc:language

=item /channel/dc:language

=item /channel/language

=item /channel/rss091:language

=back

=item $channel->link

=over 4

=item link

=item @rdf:about

=item guid[@isPermalink="true"]

=back

=item $channel->maintainer

=over 4

=item /channel/admin:errorReportsTo

=item /channel/webMaster

=back

=item $channel->modified

=over 4

=item dcterms:modified

=back

=item $channel->publisher

=over 4

=item dc:publisher

=item /channel/dc:publisher

=item /channel/managingEditor

=back

=item $channel->relation

=over 4

=item dc:relation

=back

=item $channel->rights

=over 4

=item dc:rights

=item /channel/copyright

=item /channel/creativeCommons:license

=item /channel/rss091:copyright

=back

=item $channel->source

=over 4

=item dc:source

=item source

=item /channel/title

=back

=item $channel->subject

=over 4

=item dc:subject

=item category

=back

=item $channel->title

=over 4

=item title

=item dc:title

=back

=item $channel->type

=over 4

=item dc:type

=back

=item $channel->valid

=over 4

=item dcterms:valid

=back

=head1 AUTHOR & COPYRIGHT

Please see the XML::RAI manpage for author, copyright, and license information.

=cut

=end