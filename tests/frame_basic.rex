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
say "hi"

h10 = .headers~connhdr10
f = .frame~new("CONNECT", h10, "")
say "frame wirestring:"
say f~wirestring
say
say f~wirestring~c2x
say
h11 = .headers~connhdr11
f = .frame~new("CONNECT", h11, "")
say "frame wirestring:"
say f~wirestring
say
say f~wirestring~c2x
say
h12 = .headers~connhdr12
f = .frame~new("CONNECT", h12, "")
say "frame wirestring:"
say f~wirestring
say
say f~wirestring~c2x
--
say
f~pp("pp of 1.2 frame")

-- fromstring
ts = "SEND".string~nl
ts = ts || "keya:val1".string~nl
ts = ts || "keyb:val2".string~nl
ts = ts || "keyc:val3".string~nl
ts = ts || .string~nl
ts = ts || "Data in body"
ts = ts || "00"~x2c
ffs = .frame~fromstring(ts)
ffs~pp("Test From String:")

ts = "SEND".string~nl
ts = ts || "keya:val1".string~nl
ts = ts || "keyb:val2".string~nl
ts = ts || "keyc:val3".string~nl
ts = ts || .string~nl
-- no body
ts = ts || "00"~x2c
ffs = .frame~fromstring(ts)
ffs~pp("Test From String No Body:")

say;say "bye"
exit
--
::requires "../stomprx.cls"
