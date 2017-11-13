*read a text file into one character;
*won't work if the file is longer than 32767 characters;
data one_string;
  infile "input.txt" recfm = n;
  input x $char32767.;
 run;
