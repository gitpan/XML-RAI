# Copyright (c) 2004 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::RAI::Item - An interface to the item elements in a RSS feed.
# 

package XML::RAI::Item;

use strict;
use XML::RAI::Object;

use vars qw(@ISA $XMap);
@ISA = qw( XML::RAI::Object );

BEGIN {
    my $item_map = {
        content=>['xhtml:body','content:encoded','description','dc:description','rss091:description'],
        contentstrict=>['xhtml:body','content:encoded'],
        creator=>['author'],
        valid=>['dcterms:valid','expirationDate'],
        identifier=>['guid','link'],
        abstract=>['description','dc:description','dcterms:abstract']
    };
    my $xmap = \%{$XML::RAI::Shared_map};
    while (my($k,$v) = each %$item_map) {
        $xmap->{$k} = [] unless $xmap->{$k};
        push(@{$xmap->{$k}}, @$v);
    }
    $XML::RAI::Item::XMap = $xmap;
}

1;

__END__

=begin

=head1 NAME

XML::RAI::Item - An interface to the item elements of a RSS feed.

=head1 DESCRIPTION

A subclass of L<XML::RAI::Object>, XML::RAI::Item handles the mapping 
function and retrieval of RSS item elements.

=head1 METHODS

=item $item->source

Returns the L<XML::RSS::Parser::Element> that the object is using as 
its source.

=item $item->parent

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

=item $item->abstract

=over 4

=item description

=item dc:description

=item dcterms:abstract

=back

=item $item->content

=over 4

=item xhtml:body

=item content:encoded

=item description

=item dc:description

=item rss091:description

=back

=item $item->contentstrict

=over 4

=item xhtml:body

=item content:encoded

=back

=item $item->creator

=over 4

=item author

=back

=item $item->identifier

=over 4

=item guid

=item link

=back

=item $item->valid

=over 4

=item dcterms:valid

=item expirationDate

=back

=head1 AUTHOR & COPYRIGHT

Please see the XML::RAI manpage for author, copyright, and license information.

=cut

=end