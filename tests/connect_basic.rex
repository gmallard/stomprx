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

say  time("L") "Test protocol level 1.0 ====================================="
call test10
say  time("L") "Test protocol level 1.1 ====================================="
call test11
say  time("L") "Test protocol level 1.2 ====================================="
call test12
exit

::routine test10
    say  time("L") "connect starts"
    asock = .netconn~open(.nil)
    ch = .headers~connhdr10
    cod = .directory~new
    sc = .stomprxconn~new(asock, ch, cod)
    say  time("L") "newconn complete"
    say  time("L") "session:" sc~session
    say  time("L") "server:" sc~server
    say  time("L") "protocol:" sc~protocol
    --
    call SysSleep 1.0
    say  time("L") "sleep done"
    --
    getr = .true
    if getr then do
        dh = .headers~new
        rc = .header~new(.stc~HK_RECEIPT, "test.receipt.id")
        dh~add(rc)
        say  time("L") "disconnect starts"
        sc~disconnect(dh)
        rf = sc~recvrcpt(0.3)
        rf~pp("RECEIPT Frame:")
    end
    else sc~disconnect
    say  time("L") "disconnect done"

::routine test11
    say  time("L") "connect starts"
    asock = .netconn~open(.nil)
    ch = .headers~connhdr11
    cod = .directory~new
    sc = .stomprxconn~new(asock, ch, cod)
    say  time("L") "newconn complete"
    say  time("L") "session:" sc~session
    say  time("L") "server:" sc~server
    say  time("L") "protocol:" sc~protocol
    --
    call SysSleep 1.0
    say  time("L") "sleep done"
    --
    getr = .true
    if getr then do
        dh = .headers~new
        rc = .header~new(.stc~HK_RECEIPT, "test.receipt.id")
        dh~add(rc)
        say  time("L") "disconnect starts"
        sc~disconnect(dh)
        rf = sc~recvrcpt(0.3)
        rf~pp("RECEIPT Frame:")
    end
    else sc~disconnect
    say  time("L") "disconnect done"

::routine test12
    say  time("L") "connect starts"
    asock = .netconn~open(.nil)
    ch = .headers~connhdr12
    cod = .directory~new
    sc = .stomprxconn~new(asock, ch, cod)
    say  time("L") "newconn complete"
    say  time("L") "session:" sc~session
    say  time("L") "server:" sc~server
    say  time("L") "protocol:" sc~protocol
    --
    call SysSleep 1.0
    say  time("L") "sleep done"
    --
    getr = .true
    if getr then do
        dh = .headers~new
        rc = .header~new(.stc~HK_RECEIPT, "test.receipt.id")
        dh~add(rc)
        say  time("L") "disconnect starts"
        sc~disconnect(dh)
        rf = sc~recvrcpt(0.3)
        rf~pp("RECEIPT Frame:")
    end
    else sc~disconnect
    say  time("L") "disconnect done"

--
::requires "../stomprx.cls"
