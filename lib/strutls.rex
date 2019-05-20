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
::class encdec public

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
