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
-- Stomp Frame
--
::class frame public
--
-- Attributes
--
::attribute command
::attribute hdrs
::attribute body
--
-- CTOR
--
::method init public
    expose command hdrs body
    use strict arg c, h, b
    --
    command = c
    hdrs = h
    body = b
    --

::method fromstring public class
    use strict arg ins
    --
    nl = .string~nl
    dnl = nl || nl
    x00 = "00"~x2c
    --
    parse var ins f (nl) hs (dnl) b (x00) .
    hdrs = .headers~fromstring(hs)
    fr = .frame~new(f, hdrs, b)
    return fr

::method wirestring public
    expose command hdrs body
    --
    if command == .string~nl then return command
    --
    fs = command || .string~nl
    fs = fs || hdrs~wirestring
    fs = fs || body || "00"~x2c
    return fs

::method pp public
    expose command hdrs body
    use strict arg t
    --
    say time("L") t
    say time("L") "Command:"
    if command == "" then say time("L") "(empty)"
    else say time("L") command
    --
    hdrs~pp("Headers PP From Frame:")
    --
    say time("L") "Body:"
    if body == "" then say time("L") "(empty)"
    else say time("L") body

::requires "headers.cls"
