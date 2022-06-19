
program which reads through C style macros and search/replaces text for those macros.


### macros
we can define simple macros  
``#define MY_MACRO this is my text``  

we can also define macro functions  
``#defin myFunc(x,y) x*y+(x+y)``  

you can also use previously declared macros inside other macros. 
```
#define HELLO hello  
#define WORLD world
#define BOTH HELLO WORLD

the text -> BOTH! -> expands to -> hello world!
```

you can combine regular and function style macros.   

### useage  
pass in list of file on command line.  
  
example:  
```lua macros.lua  file1 file2 file3```
