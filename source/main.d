module main;

import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens;

void main()
{
    Token[] tokens = tokenizeText(
        "/*
    This is an example file in the Fern project, along with an example
    of multi-line comments. Comments are automatically stripped before
    the tokenizing process, like any other language, so this works.
    
    Copyright (C) 2024 - Fern Developers

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

module math;

import std.stdio;
import std.math;

void main()
{
    print(\"Enter a number: \");
    string aString = getInput();

    print(\"Enter another number: \")
    string bString = getInput();

    print(\"Enter yet another number: \")
    string cString = getInput();

    // casting automatically converts from string to float
    // Although this might through an exception. 
    float a = aString |> float;


}
		");
    import parsing.treegen.gentree;

    generateGlobalScopeForCompilationUnit(tokens);
}
