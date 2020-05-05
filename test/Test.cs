
namespace NameyMcNamespace
{
	public enum AnEnum	// [[ should stop here, but not [m
	{
		One,
		Two
	}

	class Blah			// [[ should stop here, but not [m
	{
		string a="var", b=c->var, d = "var";  // gD shouldn't stop here
		string a="var", b=c.var, var = "var"; // gD should fine this one
		int arg = 0;		// gd on arg below shouldn't go back this far
		float _property;
		float property	// [[ should stop here, but not [m
		{
			get		// Stop for the property above, not here
			{
				return _property;
			}
			set		// Stop for the property above, not here
			{
				_property = value;
			}
		}

		// Only stop once on line below
		float property2 { get { return 1.0f; } set { blah; } }

		float this[int index]	// Stop here
		{
			blah;
		}

		bool FuncWithCommentsInArgs(const char *str, int numFrames,
				  float val /* = 0.0f */, Type blah /* = 0 */,
				  float val /* = 0.0f */, int quality /* = -1 */)
		{ // Land here from far below should scroll up to show Func name
			cmd;
		}

		void FuncWithNoGapBeforeNextFunc()
		{
			// The lack of a blank line between this function and the next
			// would confuse vim's default gd behaviour.
			int var = 0;		// gd on var below shouldn't stop here
		}
		new void Func1(int arg)		// Stop here, allow "new" keyword
		{
			// gd on var below should not go here
			/* Nor should gd on var stop here
			 * Nor should gd on var stop here
			 */
			{
				int var = 0;	// gd on var below shouldn't stop here
			}
			string str = "var";	/* gd on var shouldn't stop here either */
			int i = blah.var;	// gd on var shouldn't stop here either
			int i = blah->var;	// gd on var shouldn't stop here either
			int i = blah::var;	// gd on var shouldn't stop here either
			int v = b.var, var = b.var;	// YES, gd on var SHOULD FIND THIS ONE!
			int var2 = var;		// Another distraction, gd shouldn't stop here
			var;				// Place cursor on var and hit "gd"
			arg;				// gd on arg here should go back to Func1()

			if (ok &&
				IsOK())			// Don't stop here
			{
				objInfo.OnCreationComplete();
			}

			// Don't stop anywhere in the following block
			if (blah) {
				if (blah)
				{
					for (i = 0; i < 5; i++)
					{
						cmd;
					}
				}
				else
				{
					blah;
				}
			} else {
				blah;
			}

			do					// Don't stop here
			{
				blah;
			} while (blah);

			// Don't stop for lambda functions
			lambda(() =>
			{
				blah;
			});

			/* Blah blah
			 * Blah blah */
			// Ignore comment lines
			/*
			 * Blah blah
			 * Blah blah
			 */
			// Ignore code in braces like the following.  Look past
			// preceding comments to figure out the context.
			{
				blah;
			}

			Type blah = new Type	// Don't stop at object initialisers
			{
				width = _width,
				height = _height,
			};

			Type blah = new Type()	// Don't stop at object initialisers
			{
				width = _width,
				height = _height,
			};

			string[] names =		// Don't stop here
			{
				"Bob",
				"Blah",
			};

			switch (blah)
			{
				case A:
					{				// Don't stop here
						cmd;
						cmd;
					}
					return;
				default:
					{				// Don't stop here
						cmd;
					}
					break;
			}

			using (a =
				   blah())			// Don't stop here
			{
				cmd;
			}

			// Don't stop anywhere in the try-catch-finally block
			try
			{
				blah;
			}
			catch (Exception e)
			{
				blah;
			}
			finally
			{
				blah;
			}
		}

		void Func2<T>(T arg)		// Recognise functions with templates
		{
			cmd;
		}
	}

	class Blah2 : Base				// [[ should stop here, not not [m
	{
		void Func3(int num)	{		// Stop even if comment has words like if()
			cmd;
		}

		void Func4(int num,
				   int num2)		// Recognise multiline function headings
		// Don't let comments confuse you
		/*
		 * Blah blah
		 * Blah blah
		 */
		{
			cmd;

#ifdef BLAH
			if (test &&
				test2)
#endif
			{	// Avoid landing here
				cmd;
			}
			cmd;
		}

		void Func5
		(int num, int num2)			// Recognise when '(' is on new line
		{
			cmd;
		}

		void Func6
		/* Blah blah
		 * Blah blah */
		// Don't let comments confuse you
		/*
		 * Blah blah
		 * Blah blah
		 */
		(int num, int num2)			// Recognise when comments break things up
		// Don't let comments confuse you
		/*
		 * Blah blah
		 * Blah blah
		 */
		{
			cmd;

			// Leave lines here so we have room to scroll down,
			// to test that [[ will scroll up to show function heading
			//
			//
			//
			//
			//
			// That should be enough.
		}
	}
}
