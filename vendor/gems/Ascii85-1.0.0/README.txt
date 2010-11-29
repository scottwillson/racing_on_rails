= Ascii85

* http://ascii85.rubyforge.org


== DESCRIPTION:

Ascii85 is a simple gem that provides methods for encoding/decoding Adobe's
binary-to-text encoding of the same name.

See http://www.adobe.com/products/postscript/pdfs/PLRM.pdf page 131 and
http://en.wikipedia.org/wiki/Ascii85 for more information about the format.


== SYNOPSIS:

  require 'rubygems'
  require 'ascii85'

  Ascii85::encode("Ruby")
  => "<~;KZGo~>"

  Ascii85::decode("<~;KZGo~>")
  => "Ruby"

In addition, Ascii85::encode can take a second parameter that specifies the
length of the returned lines. The default is 80; use +false+ for unlimited.

Ascii85::decode expects the input to be enclosed in <~ and ~> — it
ignores everything outside of these. The output of Ascii85::decode
will have the ASCII-8BIT encoding, so in Ruby 1.9 you may have to use
<tt>String#force_encoding</tt> to correct the encoding.


== Command-line utility

This gem includes +ascii85+, a command-line utility modeled after +base64+ from
the GNU coreutils. It can be used to encode/decode Ascii85 directly from the
command-line:

    Usage: ascii85 [OPTIONS] [FILE]
    Encodes or decodes FILE or STDIN using Ascii85 and write to STDOUT.
        -w, --wrap COLUMN                Wrap lines at COLUMN. Default is 80, use 0 for no wrapping
        -d, --decode                     Decode the input
        -h, --help                       Display this help and exit
            --version                    Output version information


== INSTALL:

* sudo gem install Ascii85


== LICENSE:

(The MIT License)

Copyright (c) 2009 Johannes Holzfuß

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
