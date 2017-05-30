$input v_texcoord0

/*
 * Copyright 2011-2015 Branimir Karadzic. All rights reserved.
 * License: http://www.opensource.org/licenses/BSD-2-Clause
 */

#include <bgfx_shader.sh>
#include "../common/common.sh"

SAMPLER2D(u_texColor, 0);

void main()
{
	gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}