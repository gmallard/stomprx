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

    call hedc
    say
    call hednl
    say
    call hedcr
    say
    call hedsl
    say
    call hedmix
    exit

--
::routine hedc
    hl = .headers~new
    --
    nh = .header~new("K:A", "V:A")
    rv = hl~add(nh)
    say "Return from OK add is:" rv
    hl~pp("hedc test before encode:")
    hl~encode
    hl~pp("hedc test after encode:")
    hl~decode
    hl~pp("hedc test after decode:")
--
::routine hednl
    hl = .headers~new
    --
    nh = .header~new("K" || .string~nl || "A", "V" || .string~nl || "A")
    rv = hl~add(nh)
    say "Return from OK add is:" rv
    hl~pp("hednl test before encode:")
    hl~encode
    hl~pp("hednl test after encode:")
    hl~decode
    hl~pp("hednl test after decode:")
--
::routine hedcr
    hl = .headers~new
    --
    nh = .header~new("K" || "0d"~x2c || "A", "V" || "0d"~x2c || "A")
    rv = hl~add(nh)
    say "Return from OK add is:" rv
    hl~pp("hedcr test before encode:")
    hl~encode
    hl~pp("hedcr test after encode:")
    hl~decode
    hl~pp("hedcr test after decode:")
--
::routine hedsl
    hl = .headers~new
    --
    nh = .header~new("K" || "\" || "A", "V" || "\" || "A")
    rv = hl~add(nh)
    say "Return from OK add is:" rv
    hl~pp("hedsl test before encode:")
    hl~encode
    hl~pp("hedsl test after encode:")
    hl~decode
    hl~pp("hedsl test after decode:")
--
::routine hedmix
    hl = .headers~new
    --
    k = "K" || ":" || "A" || .string~nl || "A" || "0d"~x2c || "A" || "\" || "A"
    v = "V" || ":" || "A" || .string~nl || "A" || "0d"~x2c || "A" || "\" || "A"
    nh = .header~new(k, v)
    rv = hl~add(nh)
    say "Return from OK add is:" rv
    hl~pp("hedmix test before encode:")
    hl~encode
    hl~pp("hedmix test after encode:")
    hl~decode
    hl~pp("hedmix test after decode:")

::requires "../stomprx.cls"
