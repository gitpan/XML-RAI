package XML::RSS::Parser::Element;

use strict;
use XML::Elemental::Element;
@XML::RSS::Parser::Element::ISA = qw( XML::Elemental::Element );

use Class::XPath 1.4
     get_name => 'qname',
     get_parent => 'parent',
     get_root   => 'root',
     get_children => sub { $_[0]->contents ? @{$_[0]->contents} : () },
     get_attr_names => 'attribute_qnames',
     get_attr_value => 'attribute_by_qname', 
     get_content    => 'text_content'
;

my %xpath_prefix = (
	admin=>"http://webns.net/mvcb/",
	ag=>"http://purl.org/rss/1.0/modules/aggregation/",
	annotate=>"http://purl.org/rss/1.0/modules/annotate/",
	audio=>"http://media.tangent.org/rss/1.0/",
	cc=>"http://web.resource.org/cc/",
	company=>"http://purl.org/rss/1.0/modules/company",
	content=>"http://purl.org/rss/1.0/modules/content/",
	cp=>"http://my.theinfo.org/changed/1.0/rss/",
	dc=>"http://purl.org/dc/elements/1.1/",
	dcterms=>"http://purl.org/dc/terms/",
	email=>"http://purl.org/rss/1.0/modules/email/",
	ev=>"http://purl.org/rss/1.0/modules/event/",
	foaf=>"http://xmlns.com/foaf/0.1/",
	image=>"http://purl.org/rss/1.0/modules/image/",
	l=>"http://purl.org/rss/1.0/modules/link/",
	rdf=>"http://www.w3.org/1999/02/22-rdf-syntax-ns#",
	rdfs=>"http://www.w3.org/2000/01/rdf-schema#",
	'ref'=>"http://purl.org/rss/1.0/modules/reference/",
	reqv=>"http://purl.org/rss/1.0/modules/richequiv/",
	rss091=>"http://purl.org/rss/1.0/modules/rss091#",
	search=>"http://purl.org/rss/1.0/modules/search/",
	slash=>"http://purl.org/rss/1.0/modules/slash/",
	ss=>"http://purl.org/rss/1.0/modules/servicestatus/",
	str=>"http://hacks.benhammersley.com/rss/streaming/",
	'sub'=>"http://purl.org/rss/1.0/modules/subscription/",
	sy=>"http://purl.org/rss/1.0/modules/syndication/",
	taxo=>"http://purl.org/rss/1.0/modules/taxonomy/",
	thr=>"http://purl.org/rss/1.0/modules/threading/",
	trackback=>"http://madskills.com/public/xml/rss/module/trackback/",
	wiki=>"http://purl.org/rss/1.0/modules/wiki/",
	xhtml=>"http://www.w3.org/1999/xhtml/",
    xml=>"http://www.w3.org/XML/1998/namespace/"
);
my %xpath_ns = reverse %xpath_prefix;

sub new {
    my($class,$a) = @_;
    $a ||= {};
    my $self = bless $a,$class;
    $self;
}

#--- XML::RSS::Parser::Element 2x API methods

sub child { 
	my($self,$tag) = @_;
	my $class = ref($self);
	my $e = $class->new( { parent=>$self, name=>$tag } );
    push( @{$self->contents}, $e );
	$e;
}

sub children { 
	my($self,$name) = @_;
    return $self->contents unless defined($name);
    my @c = grep { $_->can('name') && $_->name eq $name }
        @{$self->contents};
    wantarray ? @c : $c[0];
}

sub attribute { 
    $_[0]->attributes->{$_[1]} = $_[2] if $_[2]; 
    $_[0]->attributes->{$_[1]} 
} 

sub children_names {
	my $class = ref($_[0]);
	map { $_->name } grep { ref($_) eq $class } @{$_[0]->contents};
}

#--- deprecated XML::RSS::Parser::Element 2x API methods

our $pass_thru = {
	'http://www.w3.org/1999/xhtml/body'=> 1,
    'http://www.w3.org/1999/xhtml/div'=>1,
	'http://xmlns.com/foaf/0.1/Person' =>1, # I love RDF.
	'http://xmlns.com/foaf/0.1/person' => 1
};

sub value {
    my($self,$value) = @_;
    my $class = ref($self);
    if (defined($value)) {
        warn "Deprecated function 'value' may not have worked as expected. ".   
            "Use 'contents' instead." if (scalar @{$self->contents} > 1);
        # Removes all character objects and creates a new one as the 
        # first child of its parent with the passed using the passed 
        # value.
        my @contents = grep { $_ eq $class } @{$self->contents};
        unshift @contents, XML::RSS::Parser::Characters->new({data=>$value});
    }
    return unless $self->contents;
    $pass_thru->{$self->name} ?
        $self->as_xml :
            join '', map { $_->data } grep {ref($_) ne $class} @{$self->contents};
}

sub append_value {
    my($self,$value) = @_;
    my $class = ref($self);
    if ($self->contents && 
            ref($self->contents->[-1]) ne $class) {
        my $last = $self->contents->[-1];
        $last->data($last->data.$value);
    } else {
        my $chars = XML::RSS::Parser::Characters->new({data=>$value});
        $self->contents ?
            push(@{$self->contents},$chars) :
                $self->contents( [$chars] );
    }
}

#--- xpath methods

*query = \&match;

sub qname {
    my $in = $_[1] || $_[0]->{name}; 
    my($ns,$local) = $in =~m!^(.*?)([^/#]+)$!;
    return $local if ($_[0]->root->rss_namespace_uri eq $ns);
    my $prefix =  $xpath_ns{$ns};
    unless ($prefix) { # make a generic prefix for unknown namespace URI.
        my $i = 1;
        while($xpath_prefix{"NS$i"}) { $i++ }
        $xpath_prefix{"NS$i"} = $ns;
        $xpath_ns{$ns} = "NS$i";
        $prefix = "NS$i";
    }
    # not registering #default any more. dynamic lookups instead.
    # $prefix ne '#default' ? "$prefix:$local" : $local;
    "$prefix:$local";
}


sub attribute_qnames {
	return () unless $_[0]->attributes;
    map { $_[0]->qname($_) } keys %{ $_[0]->attributes };
}

my $NAME = qr/[[:alpha:]_][\w\-\.]*/;
sub attribute_by_qname {
	my $self = shift;
	my $name = shift;
	my $ns = '';
	if ( $name=~/($NAME):($NAME)/ ) {
		$name = $2;
		$ns = $xpath_prefix{$1};
		$ns .=  '/' unless $ns=~m![/#]$!;
	} else {
	    ($ns = $self->name)=~ s/$NAME$//;
	}
	$self->attributes->{"$ns$name"};
}

#--- "pass-thru" methods

# this has its limitations, but should suffice in re-implementing the
# pass-thru function and maintain backwards compatability. i.e. missing 
# namespace prefix mappings. perhaps more.
sub as_xml {
    my $self = shift;
    my $node = shift || $self;
    return encode_xml($node->data)
        if (ref($node) eq 'XML::RSS::Parser::Characters');
    # it must be an element then.
    my($ns,$name) = $node->name =~ m!^(.*?)([^/#]+)$!;
    my $prefix = $xpath_ns{$ns};
    $name = "$prefix:$name" if ($prefix && $prefix ne '#default');
    my $out = "<$name";
    my $a = $node->attributes;
    my $children = $node->contents;
    foreach (keys %$a){
        my($ans,$aname) = $_ =~ m!^(.*?)([^/#]+)$!;
        if ($ans ne $ns) {
            my $aprefix = $xpath_ns{$ans};
            $aname = "$aprefix:$aname" if ($aprefix && $aprefix ne '#default');
        }
        $out.=" $aname=\"".encode_xml($a->{$_},1)."\"";
    }
    if ($children) {
        $out .= '>';
        map { $out .= $self->as_xml($_) } @$children;
        $out .= "</$name>";
    } else { 
        $out.='/>';
    }
    $out;
}

my %Map = ('&' => '&amp;', '"' => '&quot;', '<' => '&lt;', '>' => '&gt;',
           '\'' => '&#39;');
my $RE = join '|', keys %Map;
sub encode_xml {
    my($str,$nocdata) = @_;
    return unless defined($str);
    if (!$nocdata && $str =~ m/
        <[^>]+>  ## HTML markup
        |        ## or
        &(?:(?!(\#([0-9]+)|\#x([0-9a-fA-F]+))).*?);
                 ## something that looks like an HTML entity.
    /x) {
        ## If ]]> exists in the string, encode the > to &gt;.
        $str =~ s/]]>/]]&gt;/g;
        $str = '<![CDATA[' . $str . ']]>';
    } else {
        $str =~ s!($RE)!$Map{$1}!g;
    }
    $str;
}

1;

__END__

=begin

=head1 NAME

XML::RSS::Parser::Element -- a node in the XML::RSS::Parser parse tree.

=head1 METHODS

=over

=item XML::RSS::Parser::Element->new( [\%init] )

Constructor for XML::RSS::Parser::Element. Optionally the name,
value, attributes, root, and parent can be set with a HASH
reference using keys of the same name. See their associated
functions below for more.

=item $element->root

Returns a reference to the root element of class
L<XML::RSS::Parser::Feed> from the parse tree.

=item $element->parent( [$element] )

Returns a reference to the parent element. A
L<XML::RSS::Parser::Element> object or one of its subclasses can be
passed to optionally set the parent.

=item $element->name( [$extended_name] )

Returns the name of the element as a SCALAR. This should by the
fully namespace qualified (extended)  name of the element and not
the QName or local part.

=item $element->attributes( [\%attributes] )

Returns a HASH reference contain attributes and their values as key
value pairs. An optional parameter of a HASH reference can be
passed in to set multiple attributes. Returns C<undef> if no
attributes exist. B<NOTE:> When setting attributes with this
method, all existing attributes are overwritten irregardless of
whether they are present in the hash being passed in.

=item $element->contents([\@children])

Returns an ordered ARRAY reference of direct sibling objects.
Returns a reference to an empty array if the element does not have
any siblings. If a parameter is passed all the direct siblings are
(re)set.

=item $element->text_content

A method that returns the character data of all siblings.

=item $element->as_xml

Creates XML output markup for the element object including its siblings.

This has its limitations, but should suffice in re-implementing the
pass-thru function and maintain backwards compatability. i.e. missing 
namespace prefix mappings. perhaps more. 

Use with caution. Feedback and enhancements are appreciated.

=back

=head2 XPath-esque Methods

=over

=item $element->query($xpath)

Finds matching nodes using an XPath-esque query from anywhere in
the tree. See the L<Class::XPath> documentation for more
information.

=item $element->match($xpath)

Alias for the C<query> method. For compatability. C<query> is
preferred.

=item $element->xpath

Returns a unique XPath string to the current node which can be used
as an identifier.

=back

These methods were implemented for internal use with L<Class::XPath>
and have now been exposed for general use.

=over

=item $elemenet->qname

Returns the QName of the element based on the internal namespace
prefix mapping.

=item $element->attribute_qnames

Returns an array of attribute names in namespace qualified (QName) form based on the
internal prefix mapping.

=item $element->attribute_by_qname($qname)

Returns an array of attribute names in namespace qualified (QName) form.

=back

=head2 2x API Methods

These were easily re-implemented though implementing them with only the
methods provided by L<XML::Elemental> are trivial. They are still available for
backwards compatability reasons. 

=over

=item $element->attribute($name [, $value] )

Returns the value of an attribute specified by C<$name> as a
SCALAR. If an optional second text parameter C<$value> is passed in
the attribute is set. Returns C<undef> if the attribute does not
exist.

Using the C<attributes> method you could replicate this method like so:

 $element->attributes->{$name}; #get
 $element->attributes->{$name} = $value; #set

=item $element->child( [$extended_name] )

Constructs and returns a new element object making the current
object as its parent. An optional parameter representing the name
of the new element object can be passed. This should be the fully
namespace qualified (extended) name and not the QName or local
part.

=item $element->children( [$extended_name] )

Returns any array of child elements to the object. An optional
parameter can be passed in to return element(s) with a specific
name. If called in a SCALAR context it will return only the first
element with this name. If called in an ARRAY context the function
returns all elements with this name. If no elements exist as a
child of the object, and undefined value is returned.

B<NOTE:> In keeping with the original behaviour of the 2x API, this
method only returns L<XML::RSS::Parser::Element>s.
L<XML::RSS::Parser::Characters> are stripped out. Use the
C<contents> method for the full list of child objects.

=item $element->children_names

Returns an array containing the names of the objects children.
Empty if no children are present.

B<NOTE:> In keeping with the original behaviour of the 2x API, this
method only returns the names of L<XML::RSS::Parser::Element>s.
L<XML::RSS::Parser::Characters> are not present. 

=back

=head2 Deprecated Methods

With the refactoring of XML::RSS::Parser 3.0 to a true tree
structure, the purpose of some methods are no useful or
problematic.the operation of some methods has changed. Ever attempt
has been made to maintain backwards compatability, but some
differences in behavior are unavoidable.

=over

=item $element->value( [$value] )

Returns a reference to the value (text contents) of the element. If
an optional SCALAR parameter is passed in the value (text contents)
is set, removes all character objects and creates a new one as the
first child of its parent with the passed using the passed value.
The 2x API pass-thru functionality is still maintained. If parsing
complex feed with extensive embedded markup like FOAF or XHTML, use
of this method is likely to misbehave. Its highly recommended that
you switch to the 3x API and use the text_content method or the
contents method along with the L<XML::RSS::Parser::Character>
objects.

=item $element->append_value( $value )

Appends the value of the SCALAR parameter to the object's current
value. 

Instead of appending the C<$value> to a the immediate character
data for the element (See the notes on the value method), this
method will create a new L<XML::RSS::Parser::Characters> and set
its value with C<$value> if the last child is not character data.
If the last child of the element is a characters object, C<$value>
is appended to that objects data value.

=back

=head1 SEE ALSO

L<XML::RAI>, L<XML::RSS::Parser>, L<XML::SimpleObject>, L<Class::XPath>

=head1 AUTHOR & COPYRIGHT

Please see the XML::RAI manpage for author, copyright, and
license information.

=cut

=end