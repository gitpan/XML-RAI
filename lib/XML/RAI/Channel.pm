# Copyright (c) 2004-2005 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::RAI::Channel - an interface to the channel elements of a RSS feed.
# 

package XML::RAI::Channel;

use strict;
use XML::RAI::Object;

use vars qw(@ISA $XMap);
@ISA = qw( XML::RAI::Object );

use XML::RAI;

$XMap = {
    'format'=>['dc:format'],
    # 'link'=>['link','@rdf:about'], #special handler
    contributor=>['dc:contributor'],
    coverage=>['dc:coverage'],
    creator=>['dc:creator'],
    description=>['description','dc:description','dcterms:abstract','dcterms:alternative'],
    generator=>['admin:generatorAgent','generator'],
    identifier=>['dc:identifier'],
    issued_strict=>['dcterms:issued'],
    issued=>['dcterms:issued','dc:date','lastBuildDate','rss091:lastBuildDate'],
    language=>['@xml:lang','dc:language','language','rss091:language'],
    maintainer=>['admin:errorReportsTo','webMaster'],
    modified_strict=>['dcterms:modified'],
    modified=>['dc:terms:modified','dc:date','lastBuildDate','rss091:lastBuildDate',],
    publisher=>['dc:publisher','managingEditor'],
    relation=>['dc:relation/@rdf:resource','dc:relation'],
    rights=>['dc:rights','copyright','creativeCommons:license','rss091:copyright'],
    source=>['dc:source','source','title'],
    subject=>['dc:subject','category'],
    title=>['title','dc:title'],
    type=>['dc:type'],
    valid=>['dcterms:valid'],
};

# Class::XPath is missing some functionality we need here so we 
# help it along.
sub link {
    my $this = shift;
    my @nodes;
    # awkward use, but achieves the effect we need.
    if (@nodes = $this->source->query('link')) {} 
    elsif (@nodes = grep { 
                $_->attributes->{type} =~m!^(text/html|application/xhtml+xml)$! 
                    } $this->source->query('l:link[@rel="permalink"]') ) {} 
    elsif ( @nodes = $this->source->query('dc:relation/@rdf:resource') ) {}
    elsif ( @nodes = $this->source->query('dc:relation') ) {}
    return unless (defined $nodes[0]);
    wantarray ? @nodes : 
                ref($nodes[0]) ? $nodes[0]->value : $nodes[0]; 
}


1;

__END__

=begin

=head1 NAME

XML::RAI::Channel - An interface to the channel elements of a RSS
feed.

=head1 DESCRIPTION

A subclass of L<XML::RAI::Object>, XML::RAI::Channel handles the
mapping function and retrieval of RSS channel elements.

=head1 METHODS

=item $channel->source

Returns the L<XML::RSS::Parser::Element> that the object is using
as its source.

=item $channel->parent

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

=item $channel->contributor

=over 4

=item * dc:contributor

=back

=item $channel->coverage

=over 4

=item * dc:coverage

=back

=item $channel->creator

=over 4

=item * dc:creator

=back

=item $channel->description

=over 4

=item * description

=item * dc:description

=item * dcterms:abstract

=item * dcterms:alternative

=back

=item $channel->format

=over 4

=item * dc:format

=back

=item $channel->generator

=over 4

=item * admin:generatorAgent

=item * generator

=back

=item $channel->identifier

=over 4

=item * dc:identifier

=back

=item $channel->issued

=over 4

=item * dcterms:issued

=item * dc:date

=item * lastBuildDate

=item * rss091:lastBuildDate

=back

=item $channel->issued_strict

=over 4

=item * dcterms:issued

=back

=item $channel->language

=over 4

=item * @xml:lang

=item * dc:language

=item * language

=item * rss091:language

=back

=item $channel->link

=over 4

=item * link

=item * @rdf:about

=back

=item $channel->maintainer

=over 4

=item * admin:errorReportsTo

=item * webMaster

=back

=item $channel->modified

=over 4

=item * dc:terms:modified

=item * dc:date

=item * lastBuildDate

=item * rss091:lastBuildDate

=back

=item $channel->modified_strict

=over 4

=item * dc:terms:modified

=back

=item $channel->publisher

=over 4

=item * dc:publisher

=item * managingEditor

=back

=item $channel->relation

=over 4

=item * dc:relation/@rdf:resource

=item * dc:relation

=back

=item $channel->rights

=over 4

=item * dc:rights

=item * copyright

=item * creativeCommons:license

=item * rss091:copyright

=back

=item $channel->source

=over 4

=item * dc:source

=item * source

=item * title

=back

=item $channel->subject

=over 4

=item * dc:subject

=item * category

=back

=item $channel->title

=over 4

=item * title

=item * dc:title

=back

=item $channel->type

=over 4

=item * dc:type

=back

=item $channel->valid

=over 4

=item * dcterms:valid

=back

=head1 AUTHOR & COPYRIGHT

Please see the XML::RAI manpage for author, copyright, and license
information.

=cut

=end