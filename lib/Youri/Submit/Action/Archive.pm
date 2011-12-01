# $Id: Archive.pm 265457 2010-01-28 13:09:30Z pterjan $
package Youri::Submit::Action::Archive;

=head1 NAME

Youri::Submit::Action::Archive - Old revisions archiving

=head1 DESCRIPTION

This action plugin ensures archiving of old package revisions.

=cut

use warnings;
use strict;
use Carp;
use base qw/Youri::Submit::Action/;

sub _init {
    my $self   = shift;
    my %options = (
        perms => 644,
        @_
    );

    $self->{_perms} = $options{perms};
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    # FIXME: workaround for $self->{_verbose} not being initialized properly
    $self->{_verbose} = 1;
    # all this should be in Mandriva_upload.pm
    my $section = $repository->_get_section($package, $target, $define);
    my $main_section = $repository->_get_main_section($package, $target, $define);
    print "section $section main_section $main_section\n" if $self->{_verbose};
    my $arch = $package->get_arch();
    my $path = $arch eq 'src' ? "$target/SRPMS" : "$target/[^/]+/media";
    $path = "$repository->{_install_root}/$path";
    $path =~ s,/+,/,g;
    foreach my $replaced_package (
        $repository->get_replaced_packages($package, $target, $define)
    ) {
        my $file = $replaced_package->get_file();

	my ($rep_section, $rep_main_section) = $file =~ m,$path/(([^/]+)/.*)/[^/]+.rpm,;
	# We do accept duplicate version for other submedia of the same main media section
	print "(path '$path') file '$file' section '$rep_section' main_section '$rep_main_section'\n" if $self->{_verbose};
	next if $rep_main_section eq $main_section && $rep_section ne $section;
        my $dest = $repository->get_archive_dir($package, $target, $define);

        print "archiving file $file to $dest\n" if $self->{_verbose};

        unless ($self->{_test}) {
            # create destination dir if needed
            system("install -d -m " . ($self->{_perms} + 111) . " $dest")
                unless -d $dest;

            # install file to new location
            system("install -m $self->{_perms} $file $dest");

	    print "deleting file $file\n" if $self->{_verbose};
	    unlink $file unless $self->{_test};
        }
    }  
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
