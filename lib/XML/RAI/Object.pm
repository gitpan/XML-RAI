# Copyright (c) 2004 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::RAI::Object - Abstract base class for RAI element objects.
# 

package XML::RAI::Object;

use strict;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->init(@_);
    $self;
}

sub init {
    $_[0]->{__source} = $_[1];
    $_[0]->{__parent} = $_[2];
}

sub source { $_[0]->{__source} }
sub parent { $_[0]->{__parent} }

sub DESTROY { }

use vars qw( $AUTOLOAD );
sub AUTOLOAD {
    (my $var = $AUTOLOAD) =~ s!.+::!!;
    (my $class = $AUTOLOAD) =~ s!::[^:]+$!!;
    no strict 'refs';
    die "$var is not a recognized method."
        unless (${$class.'::XMap'}->{$var});
    *$AUTOLOAD = sub {
        foreach (@{${$class.'::XMap'}->{$var}}) {
            my @nodes = $_[0]->source->query($_);
            if (defined($nodes[0])) {
                return wantarray ? @nodes : 
                    ref($nodes[0]) ? $nodes[0]->value : $nodes[0];  
            }
        }
        return undef;
    };
    goto &$AUTOLOAD;
}

1;

__END__

=begin

=head1 NAME

XML::RAI::Object - Abstract base class for RAI element objects.

=head1 DESCRIPTION

XML::RAI::Object is an abstract base class for RAI element objects. 
Subclasses need only plug in an element map (C<$I<PACKAGE>::XMap>) 
consisting of method names (the key) and a list of XPath-esque 
queries to use as a search path in the RSS parse tree.

=head1 AUTHOR & COPYRIGHT

Please see the XML::RAI manpage for author, copyright, and license information.

=cut

=end