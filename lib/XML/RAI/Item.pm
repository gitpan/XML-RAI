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
    'format'=>['dc:format'],
    #'link'=>['link','@rdf:about','guid[@isPermaLink="true"]'], # use special handler.
    abstract=>['dcterms:abstract','description','dc:description'],
    content_strict=>['xhtml:body','xhtml:div','content:encoded'],
    content=>['xhtml:body','xhtml:div','content:encoded','description','dc:description','rss091:description'],
    contentstrict=>['xhtml:body','xhtml:div','content:encoded'], # deprecated
    contributor=>['dc:contributor'],
    coverage=>['dc:coverage'],
    created_strict=>['dcterms:created'],
    created=>['dcterms:created','dc:date','pubDate','rss091:pubDate','/channel/lastBuildDate','/channel/rss091:lastBuildDate'],
    creator=>['dc:creator','author'],
    description=>['description','dc:description','dcterms:abstract'],
    identifier=>['dc:identifier/@rdf:resource','dc:identifier','guid','link'],
    issued_strict=>['dcterms:issued'],
    issued=>['dcterms:issued','dc:date','pubDate','rss091:pubDate','/channel/lastBuildDate','/channel/rss091:lastBuildDate'],
    language=>['@xml:lang','dc:language','/@xml:lang','/channel/dc:language','/channel/language','/channel/rss091:language'],
    modified_strict=>['dcterms:modified'],
    modified=>['dcterms:modified','dc:date','pubDate','rss091:pubDate'],
    ping=>['trackback:ping/@rdf:resource','trackback:ping'],
    pinged=>['trackback:about/@rdf:resource','trackback:about'],
    publisher=>['dc:publisher','/channel/dc:publisher','/channel/managingEditor'],
    relation=>['dc:relation/@rdf:resource','dc:relation'],
    rights=>['dc:rights','/channel/copyright','/channel/creativeCommons:license','/channel/rss091:copyright'],
    source=>['dc:source','source'],
    subject=>['dc:subject','category'],
    title=>['title','dc:title'],
    type=>['dc:type'],
    valid=>['dcterms:valid','expirationDate']
};

# Class::XPath is missing some functionality we need here so we 
# help it along.
sub link {
    my $this = shift;
    my @nodes;
    # awkward use, but achieves the effect we need.
    if (@nodes = $this->source->query('link')) { } 
    elsif (@nodes = $this->source->query('@rdf:about')) { } 
    elsif (@nodes = grep { 
                ! $_->attributes ||
                    ( ! $_->attributes->{isPermaLink} ||
                        $_->attributes->{isPermaLink} eq 'true')
                            } $this->source->query('guid')) { } 
    elsif (@nodes = grep { 
                $_->attributes->{type} =~m!^(text/html|application/xhtml+xml)$! 
                    } $this->source->query('l:link[@rel="permalink"]') ) { } 
    elsif (@nodes = $this->source->query('comment') ) { }
    wantarray ? @nodes : 
                ref($nodes[0]) ? $nodes[0]->value : $nodes[0]; 
}

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

=item * xhtml:div

=item * content:encoded

=item * description

=item * dc:description

=item * rss091:description

=back

=item $item->content_strict

=over 4

=item * xhtml:body

=item * xhtml:div

=item * content:encoded

=item * description/@type="text/html"

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

=item $item->created

=over 4

=item * dcterms:created

=back

=item $item->creator

=over 4

=item * dc:creator

=item * author

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

=item $item->issued_strict

=over 4

=item * dcterms:issued

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

=item * guid[@isPermaLink="true"]

=back

=item $item->modified

=over 4

=item * dcterms:modified

=item * dc:date

=item * pubDate

=item * rss091:pubDate

=back

=item $item->modified_strict

=over 4

=item * dcterms:modified

=back

=item $item->ping

=over 4

=item * trackback:ping/@rdf:resource

=item * trackback:ping

=back

=item $item->pinged

=over 4

=item * trackback:about/@rdf:resource

=item * trackback:about

=back

=item $item->publisher

=over 4

=item * dc:publisher

=item * /channel/dc:publisher

=item * /channel/managingEditor

=back

=item $item->relation

=over 4

=item * dc:relation/@rdf:resource

=item * dc:relation

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