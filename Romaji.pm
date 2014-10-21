package Lingua::JA::Romaji;

use 5.006;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Lingua::JA::Romaji ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	&romajitokana &kanatoromaji %hiragana %katakana
) ] );

our @EXPORT_OK = (	qw( &kanatoromaji %hiragana %katakana ));

our @EXPORT = qw(
	&romajitokana
);
our $VERSION = '0.02';


# Preloaded methods go here.

#romajitokana ( romaji, kanatype)
#kanatype == ``hira'' or ``kana''.  
sub romajitokana {
    #let's ignore case
    my $romaji = lc $_[0];
    my $kanatype;
    return unless $romaji;
    if((defined $_[1]) && ($_[1] =~ m/kata/i)) {
        $kanatype = "kata";
    } else {
        $kanatype = "hira";
    }
    #handle goofy stuff with solitary and doubled n
    $romaji =~ s/[nm]([nm])/q$1/gi;
    $romaji =~ s/n\'/q/gi;
    $romaji =~ s/n$/q/gi;
    #handle regular stuff with singular n.  Is first regex necessary?
    $romaji =~ s/[nm]([bcdfghjkmnprstvz])/q$1/gi;
    #handle double consonants, perhaps ineffectually
    if ($romaji =~ m/([bcdfghjkmnprstvz])\1/i){
        $romaji=~ s/([bcdfghjkmnprstvz])$1/\*$1/gi;
    }
    my @roma = split(//,$romaji);
    my $curst = $roma[0];
    my $i=0;
    my $next = " ";
    my $output = "";
    while ((defined $next)&&($roma[$i] =~ m/[a-z\-\*]/i)) {
        $next = $roma[$i+1];
        unless ($next){
            if ($Lingua::JA::Romaji::roma{$curst}->{$kanatype}) {
                $output.=$Lingua::JA::Romaji::roma{$curst}->{$kanatype};
                $curst = "";
            }
        }
        next unless $next;
        unless ($Lingua::JA::Romaji::roma{$curst . $next}) {
            #we've gone too far, so print out what we've got, if anything
            if ($Lingua::JA::Romaji::roma{$curst}->{$kanatype}) {
                $output.=$Lingua::JA::Romaji::roma{$curst}->{$kanatype};
                $curst = "";

            } 
        } else {
            #if we're here, then curst.next is valid...
            unless ($roma[$i+2]){
                #...and there's nothing else
                $output.=$Lingua::JA::Romaji::roma{$curst . $next}->{$kanatype};
                $curst ="";
                $next = "";
            }
        } 
        $i++;
        $curst = $curst . $next;
    }
    return $output;
}

#kanatoromaji(kana)
sub kanatoromaji {
    my $kana = $_[0];
    my $rawb = unpack("H32", $kana);
#    print "$rawb\n";
    my $scratchkana = $kana;
    my $hirabegin = chr(0xA4);
    my $katabegin = chr(0xA5);
    my @skb = split(//,$scratchkana);
    my $newroma="";
    my $kanatype;
    if ($skb[0] eq $katabegin) {
        $kanatype = 1;
    } else {
        $kanatype = 0;
    }
    while (my $thisbyte = shift @skb) {
        if (($thisbyte eq $hirabegin) || ($thisbyte eq $katabegin)) {
            my $nextbyte = shift @skb;
            if ($Lingua::JA::Romaji::allkana{$thisbyte . $nextbyte}) {
                    $newroma .=  $Lingua::JA::Romaji::allkana{$thisbyte . $nextbyte};
            } else {
                $newroma .= $thisbyte . $nextbyte;
            }
        } else {
            $newroma .= $thisbyte;
        }
    }

    $newroma =~ s/\'$//;
    $newroma =~ s/n\'([^aeiouy])/n$1/gi;
    $newroma =~ s/\*(.)/$1$1/g;
    $newroma =~ s/ixy(.)/$1/ig;
    $newroma =~ s/ix(.)/y$1/ig;
    $newroma =~ s/ux(.)/$1/ig;
    if ($kanatype) {
        return uc $newroma;
    }
    return $newroma;
}

%Lingua::JA::Romaji::hiragana = (
               '��' => '.',
               '��' => '-',
               '����' => 'kya',
               '����' => 'kyu',
               '����' => 'jye',
               '����' => 'kyo',
               '�Ǥ�' => 'dya',
               '�Ǥ�' => 'dyu',
               '�Ҥ�' => 'hye',
               '�Ǥ�' => 'dyo',
               '�Ԥ�' => 'pya',
               '�Ԥ�' => 'pyu',
               '�ߤ�' => 'mye',
               '�Ԥ�' => 'pyo',
               '�¤�' => 'dja',
               '�¤�' => 'dju',
               '�¤�' => 'djo',
               '����' => 'gye',
               '�դ�' => 'fa',
               '�դ�' => 'fi',
               '�դ�' => 'fye',
               '�դ�' => 'fo',
               '����' => 'jya',
               '����' => 'jyu',
               '����' => 'jyo',
               '��' => 'xa',
               '��' => 'a',
               '��' => 'xi',
               '��' => 'i',
               '��' => 'xu',
               '�Ҥ�' => 'hya',
               '��' => 'u',
               '��' => 'xe',
               '�Ҥ�' => 'hyu',
               '��' => 'ye',
               '��' => 'xo',
               '��' => 'o',
               '�Ҥ�' => 'hyo',
               '��' => 'ka',
               '��' => 'ga',
               '��' => 'ki',
               '�ߤ�' => 'mya',
               '��' => 'gi',
               '��' => 'ku',
               '�ߤ�' => 'myu',
               '��' => 'gu',
               '�ꤧ' => 'rye',
               '��' => 'ke',
               '�ߤ�' => 'myo',
               '��' => 'ge',
               '�ˤ�' => 'nye',
               '��' => 'ko',
               '��' => 'go',
               '��' => 'sa',
               '��' => 'za',
               '�ä�' => 'tchi',
               '��' => 'syi',
               '�ä���' => 'tche',
               '��' => 'jyi',
               '����' => 'gya',
               '��' => 'su',
               '��' => 'zu',
               '����' => 'gyu',
               '��' => 'se',
               '����' => 'gyo',
               '��' => 'ze',
               '��' => 'so',
               '��' => 'zo',
               '��' => 'ta',
               '��' => 'da',
               '��' => 'tyi',
               '��' => 'dji',
               '��' => 't-',
               '��' => 'tu',
               '��' => 'dzu',
               '��' => 'te',
               '��' => 'de',
               '��' => 'to',
               '��' => 'do',
               '��' => 'na',
               '��' => 'ni',
               '�Ӥ�' => 'bye',
               '��' => 'nu',
               '��' => 'ne',
               '��' => 'no',
               '��' => 'ha',
               '�դ�' => 'fya',
               '��' => 'ba',
               '��' => 'pa',
               '�դ�' => 'fyu',
               '��' => 'hi',
               '��' => 'bi',
               '�դ�' => 'fyo',
               '����' => 'tye',
               '��' => 'pi',
               '��' => 'hu',
               '��' => 'bu',
               '��' => 'pu',
               '��' => 'he',
               '��' => 'be',
               '��' => 'pe',
               '��' => 'ho',
               '��' => 'bo',
               '��' => 'po',
               '��' => 'ma',
               '��' => 'mi',
               '��' => 'mu',
               '��' => 'me',
               '��' => 'mo',
               '��' => 'xya',
               '��' => 'ya',
               '��' => 'xyu',
               '��' => 'yu',
               '��' => 'xyo',
               '��' => 'yo',
               '��' => 'ra',
               '�ɤ�' => 'du',
               '��' => 'ri',
               '��' => 'ru',
               '��' => 're',
               '��' => 'ro',
               '���' => 'rya',
               '��' => 'xwa',
               '��' => 'wa',
               '���' => 'ryu',
               '�ˤ�' => 'nya',
               '��' => 'wi',
               '��' => 'we',
               '���' => 'ryo',
               '�ˤ�' => 'nyu',
               '��' => 'wo',
               '��' => 'q',
               '�ä���' => 'tcha',
               '�ˤ�' => 'nyo',
               '����' => 'sye',
               '�ä���' => 'tchu',
               '�Ĥ�' => 'tsa',
               '�ä���' => 'tcho',
               '�Ĥ�' => 'tse',
               '�Ĥ�' => 'tso',
               '�Ӥ�' => 'bya',
               '�Ӥ�' => 'byu',
               '�Ӥ�' => 'byo',
               '����' => 'tya',
               '����' => 'tyu',
               '����' => 'tyo',
               '����' => 'kye',
               '�Ǥ�' => 'di',
               '�Ǥ�' => 'dye',
               '�Ԥ�' => 'pye',
               '����' => 'sya',
               '����' => 'syu',
               '�¤�' => 'dje',
               '����' => 'syo'
             );
%Lingua::JA::Romaji::katakana = (
               '����' => 'kyu',
               '����' => 'jye',
               '����' => 'kyo',
               '��' => '.',
               '�ǥ�' => 'dya',
               '�ǥ�' => 'dyu',
               '�ҥ�' => 'hye',
               '�ǥ�' => 'dyo',
               '�ԥ�' => 'pya',
               '�ԥ�' => 'pyu',
               '�ߥ�' => 'mye',
               '��' => '-',
               '�ԥ�' => 'pyo',
               '�¥�' => 'dja',
               '�¥�' => 'dju',
               '�¥�' => 'djo',
               '����' => 'gye',
               '����' => 'va',
               '����' => 'vi',
               '�ե�' => 'fa',
               '�ե�' => 'fi',
               '����' => 've',
               '����' => 'vo',
               '�ե�' => 'fye',
               '�ե�' => 'fo',
               '����' => 'jya',
               '����' => 'jyu',
               '����' => 'jyo',
               '�å���' => 'tche',
               '�ҥ�' => 'hya',
               '�ҥ�' => 'hyu',
               '�ҥ�' => 'hyo',
               '�ߥ�' => 'mya',
               '�ߥ�' => 'myu',
               '�ꥧ' => 'rye',
               '�ߥ�' => 'myo',
               '�˥�' => 'nye',
               '�å�' => 'tchi',
               '����' => 'gya',
               '����' => 'gyu',
               '����' => 'gyo',
               '�ӥ�' => 'bye',
               '�ե�' => 'fya',
               '�ե�' => 'fyu',
               '�ե�' => 'fyo',
               '����' => 'tye',
               '�å���' => 'tcha',
               '��' => 'xa',
               '�å���' => 'tchu',
               '��' => 'a',
               '��' => 'xi',
               '�å���' => 'tcho',
               '��' => 'i',
               '��' => 'xu',
               '��' => 'u',
               '��' => 'xe',
               '��' => 'ye',
               '��' => 'xo',
               '��' => 'o',
               '��' => 'ka',
               '��' => 'ga',
               '��' => 'ki',
               '��' => 'gi',
               '��' => 'ku',
               '�ɥ�' => 'du',
               '��' => 'gu',
               '��' => 'ke',
               '��' => 'ge',
               '���' => 'rya',
               '��' => 'ko',
               '��' => 'go',
               '���' => 'ryu',
               '��' => 'sa',
               '�˥�' => 'nya',
               '��' => 'za',
               '���' => 'ryo',
               '��' => 'syi',
               '�˥�' => 'nyu',
               '��' => 'jyi',
               '��' => 'su',
               '�˥�' => 'nyo',
               '��' => 'zu',
               '����' => 'sye',
               '��' => 'se',
               '�ĥ�' => 'tsa',
               '��' => 'ze',
               '��' => 'so',
               '��' => 'zo',
               '��' => 'ta',
               '��' => 'da',
               '��' => 'tyi',
               '�ĥ�' => 'tse',
               '��' => 'dji',
               '��' => 't-',
               '�ĥ�' => 'tso',
               '��' => 'tu',
               '��' => 'dzu',
               '��' => 'te',
               '��' => 'de',
               '��' => 'to',
               '��' => 'do',
               '��' => 'na',
               '��' => 'ni',
               '��' => 'nu',
               '��' => 'ne',
               '�ӥ�' => 'bya',
               '��' => 'no',
               '��' => 'ha',
               '�ӥ�' => 'byu',
               '��' => 'ba',
               '��' => 'pa',
               '�ӥ�' => 'byo',
               '��' => 'hi',
               '��' => 'bi',
               '��' => 'pi',
               '��' => 'hu',
               '����' => 'tya',
               '��' => 'bu',
               '��' => 'pu',
               '����' => 'tyu',
               '��' => 'he',
               '��' => 'be',
               '����' => 'tyo',
               '��' => 'pe',
               '����' => 'kye',
               '��' => 'ho',
               '��' => 'bo',
               '��' => 'po',
               '��' => 'ma',
               '��' => 'mi',
               '��' => 'mu',
               '��' => 'me',
               '��' => 'mo',
               '��' => 'xya',
               '��' => 'ya',
               '��' => 'xyu',
               '�ǥ�' => 'di',
               '��' => 'yu',
               '��' => 'xyo',
               '��' => 'yo',
               '��' => 'ra',
               '�ǥ�' => 'dye',
               '��' => 'ri',
               '��' => 'ru',
               '��' => 're',
               '��' => 'ro',
               '��' => 'xwa',
               '��' => 'wa',
               '��' => 'wi',
               '��' => 'we',
               '�ԥ�' => 'pye',
               '��' => 'wo',
               '��' => 'q',
               '��' => 'vu',
               '��' => 'xka',
               '��' => 'xke',
               '����' => 'sya',
               '����' => 'syu',
               '�¥�' => 'dje',
               '����' => 'syo',
               '����' => 'kya'
             );
%Lingua::JA::Romaji::roma = (
           'fo' => {
                     'kata' => '�ե�',
                     'hira' => '�դ�'
                   },
           'fyu' => {
                      'kata' => '�ե�',
                      'hira' => '�դ�'
                    },
           'na' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'syo' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'fu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ne' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'nya' => {
                      'kata' => '�˥�',
                      'hira' => '�ˤ�'
                    },
           'xka' => {
                      'kata' => '��'
                    },
           'nye' => {
                      'kata' => '�˥�',
                      'hira' => '�ˤ�'
                    },
           'ni' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'syu' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'xke' => {
                      'kata' => '��'
                    },
           'no' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'va' => {
                     'kata' => '����',
                     'hira' => '����'
                   },
           'nyo' => {
                      'kata' => '�˥�',
                      'hira' => '�ˤ�'
                    },
           'ga' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           've' => {
                     'kata' => '����',
                     'hira' => '����'
                   },
           'nu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ge' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'vi' => {
                     'kata' => '����',
                     'hira' => '����'
                   },
           'nyu' => {
                      'kata' => '�˥�',
                      'hira' => '�ˤ�'
                    },
           'gi' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'vo' => {
                     'kata' => '����',
                     'hira' => '����    '
                   },
           'go' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'vu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'dya' => {
                      'kata' => '�ǥ�',
                      'hira' => '�Ǥ�'
                    },
           'gu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'dja' => {
                      'kata' => '�¥�',
                      'hira' => '�¤�'
                    },
           '*' => {
                    'kata' => '��',
                    'hira' => '��'
                  },
           'dye' => {
                      'kata' => '�ǥ�',
                      'hira' => '�Ǥ�'
                    },
           'dje' => {
                      'kata' => '�¥�',
                      'hira' => '�¤�'
                    },
           '-' => {
                    'kata' => '��',
                    'hira' => '��'
                  },
           '.' => {
                    'kata' => '��',
                    'hira' => '��'
                  },
           'dji' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'wa' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ha' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'dyo' => {
                      'kata' => '�ǥ�',
                      'hira' => '�Ǥ�'
                    },
           'djo' => {
                      'kata' => '�¥�',
                      'hira' => '�¤�'
                    },
           'we' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'he' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'dyu' => {
                      'kata' => '�ǥ�',
                      'hira' => '�Ǥ�'
                    },
           'wi' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'hi' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'dju' => {
                      'kata' => '�¥�',
                      'hira' => '�¤�'
                    },
           'wo' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ho' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'pa' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'dza' => {
                      'kata' => '�¥�',
                      'hira' => '�¤�'
                    },
           'pe' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'hu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'pi' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'dze' => {
                      'kata' => '�¥�',
                      'hira' => '�¤�'
                    },
           'gya' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'dzi' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'po' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'gye' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'tcha' => {
                       'kata' => '�å���',
                       'hira' => '�ä���'
                     },
           'xa' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'dzo' => {
                      'kata' => '�¥�',
                      'hira' => '�¤�'
                    },
           'tya' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'tche' => {
                       'kata' => '�å���',
                       'hira' => '�ä���'
                     },
           'xe' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'pu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'tye' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'dzu' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'tchi' => {
                       'kata' => '�å�',
                       'hira' => '�ä�'
                     },
           'gyo' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'xi' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'tyi' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'bya' => {
                      'kata' => '�ӥ�',
                      'hira' => '�Ӥ�'
                    },
           'a' => {
                    'kata' => '��',
                    'hira' => '��'
                  },
           'tcho' => {
                       'kata' => '�å���',
                       'hira' => '�ä���'
                     },
           'gyu' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'xo' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'bye' => {
                      'kata' => '�ӥ�',
                      'hira' => '�Ӥ�'
                    },
           'tyo' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'e' => {
                    'kata' => '��',
                    'hira' => '��'
                  },
           'ba' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'tchu' => {
                       'kata' => '�å���',
                       'hira' => '�ä���'
                     },
           'i' => {
                    'kata' => '��',
                    'hira' => '��'
                  },
           'xu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'tyu' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'be' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'byo' => {
                      'kata' => '�ӥ�',
                      'hira' => '�Ӥ�'
                    },
           'o' => {
                    'kata' => '��',
                    'hira' => '��'
                  },
           'bi' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'q' => {
                    'kata' => '��',
                    'hira' => '��'
                  },
           'byu' => {
                      'kata' => '�ӥ�',
                      'hira' => '�Ӥ�'
                    },
           'u' => {
                    'kata' => '��',
                    'hira' => '��'
                  },
           'ya' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'bo' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ja' => {
                     'kata' => '����',
                     'hira' => '����'
                   },
           'jya' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'ye' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'bu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'je' => {
                     'kata' => '����',
                     'hira' => '����'
                   },
           'jye' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'ji' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'jyi' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'cha' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'che' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'yo' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'jo' => {
                     'kata' => '����',
                     'hira' => '����'
                   },
           'jyo' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'ra' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'chi' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'tsa' => {
                      'kata' => '�ĥ�',
                      'hira' => '�Ĥ�'
                    },
           'yu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           're' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ju' => {
                     'kata' => '����',
                     'hira' => '����'
                   },
           'jyu' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'cho' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'tse' => {
                      'kata' => '�ĥ�',
                      'hira' => '�Ĥ�'
                    },
           'rya' => {
                      'kata' => '���',
                      'hira' => '���'
                    },
           'ri' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'rye' => {
                      'kata' => '�ꥧ',
                      'hira' => '�ꤧ'
                    },
           'chu' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'ro' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           't-' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'za' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'tso' => {
                      'kata' => '�ĥ�',
                      'hira' => '�Ĥ�'
                    },
           'ka' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ze' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ru' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'xwa' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'ryo' => {
                      'kata' => '���',
                      'hira' => '���'
                    },
           'ke' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'tsu' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'mya' => {
                      'kata' => '�ߥ�',
                      'hira' => '�ߤ�'
                    },
           'zi' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ki' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ryu' => {
                      'kata' => '���',
                      'hira' => '���'
                    },
           'mye' => {
                      'kata' => '�ߥ�',
                      'hira' => '�ߤ�'
                    },
           'zo' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ko' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'sa' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'da' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'zu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'se' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'myo' => {
                      'kata' => '�ߥ�',
                      'hira' => '�ߤ�'
                    },
           'ku' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'sha' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'de' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'si' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'hya' => {
                      'kata' => '�ҥ�',
                      'hira' => '�Ҥ�'
                    },
           'di' => {
                     'kata' => '�ǥ�',
                     'hira' => '�Ǥ�'
                   },
           'myu' => {
                      'kata' => '�ߥ�',
                      'hira' => '�ߤ�'
                    },
           'she' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'hye' => {
                      'kata' => '�ҥ�',
                      'hira' => '�Ҥ�'
                    },
           'shi' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'so' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'do' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'su' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'sho' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'du' => {
                     'kata' => '�ɥ�',
                     'hira' => '�ɤ�'
                   },
           'hyo' => {
                      'kata' => '�ҥ�',
                      'hira' => '�Ҥ�'
                    },
           'cya' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'n\'' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'shu' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'hyu' => {
                      'kata' => '�ҥ�',
                      'hira' => '�Ҥ�'
                    },
           'cye' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'pya' => {
                      'kata' => '�ԥ�',
                      'hira' => '�Ԥ�'
                    },
           'cyi' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'ta' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'pye' => {
                      'kata' => '�ԥ�',
                      'hira' => '�Ԥ�'
                    },
           'te' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'cyo' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'ti' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'cyu' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'pyo' => {
                      'kata' => '�ԥ�',
                      'hira' => '�Ԥ�'
                    },
           'kya' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'to' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'ma' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'pyu' => {
                      'kata' => '�ԥ�',
                      'hira' => '�Ԥ�'
                    },
           'kye' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'tu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'xya' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'me' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'mi' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'kyo' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'mo' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'fya' => {
                      'kata' => '�ե�',
                      'hira' => '�դ�'
                    },
           'kyu' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'fye' => {
                      'kata' => '�ե�',
                      'hira' => '�դ�'
                    },
           'fa' => {
                     'kata' => '�ե�',
                     'hira' => '�դ�'
                   },
           'xyo' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'mu' => {
                     'kata' => '��',
                     'hira' => '��'
                   },
           'sya' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'fe' => {
                     'kata' => '�ե�',
                     'hira' => '�դ�'
                   },
           'xyu' => {
                      'kata' => '��',
                      'hira' => '��'
                    },
           'sye' => {
                      'kata' => '����',
                      'hira' => '����'
                    },
           'fi' => {
                     'kata' => '�ե�',
                     'hira' => '�դ�'
                   },
           'fyo' => {
                      'kata' => '�ե�',
                      'hira' => '�դ�'
                    },
           'syi' => {
                      'kata' => '��',
                      'hira' => '��'
                    }
         );
%Lingua::JA::Romaji::allkana = (
              '����' => 'kyu',
              '����' => 'je',
              '����' => 'kyo',
              '�ǥ�' => 'dya',
              '�ǥ�' => 'dyu',
              '�ҥ�' => 'hye',
              '�ǥ�' => 'dyo',
              '�¥�' => 'dza',
              '�¥�' => 'dju',
              '�¥�' => 'dzo',
              '����' => 'gye',
              '�Ԥ�' => 'pya',
              '�Ԥ�' => 'pyu',
              '�ߤ�' => 'mye',
              '�Ԥ�' => 'pyo',
              '����' => 'ja',
              '����' => 'ju',
              '����' => 'jo',
              '�դ�' => 'fa',
              '�ҥ�' => 'hya',
              '�դ�' => 'fi',
              '�ҥ�' => 'hyu',
              '�ҥ�' => 'hyo',
              '�դ�' => 'fe',
              '�դ�' => 'fo',
              '�å�' => 'tchi',
              '����' => 'gya',
              '����' => 'gyu',
              '����' => 'gyo',
              '�ߤ�' => 'mya',
              '�ߤ�' => 'myu',
              '�ꤧ' => 'rye',
              '�ӥ�' => 'bye',
              '�ߤ�' => 'myo',
              '�ˤ�' => 'nye',
              '�ä���' => 'tche',
              '�դ�' => 'fya',
              '�ɥ�' => 'du',
              '�դ�' => 'fyu',
              '�դ�' => 'fyo',
              '����' => 'che',
              '�ĥ�' => 'tsa',
              '�ĥ�' => 'tse',
              '�ĥ�' => 'tso',
              '���' => 'rya',
              '�ӥ�' => 'bya',
              '���' => 'ryu',
              '�ˤ�' => 'nya',
              '�ӥ�' => 'byu',
              '���' => 'ryo',
              '�ˤ�' => 'nyu',
              '�ӥ�' => 'byo',
              '�ä���' => 'tcha',
              '�ˤ�' => 'nyo',
              '����' => 'she',
              '�ä���' => 'tchu',
              '�ä���' => 'tcho',
              '����' => 'cha',
              '�ԥ�' => 'pye',
              '����' => 'chu',
              '����' => 'cho',
              '����' => 'kye',
              '�Ǥ�' => 'di',
              '�Ǥ�' => 'dye',
              '����' => 'sha',
              '����' => 'shu',
              '�¤�' => 'dze',
              '����' => 'sho',
              '��' => '.',
              '�ԥ�' => 'pya',
              '�ԥ�' => 'pyu',
              '�ߥ�' => 'mye',
              '����' => 'kya',
              '��' => '-',
              '�ԥ�' => 'pyo',
              '����' => 'kyu',
              '����' => 'kyo',
              '����' => 'je',
              '�Ǥ�' => 'dya',
              '�Ǥ�' => 'dyu',
              '�Ǥ�' => 'dyo',
              '�Ҥ�' => 'hye',
              '����' => 'va',
              '����' => 'vi',
              '����' => 'va',
              '����' => 'vi',
              '�ե�' => 'fa',
              '�ե�' => 'fi',
              '����' => 've',
              '����' => 've',
              '�¤�' => 'dza',
              '����' => 'vo',
              '����' => 'vo',
              '�ե�' => 'fe',
              '�¤�' => 'dju',
              '�ե�' => 'fo',
              '�¤�' => 'dzo',
              '����' => 'gye',
              '�å���' => 'tche',
              '�ߥ�' => 'mya',
              '�ߥ�' => 'myu',
              '�ꥧ' => 'rye',
              '�ߥ�' => 'myo',
              '����' => 'ja',
              '�˥�' => 'nye',
              '����' => 'ju',
              '����' => 'jo',
              '��' => 'xa',
              '��' => 'a',
              '��' => 'xi',
              '��' => 'i',
              '��' => 'xu',
              '��' => 'u',
              '�Ҥ�' => 'hya',
              '��' => 'xe',
              '��' => 'e',
              '�Ҥ�' => 'hyu',
              '��' => 'xo',
              '��' => 'o',
              '��' => 'ka',
              '�Ҥ�' => 'hyo',
              '��' => 'ga',
              '��' => 'ki',
              '��' => 'gi',
              '��' => 'ku',
              '��' => 'gu',
              '��' => 'ke',
              '��' => 'ge',
              '��' => 'ko',
              '��' => 'go',
              '��' => 'sa',
              '�ե�' => 'fya',
              '�ä�' => 'tchi',
              '��' => 'za',
              '��' => 'shi',
              '�ե�' => 'fyu',
              '��' => 'ji',
              '��' => 'su',
              '����' => 'gya',
              '�ե�' => 'fyo',
              '��' => 'zu',
              '��' => 'se',
              '����' => 'gyu',
              '����' => 'che',
              '��' => 'ze',
              '����' => 'gyo',
              '��' => 'so',
              '��' => 'zo',
              '��' => 'ta',
              '��' => 'da',
              '�å���' => 'tcha',
              '��' => 'chi',
              '��' => 'dzi',
              '��' => 'xa',
              '�å���' => 'tchu',
              '��' => '*',
              '��' => 'a',
              '��' => 'tsu',
              '��' => 'xi',
              '�å���' => 'tcho',
              '��' => 'dzu',
              '��' => 'i',
              '��' => 'te',
              '��' => 'xu',
              '��' => 'de',
              '��' => 'u',
              '��' => 'to',
              '��' => 'xe',
              '��' => 'do',
              '��' => 'e',
              '��' => 'na',
              '��' => 'xo',
              '�Ӥ�' => 'bye',
              '��' => 'ni',
              '��' => 'o',
              '��' => 'nu',
              '��' => 'ka',
              '��' => 'ne',
              '��' => 'ga',
              '��' => 'no',
              '��' => 'ki',
              '��' => 'ha',
              '��' => 'gi',
              '��' => 'ba',
              '��' => 'ku',
              '��' => 'pa',
              '��' => 'gu',
              '��' => 'hi',
              '��' => 'ke',
              '��' => 'bi',
              '��' => 'ge',
              '���' => 'rya',
              '��' => 'pi',
              '��' => 'ko',
              '��' => 'fu',
              '��' => 'go',
              '���' => 'ryu',
              '��' => 'bu',
              '��' => 'sa',
              '�˥�' => 'nya',
              '��' => 'pu',
              '��' => 'za',
              '���' => 'ryo',
              '��' => 'he',
              '��' => 'shi',
              '�˥�' => 'nyu',
              '��' => 'be',
              '��' => 'ji',
              '��' => 'pe',
              '��' => 'su',
              '�˥�' => 'nyo',
              '��' => 'ho',
              '��' => 'zu',
              '����' => 'she',
              '��' => 'bo',
              '��' => 'se',
              '��' => 'po',
              '��' => 'ze',
              '��' => 'ma',
              '��' => 'so',
              '��' => 'mi',
              '��' => 'zo',
              '��' => 'mu',
              '��' => 'ta',
              '��' => 'me',
              '��' => 'da',
              '��' => 'mo',
              '��' => 'chi',
              '��' => 'xya',
              '��' => 'dzi',
              '��' => 'ya',
              '��' => '*',
              '��' => 'xyu',
              '��' => 'tsu',
              '��' => 'yu',
              '��' => 'dzu',
              '��' => 'xyo',
              '��' => 'te',
              '��' => 'yo',
              '��' => 'de',
              '�ɤ�' => 'du',
              '��' => 'ra',
              '��' => 'to',
              '��' => 'ri',
              '��' => 'do',
              '��' => 'ru',
              '��' => 'na',
              '��' => 're',
              '��' => 'ni',
              '��' => 'ro',
              '��' => 'nu',
              '��' => 'xwa',
              '��' => 'ne',
              '��' => 'wa',
              '��' => 'no',
              '��' => 'wi',
              '��' => 'ha',
              '��' => 'we',
              '��' => 'ba',
              '��' => 'wo',
              '��' => 'pa',
              '��' => 'n\'',
              '��' => 'hi',
              '��' => 'bi',
              '��' => 'pi',
              '��' => 'fu',
              '�Ĥ�' => 'tsa',
              '��' => 'bu',
              '����' => 'cha',
              '��' => 'pu',
              '��' => 'he',
              '����' => 'chu',
              '��' => 'be',
              '��' => 'pe',
              '����' => 'cho',
              '�Ĥ�' => 'tse',
              '����' => 'kye',
              '��' => 'ho',
              '��' => 'bo',
              '�Ĥ�' => 'tso',
              '��' => 'po',
              '��' => 'ma',
              '��' => 'mi',
              '��' => 'mu',
              '��' => 'me',
              '��' => 'mo',
              '��' => 'xya',
              '��' => 'ya',
              '��' => 'xyu',
              '�Ӥ�' => 'bya',
              '�ǥ�' => 'di',
              '��' => 'yu',
              '��' => 'xyo',
              '��' => 'yo',
              '�Ӥ�' => 'byu',
              '��' => 'ra',
              '�ǥ�' => 'dye',
              '��' => 'ri',
              '�Ӥ�' => 'byo',
              '��' => 'ru',
              '��' => 're',
              '��' => 'ro',
              '��' => 'xwa',
              '��' => 'wa',
              '��' => 'wi',
              '��' => 'we',
              '��' => 'wo',
              '��' => 'n\'',
              '��' => 'vu',
              '��' => 'xka',
              '��' => 'xke',
              '����' => 'sha',
              '����' => 'shu',
              '�¥�' => 'dze',
              '����' => 'sho',
              '�Ԥ�' => 'pye',
              '����' => 'kya'
            );


1;
__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Lingua::JA::Romaji - Perl extension for romaji and kana conversion

=head1 SYNOPSIS

  use Lingua::JA::Romaji ':romajitokana,:kanatoromagi';

  &romajitokana(romaji, [hira|kata])
  &kanatoromaji(EUC-encoded kana)


=head1 DESCRIPTION

Transliterates from roman characters to kana syllables, and back again.

Given an EUC-encoded string of kana $kana, $roma=&kanatoromaji($kana)
will convert to Hepburn romaji.  Hiragana is converted to lower case,
ad katakana is converted to uppercase. Given a string of romaji, 
$kana=&romajitokana($roma,$kanatype) will convert to EUC-encoded kanji. 
If $kanatype matches the pattern /kata/i, it will be katakana, otherwise
it will be hiragana.

To change the romafication style, you can modify  the entries of
%Lingua::JA::Romaji::allkana.  Each key is a single kana, and each
value is the corresponding romaji equivalent.

=head1 EXPORT

None by default.

&romajitokana, &kanatoromaji are available with EXPORT_OK,
as are %hiragana and %katakana.

=head1 BUGS

When using &kanatoromaji($kana), $kana should contain only 
proper EUC-encoded kana of the form 0xA4 or 0xA5 followed by a
single byte.  

Care should be taken when modifying %Lingua::JA::Romaji::allkana
to avoid the strings /ix/i or /ux/i as they will be removed in conversion.

Conversion is not necessarily reversible.  This is because there can be
many romaji representations of given kana.

Certain morae, namely /v[aeiou]/, can only be represented with katakana,
and &romajitokana will produce katakana characters for these morae 
even in hiragana mode.  

Kanji is not implemented at all.  It is a non-trivial problem, and
beyond the scope of this module.  

Behavior on non-little endian machines for &kanatoromaji is not
yet known.

=head1 LICENSE

This is a derived work of Jim Breen's XJDIC, and as such is licensed
under the GNU General Public License, a copy of which was distributed
with perl.  
#'

=head1 AUTHOR

Jacob C. Kesinger  E<lt>kesinger@math.ttu.eduE<gt>

=head1 SEE ALSO

L<perl>.

=cut
