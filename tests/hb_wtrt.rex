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

asock = .netconn~open(.nil)
ch = .headers~connhdr12
--
ch~setvalue(.stc~HK_HEART_BEAT, "10000,0")
--
cod = .directory~new
sc = .stomprxconn~new(asock, ch, cod)
--
say time("L") "hb_wtrt starts 60 second sleep"
call SysSleep 60
sc~showhbd      -- show heartbeat data
--
sc~disconnect
--
::requires "../stomprx.cls"
