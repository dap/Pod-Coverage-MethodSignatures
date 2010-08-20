package Pod::Coverage::MethodSignatures;

our $VERSION = "0.01";

use base Pod::Coverage;

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
print STDERR "Investigating $sym\n";
        # see if said method wasn't just imported from elsewhere
        my $glob = do { no strict 'refs'; \*{$sym} };
        my $o = B::svref_2object($glob);
print STDERR "GOT to 1\n";
        # in 5.005 this flag is not exposed via B, though it exists
        my $imported_cv = eval { B::GVf_IMPORTED_CV() } || 0x80;
        #next if $o->GvFLAGS & $imported_cv;
print STDERR "GOT to 2\n";
        # check if it's on the whitelist
        $sym =~ s/$self->{package}:://;
        next if $self->_private_check($sym);
print STDERR "GOT to 3\n";
        push @symbols, $sym;
    }
    return @symbols;
}

1;

