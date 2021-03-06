# $Id: Makefile.PL 1723 2006-10-17 13:53:27Z warly $
use ExtUtils::MakeMaker;
use Config;

WriteMakefile(
    NAME       => 'youri-submit',
    VERSION    => '0.9.3',
    AUTHOR     => 'Mageia Sysadmin Team <mageia-sysadm@mageia.org>',
    EXE_FILES  => [
        'bin/youri-submit',
        'bin/youri-submit-restricted',
        'bin/youri-submit-proxy',
	'bin/mga-signpackage'
        ],
    PREREQ_PM  => {
        'Youri::Config'          => 0,
        'Youri::Utils'           => 0,
        'Pod::Simple::HTMLBatch' => 0
    },
    PREFIX               => '/usr/local',
    INSTALLPRIVLIB       => $Config{installprivlib},
    INSTALLSITELIB       => $Config{installsitelib},
    INSTALLVENDORLIB     => $Config{installvendorlib},
    INSTALLMAN3DIR       => $Config{installman3dir},
    INSTALLSITEMAN3DIR   => $Config{installsiteman3dir},
    INSTALLVENDORMAN3DIR => $Config{installvendorman3dir},
    INSTALLSCRIPT        => '$(PREFIX)/bin',
    INSTALLSITESCRIPT    => '$(PREFIX)/bin',
    INSTALLVENDORSCRIPT  => '$(PREFIX)/bin',
    INSTALLMAN1DIR       => '$(PREFIX)/share/man/man1',
    INSTALLSITEMAN1DIR   => '$(PREFIX)/share/man/man1',
    INSTALLVENDORMAN1DIR => '$(PREFIX)/share/man/man1',
);

package MY;

sub post_constants {
    my ($self) = @_;
    my $sysconfdir = $self->{ARGS}->{SYSCONFDIR} || '$(PREFIX)/etc';
    return <<EOF;
SYSCONFDIR = $sysconfdir
EOF
}

sub top_targets {
    my ($self) = @_;
    my $top_targets = $self->SUPER::top_targets(@_);
    $top_targets =~ s/all :: pure_all manifypods/all :: pure_all manifypods htmlifypods/;
    $top_targets .= <<'EOF';
htmlifypods : $(TO_INST_PM)
	if [ ! -d blib/html ]; then mkdir blib/html; fi
	perl -MPod::Simple::HTMLBatch -e Pod::Simple::HTMLBatch::go lib blib/html
	pod2html < bin/youri-submit > blib/html/youri-submit.html
	pod2html < bin/youri-submit-restricted > blib/html/youri-submit-restricted.html
	pod2html < bin/youri-submit-proxy > blib/html/youri-submit-proxy.html
EOF
     return $top_targets;
}

sub install {
    my ($self) = @_;
    my $install = $self->SUPER::install(@_);
    $install =~ s/install :: all pure_install doc_install/install :: all pure_install doc_install config_install completion_install/;
    $install .= <<'EOF';
config_install :
	install -d -m 755 $(DESTDIR)$(SYSCONFDIR)/youri
	install -m 644 etc/submit.conf $(DESTDIR)$(SYSCONFDIR)/youri

completion_install :
	install -d -m 755 $(DESTDIR)$(SYSCONFDIR)/bash_completion.d
	install -m 644 etc/bash_completion.d/youri-submit $(DESTDIR)$(SYSCONFDIR)/bash_completion.d
EOF
    return $install;
}

sub installbin {
    my ($self) = @_;
    my $installbin = $self->SUPER::installbin(@_);
    $installbin .= <<'EOF';
bin/youri-submit : bin/youri-submit.in Makefile
	perl -p \
	    -e 's|\@sysconfdir\@|$(SYSCONFDIR)|;' \
	    < $< > $@

bin/youri-submit-restricted : bin/youri-submit-restricted.in Makefile
	perl -p \
	    -e 's|\@sysconfdir\@|$(SYSCONFDIR)|;' \
	    -e 's|\@bindir\@|$(PREFIX)/bin|;' \
	    < $< > $@

bin/youri-submit-proxy : bin/youri-submit-proxy.in Makefile
	perl -p \
	    -e 's|\@sysconfdir\@|$(SYSCONFDIR)|;' \
	    -e 's|\@bindir\@|$(PREFIX)/bin|;' \
	    < $< > $@
EOF
    return $installbin;
}
