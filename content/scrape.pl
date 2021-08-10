#!/usr/bin/perl
use v5.14;
use utf8;
use strict;
use warnings;
use Mojo::UserAgent;
use open qw/:std :encoding(UTF-8)/;

my $BASE_URL = 'http://qss.quiz-island.site/abcgo/';
my $ua = Mojo::UserAgent->new;

for my $target (2003 .. 2014) {
    my $page = 1;
    my $total = undef;

    do {
        my $dom = $ua->get($BASE_URL, form => +{
            formname => 'lite_search',
            target => $target,
            page => $page,
        })->result->dom;

        for my $tr ($dom->find('#quizzes_list tr')->each) {
            my $question = $tr->at('td:nth-child(3) a')->text;
            my $answer = $tr->at('td:nth-child(3) > div:nth-child(4)')->text;
            $answer =~ s/\A正解\s*:\s*//xms;
            say join "\t", $question, $answer;
        }

        $total //= $dom->at('.pb-5 > p:nth-child(1) > strong:nth-child(1)')->text;
        $page++;
    } while ($page * 100 < $total);
}

1;
__END__

=encoding utf8

=head1 NAME

scrape.pl - qss.quiz-island.site quiz web scraper

=head1 DESCRIPTION

2003年から2014年までのクイズデータをTSVでSTDOUTに吐くスクリプト

=head1 SYNOPSIS

    $ perl scrape.pl

=head1 DEPENDENCIES

    Mojo::UserAgent

=head1 AUTHOR

Shin Kojima <shin@kojima.org>
