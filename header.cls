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
-- Stomp Header
--
::class header public
--
-- Attributes
--
::attribute key
::attribute value
--
-- CTOR
--
::method init public
    expose key value
    use strict arg k,v
    --
    key = k
    value = v

--
::method string public
    expose key value
    return key":"value

--
::method wirestring public
    return self~string || .string~nl

--
::method equals public
    expose key value
    use strict arg other
    --
    if \other~isA(.header) then return .false
    --
    return key == other~key & value == other~value

--
::method clone public
    expose key value
    nh = .header~new("","")
    nh~key = key
    nh~value = value
    return nh

