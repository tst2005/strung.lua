local strong = require"strong"

--- First, the test and benchmark infrastructure.
--- `try` and `gmtry` run both the original and strong version of the functions, 
--- and compare either their ouput, or their speed if "bench" is passed as a 
--- parameter to the script.

local ttstr = require"util".val_to_string
local BASE = 10000
local iter, try, gmtry
if arg[1] == "bench" then 
    function try(f, a, s, d, g, h)
        -- jit.off() jit.on()
        tsi, tSo = 0, 0
        local params = {a, s, d, g, h}
        local ri, Ros
        print(("-_"):rep(30))
        print("Test: ", f, unpack(params))
        local tic = os.clock()
        for i = 1, II do
            ri = {string[f](a, s, d, g, h)}
        end
        tsi = os.clock() - tic
        local tic = os.clock()
        for i = 1, II do
            Ro = {strong[f](a, s, d, g, h)}
        end
        tSo = os.clock() - tic
        print("strong/string: ", tSo/tsi)
    end
    function gmtry(s, p)
        print(("-_"):rep(30))
        print("Test: ", "gmatch", s, p)
        local ri, ro = {}, {}
        local tic = os.clock()
        for i = 1, II do
            ro = {}
            for a, b, c, d, e, f in strong.gmatch(s, p) do
                ro[#ro + 1] = {a, b, c, d, e}
            end
        end
        local tsi = os.clock() - tic
        local tic = os.clock()
        for i = 1, II do
            ri = {}
            for a, b, c, d, e, f in string.gmatch(s, p) do
                ri[#ri + 1] = {a, b, c, d, e}
            end
        end
        local tSo = os.clock() - tic
        print("strong/string: ", tSo/tsi)
    end
    function iter(n) II = BASE * n end
else
    function try(f, ...)
        local params = {...}
        local ri, Ros
        print(("-_"):rep(30))
        print("Test: ", f, ...)
        ri = {string[f](...)}
        Ro = {strong[f](...)}
        for i, v in ipairs(params) do params[i] = tostring(v) end
        for i = 1, math.max(#ri, #Ro) do
            strong.assert(ri[i] == Ro[i], params[2], table.concat({ 
                table.concat(params, ", "), 
                "ri:", table.concat(ri, ",  "), 
                " \tRo:", table.concat(Ro, ", ")
            }, " | "))
        end
    end
    function gmtry(s, p)
        print(("-_"):rep(30))
        print("Test: ", "gmatch", s, p)
        local ri, ro = {}, {}
        for a, b, c, d, e, f in strong.gmatch(s, p) do
            ro[#ro + 1] = {a, b, c, d, e}
        end
        print"Now string"
        for a, b, c, d, e, f in string.gmatch(s, p) do
            ri[#ri + 1] = {a, b, c, d, e}
        end
        strong.assert(#ro == #ri, p, "string: \n"..ttstr(ri).."\n=/=/=/=/=/=/=/=/\nstrong:\n"..ttstr(ro))
        for i = 1, #ro do
        strong.assert(#ro[i] == #ri[i], p, "string: \n"..ttstr(ri).."\n=/=/=/=/=/=/=/=/\nstrong:\n"..ttstr(ro))
            for j = 1, #ri[i] do
                strong.assert(ri[i][j] == ro[i][j], p, "string: \n"..ttstr(ri).."\n=/=/=/=/=/=/=/=/\nstrong:\n"..ttstr(ro))
            end
        end
    end
    iter = function()end
end


--- The tests (in reverse order of complexity)

local _f, _m, _gm, _gs = string.find, string.match, string.gmatch, string.gsub

strong.install()
assert(
    string.find == strong.find
    and string.match == strong.match
    and string.gmatch == strong.gmatch
    --and string.gsub == strong.gsub
    , "`strong.install()` failed.")
--restore the originals.
string.find, string.match, string.gmatch, string.gsub = _f, _m, _gm, _gs


iter(10)

gmtry('abcdabcdabcd', "((a)(b)c)()(d)")
-- try("find", 'abcdabcdabcd', "((a)(b)c)()(d)")
-- try("find", 'abcdabcdabcd', "(a)(b)c(d)")
gmtry('abcdabcdabcd', "(a)(b)c(d)")
gmtry('abcdabcdabcd', "(a)(b)(d)")
gmtry('abcdabcdabcd', "(a)(b)(d)")
gmtry('abcabcabc', "(a)(b)")
gmtry('abcabcabc', "(ab)")

iter(10)

try("match", "faa:foo:", "(.+):(%l+)")
try("match", ":foo:", "(%l*)")
try("match", "faa:foo:", ":%l+")
try("match", "faa:foo:", ":(%l+)")
try("match", "faa:foo:", "(%l+)")
try("match", ":foo:", "(%l+)")
try("match", "foo", "%l+")
try("match", "foo", "foo")

try("find", "wwS", "^wS", 2)
try("find", "wwS", "^wS")
try("find", "wwS", "^ww", 2)
try("find", "wwS", "^ww")

try("find", "a(f()g(h(d d))[[][]]K)", "%b()%b[]", 3)
try("find", "a(f()g(h(d d))[[][]]K)", "%b()%b[]", 2)
try("find", "a(f()g(h(d d))[[][]]K)", "%b()%b[]")
try("find", "a(f()g(h(d d))K)", "%b()")
try("find", "a(f()g(h(d d))K", "%b()")
try("find", "foobarfoo", "(foo)(bar)%2%1")
try("find", "foobarbarfoo", "(foo)(bar)%2%1")
try("find", "foobarbar", "(foo)(bar)%2")
try("find", "foobarfoo", "(foo)(bar)%2")
try("find", "foobarfoo", "(foo)(bar)%1")
try("find", "foobarfoo", "(foo)bar%1")

try("find", "wwS", "((w*)S)")
try("find", "wwwwS", "((w*)%u)")
try("find", "wwS", "((%l)%u)")
try("find", "SSw", "((%u)%l)")
try("find", "wwS", "((%l*)%u)")
try("find", "wwS", "((%l-)%u)")

try("find", "wwS", "((w*)%u)")
try("find", "wwS", "((ww)%u)")
try("find", "wwS", "((%l*)S)")
try("find", "wwS", "((%l*))")


try("find", "wwSS", "()(%u+)()")
try("find", "wwwwwwS", "[^%u]*")
try("find", "wwwwwwS", "[^%u]")
try("find", "wwwwwwS", "(%l*)")
try("find", "wwSS", "(%u+)")

try("find", "wwS", "%l%u")
try("find", "wwS", "()%l%u")

try("find", "wwwwwwS", "[^%U]")
try("find", "wwwwwwS", "[%U]*")
try("find", "wwwwwwS", "[%U]+")

try("find", "wwwwwwS", "%l*")

try("find", "wwwwwwS", "[%U]")
try("find", "wwwwwwS", "[%u]")

try("find", "wwwwwwS", "[%u]*")
try("find", "wwwwwwS", "[^kfdS]*")

try("find", "wwS", "%l*()")
try("find", "wwS", "()%u+")

try("find", "w(wSESDFB)SFwe)fwe", "%(.-%)")
try("find", "w(wSESDFB)SFwe)fwe", "%(.*%)")

try("find", "wawSESDFB)SFweafwe", "a.-a")
try("find", "wawSESDFBaSFwe)fwe", "a.*a")

try("find", "a", ".")
try("find", "a6ruyfhjgjk9", ".+")

try("find", "wawSESDFBaSFwe)fwe", "a[A-Za-z]*a")

try("find", "qwwSYUGJHDwefwe", "%u+")
try("find", "wwSESDFBSFwefwe", "[A-Z]+")

try("find", "SYUGJHD", "%u+")
try("find", "SESDFBSF", "[A-Z]+")
try("find", "qwwSYUGJHD", "%u+")
try("find", "wwSESDFBSF", "[A-Z]+")

try("find", "S", "%u")
try("find", "S", "[A-Z]")

try("find", "ab", "a?b")
try("find", "b", "a?b")
try("find", "abbabbab", "a?ba?ba?ba?ba?b$")
try("find", "abbabbaba", "a?ba?ba?ba?ba?b$")

try("find", "aaaabaaaaabbaaaabb$", "a+bb$")
try("find", "aaaabaaaaabbaaaabb", "a+bb$")
try("find", "aaaaaaaabaaabaaaaabb", "a+bb")
try("find", "aaaaaaaabaaabaaaaabb", "a*bb")

try("find", "aaaaaaaabaaabaaaaab", "ba-bb")
try("find", "aaaaaaaabaaabaaaaabb", "ba-bb")

try("find", "aaa", "a+")
try("find", "aaaaaaaaaaaaaaaaaa", "a+")

try("find", "aaaaabaaaaabaaaaaaaaabb", "aabb")
try("find", "aaaaaaaaabbaaaaaaaabbaaaaaaaaaaaabbaaaaaaaaaaabbaaaaaaaaaaaabb", "aaaaaaaaaaaaabbb")

iter(100)

try("find", "baa", "aa")
try("find", "ba", "a")

try("find", "a", "aa")
try("find", "aa", "a")
try("find", "aa", "aa")
try("find", "a", "a")



