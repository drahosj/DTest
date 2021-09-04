module rt.stdc;

extern (C) int printf(const char * fmt, ...);
extern (C) int puts(char * str);

extern (C) void * malloc(int);
extern (C) void free(void *);

extern (C) char toupper(char c);
extern (C) char tolower(char c);
