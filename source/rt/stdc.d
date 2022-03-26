module rt.stdc;

extern (C) int printf(const char * fmt, ...);
extern (C) int puts(char * str);

extern (C) void * malloc(size_t);
extern (C) void free(void *);
extern (C) void * memcpy(void *, const(void) *, size_t);

extern (C) char toupper(char c);
extern (C) char tolower(char c);

extern (C) void * memset(void *, int, size_t);
