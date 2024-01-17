cdef extern from "windows.h":
    # we need to define functionality to load a dll and get a function pointer

    ctypedef struct HINSTANCE__:
        pass

    ctypedef HINSTANCE__ *HINSTANCE

    ctypedef struct HMODULE__:
        pass

    ctypedef HMODULE__ *HMODULE

    ctypedef void *FARPROC

    HMODULE LoadLibraryA(char *lpLibFileName)
    FARPROC GetProcAddress(HMODULE hModule, char *lpProcName)
    HMODULE GetModuleHandleA(char *lpModuleName)
    