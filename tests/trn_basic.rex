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

call testa
call testb
call testc
call testd
exit

--
::routine testa
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
    hdrsb = .headers~new
    --
    rc = sc~begin(hdrsb)
    say
    say "expect -1"
    say "testa BEGIN rc:" rc  -- expect a -1 here
    --
    rc = sc~commit(hdrsb)
    say
    say "expect -1"
    say "testa COMMIT rc:" rc  -- expect a -1 here
    --
    rc = sc~abort(hdrsb)
    say
    say "expect -1"
    say "testa ABORT rc:" rc  -- expect a -1 here
    --    
    say
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
::routine testb
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
    trnh1 = .header~new(.stc~HK_TRANSACTION, "trn1")
    hdrs1 = .headers~new
    hdrs1~add(trnh1)
    say
    hdrs1~pp("Transaction Header 1")
    --
    rc = sc~begin(hdrs1)
    say
    say "expect 0"
    say "testb BEGIN rc:" rc -- expect 0
    --
    rc = sc~begin(hdrs1) -- second time, same trn
    say
    say "expect -2"
    say "testb BEGIN rc:" rc -- expect -2
    --
    rc = sc~commit(hdrs1)
    say
    say "expect 0"
    say "testb COMMIT rc:" rc -- expect 0
    --    
    say
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
::routine testc
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
    trnh1 = .header~new(.stc~HK_TRANSACTION, "trn1")
    hdrs1 = .headers~new
    hdrs1~add(trnh1)
    say
    hdrs1~pp("Transaction Header 1")
    --
    rc = sc~begin(hdrs1)
    say
    say "expect 0"
    say "testc BEGIN rc:" rc -- expect 0
    --
    rc = sc~abort(hdrs1)
    say
    say "expect 0"
    say "testc ABORT rc:" rc -- expect 0
    --    
    say
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
::routine testd
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
    trnh1 = .header~new(.stc~HK_TRANSACTION, "trn1")
    hdrs1 = .headers~new
    hdrs1~add(trnh1)
    say
    hdrs1~pp("Transaction Header 1")
    --
    rc = sc~commit(hdrs1)
    say
    say "expect -2"
    say "testd COMMIT rc:" rc -- expect a -2
    --
    rc = sc~abort(hdrs1)
    say
    say "expect -2"
    say "testd ABORT rc:" rc -- expect a -2
    --    
    say
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
