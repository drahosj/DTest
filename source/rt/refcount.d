module rt.refcount;

import rt.alloc;
import rt.stdc;

struct RefCountedArray(T) {
    int[] refcount;
    int * ocount;
    T[] array;
    T * origin;
    size_t start;
    
    alias array this;

    this(Args...)(size_t count, Args args) {
        array = allocArray!T(count, args);
        origin = array.ptr;
        refcount = allocArray!int(count);
        ocount = allocate!int;

        incRef();
        printf("Created ocount: %d\n", *ocount);
    }

    ~this() {
        decRef();
    }
    
    this(this) {
        printf("Copy\n");
        incRef();
    }


    void opAssign(RefCountedArray!T src) {
        printf("assign\n");
        decRef();
        refcount = src.refcount;
        array = src.array;
        origin = src.origin;
        ocount = src.ocount;
        incRef();
    }
    
    void incRef() {
        printf("inc\n");
        if (ocount !is null) {
            *ocount += 1;
            printf("post-inc ocount: %d\n", *ocount);
        }
        foreach (i; start..(start + array.length)) {
            
            printf("i: %d pre: %d ", i, refcount[i]);
            refcount[i] += 1;
            printf("post: %d\n", refcount[i]);
        }
    }
    
    void state()
    {
        printf("STATE: ocount %d\n", *ocount);
        foreach(i; 0..refcount.length) {
            printf("i: %d count: %d\n", i, refcount[i]);
        }
    }

    void decRef() {
        if (ocount !is null) {
            printf("ocount: %d\n", *ocount);
            printf("length: %d\n", array.length);
            printf("start: %d\n", start);
            foreach(i; start..(start + array.length)) {
                printf("i: %d pre %d ", i, refcount[i]);
                assert(refcount[i] > 0, "Trying to destroy destroyed struct");
                if ((refcount[i] -= 1) == 0) {
                    static if(__traits(compiles,refcount[i].__dtor)) {
                        refcount[i].__dtor();
                    }
                }
                printf("post: %d\n", refcount[i]);
            }
            if ((*ocount -= 1) == 0) {
                free(origin);
            }
        }
    }
    
    RefCountedArray!T opSlice(B, E)(auto ref B b, auto ref E e) {
        RefCountedArray!T copy = this;
        copy.array = array[b..e];
        copy.start = b;
        return copy;
    }
}
