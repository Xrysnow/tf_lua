--
local M = {}
local ffi = require('ffi')
ffi.cdef [[
// ctype

int isalnum(int c);
int isalpha(int c);
int iscntrl(int c);
int isdigit(int c);
int isgraph(int c);
int islower(int c);
int isprint(int c);
int ispunct(int c);
int isspace(int c);
int isupper(int c);
int isxdigit(int c);
int tolower(int c);
int toupper(int c);

// locale

struct lconv {
   char *decimal_point;
   char *thousands_sep;
   char *grouping;
   char *int_curr_symbol;
   char *currency_symbol;
   char *mon_decimal_point;
   char *mon_thousands_sep;
   char *mon_grouping;
   char *positive_sign;
   char *negative_sign;
   char int_frac_digits;
   char frac_digits;
   char p_cs_precedes;
   char p_sep_by_space;
   char n_cs_precedes;
   char n_sep_by_space;
   char p_sign_posn;
   char n_sign_posn;
};

char *setlocale(int category, const char *locale);
struct lconv *localeconv();

// math

double acos(double x);
double asin(double x);
double atan(double x);
double atan2(double y, double x);
double cos(double x);
double cosh(double x);
double sin(double x);
double sinh(double x);
double tanh(double x);
double exp(double x);
double frexp(double x, int *exponent);
double ldexp(double x, int exponent);
double log(double x);
double log10(double x);
double modf(double x, double *integer);
double pow(double x, double y);
double sqrt(double x);
double ceil(double x);
double fabs(double x);
double floor(double x);
double fmod(double x, double y);

// signal

typedef int sig_atomic_t;
typedef void (* _crt_signal_t)(int);

_crt_signal_t signal(int _Signal, _crt_signal_t _Function);
int raise(int sig);

// stdio

//typedef struct FILE_ { void* _Placeholder; } FILE;
typedef int64_t fpos_t;

int fclose(FILE *stream);
void clearerr(FILE *stream);
int feof(FILE *stream);
int ferror(FILE *stream);
int fflush(FILE *stream);
int fgetpos(FILE *stream, fpos_t *pos);
FILE *fopen(const char *filename, const char *mode);
size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);
FILE *freopen(const char *filename, const char *mode, FILE *stream);
int fseek(FILE *stream, long int offset, int whence);
int fsetpos(FILE *stream, const fpos_t *pos);
long int ftell(FILE *stream);
size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);
int remove(const char *filename);
int rename(const char *old_filename, const char *new_filename);
void rewind(FILE *stream);
void setbuf(FILE *stream, char *buffer);
int setvbuf(FILE *stream, char *buffer, int mode, size_t size);
FILE *tmpfile(void);
char *tmpnam(char *str);
//int fprintf(FILE *stream, const char *format, ...);
//int printf(const char *format, ...);
//int sprintf(char *str, const char *format, ...);
//int vfprintf(FILE *stream, const char *format, va_list arg);
//int vprintf(const char *format, va_list arg);
//int vsprintf(char *str, const char *format, va_list arg);
//int fscanf(FILE *stream, const char *format, ...);
//int scanf(const char *format, ...);
//int sscanf(const char *str, const char *format, ...);
int fgetc(FILE *stream);
char *fgets(char *str, int n, FILE *stream);
int fputc(int char_, FILE *stream);
int fputs(const char *str, FILE *stream);
int getc(FILE *stream);
int getchar(void);
char *gets(char *str);
int putc(int char_, FILE *stream);
int putchar(int char_);
int puts(const char *str);
int ungetc(int char_, FILE *stream);
void perror(const char *str);

// stdlib

/*
typedef struct _div_t
{
    int quot;
    int rem;
} div_t;
typedef struct _ldiv_t
{
    long quot;
    long rem;
} ldiv_t;
*/
//
double atof(const char *str);
int atoi(const char *str);
long int atol(const char *str);
double strtod(const char *str, char **endptr);
long int strtol(const char *str, char **endptr, int base);
unsigned long int strtoul(const char *str, char **endptr, int base);
void *calloc(size_t nitems, size_t size);
void free(void *ptr);
void *malloc(size_t size);
void *realloc(void *ptr, size_t size);
void abort(void);
//int atexit(void (*func)(void));
int atexit(void *func);
void exit(int status);
char *getenv(const char *name);
int system(const char *string);
//void *bsearch(const void *key, const void *base, size_t nitems, size_t size, int (*compar)(const void *, const void *));
void *bsearch(const void *key, const void *base, size_t nitems, size_t size, void *compar);
//void qsort(void *base, size_t nitems, size_t size, int (*compar)(const void *, const void*));
void qsort(void *base, size_t nitems, size_t size, void *compar);
int abs(int x);
//div_t div(int numer, int denom);
long int labs(long int x);
//ldiv_t ldiv(long int numer, long int denom);
int rand(void);
void srand(unsigned int seed);
int mblen(const char *str, size_t n);
size_t mbstowcs(schar_t *pwcs, const char *str, size_t n);
int mbtowc(whcar_t *pwc, const char *str, size_t n);
size_t wcstombs(char *str, const wchar_t *pwcs, size_t n);
int wctomb(char *str, wchar_t wchar);

// string

void *memchr(const void *str, int c, size_t n);
int memcmp(const void *str1, const void *str2, size_t n);
void *memcpy(void *dest, const void *src, size_t n);
void *memmove(void *dest, const void *src, size_t n);
void *memset(void *str, int c, size_t n);
char *strcat(char *dest, const char *src);
char *strncat(char *dest, const char *src, size_t n);
char *strchr(const char *str, int c);
int strcmp(const char *str1, const char *str2);
int strncmp(const char *str1, const char *str2, size_t n);
int strcoll(const char *str1, const char *str2);
char *strcpy(char *dest, const char *src);
char *strncpy(char *dest, const char *src, size_t n);
size_t strcspn(const char *str1, const char *str2);
char *strerror(int errnum);
size_t strlen(const char *str);
char *strpbrk(const char *str1, const char *str2);
char *strrchr(const char *str, int c);
size_t strspn(const char *str1, const char *str2);
char *strstr(const char *haystack, const char *needle);
char *strtok(char *str, const char *delim);
size_t strxfrm(char *dest, const char *src, size_t n);

// time

typedef long clock_t;
typedef int64_t time_t;
struct tm {
   int tm_sec;
   int tm_min;
   int tm_hour;
   int tm_mday;
   int tm_mon;
   int tm_year;
   int tm_wday;
   int tm_yday;
   int tm_isdst;
};

char *asctime(const struct tm *timeptr);
clock_t clock(void);
char *ctime(const time_t *timer);
double difftime(time_t time1, time_t time2);
struct tm *gmtime(const time_t *timer);
struct tm *localtime(const time_t *timer);
time_t mktime(struct tm *timeptr);
size_t strftime(char *str, size_t maxsize, const char *format, const struct tm *timeptr);
time_t time(time_t *timer);
]]

local function _CALL(name, ...)
    return ffi.C[name](...)
end

local function _FUNCDEF()
end
local function _TYPEDEF()
end

--

---@param c number @(int)
---@return number @(int)
function M.isalnum(c)
    return _CALL("isalnum", c)
end
_FUNCDEF("isalnum", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.isalpha(c)
    return _CALL("isalpha", c)
end
_FUNCDEF("isalpha", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.iscntrl(c)
    return _CALL("iscntrl", c)
end
_FUNCDEF("iscntrl", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.isdigit(c)
    return _CALL("isdigit", c)
end
_FUNCDEF("isdigit", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.isgraph(c)
    return _CALL("isgraph", c)
end
_FUNCDEF("isgraph", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.islower(c)
    return _CALL("islower", c)
end
_FUNCDEF("islower", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.isprint(c)
    return _CALL("isprint", c)
end
_FUNCDEF("isprint", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.ispunct(c)
    return _CALL("ispunct", c)
end
_FUNCDEF("ispunct", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.isspace(c)
    return _CALL("isspace", c)
end
_FUNCDEF("isspace", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.isupper(c)
    return _CALL("isupper", c)
end
_FUNCDEF("isupper", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.isxdigit(c)
    return _CALL("isxdigit", c)
end
_FUNCDEF("isxdigit", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.tolower(c)
    return _CALL("tolower", c)
end
_FUNCDEF("tolower", { "int" }, "int")

--

---@param c number @(int)
---@return number @(int)
function M.toupper(c)
    return _CALL("toupper", c)
end
_FUNCDEF("toupper", { "int" }, "int")

--

---@param category number @(int)
---@param locale string @(const char *)
---@return number @(char *)
function M.setlocale(category, locale)
    return _CALL("setlocale", category, locale)
end
_FUNCDEF("setlocale", { "int", "const char *" }, "char *")

--

---@param x number @(double)
---@return number @(double)
function M.acos(x)
    return _CALL("acos", x)
end
_FUNCDEF("acos", { "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.asin(x)
    return _CALL("asin", x)
end
_FUNCDEF("asin", { "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.atan(x)
    return _CALL("atan", x)
end
_FUNCDEF("atan", { "double" }, "double")

--

---@param y number @(double)
---@param x number @(double)
---@return number @(double)
function M.atan2(y, x)
    return _CALL("atan2", y, x)
end
_FUNCDEF("atan2", { "double", "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.cos(x)
    return _CALL("cos", x)
end
_FUNCDEF("cos", { "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.cosh(x)
    return _CALL("cosh", x)
end
_FUNCDEF("cosh", { "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.sin(x)
    return _CALL("sin", x)
end
_FUNCDEF("sin", { "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.sinh(x)
    return _CALL("sinh", x)
end
_FUNCDEF("sinh", { "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.tanh(x)
    return _CALL("tanh", x)
end
_FUNCDEF("tanh", { "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.exp(x)
    return _CALL("exp", x)
end
_FUNCDEF("exp", { "double" }, "double")

--

---@param x number @(double)
---@param exponent number @(int *)
---@return number @(double)
function M.frexp(x, exponent)
    return _CALL("frexp", x, exponent)
end
_FUNCDEF("frexp", { "double", "int *" }, "double")

--

---@param x number @(double)
---@param exponent number @(int)
---@return number @(double)
function M.ldexp(x, exponent)
    return _CALL("ldexp", x, exponent)
end
_FUNCDEF("ldexp", { "double", "int" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.log(x)
    return _CALL("log", x)
end
_FUNCDEF("log", { "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.log10(x)
    return _CALL("log10", x)
end
_FUNCDEF("log10", { "double" }, "double")

--

---@param x number @(double)
---@param integer number @(double *)
---@return number @(double)
function M.modf(x, integer)
    return _CALL("modf", x, integer)
end
_FUNCDEF("modf", { "double", "double *" }, "double")

--

---@param x number @(double)
---@param y number @(double)
---@return number @(double)
function M.pow(x, y)
    return _CALL("pow", x, y)
end
_FUNCDEF("pow", { "double", "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.sqrt(x)
    return _CALL("sqrt", x)
end
_FUNCDEF("sqrt", { "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.ceil(x)
    return _CALL("ceil", x)
end
_FUNCDEF("ceil", { "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.fabs(x)
    return _CALL("fabs", x)
end
_FUNCDEF("fabs", { "double" }, "double")

--

---@param x number @(double)
---@return number @(double)
function M.floor(x)
    return _CALL("floor", x)
end
_FUNCDEF("floor", { "double" }, "double")

--

---@param x number @(double)
---@param y number @(double)
---@return number @(double)
function M.fmod(x, y)
    return _CALL("fmod", x, y)
end
_FUNCDEF("fmod", { "double", "double" }, "double")

--

_TYPEDEF("sig_atomic_t", "int")

--

_TYPEDEF("_crt_signal_t", "void*")

--

---@param _Signal number @(int)
---@param _Function number @(_crt_signal_t)
---@return number @(_crt_signal_t)
function M.signal(_Signal, _Function)
    return _CALL("signal", _Signal, _Function)
end
_FUNCDEF("signal", { "int", "_crt_signal_t" }, "_crt_signal_t")

--

---@param sig number @(int)
---@return number @(int)
function M.raise(sig)
    return _CALL("raise", sig)
end
_FUNCDEF("raise", { "int" }, "int")

--

_TYPEDEF("fpos_t", "int64_t")

--

---@param stream number @(FILE *)
---@return number @(int)
function M.fclose(stream)
    return _CALL("fclose", stream)
end
_FUNCDEF("fclose", { "FILE *" }, "int")

--

---@param stream number @(FILE *)
function M.clearerr(stream)
    return _CALL("clearerr", stream)
end
_FUNCDEF("clearerr", { "FILE *" }, "void")

--

---@param stream number @(FILE *)
---@return number @(int)
function M.feof(stream)
    return _CALL("feof", stream)
end
_FUNCDEF("feof", { "FILE *" }, "int")

--

---@param stream number @(FILE *)
---@return number @(int)
function M.ferror(stream)
    return _CALL("ferror", stream)
end
_FUNCDEF("ferror", { "FILE *" }, "int")

--

---@param stream number @(FILE *)
---@return number @(int)
function M.fflush(stream)
    return _CALL("fflush", stream)
end
_FUNCDEF("fflush", { "FILE *" }, "int")

--

---@param stream number @(FILE *)
---@param pos number @(fpos_t *)
---@return number @(int)
function M.fgetpos(stream, pos)
    return _CALL("fgetpos", stream, pos)
end
_FUNCDEF("fgetpos", { "FILE *", "fpos_t *" }, "int")

--

---@param filename string @(const char *)
---@param mode string @(const char *)
---@return number @(FILE *)
function M.fopen(filename, mode)
    return _CALL("fopen", filename, mode)
end
_FUNCDEF("fopen", { "const char *", "const char *" }, "FILE *")

--

---@param ptr number @(void *)
---@param size number @(size_t)
---@param nmemb number @(size_t)
---@param stream number @(FILE *)
---@return number @(size_t)
function M.fread(ptr, size, nmemb, stream)
    return _CALL("fread", ptr, size, nmemb, stream)
end
_FUNCDEF("fread", { "void *", "size_t", "size_t", "FILE *" }, "size_t")

--

---@param filename string @(const char *)
---@param mode string @(const char *)
---@param stream number @(FILE *)
---@return number @(FILE *)
function M.freopen(filename, mode, stream)
    return _CALL("freopen", filename, mode, stream)
end
_FUNCDEF("freopen", { "const char *", "const char *", "FILE *" }, "FILE *")

--

---@param stream number @(FILE *)
---@param offset number @(long int)
---@param whence number @(int)
---@return number @(int)
function M.fseek(stream, offset, whence)
    return _CALL("fseek", stream, offset, whence)
end
_FUNCDEF("fseek", { "FILE *", "long int", "int" }, "int")

--

---@param stream number @(FILE *)
---@param pos number @(const fpos_t *)
---@return number @(int)
function M.fsetpos(stream, pos)
    return _CALL("fsetpos", stream, pos)
end
_FUNCDEF("fsetpos", { "FILE *", "const fpos_t *" }, "int")

--

---@param stream number @(FILE *)
---@return number @(long int)
function M.ftell(stream)
    return _CALL("ftell", stream)
end
_FUNCDEF("ftell", { "FILE *" }, "long int")

--

---@param ptr number @(const void *)
---@param size number @(size_t)
---@param nmemb number @(size_t)
---@param stream number @(FILE *)
---@return number @(size_t)
function M.fwrite(ptr, size, nmemb, stream)
    return _CALL("fwrite", ptr, size, nmemb, stream)
end
_FUNCDEF("fwrite", { "const void *", "size_t", "size_t", "FILE *" }, "size_t")

--

---@param filename string @(const char *)
---@return number @(int)
function M.remove(filename)
    return _CALL("remove", filename)
end
_FUNCDEF("remove", { "const char *" }, "int")

--

---@param old_filename string @(const char *)
---@param new_filename string @(const char *)
---@return number @(int)
function M.rename(old_filename, new_filename)
    return _CALL("rename", old_filename, new_filename)
end
_FUNCDEF("rename", { "const char *", "const char *" }, "int")

--

---@param stream number @(FILE *)
function M.rewind(stream)
    return _CALL("rewind", stream)
end
_FUNCDEF("rewind", { "FILE *" }, "void")

--

---@param stream number @(FILE *)
---@param buffer number @(char *)
function M.setbuf(stream, buffer)
    return _CALL("setbuf", stream, buffer)
end
_FUNCDEF("setbuf", { "FILE *", "char *" }, "void")

--

---@param stream number @(FILE *)
---@param buffer number @(char *)
---@param mode number @(int)
---@param size number @(size_t)
---@return number @(int)
function M.setvbuf(stream, buffer, mode, size)
    return _CALL("setvbuf", stream, buffer, mode, size)
end
_FUNCDEF("setvbuf", { "FILE *", "char *", "int", "size_t" }, "int")

--

---@return number @(FILE *)
function M.tmpfile()
    return _CALL("tmpfile")
end
_FUNCDEF("tmpfile", {  }, "FILE *")

--

---@param str number @(char *)
---@return number @(char *)
function M.tmpnam(str)
    return _CALL("tmpnam", str)
end
_FUNCDEF("tmpnam", { "char *" }, "char *")

--

---@param stream number @(FILE *)
---@return number @(int)
function M.fgetc(stream)
    return _CALL("fgetc", stream)
end
_FUNCDEF("fgetc", { "FILE *" }, "int")

--

---@param str number @(char *)
---@param n number @(int)
---@param stream number @(FILE *)
---@return number @(char *)
function M.fgets(str, n, stream)
    return _CALL("fgets", str, n, stream)
end
_FUNCDEF("fgets", { "char *", "int", "FILE *" }, "char *")

--

---@param char_ number @(int)
---@param stream number @(FILE *)
---@return number @(int)
function M.fputc(char_, stream)
    return _CALL("fputc", char_, stream)
end
_FUNCDEF("fputc", { "int", "FILE *" }, "int")

--

---@param str string @(const char *)
---@param stream number @(FILE *)
---@return number @(int)
function M.fputs(str, stream)
    return _CALL("fputs", str, stream)
end
_FUNCDEF("fputs", { "const char *", "FILE *" }, "int")

--

---@param stream number @(FILE *)
---@return number @(int)
function M.getc(stream)
    return _CALL("getc", stream)
end
_FUNCDEF("getc", { "FILE *" }, "int")

--

---@return number @(int)
function M.getchar()
    return _CALL("getchar")
end
_FUNCDEF("getchar", {  }, "int")

--

---@param str number @(char *)
---@return number @(char *)
function M.gets(str)
    return _CALL("gets", str)
end
_FUNCDEF("gets", { "char *" }, "char *")

--

---@param char_ number @(int)
---@param stream number @(FILE *)
---@return number @(int)
function M.putc(char_, stream)
    return _CALL("putc", char_, stream)
end
_FUNCDEF("putc", { "int", "FILE *" }, "int")

--

---@param char_ number @(int)
---@return number @(int)
function M.putchar(char_)
    return _CALL("putchar", char_)
end
_FUNCDEF("putchar", { "int" }, "int")

--

---@param str string @(const char *)
---@return number @(int)
function M.puts(str)
    return _CALL("puts", str)
end
_FUNCDEF("puts", { "const char *" }, "int")

--

---@param char_ number @(int)
---@param stream number @(FILE *)
---@return number @(int)
function M.ungetc(char_, stream)
    return _CALL("ungetc", char_, stream)
end
_FUNCDEF("ungetc", { "int", "FILE *" }, "int")

--

---@param str string @(const char *)
function M.perror(str)
    return _CALL("perror", str)
end
_FUNCDEF("perror", { "const char *" }, "void")

--

---@param str string @(const char *)
---@return number @(double)
function M.atof(str)
    return _CALL("atof", str)
end
_FUNCDEF("atof", { "const char *" }, "double")

--

---@param str string @(const char *)
---@return number @(int)
function M.atoi(str)
    return _CALL("atoi", str)
end
_FUNCDEF("atoi", { "const char *" }, "int")

--

---@param str string @(const char *)
---@return number @(long int)
function M.atol(str)
    return _CALL("atol", str)
end
_FUNCDEF("atol", { "const char *" }, "long int")

--

---@param str string @(const char *)
---@param endptr number @(char * *)
---@return number @(double)
function M.strtod(str, endptr)
    return _CALL("strtod", str, endptr)
end
_FUNCDEF("strtod", { "const char *", "char * *" }, "double")

--

---@param str string @(const char *)
---@param endptr number @(char * *)
---@param base number @(int)
---@return number @(long int)
function M.strtol(str, endptr, base)
    return _CALL("strtol", str, endptr, base)
end
_FUNCDEF("strtol", { "const char *", "char * *", "int" }, "long int")

--

---@param str string @(const char *)
---@param endptr number @(char * *)
---@param base number @(int)
---@return number @(unsigned long int)
function M.strtoul(str, endptr, base)
    return _CALL("strtoul", str, endptr, base)
end
_FUNCDEF("strtoul", { "const char *", "char * *", "int" }, "unsigned long int")

--

---@param nitems number @(size_t)
---@param size number @(size_t)
---@return number @(void *)
function M.calloc(nitems, size)
    return _CALL("calloc", nitems, size)
end
_FUNCDEF("calloc", { "size_t", "size_t" }, "void *")

--

---@param ptr number @(void *)
function M.free(ptr)
    return _CALL("free", ptr)
end
_FUNCDEF("free", { "void *" }, "void")

--

---@param size number @(size_t)
---@return number @(void *)
function M.malloc(size)
    return _CALL("malloc", size)
end
_FUNCDEF("malloc", { "size_t" }, "void *")

--

---@param ptr number @(void *)
---@param size number @(size_t)
---@return number @(void *)
function M.realloc(ptr, size)
    return _CALL("realloc", ptr, size)
end
_FUNCDEF("realloc", { "void *", "size_t" }, "void *")

--


function M.abort()
    return _CALL("abort")
end
_FUNCDEF("abort", {  }, "void")

--

---@param func number @(void *)
---@return number @(int)
function M.atexit(func)
    return _CALL("atexit", func)
end
_FUNCDEF("atexit", { "void *" }, "int")

--

---@param status number @(int)
function M.exit(status)
    return _CALL("exit", status)
end
_FUNCDEF("exit", { "int" }, "void")

--

---@param name string @(const char *)
---@return number @(char *)
function M.getenv(name)
    return _CALL("getenv", name)
end
_FUNCDEF("getenv", { "const char *" }, "char *")

--

---@param string string @(const char *)
---@return number @(int)
function M.system(string)
    return _CALL("system", string)
end
_FUNCDEF("system", { "const char *" }, "int")

--

---@param key number @(const void *)
---@param base number @(const void *)
---@param nitems number @(size_t)
---@param size number @(size_t)
---@param compar number @(void *)
---@return number @(void *)
function M.bsearch(key, base, nitems, size, compar)
    return _CALL("bsearch", key, base, nitems, size, compar)
end
_FUNCDEF("bsearch", { "const void *", "const void *", "size_t", "size_t", "void *" }, "void *")

--

---@param base number @(void *)
---@param nitems number @(size_t)
---@param size number @(size_t)
---@param compar number @(void *)
function M.qsort(base, nitems, size, compar)
    return _CALL("qsort", base, nitems, size, compar)
end
_FUNCDEF("qsort", { "void *", "size_t", "size_t", "void *" }, "void")

--

---@param x number @(int)
---@return number @(int)
function M.abs(x)
    return _CALL("abs", x)
end
_FUNCDEF("abs", { "int" }, "int")

--

---@param x number @(long int)
---@return number @(long int)
function M.labs(x)
    return _CALL("labs", x)
end
_FUNCDEF("labs", { "long int" }, "long int")

--

---@return number @(int)
function M.rand()
    return _CALL("rand")
end
_FUNCDEF("rand", {  }, "int")

--

---@param seed number @(unsigned int)
function M.srand(seed)
    return _CALL("srand", seed)
end
_FUNCDEF("srand", { "unsigned int" }, "void")

--

---@param str string @(const char *)
---@param n number @(size_t)
---@return number @(int)
function M.mblen(str, n)
    return _CALL("mblen", str, n)
end
_FUNCDEF("mblen", { "const char *", "size_t" }, "int")

--

---@param pwcs number @(schar_t *)
---@param str string @(const char *)
---@param n number @(size_t)
---@return number @(size_t)
function M.mbstowcs(pwcs, str, n)
    return _CALL("mbstowcs", pwcs, str, n)
end
_FUNCDEF("mbstowcs", { "schar_t *", "const char *", "size_t" }, "size_t")

--

---@param pwc number @(whcar_t *)
---@param str string @(const char *)
---@param n number @(size_t)
---@return number @(int)
function M.mbtowc(pwc, str, n)
    return _CALL("mbtowc", pwc, str, n)
end
_FUNCDEF("mbtowc", { "whcar_t *", "const char *", "size_t" }, "int")

--

---@param str number @(char *)
---@param pwcs string @(const wchar_t *)
---@param n number @(size_t)
---@return number @(size_t)
function M.wcstombs(str, pwcs, n)
    return _CALL("wcstombs", str, pwcs, n)
end
_FUNCDEF("wcstombs", { "char *", "const wchar_t *", "size_t" }, "size_t")

--

---@param str number @(char *)
---@param wchar number @(wchar_t)
---@return number @(int)
function M.wctomb(str, wchar)
    return _CALL("wctomb", str, wchar)
end
_FUNCDEF("wctomb", { "char *", "wchar_t" }, "int")

--

---@param str number @(const void *)
---@param c number @(int)
---@param n number @(size_t)
---@return number @(void *)
function M.memchr(str, c, n)
    return _CALL("memchr", str, c, n)
end
_FUNCDEF("memchr", { "const void *", "int", "size_t" }, "void *")

--

---@param str1 number @(const void *)
---@param str2 number @(const void *)
---@param n number @(size_t)
---@return number @(int)
function M.memcmp(str1, str2, n)
    return _CALL("memcmp", str1, str2, n)
end
_FUNCDEF("memcmp", { "const void *", "const void *", "size_t" }, "int")

--

---@param dest number @(void *)
---@param src number @(const void *)
---@param n number @(size_t)
---@return number @(void *)
function M.memcpy(dest, src, n)
    return _CALL("memcpy", dest, src, n)
end
_FUNCDEF("memcpy", { "void *", "const void *", "size_t" }, "void *")

--

---@param dest number @(void *)
---@param src number @(const void *)
---@param n number @(size_t)
---@return number @(void *)
function M.memmove(dest, src, n)
    return _CALL("memmove", dest, src, n)
end
_FUNCDEF("memmove", { "void *", "const void *", "size_t" }, "void *")

--

---@param str number @(void *)
---@param c number @(int)
---@param n number @(size_t)
---@return number @(void *)
function M.memset(str, c, n)
    return _CALL("memset", str, c, n)
end
_FUNCDEF("memset", { "void *", "int", "size_t" }, "void *")

--

---@param dest number @(char *)
---@param src string @(const char *)
---@return number @(char *)
function M.strcat(dest, src)
    return _CALL("strcat", dest, src)
end
_FUNCDEF("strcat", { "char *", "const char *" }, "char *")

--

---@param dest number @(char *)
---@param src string @(const char *)
---@param n number @(size_t)
---@return number @(char *)
function M.strncat(dest, src, n)
    return _CALL("strncat", dest, src, n)
end
_FUNCDEF("strncat", { "char *", "const char *", "size_t" }, "char *")

--

---@param str string @(const char *)
---@param c number @(int)
---@return number @(char *)
function M.strchr(str, c)
    return _CALL("strchr", str, c)
end
_FUNCDEF("strchr", { "const char *", "int" }, "char *")

--

---@param str1 string @(const char *)
---@param str2 string @(const char *)
---@return number @(int)
function M.strcmp(str1, str2)
    return _CALL("strcmp", str1, str2)
end
_FUNCDEF("strcmp", { "const char *", "const char *" }, "int")

--

---@param str1 string @(const char *)
---@param str2 string @(const char *)
---@param n number @(size_t)
---@return number @(int)
function M.strncmp(str1, str2, n)
    return _CALL("strncmp", str1, str2, n)
end
_FUNCDEF("strncmp", { "const char *", "const char *", "size_t" }, "int")

--

---@param str1 string @(const char *)
---@param str2 string @(const char *)
---@return number @(int)
function M.strcoll(str1, str2)
    return _CALL("strcoll", str1, str2)
end
_FUNCDEF("strcoll", { "const char *", "const char *" }, "int")

--

---@param dest number @(char *)
---@param src string @(const char *)
---@return number @(char *)
function M.strcpy(dest, src)
    return _CALL("strcpy", dest, src)
end
_FUNCDEF("strcpy", { "char *", "const char *" }, "char *")

--

---@param dest number @(char *)
---@param src string @(const char *)
---@param n number @(size_t)
---@return number @(char *)
function M.strncpy(dest, src, n)
    return _CALL("strncpy", dest, src, n)
end
_FUNCDEF("strncpy", { "char *", "const char *", "size_t" }, "char *")

--

---@param str1 string @(const char *)
---@param str2 string @(const char *)
---@return number @(size_t)
function M.strcspn(str1, str2)
    return _CALL("strcspn", str1, str2)
end
_FUNCDEF("strcspn", { "const char *", "const char *" }, "size_t")

--

---@param errnum number @(int)
---@return number @(char *)
function M.strerror(errnum)
    return _CALL("strerror", errnum)
end
_FUNCDEF("strerror", { "int" }, "char *")

--

---@param str string @(const char *)
---@return number @(size_t)
function M.strlen(str)
    return _CALL("strlen", str)
end
_FUNCDEF("strlen", { "const char *" }, "size_t")

--

---@param str1 string @(const char *)
---@param str2 string @(const char *)
---@return number @(char *)
function M.strpbrk(str1, str2)
    return _CALL("strpbrk", str1, str2)
end
_FUNCDEF("strpbrk", { "const char *", "const char *" }, "char *")

--

---@param str string @(const char *)
---@param c number @(int)
---@return number @(char *)
function M.strrchr(str, c)
    return _CALL("strrchr", str, c)
end
_FUNCDEF("strrchr", { "const char *", "int" }, "char *")

--

---@param str1 string @(const char *)
---@param str2 string @(const char *)
---@return number @(size_t)
function M.strspn(str1, str2)
    return _CALL("strspn", str1, str2)
end
_FUNCDEF("strspn", { "const char *", "const char *" }, "size_t")

--

---@param haystack string @(const char *)
---@param needle string @(const char *)
---@return number @(char *)
function M.strstr(haystack, needle)
    return _CALL("strstr", haystack, needle)
end
_FUNCDEF("strstr", { "const char *", "const char *" }, "char *")

--

---@param str number @(char *)
---@param delim string @(const char *)
---@return number @(char *)
function M.strtok(str, delim)
    return _CALL("strtok", str, delim)
end
_FUNCDEF("strtok", { "char *", "const char *" }, "char *")

--

---@param dest number @(char *)
---@param src string @(const char *)
---@param n number @(size_t)
---@return number @(size_t)
function M.strxfrm(dest, src, n)
    return _CALL("strxfrm", dest, src, n)
end
_FUNCDEF("strxfrm", { "char *", "const char *", "size_t" }, "size_t")

--

_TYPEDEF("clock_t", "long")

--

_TYPEDEF("time_t", "int64_t")

--

---@param timeptr number @(const struct tm *)
---@return number @(char *)
function M.asctime(timeptr)
    return _CALL("asctime", timeptr)
end
_FUNCDEF("asctime", { "const struct tm *" }, "char *")

--

---@return number @(clock_t)
function M.clock()
    return _CALL("clock")
end
_FUNCDEF("clock", {  }, "clock_t")

--

---@param timer number @(const time_t *)
---@return number @(char *)
function M.ctime(timer)
    return _CALL("ctime", timer)
end
_FUNCDEF("ctime", { "const time_t *" }, "char *")

--

---@param time1 number @(time_t)
---@param time2 number @(time_t)
---@return number @(double)
function M.difftime(time1, time2)
    return _CALL("difftime", time1, time2)
end
_FUNCDEF("difftime", { "time_t", "time_t" }, "double")

--

---@param timeptr number @(struct tm *)
---@return number @(time_t)
function M.mktime(timeptr)
    return _CALL("mktime", timeptr)
end
_FUNCDEF("mktime", { "struct tm *" }, "time_t")

--

---@param str number @(char *)
---@param maxsize number @(size_t)
---@param format string @(const char *)
---@param timeptr number @(const struct tm *)
---@return number @(size_t)
function M.strftime(str, maxsize, format, timeptr)
    return _CALL("strftime", str, maxsize, format, timeptr)
end
_FUNCDEF("strftime", { "char *", "size_t", "const char *", "const struct tm *" }, "size_t")

--

---@param timer number @(time_t *)
---@return number @(time_t)
function M.time(timer)
    return _CALL("time", timer)
end
_FUNCDEF("time", { "time_t *" }, "time_t")

--

return M
