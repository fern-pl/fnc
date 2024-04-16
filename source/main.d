module main;

import parsing.tokenizer.make_tokens;

void main()
{
	tokenizeText(
		"
			module a;

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
}
