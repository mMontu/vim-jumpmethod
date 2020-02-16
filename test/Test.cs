
namespace NameyMcNamespace
{
	public enum AnEnum	// [[ should stop here, but not [m
	{
		One,
		Two
	}

	class Blah			// [[ should stop here, but not [m
	{
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

		void Func1()			// Stop here
		{
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
		}
	}
}
