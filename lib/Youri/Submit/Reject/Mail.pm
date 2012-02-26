# $Id$
package Youri::Submit::Reject::Mail;

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
use base qw/Youri::Submit::Reject/;

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
    my ($self, $package, $errors, $repository, $target, $define) = @_;
    croak "Not a class method" unless ref $self;

    my $section = $repository->_get_section($package, $target, $define);

    my $subject =
        ($self->{_prefix} ?  '[' . $self->{_prefix} . '] ' : '' ) . ($section ? "$section " : '') .
        $package->get_revision_name();
    my $information = $package->get_information();
    my $last_change = $package->get_last_change();
    my $author = $last_change->[Youri::Package::CHANGE_AUTHOR] if $last_change;
    my $list = $last_change->[Youri::Package::CHANGE_TEXT] if $last_change;
    my $content =
        "Errors: \n\n" . join("\n", map {
          ( "* $_", (map { "  - $_" } @{$errors->{$_}}), "\n");
        } sort(keys %$errors)) . "\n" .
        $information . "\n" .
        $author . ":\n$list";

    # ensure proper codeset conversion
    # for informations coming from package
    my $charset = $repository->get_package_charset();
    from_to($content, $charset, $self->{_charset});
    from_to($subject, $charset, $self->{_charset});

    my $mail = MIME::Entity->build(
        Type     => 'text/plain',
        Charset  => $self->{_charset},
        Encoding => $self->{_encoding},
        From     => $self->{_from},
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002-2006, YOURI project

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
