#include <stdio.h>
#include <unistd.h>

int main()
{
  printf("entering loop...\n");
  setbuf(stdout, NULL);

  int i = 0;
  while (1) {
    printf("Hello, World from C! %d\n", i);
    fflush(stdout);
    i++;
    sleep(1);

    if (i > 3) break;
  }
  return 0;
}
