/*
 Copyright © 2019 Guy M. Allard

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http:www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/
--
-- STOMP Headers
--
::class headers public
--
-- CTOR
--
::method init public
    expose hl eder
    self~init:super
    hl = .list~new
    eder = .encdecer~new
--
--
::method connhdr10 public class
    return .headers~connhdrx("1.0")

--
::method connhdr11 public class
    return .headers~connhdrx("1.1")

--
::method connhdr12 public class
    return .headers~connhdrx("1.2")

--
::method connhdrx public class
    use strict arg proto
    rh = .headers~new
    --
    hv = "guest"
    t = value("STOMP_LOGIN", "", .stc~env)
    if t <> "" then hv = t
    rh~add(.header~new(.stc~HK_LOGIN, hv))
    --
    hv = "guest"
    t = value("STOMP_PASSCODE", "", .stc~env)
    if t <> "" then hv = t
    rh~add(.header~new(.stc~HK_PASSCODE, hv))
    --
    hv = "localhost"
    t = value("STOMP_VHOST", "", .stc~env)
    if t <> "" then hv = t
    rh~add(.header~new(.stc~HK_VHOST, hv))
    --
    hv = "0,0"
    t = value("STOMP_HEARTBEAT", "", .stc~env)
    if t <> "" then hv = t
    rh~add(.header~new(.stc~HK_HEART_BEAT, hv))
    --
    rh~add(.header~new(.stc~HK_ACCEPT_VERSION, proto))
    return rh

--
::method fromstring public class
    use strict arg ins
    h = .headers~new
    ls = ins~makeArray()
    do ln over ls~allItems
        parse var ln k ":" v
        hdr = .header~new(k, v)
        if \h~add(hdr) then say "WARNING not a header"
    end
    return h

--
::method add public
    expose hl
    use strict arg other
    --
    if \other~isA(.header) then return .false
    hl~append(other)
    return .true

--
::method rmkey public
    expose hl
    use strict arg k
    rv = .false
    do hn over hl~allItems()
        if hn~key == k then do
            hl~removeItem(hn)
            rv = .true
        end
    end
    return rv

--
::method value public
    expose hl
    use strict arg k
    do hn over hl~allItems()
        if hn~key == k then return hn~value
    end
    return .nil

--
::method allvalues public
    expose hl
    use strict arg k
    ra = .array~new
    do hn over hl~allItems()
        if hn~key == k then ra~append(hn~value)
    end
    if ra~items == 0 then return .nil
    return ra

--
::method string public
    expose hl
    --
    rs = ""
    do hn over hl~allItems()
        rs = rs || hn~key || ":" || hn~value || .string~nl
    end
    return rs
--
::method wirestring public
    expose hl
    return self~string || .string~nl
--
::method pp public
    expose hl
    use strict arg t
    say t
    --
    say "Header count:" hl~items
    do hn over hl~allItems()
        say "Key->"hn~key", Value->"hn~value
    end

--
::method equals public
    expose hl
    use strict arg other
    --
    if \other~isA(.headers) then return .false
    --
    do hn over hl~allItems()
        ov = other~value(hn~key)
        -- key not found?
        if  ov == .nil then return .false
        -- check values are equal
        if ov \= hn~value then return .false
    end
    return .true

--
::method clone public
    expose hl
    nhd = .headers~new
    do hn over hl~allItems
        nhd~add(hn)
    end
    return nhd

--
::method encode public
    expose hl eder
    do hn over hl~allItems
        hn~key = eder~enc(hn~key)
        hn~value = eder~enc(hn~value)
    end
--
::method decode public
    expose hl eder
    do hn over hl~allItems
        hn~key = eder~dec(hn~key)
        hn~value = eder~dec(hn~value)
    end

--
::method setvalue public
    expose hl
    use strict arg k,nv
    do hn over hl~allItems
        if k == hn~key then do
            hn~value = nv
            return .true
        end
    end
    return .false

--
::method setkey public
    expose hl
    use strict arg k,nk
    do hn over hl~allItems
        if k == hn~key then do
            hn~key = nk
            return .true
        end
    end
    return .false

-- ///////////////////////////////////////////////////////////////////////////
::class encdecer public

--
::method init public
    expose edl
    x = .edlist~new
    edl = x~list

--
::method enc public
    expose edl
    use strict arg ind
    oe = ind
    do x over edl~allItems
        oe = oe~changeStr(x~decoded, x~encoded)
    end
    return oe

--
::method dec public
    expose edl
    use strict arg ine
    od = ine
    do x over edl~allItems
        od = od~changeStr(x~encoded, x~decoded)
    end
    return od

--
::method pp public
    expose edl
    use strict arg t
    say t
    --
    do ne over edl~allItems
        ne~pp("Next E/D Pair:")
    end
-- ///////////////////////////////////////////////////////////////////////////
::class edlist public

--
::method init public
    expose edl
    edl = .list~new
    edl~append(.edelt~new("\\", "\"))
    edl~append(.edelt~new("\n", .string~nl))
    edl~append(.edelt~new("\r", "0d"~x2c))
    edl~append(.edelt~new("\c", ":"))

--
::method list public
    expose edl
    return edl

-- ///////////////////////////////////////////////////////////////////////////
::class edelt public

--
::method init public
    expose encoded decoded
    use strict arg enc,dec
    encoded = enc
    decoded = dec

--
::method encoded public
    expose encoded
    return encoded

--
::method decoded public
    expose decoded
    return decoded

--
::method pp public
    expose encoded decoded
    use strict arg t
    say t
    say "Encoded->"encoded", Decoded->"decoded

::requires "stc.cls"
::requires "header.cls"
