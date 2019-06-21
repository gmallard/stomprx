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
call recv12
say "recv tests end"
exit
--
::routine recv12
    say "recv12 connect starts" time("L")
    asock = .netconn~open(.nil)
    ch = .headers~connhdr12
    cod = .directory~new
    sc = .connection~new(asock, ch, cod)
    say "newconn complete" time("L")
    say "session:" sc~session time("L")
    say "server:" sc~server time("L")
    say "protocol:" sc~protocol time("L")
    --
    call SysSleep 1.0
    say "sleep done" time("L")
    --
    t = value("STOMP_NMSGS", "", .stc~env)
    nmsgs = 1
    if t <> "" then nmsgs = t
    say "NMSGS:" nmsgs time("L")
    subq = .queue~new
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
    src = sc~subscribe(sunh1, subq)
    say "recv12 subscribe rc is" src time("L")
    --
    mc = 0
    do until mc >= nmsgs
        say "Calling receive:" time("L")
        tmsg = subq~pull
        if tmsg == .nil then do
            call SysSleep 0.2
            iterate
        end
        mc = mc + 1
        say "Message Count is:" mc time("L")
        tmsg~pp("RECEIVED Frame:")
    end
    --
    urc = sc~unsubscribe(sunh1)
    say "recv12 unsubscribe rc is" urc time("L")
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
::requires "../stomprx.cls"
