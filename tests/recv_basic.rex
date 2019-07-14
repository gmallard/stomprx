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

say "recv tests start"
call recv10
call recv10nid
call recv11
call recv12
say "recv tests end"
exit
--
::routine recv10
    say "recv10 connect starts" time("L")
    asock = .netconn~open(.nil)
    ch = .headers~connhdr10
    cod = .directory~new
    sc = .stomprxconn~new(asock, ch, cod)
    say "newconn complete" time("L")
    say "session:" sc~session
    say "server:" sc~server
    say "protocol:" sc~protocol
    --
    call SysSleep 1.0
    say "sleep done"
    --
    startmsg = 1
    t = value("STOMP_NMSGS", "", .stc~env)
    nmsgs = 1
    if t <> "" then nmsgs = t
    --
    sunh1 = .headers~new
    dest = "/queue/rexx/test/recv/10"
    desth = .header~new(.stc~HK_DESTINATION, dest)
    sunh1~add(desth)
    id = "recv_10"
    idh = .header~new(.stc~HK_ID, id)
    sunh1~add(idh)
    sunh1~pp("recv10 Headers 10:")
    --
    src = sc~subscribe(sunh1)
    say "recv10 subscribe rc is" src
    --
    do i = startmsg to nmsgs
        say "Calling receive:"
        aframe = sc~receive(0.3)
        aframe~pp("RECEIVED Frame:")
    end
    --
    urc = sc~unsubscribe(sunh1)
    say "recv10 unsubscribe rc is" urc
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
    say "recv10 disconnect done" time("L")
    return 0
--
::routine recv10nid
    say "recv10nid connect starts" time("L")
    asock = .netconn~open(.nil)
    ch = .headers~connhdr10
    cod = .directory~new
    sc = .stomprxconn~new(asock, ch, cod)
    say "newconn complete" time("L")
    say "session:" sc~session
    say "server:" sc~server
    say "protocol:" sc~protocol
    --
    call SysSleep 1.0
    say "sleep done"
    --
    startmsg = 1
    t = value("STOMP_NMSGS", "", .stc~env)
    nmsgs = 1
    if t <> "" then nmsgs = t
    --
    sunh1 = .headers~new
    dest = "/queue/rexx/test/recv/10nid"
    desth = .header~new(.stc~HK_DESTINATION, dest)
    sunh1~add(desth)
    sunh1~pp("SUB-UNSUB Headers 1 before:")
    --
    src = sc~subscribe(sunh1)
    say "recv10nid subscribe rc is" src
    --
    do i = startmsg to nmsgs
        say "Calling receive:"
        aframe = sc~receive(0.3)
        aframe~pp("RECEIVED Frame:")
    end
    sunh1~pp("SUB-UNSUB Headers 1 after:")
    --
    urc = sc~unsubscribe(sunh1)
    say "recv10nid unsubscribe rc is" urc
    --
    getr = .true
    if getr then do
        dh = .headers~new
        rc = .header~new(.stc~HK_RECEIPT, "test.receipt.id.nid.sun10nid")
        dh~add(rc)
        say "disconnect starts" time("L")
        sc~disconnect(dh)
        rf = sc~recvrcpt(0.3)
        rf~pp("RECEIPT Frame:")
    end
    else sc~disconnect
    say "recv10nid disconnect done" time("L")
    return 0
--
::routine recv11
    say "recv11 connect starts" time("L")
    asock = .netconn~open(.nil)
    ch = .headers~connhdr11
    cod = .directory~new
    sc = .stomprxconn~new(asock, ch, cod)
    say "newconn complete" time("L")
    say "session:" sc~session
    say "server:" sc~server
    say "protocol:" sc~protocol
    --
    call SysSleep 1.0
    say "sleep done"
    --
    startmsg = 1
    t = value("STOMP_NMSGS", "", .stc~env)
    nmsgs = 1
    if t <> "" then nmsgs = t
    --
    sunh1 = .headers~new
    dest = "/queue/rexx/test/recv/11"
    desth = .header~new(.stc~HK_DESTINATION, dest)
    sunh1~add(desth)
    id = "recv_11"
    idh = .header~new(.stc~HK_ID, id)
    sunh1~add(idh)
    sunh1~pp("recv11 Headers 11:")
    --
    src = sc~subscribe(sunh1)
    say "recv11 subscribe rc is" src
    --
    do i = startmsg to nmsgs
        say "Calling receive:"
        aframe = sc~receive(0.3)
        aframe~pp("RECEIVED Frame:")
    end
    --
    urc = sc~unsubscribe(sunh1)
    say "recv11 unsubscribe rc is" urc
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
    say "recv11 disconnect done" time("L")
    return 0
--
::routine recv12
    say "recv12 connect starts" time("L")
    asock = .netconn~open(.nil)
    ch = .headers~connhdr12
    cod = .directory~new
    sc = .stomprxconn~new(asock, ch, cod)
    say "newconn complete" time("L")
    say "session:" sc~session
    say "server:" sc~server
    say "protocol:" sc~protocol
    --
    call SysSleep 1.0
    say "sleep done"
    --
    startmsg = 1
    t = value("STOMP_NMSGS", "", .stc~env)
    nmsgs = 1
    if t <> "" then nmsgs = t
    --
    sunh1 = .headers~new
    dest = "/queue/rexx/test/recv/12"
    desth = .header~new(.stc~HK_DESTINATION, dest)
    sunh1~add(desth)
    id = "recv_12"
    idh = .header~new(.stc~HK_ID, id)
    sunh1~add(idh)
    sunh1~pp("recv2 Headers 12:")
    --
    src = sc~subscribe(sunh1)
    say "recv12 subscribe rc is" src
    --
    do i = startmsg to nmsgs
        say "Calling receive:"
        aframe = sc~receive(0.3)
        aframe~pp("RECEIVED Frame:")
    end
    --
    urc = sc~unsubscribe(sunh1)
    say "recv12 unsubscribe rc is" urc
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
    say "recv12 disconnect done" time("L")
    return 0

--
::requires "../stomprxconn.cls"
