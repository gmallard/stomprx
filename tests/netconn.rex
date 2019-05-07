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

-- Test defaults
asock = .netconn~open(.nil)
say "Sock is:" asock
if asock~close() \= 'READY:'
then say 'SockClose1 Failed' asock~description

-- Test override from properties file
asock = .netconn~open("tnetc.properties")
say "Sock is:" asock
if asock~close() \= 'READY:'
then say 'SockClose2 Failed' asock~description

--
::requires "../netconn/netconn.cls"
