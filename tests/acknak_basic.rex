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

call test10
call test11
call test12

exit
--
::routine test10
    --
    say "connect starts" time("L")
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
    ah = .headers~new
    rc = sc~ack(ah)
    say "Expect a -1"
    say "ack10 rc:" rc
    rc = sc~nack(ah)
    say "Expect a -1"
    say "nack10 rc:" rc
    --
    getr = .true
    if getr then do
        dh = .headers~new
        rc = .header~new(.stc~HK_RECEIPT, "test.receipt.id")
        dh~add(rc)
        say "disconnect starts" time("L")
        sc~disconnect(dh)
        rf = sc~recvrcpt(0.3)
        rf~pp("RECEIPT Frame:")
    end
    else sc~disconnect
    say "disconnect done" time("L")
--
::routine test11
    --
    say "connect starts" time("L")
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
    midh = .header~new(.stc~HK_MESSAGE_ID, "msg1-id-1")
    --
    ah = .headers~new
    rc = sc~ack(ah)
    say "Expect a -2"
    say "ack11 rc:" rc
    rc = sc~nack(ah)
    say "Expect a -2"
    say "nack11 rc:" rc
    --
    ah~add(midh)
    rc = sc~ack(ah)
    say "Expect a -3"
    say "ack11 rc:" rc
    rc = sc~nack(ah)
    say "Expect a -3"
    say "nack11 rc:" rc
    --
    getr = .true
    if getr then do
        dh = .headers~new
        rc = .header~new(.stc~HK_RECEIPT, "test.receipt.id")
        dh~add(rc)
        say "disconnect starts" time("L")
        sc~disconnect(dh)
        rf = sc~recvrcpt(0.3)
        rf~pp("RECEIPT Frame:")
    end
    else sc~disconnect
    say "disconnect done" time("L")
--
::routine test12
    --
    say "connect starts" time("L")
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
    ah = .headers~new
    rc = sc~ack(ah)
    say "Expect a -4"
    say "ack12 rc:" rc
    rc = sc~nack(ah)
    say "Expect a -4"
    say "nack12 rc:" rc
    -- idh = .header~new(.stc~HK_ID, "sub1-id-1")
    --
    getr = .true
    if getr then do
        dh = .headers~new
        rc = .header~new(.stc~HK_RECEIPT, "test.receipt.id")
        dh~add(rc)
        say "disconnect starts" time("L")
        sc~disconnect(dh)
        rf = sc~recvrcpt(0.3)
        rf~pp("RECEIPT Frame:")
    end
    else sc~disconnect
    say "disconnect done" time("L")
--

::requires "../stomprx.cls"
