#include <stdio.h>

int main()
{
  divFuncX(800);
  divFuncY(800);

  return 0;
}

int divFuncX (int x)
{
  x -= 612;
  x /= 60;

  printf("x is %d\n", x);
  
  return x;
}

int divFuncY (int y)
{
  y -=127;
  y /= 40;

  printf("y is %d\n", y);
  
  return y;
}
