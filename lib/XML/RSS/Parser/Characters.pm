package XML::RSS::Parser::Characters;

use strict;

use XML::Elemental::Characters;
@XML::RSS::Parser::Characters::ISA = qw( XML::Elemental::Characters );

sub new {
    my($class,$a) = @_;
    my $self = bless {}, $class;
    $self->data($a->{data}) if ($a);
    $self;
}

###--- hack to keep Class::XPath happy.
sub qname { '' }
sub attributes { {} }
sub contents { () }
sub text_content { $_[0]->data; }
sub attribute_qnames { };

1;

__END__

=begin

=head1 NAME

XML::RSS::Parser::Characters - an object representing a character
data in an RSS parse tree.

=head1 METHODS

=item XML::RSS::Parser::Character->new( [\%init] )

Constructor. Optionally the data and parent can be set with a HASH
reference using keys of the same name. See their associated
functions below for more.

=item $chars->parent([$object])

Returns a reference to the parent object. If a parameter is passed
the parent is set.

=item $chars->data([$string])

A method that returns the character data as a string. If a
parameter is passed the value is set.

=item $chars->root

Returns a reference to the root element of class
L<XML::RSS::Parser::Feed> from the parse tree.

=head1 AUTHOR & COPYRIGHT

Please see the XML::RAI manpage for author, copyright, and
license information.

=cut

=end