#!/usr/bin/perl -w

use Text::Tokenizer ':all';

#open file and set add it to tokenizer inputs
open(F_CONFIG, "input.conf");
$tok_id = tokenizer_new(F_CONFIG);
tokenizer_options(TOK_OPT_NOUNESCAPE|TOK_OPT_PASSCOMMENT);

while(1) {
  ($str, $tok_type, $line, $err, $errline) = tokenizer_scan();
  last if($tok == TOK_ERROR || $tok == TOK_EOF);

  if($tok == TOK_TEXT)            {       }
  elsif($tok == TOK_BLANK)        {       }
  elsif($tok == TOK_DQUOTE)       { $str  = "\"$str\"";   }
  elsif($tok == TOK_SQUOTE)       { $str  = "\'$str\'";   }
  elsif($tok == TOK_SIQUOTE)      { $str  = "\`$str\'";   }
  elsif($tok == TOK_IQUOTE)       { $str  = "\`$str\`";   }
  elsif($tok == TOK_EOL)          {       }
  elsif($tok == TOK_COMMENT)      {       }
  elsif($tok == TOK_UNDEF)        { last; }
  else                            { last; };
  print $str;
}
tokenizer_delete($tokid);
