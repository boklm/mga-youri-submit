package Youri::Submit::Check::Deps;

=head1 NAME

Youri::Submit::Check::Deps - Check dependencies

=head1 DESCRIPTION

This check plugin rejects packages with unresolved dependencies.

=cut

use warnings;
use strict;
use Carp;
use Youri::Media::URPM;
use base qw/Youri::Submit::Check/;

sub resolvedep {
    my ($media, @requires) = @_;

    my @errors;
    my $index = sub {
        my ($package) = @_;

	my @provides = $package->get_provides();

	@requires = grep {
	    my $require = $_;
	    my $notfound = 1;
            foreach my $provide (@provides) {
                next unless $provide->[Youri::Package::Relationship::NAME] eq $require->[Youri::Package::Relationship::NAME];
                if ($require->[Youri::Package::Relationship::RANGE]) {
                    next unless $package->check_ranges_compatibility($provide->[Youri::Package::Relationship::RANGE], $require->[Youri::Package::Relationship::RANGE]);
	        }
	        $notfound = 0;
	    }

            if ($notfound && $require->[Youri::Package::Relationship::NAME] =~ m|/|) {
                foreach my $file ($package->get_files()) {
		    next unless $file eq $require->[Youri::Package::Relationship::NAME];
		    $notfound = 0;
		    last;
	        }
            }
	    $notfound;
        } @requires;
    };
    $media->traverse_headers($index);
    foreach my $require (@requires) {
	    push (@errors, "Unresolved dep on " . $require->[Youri::Package::Relationship::NAME] . " " . $require->[Youri::Package::Relationship::RANGE]);
    }
    return @errors;
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    # FIXME Define some Youri::Media with allowed_deps in the config and
    # match target + section to a media
    my $section = $repository->_get_section($package, $target, $define);
    return unless $target eq "cauldron" && $section eq 'core/release';

    my @requires = $package->get_requires();
    
    my $path = $repository->get_install_root() . "/" . $target;
    # FIXME we need dependencies on all archs except for ExclusiveArch
    # Unfortunately some dependencies depend on the arch were the src.rpm was geenrated
    # Currently src.rpm is generated on x86_64, so we need to check on that one
    # If the package is not buildable on x86_64 we just don't test anything
    my $arch = 'x86_64';
    my @exclusivearchs = $package->get_tag("exclusivearchs");
    return if @exclusivearchs && ! (grep {$_ eq $arch} @exclusivearchs);
#    foreach my $arch ($repository->get_extra_arches()) {
        my $media = new Youri::Media::URPM(name => "core.".$arch,
                                           type => "binary",
					   hdlist => "$path/$arch/media/$section/media_info/hdlist.cz");
    return resolvedep($media, @requires);
#    }

}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
