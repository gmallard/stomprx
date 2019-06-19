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
--
-- Stomp Connection
--
::class connection public
--
-- Attributes
--
::attribute edd get
::attribute connframe get
::attribute protocol get
::attribute session get
::attribute server get
--
-- CTOR
--
::method init public
    expose edd socket connframe protocol session server,
        wtrq errq rcptq msgq,
        shutdown NL DNL X00,
        discdbg rdrdbg wtrdbg,
        rdrslt wtrslt
    use strict arg as, ch, od
    socket = as
    -- encode / decode data logic
    edd = .encdec~new
    --
    cf = .frame~new(.stc~CONNECT, ch, "")
    -- cf~pp("Connect Frame:")
    -- say "raw data:"
    -- say cf~wirestring~c2x
    -- Write the CONNECT frame
    bw = SockSend(socket, cf~wirestring || .string~nl)
    -- say "Bytes written:" bw    
    call SysSleep(0.1)
    retc = SockRecv(socket, 'rcf', 2048)
    -- say "Return Code:" retc
    -- say "Len Received:" rcf~length
    -- say "Data Received:"
    -- say rcf
    -- say "========================="
    connframe = .frame~fromstring(rcf)
    -- connframe~pp("Connection frame")
    if connframe~command == ERROR then
        say "WARNING - ERROR from broker on CONNECT"
    else do
        -- say "connect complete"
        -- say "vercon:|" .stc~HK_VERSION "|"
        -- ch = connframe~hdrs
        -- ch~pp("CONNECT Frame Headers:")
        protocol = connframe~hdrs~value(.stc~HK_VERSION)
        session = connframe~hdrs~value(.stc~HK_SESSION)
        server = connframe~hdrs~value(.stc~HK_SERVER)
        -- say "protocol:" protocol
    end
    --
    self~loadopts(od)
    shutdown = .false
    --
    -- start the reader
    self~start("reader", rdrslt)
    call SysSleep 0.2
    -- start the writer
    -- say "XDBG starting writer" wtrslt
    self~start("writer", wtrslt)
    call SysSleep 0.2
    -- say "XDBG done starting writer" wtrslt

::method disconnect public
    expose socket wtrq shutdown discdbg
    use arg odh
    --
    if odh == "ODH" then
        useh = .headers~new
    else
        useh = odh
    --
    discdbg = .true
    df = .frame~new(.stc~DISCONNECT, useh, "")
    in = wtrq~append(df) -- send frame to writer
    call SysSleep 0.5
    shutdown = .true
    --
    retc = SockClose(socket)
    if discdbg then say "disconnect close return code:" retc
    
::method writer unguarded
    expose socket wtrq shutdown wtrdbg
    use strict arg wst
    -- say "XDBG wtr starts" wtrdbg wst
    if wtrdbg then say "writer starts"
    lc = 0
    wfc = 0
    do forever
        lc = lc + 1 
        -- say "writer start next loop" lc
        if shutdown then leave
        --
        nxf = wtrq~pull
        if nxf == .nil then do
            -- say "writer sleeps"
            call SysSleep wst
            iterate
        end
        -- nxf~pp("In Frame writer:")
        wfc = wfc + 1
        nfd = nxf~wirestring
        bw = SockSend(socket, nfd || .string~nl)
        if wtrdbg then do
            say "frame number" wfc "sent" bw "bytes"
        end
    end
    --
    if wtrdbg then say "writer ends"

::method reader unguarded
    expose socket shutdown errq rcptq msgq NL DNL X00 rdrdbg
    use strict arg rst
    if rdrdbg then say "READER: reader starts"
    hbb = ""
    --
    -- The reader implementation is a state machine.
    --
    moredata = 0
    nldrain = 1
    findeoh = 2
    accumbdy0 = 3
    sendq = 4
    getcmd = 5
    accumbdyl = 6
    --
    command = ""
    headers = ""
    body = ""
    fcl = .nil
    --
    state = moredata
    resumest = nldrain
    do forever
        select
            --
            when state == moredata then do
                if rdrdbg then say "READER: state is moredata"
                ret = SockRecv(socket, 'ldata', 1024)
                if ret < 1 then do
                    if ret < 0 then say 'READER: SockRecv failed:' errno
                    else say 'READER: Socket closed:' errno
                    leave
                end
                hbb = hbb || ldata
                state = resumest
                iterate
            end
            --
            when state == nldrain then do
                if rdrdbg then say "READER: state is nldrain"
                do while hbb~subchar(1) == .string~nl
                    if hbb~length == 1 then do
                        hbb = ""
                        leave
                    end
                    else hbb = hbb~substr(2)
                end
                if hbb~length == 0 then do
                    state = moredata
                    resumest = nldrain
                    iterate
                end
                state = getcmd
                iterate
            end
            --
            when state == findeoh then do
                if rdrdbg then say "READER: state is findeoh"
                if hbb~subchar(1) == NL then do
                    headers = .headers~new
                    hbb = hbb~substr(2)
                    if hbb~subchar(1) == X00 then do
                        hbb = hbb~substr(2)
                        body = ""
                        state = sendq
                        iterate
                    end
                    state = accumbdy0
                    iterate
                end
                if hbb~pos(DNL) == 0 then do
                    state = moredata
                    resumest = findeoh
                    iterate
                end
                parse var hbb hs (DNL) hbb
                headers = .headers~fromstring(hs)
                if hbb~subchar(1) == X00 then do
                    hbb = hbb~substr(2)
                    body = ""
                    state = sendq
                    iterate
                end
                fcl = headers~value(.stc~HK_CONTENT_LENGTH)
                if fcl == .nil then do
                    state = accumbdy0
                    iterate
                end
                else do
                    state = accumbdyl
                    iterate
                end
            end
            --
            when state == accumbdy0 then do
                if rdrdbg then say "READER: state is accumbdy0"
                px0 = hbb~pos(X00)
                if px0 > 0 then do
                    body = hbb~substr(1,px0-1)
                    hbb = hbb~substr(px0+1)
                    state = sendq
                    iterate
                end
                --
                found = .false
                do while \found
                    ret = SockRecv(socket, 'ldata', 1024)
                    if ret < 1 then do
                        if ret < 0 then
                            say 'SockRecv failed:' errno
                        else
                            say 'Socket closed:' errno
                        leave
                    end
                    hbb = hbb || ldata
                    if ldata~pos(.stc~X00) > 0 then found = .true
                end
                --
                px0 = hbb~pos(X00)
                body = hbb~substr(1,px0-1)
                hbb = hbb~substr(px0+1)
                state = sendq
                iterate
            end
            --
            when state == sendq then do
                if rdrdbg then say "READER: state is sendq"
                --
                -- say "command:" command
                -- headers~pp("parsed headers:")
                -- say "bodyx:" body~c2x body~length()
                -- leave
                --
                nf = .frame~new(command, headers, body)
                if command == .stc~ERROR then errq~append(nf)
                if command == .stc~RECEIPT then rcptq~append(nf)
                if command == .stc~MESSAGE then msgq~append(nf)
                --
                command = ""
                headers = ""
                body = ""
                fcl = .nil
                --
                state = nldrain
                iterate
            end
            --
            when state == getcmd then do
                if rdrdbg then say "READER: state is getcmd"
                if hbb~pos(NL) == 0 then do
                    state = moredata
                    resumest = getcmd
                    iterate
                end
                parse var hbb command (NL) hbb
                if hbb == "" then do
                    state = moredata
                    resumest = findeoh
                    iterate
                end
                state = findeoh
                iterate
            end
            --
            when state == accumbdyl then do
                if rdrdbg then say "READER: state is accumbdyl"
                hbl = hbb~length
                do while hbl < fcl
                    ret = SockRecv(socket, 'ldata', 1024)
                    if ret < 1 then do
                        if ret < 0 then
                            say 'READER: SockRecv failed:' errno
                        else
                            say 'READER: Socket closed:' errno
                        leave
                    end
                    hbb = hbb || ldata
                end
                --
                body = hbb~substr(1, fcl)
                hbb = hbb~substr(fcl + 1)
                state = sendq
                iterate
            end
        end -- select
        if shutdown then leave
    end -- forever do
    --
    if rdrdbg then say "READER: reader ends"
--
::method recverr
    expose errq
    use arg slt
    --
    if slt == "SLT" then do
        tf = errq~pull
        return tf
    end
    --
    do forever
        tf = errq~pull
        if tf <> .nil then return tf
        call SysSleep slt
    end
--
::method recvrcpt
    expose rcptq
    use arg slt
    --
    if slt == "SLT" then do
        tf = rcptq~pull
        return tf
    end
    --
    do forever
        tf = rcptq~pull
        if tf <> .nil then return tf
        call SysSleep slt
    end
--
::method recvmsg
    expose msgq
    use arg slt
    --
    if slt == "SLT" then do
        tf = msgq~pull
        return tf
    end
    --
    do forever
        tf = msgq~pull
        if tf <> .nil then return tf
        call SysSleep slt
    end

--
::method loadopts private
    expose discdbg rdrdbg wtrdbg,
        rdrslt wtrslt,
        wtrq rcptq errq,
        NL DNL X00
    use arg sopt
    --
    ldbg = .false
    --
    wtrq = .queue~new
    errq = .queue~new
    rcptq = .queue~new
    msgq = .queue~new
    --
    NL = .string~nl
    DNL = .string~nl || .string~nl
    X00 = "00"~x2c
    --
    if sopt == "SOPT" then ho = .false
    else ho = .true
    --
    discdbg = .false
    if ho then do
        if sopt~entry("discdbg") <> .nil then
            discdbg = .true
    end
    t = value("STOMPRX_DISCDBG", "", .stc~env)
    if t <> "" then
        discdbg = .true
    if ldbg then say "discdbg:" discdbg
    --
    rdrdbg = .false
    if ho then do
        if sopt~entry("rdrdbg") <> .nil then
            rdrdbg = .true
    end
    t = value("STOMPRX_RDRDBG", "", .stc~env)
    if t <> "" then
        rdrdbg = .true
    if ldbg then say "rdrdbg:" rdrdbg
    --
    wtrdbg = .false
    if ho then do
        if sopt~entry("wtrdbg") <> .nil then
            wtrdbg = .true
    end
    t = value("STOMPRX_WTRDBG", "", .stc~env)
    if t <> "" then
        wtrdbg = .true
    if ldbg then say "wtrdbg:" wtrdbg
    --
    rdrslt = 0.2
    if ho then do
        if sopt~entry("rdrslt") <> .nil then
            rdrslt = sopt~entry("rdrslt")
    end
    t = value("STOMPRX_RDRSLT", "", .stc~env)
    if t <> "" then
        rdrslt = t
    if ldbg then say "rdrslt:" rdrslt
    --
    wtrslt = 0.2
    if ho then do
        if sopt~entry("wtrslt") <> .nil then
            wtrslt = sopt~entry("wtrslt")
    end
    t = value("STOMPRX_WTRSLT", "", .stc~env)
    if t <> "" then
        wtrslt = t
    if ldbg then say "wtrslt:" wtrslt

::method send
    expose wtrq
    use strict arg h,b
    if h~value(.stc~HK_DESTINATION) == .nil then return -1
    sf = .frame~new(.stc~SEND, h, b)
    -- h~pp("In SEND. headers:")
    tix = wtrq~append(sf)
    -- say "send tix:" tix
    return 0

::requires 'rxsock' LIBRARY
/* Watch this.  Order is important. */
::requires "uuid.cls"
::requires "stc.cls"
::requires "header.cls"
::requires "headers.cls"
::requires "strutls.rex"
::requires "frame.cls"
::requires "netconn.cls"
