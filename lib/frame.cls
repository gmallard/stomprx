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

::method wirestring public
    expose command hdrs body
    --
    fs = command || .string~nl
    fs = fs || hdrs~wirestring
    fs = fs || body || "00"~x2c
    return fs

::method pp public
    expose command hdrs body
    use strict arg t
    --
    say t
    say "Command:"
    if command == "" then say "(empty)"
    else say command
    --
    hdrs~pp("Headers:")
    --
    say "Body:"
    if body == "" then say "(empty)"
    else say body
