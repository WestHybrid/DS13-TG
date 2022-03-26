#define VECTOR_POOL_MAX  20000
#define VECTOR_POOL_FULL 4000

#define release_vector(A)\
if(!istype(A, /vector2 && A)){\
	stack_trace("Invalid vector released to pool: [A]. File: [__FILE__], line: [__LINE__]")}\
else if(length(GLOB.vector_pool) < VECTOR_POOL_MAX){\
	GLOB.vector_pool += A;}\
A = null;

/atom/proc/get_global_pixel_loc()
	return get_new_vector(((x-1)*world.icon_size) + pixel_x + 16, ((y-1)*world.icon_size) + pixel_y + 16)
