module rt.refcount;

import rt.alloc;

struct RefCountedArray(T) {
    int * refcount;
    T[] array;
    T * origin;

    this(Args...)(size_t count, Args args) {
        array = allocArray!T(count, args);
        origin = array.ptr;
        refcount = allocate!int();

        *refcount = 1;
    }

    ~this() {
        decRef();
    }

    this(this) {
        if (refcount !is null) *refcount += 1;
    }


    void opAssign(RefCountedArray!T src) {
        *src.refcount += 1;
        decRef();
        refcount = src.refcount;
        array = src.array;
        origin = src.origin;

    }

    void decRef() {
        if (refcount !is null) {
            if ((*refcount -= 1) == 0) {
                deallocate(refcount);
                deallocate(origin);
            }
        }
    }
    /* Array compatibility operators */

    @property length() { return array.length; }
    @property size_t opDollar() { return array.length; }

    ref T opIndex(size_t i) { return array[i]; }
    
    RefCountedArray!T opIndex(size_t[2] bounds) {
        RefCountedArray!T copy = this;
        copy.array = array[bounds[0]..bounds[1]];
        
        return copy;
    }
    
    auto opIndex() { return array; }
}
