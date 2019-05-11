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
hn = .header~new("keya", "valuea")
say "Header is:" hn~string
hn~key = "keyb"
hn~value = "valueb"
say "Header now is:" hn~string
say "Header hex is:" hn~string~c2x
say "Wire string is:" hn~wirestring
say "Hex Wire string:" hn~wirestring~c2x
::requires "../lib/header.cls"
