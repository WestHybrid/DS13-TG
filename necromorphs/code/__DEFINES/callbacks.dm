
#define INVOKE_NEXT_TICK(arguments...) addtimer(CALLBACK(##arguments), 1)
