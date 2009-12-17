#!/usr/bin/perl

my %Geek=(
    "B"  => "Business",
    "C"  => "Classics",
    "CA" => "Commercial Arts",
    "CM" => "Computer Management",
    "CS" => "Computer Science",
    "CC" => "Communications",
    "E"  => "Engineering",
    "ED" => "Education",
    "FA" => "Fine Arts",
    "G"  => "Government",
    "H"  => "Humanities",
    "IT" => "Information Technology",
    "J"  => "Jurisprudence (Law)",
    "LS" => "Library Science",
    "L"  => "Literature",
    "MC" => "Mass Communications",
    "M"  => "Math",
    "MD" => "Medicine",
    "MU" => "Music",
    "PA" => "Performing Arts",
    "P"  => "Philosophy",
    "S"  => "Science (Physics, Chemistry, Biology, etc.)",
    "SS" => "Social Science (Psychology, Sociology, etc.)",
    "TW" => "Technical Writing",
    "O"  => "Other",
    "U"  => "Undecided",
    "!"  => "No qualifications",
    "AT" => "All Trades"
);

my %d=(
    "++" => "I tend to wear conservative dress such as a business suit or worse, a tie.",
    "+" => "Good leisure-wear. Slacks, button-shirt, etc. No jeans, tennis shoes, or t-shirts.",
    "" => "I dress a lot like those found in catalog ads. Bland, boring, without life or meaning.",
    "-" => "I'm usually in jeans and a t-shirt.",
    "--" => "My t-shirts go a step further and have a trendy political message on them.",
    "---" => "Punk dresser, including, but not limited to, torn jeans and shirts, body piercings, and prominent tattoos.",
    "x" => "Cross Dresser",
    "?" => "I have no idea what I am wearing right now, let alone what I wore yesterday.",
    "!" => "No clothing. Quite a fashion statement, don't you think?",
    "pu" => "I wear the same clothes all the time, no matter the occasion, forgetting to do laundry between wearings.",
);

my %s1=(
    '+++' => 'I usually have to duck through doors',
    '++'  => 'I\'m a basketball candidate',
    '+'   => 'I\'m a little taller than most',
    ''    => 'I\'m an average geek',
    '-'   => 'I look up to most people',
    '--'  => 'I look up to damn near everybody',
    '---' => 'I take a phone book with me when I go out'
);

my %s2=(
    '+++' => 'I take up three movie seats',
    '++'  => 'I\'m a linebacker candidate',
    '+'   => 'I\'m a little rounder than most',
    ''    => 'I\'m an average geek',
    '-'   => 'Everyone tells me to gain a few pounds',
    '--'  => 'I tend to have to fight against a strong breeze',
    '---' => 'My bones are poking through my skin'
);

my %a=(
    "+++"   => "I'm 60 and up",
    "++"    => "I'm 50-59",
    "+"     => "I'm 40-49",
    ""      => "I'm 30-39",
    "-"     => "I'm 25-29",
    "--"    => "I'm 20-24",
    "---"   => "I'm 15-19",
    "----"  => "I'm 10-14",
    "-----" => "I'm 9 and under (Geek in training?)",
    "?"     => "I'm immortal",
    "!"     => "It's none of your business how old I am",
);

my %C=(
    "++++" => "I'll be first in line to get the new cybernetic interface installed into my skull.",
    "+++" => "You mean there is life outside of Internet? You're shittin' me! I haven't dragged myself to class in weeks.",
    "++" => "Computers are a large part of my existence. When I get up in the morning, the first thing I do is log myself in. I play games or mud on weekends, but still manage to stay off of academic probation.",
    "+" => "Computers are fun and I enjoy using them. I play a mean game of DOOM! and can use a word processor without resorting to the manual too often. I know that a 3.5\" disk is not a hard disk. I also know that when it says 'press any key to continue', I don't have to look for a key labeled 'ANY'.",
    "" => "Computers are a tool, nothing more. I use it when it serves my purpose.",
    "-" => "Anything more complicated than my calculator and I'm screwed.",
    "--" => "Where's the on switch?",
    "---" => "If you even mention computers, I will rip your head off!",
);

my %U1=(
    "B" => "I use BSD",
    "L" => "I use Linux",
    "U" => "I use Ultrix",
    "A" => "I use AIX",
    "V" => "I use SysV",
    "H" => "I use HPUX",
    "I" => "I use IRIX",
    "O" => "I use OSF/1 (aka Digital Unix)",
    "S" => "I use Sun OS/Solaris",
    "C" => "I use SCO Unix",
    "X" => "I use NeXT",
    "*" => "I use some other UNIX-like OS",
);

my %U2=(
    "++++" => "I am the sysadmin. If you try and crack my machine don't be surprised if the municipal works department gets an \"accidental\" computer-generated order to put start a new landfill on your front lawn or your quota is reduced to 4K.",
    "+++" => "I don't need to crack /etc/passwd because I just modified su so that it doesn't prompt me. The admin staff doesn't even know I'm here.",
    "++" => "I've get the entire admin ticked off at me because I am always using all of the CPU time and trying to run programs that I don't have access to. I'm going to try cracking /etc/passwd next week, just don't tell anyone.",
    "+" => "I not only have a Unix account, but I slam VMS any chance get.",
    "" => "I have a Unix account to do my stuff in",
    "-" => "I have a VMS account.",
    "--" => "I've seen Unix and didn't like it. DEC rules!",
    "---" => "Unix geeks are actually nerds in disguise.",
);

my %P=(
    "+++++" => "I am Larry Wall, Tom Christiansen, or Randal Schwartz.",
    "++++" => "I don't write Perl, I speak it. Perl has superseded all other programming languages. I firmly believe that all programs can be reduced to a Perl one-liner. I use Perl to achieve U+++ status.",
    "+++" => "Perl is a very powerful programming tool. Not only do I no longer write shell scripts, I also no longer use awk or sed. I use Perl for all programs of less than a thousand lines.",
    "++" => "Perl is a powerful programming tool. I don't write shell scripts anymore because I write them in Perl.",
    "+" => "I know of Perl. I like Perl. I just haven't learned much Perl, but it is on my agenda.",
    "" => "I know Perl exists, but that's all.",
    "-" => "What's Perl got that awk and sed don't have?",
    "--" => "Perl users are sick, twisted programmers who are just showing off.",
    "---" => "Perl combines the power of sh, the clarity of sed, and the performance of awk with the simplicity of C. It should be banned.",
    "!" => "Our paranoid admin won't let us install Perl! Says it's a \"hacking tool\".",
);

my %L=(
    "+++++" => "I am Linus, grovel before me.",
    "++++" => "I am a Linux wizard. I munch C code for breakfast and have enough room left over for a kernel debugging. I have so many patches installed that I lost track about ten versions ago. Linux newbies consider me a net.god.",
    "+++" => "I use Linux exclusively on my system. I monitor comp.os.linux.* and even answer questions sometimes.",
    "++" => "I use Linux ALMOST exclusively on my system. I've given up trying to achieve Linux.God status, but welcome the OS as a replacement for DOS. I only boot to DOS to play games.",
    "+" => "I've managed to get Linux installed and even used it a few times. It seems like it is just another OS.",
    "" => "I know what Linux is, but that's about all",
    "-" => "I have no desire to use Linux and frankly don't give a rats patootie about it. There are other, better, operating systems out there. Like Mac, DOS, or Amiga-OS. Or, better yet even, would be another free Unix OS like FreeBSD.",
    "--" => "Unix sucks. Because Linux = Unix. Linux Sucks. I worship Bill Gates.",
    "---" => "I am Bill Gates.",
);

my %E=(
    "+++" => "Emacs is my login shell!! M-x doctor is my psychologist! I use emacs to control my TV and toaster oven! All you vi people don't know what you're missing! I read alt.religion.emacs, alt.sex.emacs, and comp.os.emacs.",
    "++" => "I know and use elisp regularly!",
    "+" => "Emacs is great! I read my mail and news with it!",
    "" => "Yeah, I know what emacs is, and use it as my regular editor.",
    "-" => "Emacs is too big and bloated for my tastes",
    "--" => "Emacs is just a fancy word processor",
    "---" => "Emacs sucks! vi forever!!!",
    "----" => "Emacs sucks! pico forever!!!",
);

my %W=(
    "+++" => "I am a WebMaster . Don't even think about trying to view my homepage without the latest version of Netscape. When I'm not on my normal net connection, I surf the web using my Newton and a cellular modem.",
    "++" => "I have a homepage. I surf daily. My homepage is advertised in my .signature.",
    "+" => "I have the latest version of Netscape, and wander the web only when there's something specific I'm looking for.",
    "" => "I have a browser and a connection. Occasionally I'll use them.",
    "-" => "The web is really a pain. Life was so much easier when you could transfer information by simple ASCII. Now everyone won't even consider your ideas unless you spiff them up with bandwidth-consuming pictures and pointless information links.",
    "--" => "A pox on the Web! It wastes time and bandwidth and just gives the uneducated morons a reason to clutter the Internet.",
);

my %N=(
    "++++" => "I am Tim Pierce",
    "+++" => "I read so many newsgroups that the next batch of news comes in before I finish reading the last batch, and I have to read for about 2 hours straight before I'm caught up on the morning's news. Then there's the afternoon...",
    "++" => "I read all the news in a select handful of groups.",
    "+" => "I read news recreationally when I have some time to kill.",
    "" => "Usenet News? Sure, I read that once",
    "-" => "News is a waste of my time and I avoid it completely",
    "--" => "News sucks! 'Nuff said.",
    "---" => "I work for Time Magazine.",
    "----" => "I am a Scientologist.",
    "*" => "All I do is read news",
);

my %o=(
    "+++++" => "I am Steve Kinzler",
    "++++" => "I am an active Priest",
    "+++" => "I was a Priest, but have retired.",
    "++" => "I have made the Best Of Oracularities.",
    "+" => "I have been incarnated at least once.",
    "" => "I've submitted a question, but it has never been incarnated.",
    "-" => "I sent my question to the wrong group and got flamed.",
    "--" => "Who needs answers from a bunch of geeks anyhow?",
);

my %K=(
    "++++++" => "I am Kibo",
    "+++++" => "I've had sex with Kibo",
    "++++" => "I've met Kibo",
    "+++" => "I've gotten mail from Kibo",
    "++" => "I've read Kibo",
    "+" => "I like Kibo",
    "" => "I know who Kibo is",
    "-" => "I don't know who Kibo is",
    "--" => "I dislike Kibo",
    "---" => "I am currently hunting Kibo down with the intent of ripping his still-beating heart out of his chest and showing it to him as he dies",
    "----" => "I am Xibo",
);

my %w=(
    "+++++" => "I am Bill Gates",
    "++++" => "I have Windows, Windows 95, Windows NT, and Windows NT Advanced Server all running on my SMP RISC machine. I haven't seen daylight in six months.",
    "+++" => "I am a MS Windows programming god. I wrote a VxD driver to allow MS Windows and DOS to share the use of my waffle iron. P.S. Unix sux.",
    "++" => "I write MS Windows programs in C and think about using C++ someday. I've written at least one DLL.",
    "+" => "I have installed my own custom sounds, wallpaper, and screen savers so my PC walks and talks like a fun house. Oh yeah, I have a hundred TrueType(tm) fonts that I've installed but never used. I never lose Minesweeper and Solitaire",
    "" => "Ok, so I use MS Windows, I don't have to like it.",
    "-" => "I'm still trying to install MS Windows and have at least one peripheral that never works right",
    "--" => "MS Windows is a joke operating system. Hell, it's not even an operating system. NT is Not Tough enough for me either. 95 is how may times it will crash an hour.",
    "---" => "Windows has set back the computing industry by at least 10 years. Bill Gates should be drawn, quartered, hung, shot, poisoned, disembowelled, and then REALLY hurt.",
);

my %O=(
    "+++" => "I live, eat and breathe OS/2. All of my hard drives are HPFS. I am the Anti-Gates.",
    "++" => "I use OS/2 for all my computing needs. I use some DOS and Windows programs, but run them under OS/2. If the program won't run under OS/2, then obviously I don't need it.",
    "+" => "I keep a DOS partition on my hard drive \"just in case\". I'm afraid to try HPFS.",
    "" => "I finally managed to get OS/2 installed but wasn't too terribly impressed.",
    "-" => "Tried OS/2, didn't like it.",
    "--" => "I can't even get OS/2 to install!",
    "---" => "Windows RULES!!! Long live Bill Gates. (See w++++)",
    "----" => "I am Bill Gates of Borg. OS/2 is irrelevant.",
);

my %M=(
    "++" => "I am a Mac guru. Anything those DOS putzes and Unix nerds can do, I can do better, and if not, I'll write the damn software to do it.",
    "+" => "A Mac has it's uses and I use it quite often.",
    "" => "I use a Mac, but I'm pretty indifferent about it.",
    "-" => "Macs suck. All real geeks have a character prompt.",
    "--" => "Macs do more than suck. They make a user stupid by allowing them to use the system without knowing what they are doing. Mac weenies have lower IQs than the fuzz in my navel.",
);

my %V=(
    "+++" => "I am a VMS sysadmin. I wield far more power than those UNIX admins, because UNIX can be found on any dweeb's desktop. Power through obscurity is my motto.",
    "++" => "Unix is a passing fad compared to the real power in the universe, my VMS system.",
    "+" => "I tend to like VMS better than Unix",
    "" => "I've used VMS.",
    "-" => "Unix is much better than VMS for my computing needs.",
    "--" => "I would rather smash my head repeatedly into a brick wall than suffer the agony of working with VMS. It's reminiscent of a dead and decaying pile of moose droppings. Unix rules the universe.",
);

my %PS=(
    "+++" => "Legalize drugs! Abolish the government. \"Fuck the draft!\"",
    "++" => "I give to liberal causes. I march for gay rights. I'm a card carrying member of the ACLU. Keep abortion safe and legal.",
    "+" => "My whole concept of liberalism is that nobody has the right to tell anybody else what to do, on either side of the political fence. If you don't like it, turn the bloody channel.",
    "" => "I really don't have an opinion; nobody's messing with my freedoms right now.",
    "-" => "Label records! Keep dirty stuff off the TV and the Internet.",
    "--" => "Oppose sex education, abortion rights, gay rights. Rush Limbaugh is my spokesman.",
    "---" => "Repent left-wing sinners and change your wicked evil ways. Buchanan/Robertson in '96.",
);

my %PE=(
    "+++" => "Abolish antitrust legislation. Raise taxes on everyone but the rich so that the money can trickle-down to the masses.",
    "++" => "Keep the government off the backs of businesses. Deregulate as much as possible.",
    "+" => "Balance the budget with spending cuts and an amendment.",
    "" => "Distrust both government and business.",
    "-" => "It's ok to increase government spending, so we can help more poor people. Tax the rich! Cut the defense budget!",
    "--" => "Capitalism is evil! Government should provide the services we really need. Nobody should be rich.",
);

my %Y=(
    "+++" => "I am T.C. May",
    "++" => "I am on the cypherpunks mailing list and active around Usenet. I never miss an opportunity to talk about the evils of Clipper and ITAR and the NSA. Orwell's 1984 is more than a story, it is a warning to our's and future generations. I'm a member of the EFF.",
    "+" => "I have an interest and concern in privacy issues, but in reality I am not really all that active or vocal.",
    "" => "I'm pretty indifferent on the whole issue if privacy.",
    "-" => "It seems to me that all of these concerns are a little extreme. I mean, the government must be able to protect itself from criminals and the populace from indecent speech.",
    "--" => "Get a life. The only people that need this kind of protection are people with something to hide. I think cypherpunks are just a little paranoid.",
    "---" => "I am L. Detweiler.",
);

my %PGP=(
    "++++" => "I am Philip Zimmerman",
    "+++" => "I don't send or answer mail that is not encrypted, or at the very least signed. If you are reading this without decrypting it first, something is wrong. IT DIDN'T COME FROM ME!",
    "++" => "I have the most recent version and use PGP regularly",
    "+" => "\"Finger me for my PGP public key\"",
    "" => "I've used PGP, but stopped long ago.",
    "-" => "I don't have anything to hide.",
    "--" => "I feel that the glory of the Internet is in the anarchic, trusting environment that so nurtures the exchange of information. Encryption just bogs that down.",
    "---" => "If you support encryption on the Internet, you must be a drug dealer or terrorist or something like that.",
    "----" => "Oh, here is something you all can use that is better (insert Clipper here).",

);

my %t=(
    "+++" => "Star Trek's not just a TV show, it's a religion. I know all about warp field dynamics and the principles behind the transporter. I have memorized the TECH manual. I speak Klingon. I go to cons with Vulcan ears on. I have no life.",
    "++" => "Star Trek's the best show around. I have all the episodes and the movies on tape and can quote entire scenes verbatim. I've built a few of the model kits too. But you'll never catch me at one of those conventions. Those people are kooks.",
    "+" => "Star Trek's a damn fine TV show and is one of the only things good on television any more.",
    "" => "Star Trek's just another TV show",
    "-" => "Maybe it is just me, but I have no idea what the big deal with Star Trek is. Perhaps I'm missing something but I just think it is bad drama.",
    "--" => "Star Trek is just another Space Opera. William Shatner isn't an actor, he's a poser! And what's with this Jean-Luc Picard? A Frenchman with a British accent? Come on. Isn't Voyager just a rehash of Lost in Space? Has Sisko even breathed in the last two seasons? Come on. I'd only watch this show if my remote control broke.",
    "---" => "Star Trek SUCKS! It is the worst crap I have ever seen! Hey, all you trekkies out there, GET A LIFE! (William Shatner is a t---)",
    "*" => "I identify with Barclay, the greatest of the Trek Geeks.",
);

my %_5=(
    "++++" => "I am J. Michael Straczynski",
    "+++" => "I am a True Worshipper of the Church of Joe who lives eats breathes and thinks Babylon 5, and has Evil thoughts about stealing Joe's videotape archives just to see episodes earlier. I am planning to break into the bank and steal the triple-encoded synopsis of the 5-year arc.",
    "++" => "Babylon 5: Finally a show that shows what a real future would look like. None of this Picardian \"Let's talk about it and be friends\" crap. And what's this? We finally get to see a bathroom! Over on that Enterprise, they've been holding it for over seven years!",
    "+" => "Babylon 5 certainly presents a fresh perspective in the Sci-Fi universe. I watch it weekly.",
    "" => "I've seen Babylon 5, I am pretty indifferent to it.",
    "-" => "Babylon 5 is sub-par. The acting is wooden, the special effects are obviously poor quality. In general, it seems like a very cheap Star Trek ripoff.",
    "--" => "Babylon 5: You call this Sci-Fi? That is such a load of crap! This show is just a soap with bad actors, piss-poor effects, and lame storylines. Puh-leese.",
);

my %X=(
    "++++" => "I am Chris Carter",
    "+++" => "This is the BEST show on TV, and it's about time. I've seen everything David Duchovny and Gillian Anderson have ever done that been recorded and I'm a loyal Duchovny/ Gillian Anderson fan. I've Converted at least 10 people. I have every episode at SP, debate the fine details on-line, and have a credit for at least 2 YAXAs.",
    "++" => "This is one of the better shows I've seen. I wish I'd taped everything from the start at SP, because I'm wearing out my EP tapes. I'll periodically debate online. I've Converted at least 5 people. I've gotten a YAXA.",
    "+" => "I've Converted my family and watch the show when I remember. It's really kinda fun.",
    "" => "Ho hum. Just another Fox show.",
    "-" => "It's ok if you like paranoia and conspiracy stories, but, let's face it, it's crap.",
    "--" => "If I wanted to watch this kind of stuff, I'd talk to Oliver Stone",
);

my %R=(
    "+++" => "I've written and published my own gaming materials.",
    "++" => "There is no life outside the role of the die. I know all of piddly rules of (chosen game). _MY_ own warped rules scare the rest of the players.",
    "+" => "I've got my weekly sessions set up and a character that I know better than I know myself.",
    "" => "Role-Playing? That's just something to do to kill a Saturday afternoon",
    "-" => "Gosh, what an utter waste of time!",
    "--" => "Role-Players are instruments of pure evil.",
    "---" => "I work for T\$R.",
    "*" => "I thought life WAS role-playing?",
);

my %tv=(
    "+++" => "There's nothing I can experience \"out there\" that I can't see coming over my satellite dish. I wish there were MORE channels. I live for the O.J. Trial.",
    "++" => "I just leave the tv on, to make sure I don't miss anything.",
    "+" => "I watch some tv every day.",
    "" => "I watch only the shows that are actually worthwhile, such as those found on PBS.",
    "-" => "I watch tv for the news and 'special programming.'",
    "--" => "I turn my tv on during natural disasters.",
    "!" => "I do not own a television.",
);

my %b=(
    "++++" => "I read a book a day. I have library cards in three states. I have discount cards from every major bookstore. I've ordered books from another country to get my Favorite Author Fix.",
    "+++" => "I consume a few books a week as part of a staple diet.",
    "++" => "I find the time to get through at least one new book a month.",
    "+" => "I enjoy reading, but don't get the time very often.",
    "" => "I read the newspaper and the occasional book.",
    "-" => "I read when there is no other way to get the information.",
    "--" => "I did not actually READ the geek code, I just had someone tell me.",
);

my %DI=(
    "+++++" => "I am Scott Adams.",
    "++++" => "I've received mail from Scott Adams. I'm in the DNRC (Dogbert's New Ruling Class).",
    "+++" => "I am a Dilbert prototype",
    "++" => "I work with people that act a lot like Dilbert and his boss.",
    "+" => "I read Dilbert daily, often understanding it",
    "" => "I read Dilbert infrequently, rarely understanding it",
    "-" => "Is that the comic about the engineers?",
    "--" => "Don't read it, but I think the dog is kinda cute.",
    "---" => "I don't think it's funny to make fun of managers trying their best to run their organizational units.",
);

my %D=(
    "++++" => "I work for iD Software.",
    "+++" => "I crank out PWAD files daily, complete with new monsters, weaponry, sounds and maps. I'm a DOOM God. I can solve the original maps in nightmare mode with my eyes closed.",
    "++" => "I've played the shareware version and bought the real one and I'm actually pretty good at the game. I occasionally download PWAD files and play them too.",
    "+" => "It's a fun, action game that is a nice diversion on a lazy afternoon.",
    "" => "I've played the game and I'm pretty indifferent.",
    "-" => "I've played the game and really didn't think it was all that impressive.",
    "--" => "It's an overly-violent game and pure crap",
    "---" => "To hell with Doom, I miss Zork.",
    "----" => "I've seen better on my Atari 2600",
);

my %G=(
    "+++++" => "I am Robert Hayden",
    "++++" => "I have made a suggestion for future versions of the Geek Code",
    "+++" => "I have memorized the entire Geek Code, and can decode others' codes in my head. I know by heart where to find the current version of the code on the net.",
    "++" => "I know what each letter in the Geek Code means, but sometimes have to look up the specifics.",
    "+" => "I was once G++ (or higher), but the new versions are getting too long and too complicated.",
    "" => "I know what the Geek Code is and even did up this code.",
    "-" => "What a tremendous waste of time this Geek Code is.",
    "--" => "Not only is the Geek Code a waste of time, but it obviously shows that this Hayden guy needs a life.",
);

my %e=(
    "+++++" => "I am Stephen Hawking",
    "++++" => "Managed to get my Ph.D.",
    "+++" => "Got a Masters degree",
    "++" => "Got a Bachelors degree",
    "+" => "Got an Associates degree",
    "" => "Finished High School",
    "-" => "Haven't finished High School",
    "--" => "Haven't even entered High School",
    "*" => "I learned everything there is to know about life from the \"Hitchhiker's Trilogy\".",
);

my %h=(
    "++" => "Living in a cave with 47 computers and an Internet feed, located near a Dominoes pizza. See !d.",
    "+" => "Living alone, get out once a week to buy food, no more than once a month to do laundry. All surfaces covered.",
    "" => "Friends come over to visit every once in a while to talk about Geek things. There is a place for them to sit.",
    "-" => "Living with one or more registered Geeks.",
    "--" => "Living with one or more people who know nothing about being a Geek and refuse to watch Babylon 5.",
    "---" => "Married",
    "----" => "Married with children - Al Bundy can sympathize",
    "!" => "I am stuck living with my parents!",
    "*" => "I'm not sure where I live anymore. This lab/workplace seems like home to me.",
);

my %r=(
    "+++" => "Found someone, dated, and am now married.",
    "++" => "I've dated my current S.O. for a long time.",
    "+" => "I date frequently, bouncing from one relationship to another.",
    "" => "I date periodically.",
    "-" => "I have difficulty maintaining a relationship.",
    "--" => "People just aren't interested in dating me.",
    "---" => "I'm beginning to think that I'm a leper or something, the way people avoid me like the plague.",
    "!" => "I've never had a relationship.",
    "*" => "Member of the SBCA (Sour Bachelor(ette)'s Club of America). The motto is 'Bitter, but not Desperate'.",
    "%" => "I was going out with someone, but the asshole dumped me.",
);

my %z=(
    "+++++" => "I am Madonna",
    "++++" => "I have a few little rug rats to prove I've been there. Besides, with kids around, who has time for sex?",
    "+++" => "I'm married, so I can get it (theoretically) whenever I want.",
    "++" => "I was once referred to as 'easy'. I have no idea where that might have come from though.",
    "+" => "I've had real, live sex.",
    "" => "I've had sex. Oh! You mean with someone else? Then no.",
    "-" => "Not having sex by choice.",
    "--" => "Not having sex because I just can't get any...",
    "---" => "Not having sex because I'm a nun or a priest.",
    "*" => "I'm a pervert.",
    "**" => "I've been known to make perverts look like angels.",
    "!" => "Sex? What's that? I've had no sexual experiences.",
    "?" => "It's none of your business what my sex life is like.",
    "!+" => "Sex? What's that? No experience, willing to learn!",
);

my $code=join " ", <>;
$code=~s/--+\s*BEGIN GEEK CODE BLOCK\s*--+//;
$code=~s/--+\s*END GEEK CODE BLOCK\s*--+//;
$code=~s/[\n\r]//g;

my @parts=split / +/, $code;

foreach (@parts) {
    next if /^\s*$/;
    print " - ";
    if (/^G(?:B|C|CA|CM|CS|CC|E|ED|FA|G|H|IT|J|LS|L|MC|M|MD|MU|PA|P|S|SS|TW)/) {
        s/^G//;
        my @geekness=split /\//;
        print "Geek of ";
        my $f=0;
        foreach (@geekness) {
            print ", " if $f;
            print $Geek{$_};
            $f=1;
        }
    } elsif (/^(!?)d(.*)$/) {
        print $d{'!'} if ($1);
        print $d{$2} unless ($1);
    } elsif (/^s([+-]*):([+-]*)$/) {
        print $s1{$1}."\n - ".$s2{$2};
    } elsif (/^(!?)a([+-?]*)$/) {
        print $a{'!'} if ($1);
        print $a{$2} unless ($1);
    } elsif (/^a(\d+)$/) {
        print "I'm $1 years old";
    } elsif (/^C([+-]*)$/) {
        print $C{$1};
    } elsif (/^U([BLUAVHIOSCX*])([+-]*)$/) {
        print $U1{$1}."\n - ".$U2{$2};
    } elsif (/^P([+!-]*)$/) {
        print $P{$1};
    } elsif (/^L([+-]*)$/) {
        print $L{$1};
    } elsif (/^E([+-]*)$/) {
        print $E{$1};
	} elsif (/^W([+-]*)$/) {
		print $W{$1};
 	} elsif (/^N([+*-]*)$/) {
		print $N{$1};
 	} elsif (/^o([+-]*)$/) {
		print $o{$1};
 	} elsif (/^K([+-]*)$/) {
		print $K{$1};
 	} elsif (/^w([+-]*)$/) {
		print $w{$1};
 	} elsif (/^O([+-]*)$/) {
		print $O{$1};
 	} elsif (/^M([+-]*)$/) {
		print $M{$1};
 	} elsif (/^V([+-]*)$/) {
		print $V{$1};
 	} elsif (/^PS([+-]*)$/) {
		print $PS{$1};
 	} elsif (/^PE([+-]*)$/) {
		print $PE{$1};
 	} elsif (/^Y([+-]*)$/) {
		print $Y{$1};
 	} elsif (/^PGP([+-]*)$/) {
		print $PGP{$1};
 	} elsif (/^t([+*-]*)$/) {
		print $t{$1};
 	} elsif (/^5([+-]*)$/) {
		print $_5{$1};
 	} elsif (/^X([+-]*)$/) {
		print $X{$1};

 	} elsif (/^R([+*-]*)$/) {
		print $R{$1};

    } elsif (/^(!?)tv([+-]*)$/) {
        print $tv{'!'} if ($1);
        print $tv{$2} unless ($1);

 	} elsif (/^b([+-]*)$/) {
		print $b{$1};
 	} elsif (/^DI([+-]*)$/) {
		print $DI{$1};
 	} elsif (/^D([+-]*)$/) {
		print $D{$1};
 	} elsif (/^G([+-]*)$/) {
		print $G{$1};
 	} elsif (/^e([+*-]*)$/) {
		print $e{$1};
 	} elsif (/^h([+!*-]*)$/) {
		print $h{$1};
        
    } elsif (/^(!?)r([+%*-]*)$/) {
        print $r{'!'} if ($1);
        print $r{$2} unless ($1);

    } elsif (/^(!?)([xyz])([+?*-]*)$/) {
        print("Female: ") if ($2 eq "x");
        print("Male: ") if ($2 eq "y");
        print("Undisclosed: ") if ($2 eq "z");
        if ($1) {
            print $z{'!+'} if ($3 eq '+');
            print $z{'!'} unless ($3 eq '+');
        }
        print $z{$3} unless ($1);
    }

    print "\n";
}

#print $code;
