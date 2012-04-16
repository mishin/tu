package Turnaround::I18N::Handle;

use strict;
use warnings;

use base 'Turnaround::Base';

sub language { $_[0]->{language} }

sub loc {&maketext}

sub maketext {
    my $self = shift;

    return $self->{handle}->maketext(@_);
}

1;