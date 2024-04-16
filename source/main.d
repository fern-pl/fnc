module main;

import parsing.tokenizer.tokens;
import parsing.tokenizer.make_tokens;

void main()
{
	Token[] tokens = tokenizeText(
		"
			module a.test.module{

			struct A kind:xmmword
			{
				uint a;
				ushort b;

				uint foo()
				{
				return a; 
				}
			}

			struct B
			{
				uint a;
				byte b;

				byte bar()
				{
				return b; 
				}
			}

			void main()
			{
				A a;
				uint b = a.foo();
				byte c = a |> B.bar();
			}
		");
	import parsing.treegen.gentree;
	generateGlobalScopeForCompilationUnit(tokens);
}
