# $Id: Mail.pm 223952 2007-06-23 13:54:13Z pixel $
package Youri::Submit::Action::Mail;

=head1 NAME

Youri::Submit::Action::Mail - Mail notification

=head1 DESCRIPTION

This action plugin ensures mail notification of new package revisions.

=cut

use warnings;
use strict;
use MIME::Entity;
use Encode qw/from_to/;
use Carp;
use Youri::Package;
use base qw/Youri::Submit::Action/;

sub _init {
    my $self   = shift;
    my %options = (
        mta      => '/usr/sbin/sendmail',
        to       => '',
        from     => '',
        cc       => '',
        prefix   => '',
        encoding => 'quoted-printable',
        charset  => 'iso-8859-1',
        @_
    );

    croak "undefined mail MTA" unless $options{mta};
    croak "invalid mail MTA $options{mta}" unless -x $options{mta};
    croak "undefined to" unless $options{to};
    if ($options{cc}) {
        croak "cc should be an hashref" unless ref $options{cc} eq 'HASH';
    }
    croak "invalid charset $options{charset}"
        unless Encode::resolve_alias($options{charset});

    $self->{_mta}      = $options{mta};
    $self->{_to}       = $options{to};
    $self->{_from}     = $options{from};
    $self->{_cc}       = $options{cc};
    $self->{_prefix}   = $options{prefix};
    $self->{_encoding} = $options{encoding};
    $self->{_charset}  = $options{charset};
}

sub run {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    return unless $package->is_source();

    my $from = $package->get_packager();

    # force from adress if defined
    $from =~ s/<.*>/<$self->{_from}>/ if $self->{_from};

    my $subject = $self->get_subject($package, $repository, $target, $define);
    my $content = $self->get_content($package, $repository, $target, $define);

    # ensure proper codeset conversion
    # for informations coming from package
    my $charset = $repository->get_package_charset();
    from_to($content, $charset, $self->{_charset});
    from_to($subject, $charset, $self->{_charset});

    my $mail = MIME::Entity->build(
        Type     => 'text/plain',
        Charset  => $self->{_charset},
        Encoding => $self->{_encoding},
        From     => $from,
        To       => $self->{_to},
        Subject  => $subject,
        Data     => $content,
    );

    if ($self->{_cc}) {
        my $cc = $self->{_cc}->{$package->get_name()};
        $mail->head()->add('cc', $cc) if $cc;
    }

    if ($self->{_test}) {
        $mail->print(\*STDOUT);
    } else {
        open(MAIL, "| $self->{_mta} -t -oi -oem") or die "Can't open MTA program: $!";
        $mail->print(\*MAIL);
        close MAIL;
    }

}

sub get_subject {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my $section = $repository->_get_section($package, $target, $define);
    return 
        ($self->{_prefix} ?  '[' . $self->{_prefix} . '] ' : '' ) . 
	"$target " . ($section ? "$section " : '' ) .
        $package->as_formated_string('%{name}-%{version}-%{release}');
}

sub get_content {
    my ($self, $package, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my $information = $package->as_formated_string(<<EOF);
Name        : %-27{NAME}  Relocations: %|PREFIXES?{[%{PREFIXES} ]}:{(not relocatable)}|
Version     : %-27{VERSION}       Vendor: %{VENDOR}
Release     : %-27{RELEASE}   Build Date: %{BUILDTIME:date}
Install Date: %|INSTALLTIME?{%-27{INSTALLTIME:date}}:{(not installed)         }|      Build Host: %{BUILDHOST}
Group       : %-27{GROUP}   Source RPM: %{SOURCERPM}
Size        : %-27{SIZE}%|LICENSE?{      License: %{LICENSE}}|
Signature   : %|DSAHEADER?{%{DSAHEADER:pgpsig}}:{%|RSAHEADER?{%{RSAHEADER:pgpsig}}:{%|SIGGPG?{%{SIGGPG:pgpsig}}:{%|SIGPGP?{%{SIGPGP:pgpsig}}:{(none)}|}|}|}|
%|PACKAGER?{Packager    : %{PACKAGER}\n}|%|URL?{URL         : %{URL}\n}|Summary     : %{SUMMARY}
Description :\n%{DESCRIPTION}
EOF

    my $last_change = $package->get_last_change();

    return
        $information . "\n" .
        $last_change->get_author() . ":\n" .
	$last_change->get_raw_text();
}


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
