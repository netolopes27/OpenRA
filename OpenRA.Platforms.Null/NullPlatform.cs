#region Copyright & License Information
/*
 * Copyright 2007-2015 The OpenRA Developers (see AUTHORS)
 * This file is part of OpenRA, which is free software. It is made
 * available to you under the terms of the GNU General Public License
 * as published by the Free Software Foundation. For more information,
 * see COPYING.
 */
#endregion

using System.Drawing;
using OpenRA;

[assembly: Platform(typeof(OpenRA.Platforms.Null.DeviceFactory))]

namespace OpenRA.Platforms.Null
{
	public class DeviceFactory : IDeviceFactory
	{
		public IGraphicsDevice CreateGraphics(Size size, WindowMode windowMode)
		{
			return new NullGraphicsDevice(size, windowMode);
		}

		public ISoundEngine CreateSound()
		{
			return new NullSoundEngine();
		}
	}
}
