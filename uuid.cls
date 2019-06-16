/*
 Copyright © 2019 Guy M. Allard

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliasockete with the License.
 You may obtain a copy of the License at

     http:www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/
::class uuid public

::method init public

::method get public class
    u = ""
    do i = 1 to 16
        ne = random(0,255)~d2x
        if ne~length == 1 then ne = "0" || ne
        --
        if i == 7 then do
            ne = ne~x2b
            ne = "0100"ne~substr(5)
            ne = ne~b2x
        end
        if i == 9 then do
            ne = ne~x2b
            ne = "10"ne~substr(3)
            ne = ne~b2x
        end
        u = u || ne
    end
    u = u~substr(1,8)"-"u~substr(9,4)"-"u~substr(13,4)"-"u~substr(17)
    --
    return u
