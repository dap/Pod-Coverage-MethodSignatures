package Pod::Coverage::MethodSignatures;

our $VERSION = "0.01";

use base Pod::Coverage;

BEGIN { defined &TRACE_ALL or eval 'sub TRACE_ALL () { 0 }' }

sub _get_syms {
    my $self    = shift;
    my $package = shift;

    print "requiring '$package'\n" if TRACE_ALL;
    eval qq{ require $package };
    print "require failed with $@\n" if TRACE_ALL and $@;
    return if $@;

    print "walking symbols\n" if TRACE_ALL;
    my $syms = Devel::Symdump->new($package);

    my @symbols;
    for my $sym ( $syms->functions ) {

        # see if said method wasn't just imported from elsewhere
        # using some Pod::Coverage pre-0.18 code
        my $b_cv = B::svref_2object(\&{ $sym });
        print "checking origin package for '$sym':\n",
            "\t", $b_cv->GV->STASH->NAME, "\n" if TRACE_ALL;
        next unless $b_cv->GV->STASH->NAME eq $self->{'package'};

        # check if it's on the whitelist
        $sym =~ s/$self->{package}:://;
        next if $self->_private_check($sym);

        push @symbols, $sym;
    }
    return @symbols;
}

sub _trustme_check {
    my ($self, $sym) = @_;
    return (grep { $sym eq $_ } (qw/func method/))
        || $self->SUPER::_trustme_check(@_);
    
}

1;
