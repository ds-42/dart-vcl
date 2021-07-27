part of vcl;

abstract class CHAR
{
  static const int NULL      = 0x0000;
  static const int SOX       = 0x0001;
  static const int STX       = 0x0002;
  static const int ETX       = 0x0003;
  static const int EOT       = 0x0004;
  static const int ENQ       = 0x0005;
  static const int ASC       = 0x0006;
  static const int BEL       = 0x0007;
  static const int BS        = 0x0008;
  static const int HT        = 0x0009;
  static const int TAB       = 0x0009; // \t
  static const int LF        = 0x000A; // \n
  static const int VT        = 0x000B;
  static const int FF        = 0x000C;
  static const int CR        = 0x000D; // \r
  static const int SO        = 0x000E;
  static const int SI        = 0x000F;

  static const int DLE       = 0x0010;
  static const int DC1       = 0x0011;
  static const int DC2       = 0x0012;
  static const int DC3       = 0x0013;
  static const int DC4       = 0x0014;
  static const int NAK       = 0x0015;
  static const int SYN       = 0x0016;
  static const int ETB       = 0x0017;
  static const int CAN       = 0x0018;
  static const int EM        = 0x0019;
  static const int SUB       = 0x001A;
  static const int ESC       = 0x001B;
  static const int FS        = 0x001C;
  static const int GSP       = 0x001D;
  static const int RSP       = 0x001E;
  static const int US        = 0x001F;

  static const int SPACE     = 0x0020;
  static const int NOT       = 0x0021; //  !
  static const int QUOTATION = 0x0022; //  "
  static const int QUOT      = 0x0022; //  " *short
  static const int HASH      = 0x0023; //  #
  static const int DOLLAR    = 0x0024; //  $
  static const int PERCENT   = 0x0025; //  %
  static const int AMPERSAND = 0x0026; //  &
  static const int AMP       = 0x0026; //  & *short
  static const int APOSTROPHE= 0x0027; //  '
  static const int APOS      = 0x0027; //  ' *short
  static const int LP        = 0x0028; //  (
  static const int RP        = 0x0029; //  )

  static const int MUL       = 0x002A; //  *
  static const int PLUS      = 0x002B; //  +
  static const int COMMA     = 0x002C; //  ,
  static const int MINUS     = 0x002D; //  -
  static const int DOT       = 0x002E; //  .
  static const int DIV       = 0x002F; //  /

  static const int ZERO      = 0x0030; //  0
  static const int ONE       = 0x0031; //  1
  static const int TWO       = 0x0032; //  2
  static const int THREE     = 0x0033; //  3
  static const int FOUR      = 0x0034; //  4
  static const int FIVE      = 0x0035; //  5
  static const int SIX       = 0x0036; //  6
  static const int SEVEN     = 0x0037; //  7
  static const int EIGHT     = 0x0038; //  8
  static const int NINE      = 0x0039; //  9
  static const int COLON     = 0x003A; //  :
  static const int SEMI      = 0x003B; //  ;
  static const int LESS      = 0x003C; //  <
  static const int LT        = 0x003C; //  < *short
  static const int EQUALS    = 0x003D; //  =
  static const int MORE      = 0x003E; //  >
  static const int GT        = 0x003E; //  > *short
  static const int QUESTION  = 0x003F; //  ?

  static const int A         = 0x0041; //  A
  static const int B         = 0x0042; //  B
  static const int C         = 0x0043; //  C
  static const int D         = 0x0044; //  D
  static const int E         = 0x0045; //  E
  static const int F         = 0x0046; //  F
  static const int G         = 0x0047; //  G
  static const int H         = 0x0048; //  H
  static const int I         = 0x0049; //  I
  static const int J         = 0x004A; //  J
  static const int K         = 0x004B; //  K
  static const int L         = 0x004C; //  L
  static const int M         = 0x004D; //  M
  static const int N         = 0x004E; //  N
  static const int O         = 0x004F; //  O

  static const int P         = 0x0050; //  P
  static const int Q         = 0x0051; //  Q
  static const int R         = 0x0052; //  R
  static const int S         = 0x0053; //  S
  static const int T         = 0x0054; //  T
  static const int U         = 0x0055; //  U
  static const int V         = 0x0056; //  V
  static const int W         = 0x0057; //  W
  static const int X         = 0x0058; //  X
  static const int Y         = 0x0059; //  Y
  static const int Z         = 0x005A; //  Z
  static const int LS        = 0x005B; //  [
  static const int SLASH     = 0x005C; //  \
  static const int RS        = 0x005D; //  ]
  static const int XOR       = 0x005E; //  ^
  static const int LOWLINE   = 0x005F; //  _

  static const int a         = 0x0061; //  a
  static const int b         = 0x0062; //  b
  static const int c         = 0x0063; //  c
  static const int d         = 0x0064; //  d
  static const int e         = 0x0065; //  e
  static const int f         = 0x0066; //  f
  static const int g         = 0x0067; //  g
  static const int h         = 0x0068; //  h
  static const int i         = 0x0069; //  i
  static const int j         = 0x006A; //  j
  static const int k         = 0x006B; //  k
  static const int l         = 0x006C; //  l
  static const int m         = 0x006D; //  m
  static const int n         = 0x006E; //  n
  static const int o         = 0x006F; //  o

  static const int p         = 0x0070; //  p
  static const int q         = 0x0071; //  q
  static const int r         = 0x0072; //  r
  static const int s         = 0x0073; //  s
  static const int t         = 0x0074; //  t
  static const int u         = 0x0075; //  u
  static const int v         = 0x0076; //  v
  static const int w         = 0x0077; //  w
  static const int x         = 0x0078; //  x
  static const int y         = 0x0079; //  y
  static const int z         = 0x007A; //  z

  static const int LB        = 0x007B; //  {
  static const int OR        = 0x007C; //  |
  static const int RB        = 0x007D; //  }
  static const int TILDE     = 0x007E; //  ~

}