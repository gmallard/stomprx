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
-- Stomp RX Utilities
--
::class strutls public

-- Check file existance
::method isFile public class
    use strict arg fname
    qfile=.stream~new(fname)
    if qfile~query("exists")="" then
        return .false
    else
        return .true

-- ///////////////////////////////////////////////////////////////////////////
::class encdec

--
::method init
    expose edl
    x = .edlist~new
    edl = x~list

--
::method enc
    expose edl
    use strict arg ind
    oe = ind
    do x over edl~allItems
        oe = oe~changeStr(x~decoded, x~encoded)
    end
    return oe

--
::method dec
    expose edl
    use strict arg ine
    od = ine
    do x over edl~allItems
        od = od~changeStr(x~encoded, x~decoded)
    end
    return od

-- ///////////////////////////////////////////////////////////////////////////
::class edlist

--
::method init
    expose edl
    edl = .list~new
    edl~append(.edelt~new("\\", "\"))
    edl~append(.edelt~new("\n", .string~nl))
    edl~append(.edelt~new("\r", "0d"~x2c))
    edl~append(.edelt~new("\c", ":"))

--
::method list
    expose edl
    return edl

-- ///////////////////////////////////////////////////////////////////////////
::class edelt

--
::method init
    expose encoded decoded
    use strict arg enc,dec
    encoded = enc
    decoded = dec

--
::method encoded
    expose encoded
    return encoded

--
::method decoded
    expose decoded
    return decoded
