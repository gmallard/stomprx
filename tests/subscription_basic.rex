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

say "subscription tests start"

sunh1 = .headers~new
dest = "/queue/rexx/test/sub/unsub"
desth = .header~new(.stc~HK_DESTINATION, dest)
sunh1~add(desth)
id = "AN_APPL_SUPPLIED_ID_1"
idh = .header~new(.stc~HK_ID, id)
sunh1~add(idh)
sunh1~pp("SUB-UNSUB Headers 1:")

asub = .subscription~new(sunh1)
say "asub dest:" asub~dest
say "asub id:" asub~id

say "subscription tests end"
exit
--

--
::requires "../stomprx.cls"
