# Copyright (c) 2004 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::RAI::Item - an interface to the item elements in a RSS feed.
# 

package XML::RAI::Item;

use strict;
use XML::RAI::Object;

use vars qw(@ISA $XMap);
@ISA = qw( XML::RAI::Object );

$XMap = {
    content=>['xhtml:body','content:encoded','description','dc:description','rss091:description'],
    contentstrict=>['xhtml:body','content:encoded'],
    created=>['dcterms:created','dc:date','pubDate','rss091:pubDate','/channel/lastBuildDate','/channel/rss091:lastBuildDate'],
    creator=>['dc:creator','author'],
    language=>['@xml:lang','dc:language','/@xml:lang','/channel/dc:language','/channel/language','/channel/rss091:language'],
    valid=>['dcterms:valid','expirationDate'],
    relation=>['dc:relation','trackback:about/@rdf:resource','trackback:about'],
    identifier=>['dc:identifier/@rdf:resource','dc:identifier','guid','link'],
    abstract=>['dcterms:abstract','description','dc:description'],
    ping=>['trackback:ping/@rdf:resource','trackback:ping'],
    title=>['title','dc:title'],
    'link'=>['link','@rdf:about','guid[@isPermalink="true"]'],
    description=>['description','dc:description','dcterms:abstract'],
    subject=>['dc:subject','category'],
    publisher=>['dc:publisher','/channel/dc:publisher','/channel/managingEditor'],
    contributor=>['dc:contributor'],
    modified=>['dcterms:modified','dc:date','pubDate','rss091:pubDate'],
    issued=>['dcterms:issued','dc:date','pubDate','rss091:pubDate','/channel/lastBuildDate','/channel/rss091:lastBuildDate'],
    source=>['dc:source','source','/channel/title'],
    rights=>['dc:rights','/channel/copyright','/channel/creativeCommons:license','/channel/rss091:copyright'],
    type=>['dc:type'],
    'format'=>['dc:format'],
    coverage=>['dc:coverage'],
    creator=>['dc:creator'],
};

1;

__END__

=begin

=head1 NAME

XML::RAI::Item - An interface to the item elements of a RSS feed.

=head1 DESCRIPTION

A subclass of L<XML::RAI::Object>, XML::RAI::Item handles the
mapping function and retrieval of RSS item elements.

=head1 METHODS

=item $item->source

Returns the L<XML::RSS::Parser::Element> that the object is using
as its source.

=item $item->parent

Returns the parent of the RAI object.

=head2 META DATA ACCESSORS

These accessor methods attempt to retrieve meta data from the
source L<XML::RSS::Parser> element by checking a list of potential
tag names until one returns a value.  They are generally based on
Dublin Core terminology and RSS elements that are common across the
many formats. If called in a SCALAR context, the value of the first
element of the tag being matched is returned. If called in an ARRAY
context it will return all of the values to the tag being matched
-- it does not return all of the values for all of the tags that
have been mapped to the method. (Note that some mappings only allow
one value to be returned.) Returns C<undef> if nothing could be
found.

The following are the tags (listed in XPath notation) mapped to
each method and the order in which they are checked.

=item $item->abstract

=over 4

=item * dcterms:abstract

=item * description

=item * dc:description

=back

=item $item->content

=over 4

=item * xhtml:body

=item * content:encoded

=item * description

=item * dc:description

=item * rss091:description

=back

=item $item->contentstrict

=over 4

=item * xhtml:body

=item * content:encoded

=back

=item $item->contributor

=over 4

=item * dc:contributor

=back

=item $item->coverage

=over 4

=item * dc:coverage

=back

=item $item->created

=over 4

=item * dcterms:created

=item * dc:date

=item * pubDate

=item * rss091:pubDate

=item * /channel/lastBuildDate

=item * /channel/rss091:lastBuildDate

=back

=item $item->creator

=over 4

=item * dc:creator

=back

=item $item->description

=over 4

=item * description

=item * dc:description

=item * dcterms:abstract

=back

=item $item->format

=over 4

=item * dc:format

=back

=item $item->identifier

=over 4

=item * dc:identifier/@rdf:resource

=item * dc:identifier

=item * guid

=item * link

=back

=item $item->issued

=over 4

=item * dcterms:issued

=item * dc:date

=item * pubDate

=item * rss091:pubDate

=item * /channel/lastBuildDate

=item * /channel/rss091:lastBuildDate

=back

=item $item->language

=over 4

=item * @xml:lang

=item * dc:language

=item * /@xml:lang

=item * /channel/dc:language

=item * /channel/language

=item * /channel/rss091:language

=back

=item $item->link

=over 4

=item * link

=item * @rdf:about

=item * guid[@isPermalink="true"]

=back

=item $item->modified

=over 4

=item * dcterms:modified

=item * dc:date

=item * pubDate

=item * rss091:pubDate

=back

=item $item->ping

=over 4

=item * trackback:ping/@rdf:resource

=item * trackback:ping

=back

=item $item->publisher

=over 4

=item * dc:publisher

=item * /channel/dc:publisher

=item * /channel/managingEditor

=back

=item $item->relation

=over 4

=item * dc:relation

=item * trackback:about/@rdf:resource

=item * trackback:about

=back

=item $item->rights

=over 4

=item * dc:rights

=item * /channel/copyright

=item * /channel/creativeCommons:license

=item * /channel/rss091:copyright

=back

=item $item->source

=over 4

=item * dc:source

=item * source

=item * /channel/title

=back

=item $item->subject

=over 4

=item * dc:subject

=item * category

=back

=item $item->title

=over 4

=item * title

=item * dc:title

=back

=item $item->type

=over 4

=item * dc:type

=back

=item $item->valid

=over 4

=item * dcterms:valid

=item * expirationDate

=back

=head1 AUTHOR & COPYRIGHT

Please see the XML::RAI manpage for author, copyright, and license
information.

=cut

=end