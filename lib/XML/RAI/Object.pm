# Copyright (c) 2004-2005 Timothy Appnel
# http://www.timaoutloud.org/
# This code is released under the Artistic License.
#
# XML::RAI::Object - A base class for RAI element objects.
# 

package XML::RAI::Object;

use strict;

use Date::Parse 2.26;
use Date::Format;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->init(@_);
    $self;
}

sub init {
    $_[0]->{__source} = $_[1];
    $_[0]->{__parent} = $_[2];
    $_[0]->{__RAI} = $_[2];
    while ($_[0]->{__RAI}->can('parent')) { 
        $_[0]->{__RAI} = $_[0]->{__RAI}->parent 
    }
}

sub source { $_[0]->{__source} }
sub parent { $_[0]->{__parent} }

sub generic_handler {
    my ($this,$class,$var) = @_;
    no strict 'refs';
    foreach (@{${$class.'::XMap'}->{$var}}) { 
        my @nodes = $this->source->query($_);
        if (defined($nodes[0])) {
            return wantarray ? @nodes : 
                ref($nodes[0]) ? $nodes[0]->value : $nodes[0]; 
        }
    }
    return undef;
}

sub time_handler {
    my @r = generic_handler(@_);
    return undef unless $r[0];
    my $timef = $_[0]->{__RAI}->time_format;
    if ($timef eq 'EPOCH') { 
        map { $_ = str2time($_,0) } @r
    } elsif ($timef) {
        map { 
            my @time = localtime(str2time($_->text_content,0)); 
            $_ = strftime( $timef, @time, 0);
        } @r 
    } else { # PASS-THRU
        map { $_ = $_->text_content } @r
    }
    wantarray ? @r : $r[0];
}

sub DESTROY { }

use vars qw( $AUTOLOAD );
sub AUTOLOAD {
    (my $var = $AUTOLOAD) =~ s!.+::!!;
    (my $class = $AUTOLOAD) =~ s!::[^:]+$!!;
    no strict 'refs';
    die "$var is not a recognized method."
        unless (${$class.'::XMap'}->{$var});
    if ($var=~m/^(created|modified|issued|valid)$/) {
        *$AUTOLOAD = sub { time_handler($_[0],$class,$var) }; 
    } else {
        *$AUTOLOAD = sub { generic_handler($_[0],$class,$var) };
    }
    goto &$AUTOLOAD;
}

1;

__END__

=begin

=head1 NAME

XML::RAI::Object - A base class for RAI element objects.

=head1 DESCRIPTION

XML::RAI::Object is an base class for RAI element objects.
Subclasses need only plug in an element map (C<$I<PACKAGE>::XMap>)
consisting of method names (the key) and a list of XPath-esque
queries to use as a search path in the RSS parse tree.

=head1 AUTHOR & COPYRIGHT

Please see the XML::RAI manpage for author, copyright, and license
information.

=cut

=end