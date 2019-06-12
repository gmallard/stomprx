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
    expose hl
    self~init:super
    hl = .list~new
--
--
::method connhdr10 public class
    h10 = .headers~new
    hl = .header~new("login", "guest")
    hp = .header~new("passcode", "guest")
    hv = .header~new("accept-version", "1.0")
    hh = .header~new("host", "localhost")
    h10~add(hl); h10~add(hp); h10~add(hv); h10~add(hh)
    return h10

--
::method connhdr11 public class
    h11 = .headers~new
    hl = .header~new("login", "guest")
    hp = .header~new("passcode", "guest")
    hv = .header~new("accept-version", "1.1")
    hh = .header~new("host", "localhost")
    hhb = .header~new("heart-beat", "0,0")
    h11~add(hl); h11~add(hp); h11~add(hv); h11~add(hh); h11~add(hhb)
    return h11
--
::method connhdr12 public class
    h12 = .headers~new
    hl = .header~new("login", "guest")
    hp = .header~new("passcode", "guest")
    hv = .header~new("accept-version", "1.2")
    hh = .header~new("host", "localhost")
    hhb = .header~new("heart-beat", "0,0")
    h12~add(hl); h12~add(hp); h12~add(hv); h12~add(hh); h12~add(hhb)
    return h12
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
    expose hl
    use strict arg edl
    do hn over hl~allItems
        hn~key = edl~enc(hn~key)
        hn~value = edl~enc(hn~value)
    end
--
::method decode public
    expose hl
    use strict arg edl
    do hn over hl~allItems
        hn~key = edl~dec(hn~key)
        hn~value = edl~dec(hn~value)
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

::requires "header.cls"
