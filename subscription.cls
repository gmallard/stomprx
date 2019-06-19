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
::class subscription public

::attribute dest get
::attribute id get
::attribute msgq get

::method init public
    expose dest id msgq
    use arg sh, smq
    --
    if smq == "SMQ" then msgq = .nil
    else msgq = smq
    --
    dest = sh~value(.stc~HK_DESTINATION)
    --
    id = sh~value(.stc~HK_ID)
--
::requires "stc.cls"
