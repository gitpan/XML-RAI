package XML::RSS::Parser;

use strict;

use XML::Parser;
use XML::Parser::Style::Elemental;
use vars qw($VERSION @ISA);
$VERSION = 3.03;
@ISA = qw( XML::Parser );

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(
    			  Namespaces    => 1,
				  NoExpand      => 1,
				  ParseParamEnt => 0,
				  Handlers      => {
                    Init => \&XML::Parser::Style::Elemental::Init,
                    Start => \&XML::Parser::Style::Elemental::Start,
                    Char => \&XML::Parser::Style::Elemental::Char,
                    End => \&XML::Parser::Style::Elemental::End,
                    Final => \&XML::Parser::Style::Elemental::Final
				  },
				  Elemental=> {
				    Document=>'XML::RSS::Parser::Feed',
				    Element=>'XML::RSS::Parser::Element',
				    Characters=>'XML::RSS::Parser::Characters'
				  }
				);
    bless ($self,$class);
    return $self;
}

sub parse { $_[0]->rss_normalize($_[0]->SUPER::parse($_[1])); }

sub ns_qualify { 
	my ($class,$name, $namespace) = @_;
	if (defined($namespace)) { 
		$namespace .= '/' unless $namespace=~/(\/|#)$/;
		return $namespace . $name;
	} else { return $name; }
}

#--- utils

# Since different RSS formats have slightly different tag hierarchies
# we make some alternations after processing so bring them all into
# line.
sub rss_normalize {
    my $self = shift;
    my $doc = shift;
    my $nsq_channel = $doc->find_rss_namespace.'channel';
    my $root = $doc->contents->[0];
    my @new_contents;
    foreach (@{ $root->contents }) {
        if ($_->can('name') && ($_->name eq $nsq_channel)) {
            $_->parent($doc);
            $doc->contents([$_]);
        } else {
            push(@new_contents,$_);
        }
    }
    my $channel = $doc->contents->[0];
    map { $_->parent($channel) } @new_contents;
    $channel->contents([@{$channel->contents},@new_contents]);
    $root->parent(undef);
    $root->contents(undef);
    $doc;
}

1;

__END__

=begin

=head1 NAME

XML::RSS::Parser - A liberal object-oriented parser for RSS feeds.

=head1 SYNOPSIS

 #!/usr/bin/perl -w
 
 use strict; 
 use XML::RSS::Parser;
 
 my $p = new XML::RSS::Parser; 
 my $feed = $p->parsefile('/path/to/some/rss/file');
 
 # output some values 
 my $feed_title = $feed->query('/channel/title');
 print $feed_title->text_content;
 my $count = $feed->item_count;
 print " ($count)\n";
 foreach my $i ( $feed->query('//item') ) { 
     my $node = $i->query('title');
     print '  '.$node->text_content;
     print "\n"; 
 }

=head1 DESCRIPTION

XML::RSS::Parser is a lightweight liberal parser of RSS feeds. This
parser is "liberal" in that it does not demand compliance of a
specific RSS version and will attempt to gracefully handle tags it
does not expect or understand.  The parser's only requirements is
that the file is well-formed XML and remotely resembles RSS.
Roughly speaking, well formed XML with a C<channel> element as a
direct sibling or the root tag and C<item> elements etc.

There are a number of advantages to using this module then just
using a standard parser-tree combination. There are a number of
different RSS formats in use today. In very subtle ways these
formats are not entirely compatible from one to another.
XML::RSS::Parser makes a couple assumptions to "normalize" the
parse tree into a more consistent form. For instance, it forces
C<channel> and C<item> into a parent-child relationship. For more
detail see L<SPECIAL PROCESSING NOTES>.

This module is leaner then L<XML::RSS> -- the majority of code was
for generating RSS files. It also provides a XPath-esque interface
to the feed's tree.

While XML::RSS::Parser creates a normalized parse tree, it still
leaves the mapping of overlapping and alternate tags common in the
RSS format space to the developer. For this look at the L<XML::RAI>
(RSS Abstraction Interface) package which provides an
object-oriented layer to XML::RSS::Parser trees that transparently
maps these various tags to one common interface.

Your feedback and suggestions are greatly appreciated. See the L<TO
DO> section for some brief thoughts on next steps.

=head2 SPECIAL PROCESSING NOTES

There are a number of different RSS formats in use today. In very
subtle ways these formats are not entirely compatible from one to
another. What's worse is that there are unlabeled versions within
the standard in addition to tags with overlapping purposes and
vague definitions. (See Mark Pilgrim's "The myth of RSS
compatibility"
L<http://diveintomark.org/archives/2004/02/04/incompatible-rss> for
just a sampling of what I mean.) To ease working with RSS data in
different formats, the parser does not create the feed's parse tree
verbatim. Instead it makes a few assumptions to "normalize" the
parse tree into a more consistent form.

With the refactoring of this module and the switch to a true tree
structure, the normalization process has been simplified. Some of
the version 2x proved to be problematic with more advanced and
complex feeds.

=over

=item * The RSS namespace (if any) is extracted from the first
sibling of the root tag. We don't use the root tag because in RSS
1.0 the root tag is in the RDF namespace and not RSS. That
namespace is treated as the '#default' (no prefix) namespace for
the parse tree.

=item * The parser will not include the root tags of C<rss> or
C<RDF> in the tree. Namespace declaration information is still
extracted. The C<version> attribute, if defined, is moved to the
C<channel> element.

=item * The parser forces C<channel> and C<item> into a
parent-child relationship. In versions 0.9 and 1.0, C<channel> and
C<item> tags are siblings.

=back

=head1 METHODS

The following objects and methods are provided in this package.

=item XML::RSS::Parser->new

Constructor. Returns a reference to a new XML::RSS::Parser object.

=item $parser->parse(source)

Inherited from L<XML::Parser>, the SOURCE parameter should either
open an IO::Handle or a string containing the whole XML document. A
die call is thrown if a parse error occurs otherwise it will return
a L<XML::RSS::Parser::Feed> object.

=item $parser->parsefile(file)

Inherited from L<XML::Parser>, FILE is an open handle. The file is
closed no matter how parse returns. A die call is thrown if a parse
error occurs otherwise it will return a L<XML::RSS::Parser::Feed>
object.

=item XML::RSS::Parser->ns_qualify(element, namesapce_uri)

An simple utility method implemented as an abstract method that
will return a fully namespace qualified string for the supplied
element.

=head1 DEPENDENCIES

L<XML::Parser>, L<XML::Elemental>, L<Class::XPath> 1.4*

Versions up to 1.4 have a design flaw that would cause it to choke
on feeds with the / character in an attribute value. For example
the Yahoo! feeds.

=head1 SEE ALSO

L<XML::RAI>

The Feed Validator L<http://www.feedvalidator.org/>

What is RSS?
L<http://www.xml.com/pub/a/2002/12/18/dive-into-xml.html>

Raising the Bar on RSS Feed Quality
L<http://www.oreillynet.com/pub/a/webservices/2002/11/19/
rssfeedquality.html>

The myth of RSS compatibility
L<http://diveintomark.org/archives/2004/02/04/incompatible-rss>

=head1 TO DO

=over

=item * Add whitespace filtering switch.

=back

=head1 AUTHOR & COPYRIGHT

Please see the XML::RAI manpage for author, copyright, and license
information.

=cut

=end
