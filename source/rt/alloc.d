module rt.alloc;

import rt.stdc;

enum isAllocable(T) = 
    is(T == struct) ||
    is(__traits(isScalar, T));

T * allocate(T, A...)(A a) if (isAllocable!T) 
{
    T *ptr = cast(T *) malloc(T.sizeof);
    if (!ptr) assert(0, "Malloc failed!");
    
    initialize(ptr, a);

    return ptr;
}

void initialize(T, A...)(T * t, A args)  if (isAllocable!T)
{
    static if (is(T == struct)) {
        auto initializer = __traits(initSymbol, T);
        if (initializer.ptr == null) {
            memset(t, 0, initializer.length);
        } else {
            memcpy(t, initializer.ptr, initializer.length);
        }
        static if (args.length > 0) {
            ptr.__ctor(args);
        }
    } else static if (__traits(isScalar, T)) {
        T tmp;
        *t = tmp;
    }
}

T[] allocArray(T, A...)(size_t count, A args) if (isAllocable!T) 
{
    assert(count != 0);

    void * ptr = malloc(T.sizeof * count);

    if (!ptr) assert(0, "Malloc failed!");

    T[] ary = (cast(T*) ptr)[0..count];


    foreach(i; 0..count) {
        initialize(&ary[i], args);
    }

    return ary;
}

void deallocate(T)(T[] ary) 
{
    foreach(t; ary) {
        static if (__traits(compiles, ptr.__dtor())) {
            t.__dtor();
        }
    }
    free(ary.ptr);
}

void deallocate(T)(T * ptr) 
{
    static if (__traits(compiles, ptr.__dtor())) {
        ptr.__dtor();
    }
    free(ptr);
}
