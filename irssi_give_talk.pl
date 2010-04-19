#use strict;
use vars qw($VERSION %IRSSI);

use Irssi;

$VERSION = '0.2';
%IRSSI = (
    authors	=> 'Josh Holland',
    contact	=> 'jrh@joshh.co.uk',
    name	=> 'irssi-give-talk',
    description	=> 'Walk through a text file line by line with the /talknext command',
    license	=> 'Public Domain',
    url		=> 'http://media.joshh.co.uk/irssi_give_talk.pl',
    changed	=> 'Sat Feb 13 16:29:30 UTC 2010',
);

my %TALKS;
my %TALK_POINTER;
my %TALK_NAMES;

sub talkload {
    my ($data, $server, $witem) = @_;
    open my $talkfile, "<", $data or do {
	Irssi::print($!);
	return;
    };
    {
	local $/;
	$TALKS{$witem->{name}} = <$talkfile>;
    }
    $TALK_POINTER{$witem->{name}} = 0;
    $TALK_NAMES{$witem->{name}} = $data;
    $witem->print("Loaded $data. Use /talknext to start displaying it and /talkinfo for information about it");
}

sub next {
    my ($data, $server, $witem) = @_;
    if ($TALK_POINTER{$witem->{name}} >= split /\n/, $TALKS{$witem->{name}}) {
	$witem->print("No next line; talk is finished");
	return;
    }
    my @lines = split /\n/, $TALKS{$witem->{name}};
    $TALK_POINTER{$witem->{name}}++ unless $lines[$TALK_POINTER{$witem->{name}}]; # skip empty lines
    $witem->command("msg $witem->{name} $lines[$TALK_POINTER{$witem->{name}}]");
    $TALK_POINTER{$witem->{name}}++;
}

sub info {
    my ($data, $server, $witem) = @_;
    my @lines = split /\n/, $TALKS{$witem->{name}};
    $witem->print("Current talk for $witem->{name}: $TALK_NAMES{$witem->{name}}");
    if ($TALK_POINTER{$witem->{name}} == 0) {
	$witem->print("Have not started displaying this talk yet");
    } else {
	$witem->print("Last line displayed: $lines[$TALK_POINTER{$witem->{name}}-1]");
    }
    if ($TALK_POINTER{$witem->{name}} == @lines) {
	$witem->print("This talk is finished");
    } else {
	$witem->print("Next line to be displayed: $lines[$TALK_POINTER{$witem->{name}}]");
    }
    my $length = @lines;
    $witem->print("Currently on line $TALK_POINTER{$witem->{name}} of $length");
}

Irssi::command_bind('talkload', 'talkload');
Irssi::command_bind('talknext', 'next');
Irssi::command_bind('talkinfo', 'info');
