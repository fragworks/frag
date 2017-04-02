template workaround_create*[T]: ptr T = cast[ptr T](alloc0(sizeof(T)))
template workaround_createShared*[T]: ptr T = cast[ptr T](allocShared0(sizeof(T)))