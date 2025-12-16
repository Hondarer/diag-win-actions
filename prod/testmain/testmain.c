#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#pragma warning(push)
#pragma warning(disable: 4100)
#else
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
#endif

int main(int argc, char *argv[])
{
    printf("Hello, World\n");
    return 0;
}

#if _WIN32
#pragma warning(pop)
#else
#pragma GCC diagnostic pop
#endif
