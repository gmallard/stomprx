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

say "subunsub tests start"
call test10
call test10nid
call test11
call test12
say "subunsub tests end"
exit
--
::routine test10
    say "test10 connect starts" time("L")
    asock = .netconn~open(.nil)
    ch = .headers~connhdr10
    cod = .directory~new
    sc = .connection~new(asock, ch, cod)
    say "newconn complete" time("L")
    say "session:" sc~session
    say "server:" sc~server
    say "protocol:" sc~protocol
    --
    call SysSleep 1.0
    say "sleep done"
    --
    sunh1 = .headers~new
    dest = "/queue/rexx/test/sub/unsub"
    desth = .header~new(.stc~HK_DESTINATION, dest)
    sunh1~add(desth)
    id = "AN_APPL_SUPPLIED_ID_1"
    idh = .header~new(.stc~HK_ID, id)
    sunh1~add(idh)
    sunh1~pp("SUB-UNSUB Headers 10:")
    --
    src = sc~subscribe(sunh1)
    say "test10 subscribe rc is" src
    --
    urc = sc~unsubscribe(sunh1)
    say "test10 unsubscribe rc is" urc
    --
    getr = .true
    if getr then do
        dh = .headers~new
        rc = .header~new(.stc~HK_RECEIPT, "test.receipt.id.sun10")
        dh~add(rc)
        say "disconnect starts" time("L")
        sc~disconnect(dh)
        rf = sc~recvrcpt(0.3)
        rf~pp("RECEIPT Frame:")
    end
    else sc~disconnect
    say "test10 disconnect done" time("L")
    return 0
--
::routine test10nid
    say "test10nid connect starts" time("L")
    asock = .netconn~open(.nil)
    ch = .headers~connhdr10
    cod = .directory~new
    sc = .connection~new(asock, ch, cod)
    say "newconn complete" time("L")
    say "session:" sc~session
    say "server:" sc~server
    say "protocol:" sc~protocol
    --
    call SysSleep 1.0
    say "sleep done"
    --
    sunh1 = .headers~new
    dest = "/queue/rexx/test/sub/unsub/nid"
    desth = .header~new(.stc~HK_DESTINATION, dest)
    sunh1~add(desth)
    sunh1~pp("SUB-UNSUB Headers 1 before:")
    --
    src = sc~subscribe(sunh1)
    say "test10nid subscribe rc is" src
    sunh1~pp("SUB-UNSUB Headers 1 after:")
    --
    urc = sc~unsubscribe(sunh1)
    say "test10nid unsubscribe rc is" urc
    --
    getr = .true
    if getr then do
        dh = .headers~new
        rc = .header~new(.stc~HK_RECEIPT, "test.receipt.id.nid.sun10")
        dh~add(rc)
        say "disconnect starts" time("L")
        sc~disconnect(dh)
        rf = sc~recvrcpt(0.3)
        rf~pp("RECEIPT Frame:")
    end
    else sc~disconnect
    say "test10nid disconnect done" time("L")
    return 0
--
::routine test11
    say "test11 connect starts" time("L")
    asock = .netconn~open(.nil)
    ch = .headers~connhdr11
    cod = .directory~new
    sc = .connection~new(asock, ch, cod)
    say "newconn complete" time("L")
    say "session:" sc~session
    say "server:" sc~server
    say "protocol:" sc~protocol
    --
    call SysSleep 1.0
    say "sleep done"
    --
    sunh1 = .headers~new
    dest = "/queue/rexx/test/sub/unsub/11"
    desth = .header~new(.stc~HK_DESTINATION, dest)
    sunh1~add(desth)
    id = "AN_APPL_SUPPLIED_ID_11"
    idh = .header~new(.stc~HK_ID, id)
    sunh1~add(idh)
    sunh1~pp("SUB-UNSUB Headers 1:")
    --
    src = sc~subscribe(sunh1)
    say "test11 subscribe rc is" src
    --
    urc = sc~unsubscribe(sunh1)
    say "test11 unsubscribe rc is" urc
    --
    getr = .true
    if getr then do
        dh = .headers~new
        rc = .header~new(.stc~HK_RECEIPT, "test.receipt.id.sun11")
        dh~add(rc)
        say "disconnect starts" time("L")
        sc~disconnect(dh)
        rf = sc~recvrcpt(0.3)
        rf~pp("RECEIPT Frame:")
    end
    else sc~disconnect
    say "test11 disconnect done" time("L")
    return 0
--
::routine test12
    say "test12 connect starts" time("L")
    asock = .netconn~open(.nil)
    ch = .headers~connhdr12
    cod = .directory~new
    sc = .connection~new(asock, ch, cod)
    say "newconn complete" time("L")
    say "session:" sc~session
    say "server:" sc~server
    say "protocol:" sc~protocol
    --
    call SysSleep 1.0
    say "sleep done"
    --
    sunh1 = .headers~new
    dest = "/queue/rexx/test/sub/unsub/12"
    desth = .header~new(.stc~HK_DESTINATION, dest)
    sunh1~add(desth)
    id = "AN_APPL_SUPPLIED_ID_12"
    idh = .header~new(.stc~HK_ID, id)
    sunh1~add(idh)
    sunh1~pp("SUB-UNSUB Headers 1:")
    --
    src = sc~subscribe(sunh1)
    say "test12 subscribe rc is" src
    --
    urc = sc~unsubscribe(sunh1)
    say "test12 unsubscribe rc is" urc
    --
    getr = .true
    if getr then do
        dh = .headers~new
        rc = .header~new(.stc~HK_RECEIPT, "test.receipt.id.sun12")
        dh~add(rc)
        say "disconnect starts" time("L")
        sc~disconnect(dh)
        rf = sc~recvrcpt(0.3)
        rf~pp("RECEIPT Frame:")
    end
    else sc~disconnect
    say "test12 disconnect done" time("L")
    return 0

--
::requires "../stomprx.cls"
