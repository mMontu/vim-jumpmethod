# vim-jumpmethod
Add better `[[`, `]]`, `]m`, `[m`, `gd`, `gD` support for C++, C# and java

# Installation

* If using [vim-plug](https://github.com/junegunn/vim-plug), add the following line to your .vimrc file:
`Plug 'RobertCWebb/vim-jumpmethod'`.  Then run vim and use `:PlugInstall`

* Otherwise, copy the files into the matching subfolders in your vimfiles folder

# About

Based on [Andrew Radev's awesome Stack Overflow
answer](https://stackoverflow.com/a/6855438/79125), this plugin improves
`]m` and `[m` support for C#, Java, and C++.

It also uses [bybor answer](https://stackoverflow.com/a/25521838/79125) to use
OmniSharp support, if available.


Turned into a plugin by [idbrii](https://github.com/idbrii/vim-jumpmethod)

Modified by [RobertCWebb](https://github.com/RobertCWebb/vim-jumpmethod) in the following ways:

* Added Test.cs as a C# file to test on.  The fixes listed below reference it
* Fixed: In Func1() there were false positives where `if` or `using` statements span multiple lines
* Fixed: Func2() failed to hit before due to the template definition
* Fixed: Func3() failed to hit because a comment contained the word "if"
* Fixed: Func4() failed to hit because function heading was split over multiple lines
* Fixed: Func5() failed to hit too, here the '(' is also on a new line
* Fixed: Func6() failed to hit due to comments getting in the way
* Fixed previous position marker not being set, ie after using `[m` or `]m` you should be able to use `''` to go back to previous line
* Also, when searching back, I made it scroll up a little so the function name is visible, even though the cursor still lands on the '{' below
* Added mappings for `[[`, `]]`, `[]` and `][` which stop at class, property and enum definitions in addition to functions.  Their standard behaviour in vim is often useless for C# and C++.  `[m` and `]m` still only stop at methods and functions
* Added mappings for `gd` and `gD` which work much better in C++ and C#
