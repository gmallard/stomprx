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
-- For Heart Beat Values
--
::options digits 18
--
-- Attributes
--
::attribute connframe get
::attribute protocol get
::attribute session get
::attribute server get
--
-- CTOR
--
::method init public
    expose socket connframe protocol session server,
        wtrq errq rcptq msgq,
        shutdown NL DNL X00,
        discdbg rdrdbg wtrdbg,
        rdrslt wtrslt,
        subl atrl,
        chhb srhb hbd
    use strict arg as, ch, od
    socket = as
    --
    cf = .frame~new(.stc~CONNECT, ch, "")
    -- cf~pp("Connect Frame:")
    -- say time("L") "raw data:"
    -- say time("L") cf~wirestring~c2x
    -- Write the CONNECT frame
    bw = SockSend(socket, cf~wirestring || .string~nl)
    -- say time("L") "Bytes written:" bw    
    call SysSleep(0.1)
    retc = SockRecv(socket, 'rcf', 2048)
    -- say time("L") "Return Code:" retc
    -- say time("L") "Len Received:" rcf~length
    -- say time("L") "Data Received:"
    -- say time("L") rcf
    -- say time("L") "========================="
    connframe = .frame~fromstring(rcf)
    -- connframe~pp("Connection frame")
    if connframe~command == ERROR then do
        say time("L") "ERROR from broker on CONNECT !!!"
        connframe~pp("CONNECT ERROR:")
        exit
    end
    else do
        -- say time("L") "connect complete"
        -- say time("L") "vercon:|" .stc~HK_VERSION "|"
        -- ch = connframe~hdrs
        -- ch~pp("CONNECT Frame Headers:")
        protocol = connframe~hdrs~value(.stc~HK_VERSION)
        session = connframe~hdrs~value(.stc~HK_SESSION)
        server = connframe~hdrs~value(.stc~HK_SERVER)
        -- say time("L") "protocol:" protocol
        --
        chhb = ch~value(.stc~HK_HEART_BEAT)
        srhb = connframe~hdrs~value(.stc~HK_HEART_BEAT)
    end
    --
    self~loadopts(od)
    --
    hbd~pp("Heart Beat Data:")
    --
    shutdown = .false
    --
    -- start the reader
    self~start("reader", rdrslt)
    call SysSleep 0.2
    -- start the writer
    -- say time("L") "XDBG starting writer" wtrslt
    self~start("writer", wtrslt)
    call SysSleep 0.2
    -- say time("L") "XDBG done starting writer" wtrslt

--
-- STOMP DISCONNECT
-- Required Parameters:
--      None
-- Optional Parameters:
--      Headers with a RECEIPT request
-- Returns:
--      Nothing
--
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
    if discdbg then say time("L") "disconnect close return code:" retc
    
::method writer unguarded
    expose socket wtrq shutdown wtrdbg protocol
    use strict arg wst
    -- say time("L") "XDBG wtr starts" wtrdbg wst
    if wtrdbg then say time("L") "WRITER: starts"
    lc = 0
    wfc = 0
    do forever
        lc = lc + 1 
        -- say time("L") "writer start next loop" lc
        if shutdown then leave
        --
        nxf = wtrq~pull
        if nxf == .nil then do
            -- say time("L") "writer sleeps"
            call SysSleep wst
            iterate
        end
        -- nxf~pp("In Frame writer Before Encode:")
        if protocol <> .stc~SPL_10 then do
            nxf~hdrs~encode
        end
        nxf~pp("In Frame writer After Encode:")
        wfc = wfc + 1
        nfd = nxf~wirestring
        nfd = nfd || .string~nl
        -- say time("L") "wtr frdump:" wfc "hex:" nfd~c2x
        bw = SockSend(socket, nfd)
        if wtrdbg then do
            say time("L") "WRITER: frame number" wfc "sent" bw "bytes"
        end
    end
    --
    if wtrdbg then say time("L") "WRITER: writer ends"

::method reader unguarded
    expose socket shutdown errq rcptq msgq NL DNL X00 rdrdbg,
        subl protocol
    use strict arg rst
    if rdrdbg then say time("L") "READER: reader starts"
    hbb = ""
    --
    -- The reader implementation is a state machine.
    --
    moredata = 0
    znldrain = 1
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
    resumest = znldrain
    do forever
        select
            --
            when state == moredata then do
                if rdrdbg then say time("L") "READER: state is moredata"
                if rdrdbg then say time("L") "READER: hbb md" hbb~c2x
                ret = SockRecv(socket, 'ldata', 1024)
                if ret < 1 then do
                    if ret < 0 then say time("L") 'READER: SockRecv failed:' errno
                    else say time("L") 'READER: Socket closed:' errno
                    leave
                end
                hbb = hbb || ldata
                state = resumest
                iterate
            end
            --
            when state == znldrain then do
                if rdrdbg then say time("L") "READER: state is znldrain"
                if rdrdbg then say time("L") "READER: hbb nld" hbb~c2x

                do while hbb~subchar(1) == "00"~x2c
                    if hbb~length == 1 then do
                        hbb = ""
                        state = moredata
                        resumest = znldrain
                        iterate
                    end
                    else hbb = hbb~substr(2)
                end

                do while hbb~subchar(1) == .string~nl
                    if hbb~length == 1 then do
                        hbb = ""
                        state = moredata
                        resumest = znldrain
                        iterate
                    end
                    else hbb = hbb~substr(2)
                end

                if hbb~length == 0 then do
                    state = moredata
                    resumest = znldrain
                    iterate
                end

                state = getcmd
                iterate
            end
            --
            when state == findeoh then do
                if rdrdbg then say time("L") "READER: state is findeoh"
                if rdrdbg then say time("L") "READER: hbb feoh" hbb~c2x
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
                -- headers~pp("Read Headers Before Decode:")
                -- Always decode, regardless of protocol level
                headers~decode
                -- headers~pp("Read Headers After Decode:")
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
                if rdrdbg then say time("L") "READER: state is accumbdy0"
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
                            say time("L") 'SockRecv failed:' errno
                        else
                            say time("L") 'Socket closed:' errno
                        leave
                    end
                    hbb = hbb || ldata
                    if ldata~pos(X00) > 0 then found = .true
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
                if rdrdbg then say time("L") "READER: state is sendq"
                if rdrdbg then say time("L") "READER: hbb seq" hbb~c2x
                --
                nf = .frame~new(command, headers, body)
                -- nf~pp("READER Frame Dump:")
                lcldbg = .false
                select
                    when command == .stc~ERROR then do
                        if lcldbg then say time("L") "READER: append errq"
                        errq~append(nf)
                    end
                    when command == .stc~RECEIPT then do
                        if lcldbg then say time("L") "READER: append rcptq"
                        rcptq~append(nf)
                    end
                    when command == .stc~MESSAGE then do
                        if lcldbg then say time("L") "READER: have MESSAGE"
                        msub = headers~value(.stc~HK_SUBSCRIPTION)
                        sent = subl~at(msub)
                        if sent == .nil then do
                            if lcldbg then say time("L") "READER: append msgq 1"
                            msgq~append(nf)
                        end
                        else
                            if sent~msgq == .nil then do
                                if lcldbg then say time("L") "READER: append msgq 2"
                                msgq~append(nf)
                            end
                            else do
                                if lcldbg then say time("L") "READER: append sent~msgq"
                                sent~msgq~append(nf)
                            end
                    end
                    otherwise do
                        say time("L") "READER: Error, bad frame:"
                        say time("L") "READER: Error, command:" command~c2x
                        say time("L") "READER: Error, headers:" headers~wirestring~c2x
                        say time("L") "READER: Error, body:" body~c2x
                        exit
                    end
                end
                --
                command = ""
                headers = ""
                body = ""
                fcl = .nil
                --
                state = znldrain
                iterate
            end
            --
            when state == getcmd then do
                if rdrdbg then say time("L") "READER: state is getcmd"
                if rdrdbg then say time("L") "READER: hbb gtc" hbb~c2x

                -- Need more data?
                if hbb~pos(NL) == 0 then do
                    state = moredata
                    resumest = getcmd
                    iterate
                end

                parse var hbb command (NL) hbb
                if rdrdbg then say time("L") "READER: command:" command~c2x "|" || command || "|"
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
                if rdrdbg then say time("L") "READER: state is accumbdyl"
                if rdrdbg then say time("L") "READER: hbb accl" hbb~c2x
                hbl = hbb~length
                if rdrdbg then say time("L") "READER: lens hbl" hbl "fcl" fcl
                do while hbl < fcl
                    ret = SockRecv(socket, 'ldata', 1024)
                    if ret < 1 then do
                        if ret < 0 then
                            say time("L") 'READER: SockRecv failed:' errno
                        else
                            say time("L") 'READER: Socket closed:' errno
                        leave
                    end
                    if rdrdbg then say time("L") "READER: ldata:" ldata~length ldata~c2x
                    hbb = hbb || ldata
                    hbl = hbb~length    -- Update hold back buffer length
                end
                --
                body = hbb~substr(1, fcl)
                -- Get Past body and X00
                hbb = hbb~substr(fcl + 2)
                state = sendq
                iterate
            end
        end -- select
        if shutdown then leave
    end -- forever do
    --
    if rdrdbg then say time("L") "READER: reader ends"

--
-- Public Method recverr
--
-- Required Parameters:
--      None
-- Optional Parameters:
--      An optional read wait time
-- Returns:
--      An ERROR frame or .nil.
-- Operation:
--      If the optional read wait time is not present, this method acts
--      as a polling mechanism.  If an ERROR frame is present on the 
--      internal ERROR queue it is returned immediately.  Otherwise .nil
--      is returned.
--      If the read wait time is present, this method loops until an ERROR
--      frame becomes available.  The read wait time is used to determine
--      wait time before looping again.  Be careful, this is potentially
--      an infinite loop.
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
-- Public Method recvrcpt
--
-- Required Parameters:
--      None
-- Optional Parameters:
--      An optional read wait time
-- Returns:
--      An RECEIPT frame or .nil.
-- Operation:
--      If the optional read wait time is not present, this method acts
--      as a polling mechanism.  If an RECEIPT frame is present on the 
--      internal RECEIPT queue it is returned immediately.  Otherwise .nil
--      is returned.
--      If the read wait time is present, this method loops until an ERROR
--      frame becomes available.  The read wait time is used to determine
--      wait time before looping again.  Be careful, this is potentially
--      an infinite loop.
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
-- Public Method recvmsg
--
-- Required Parameters:
--      None
-- Optional Parameters:
--      An optional read wait time
-- Returns:
--      An MESSAGE frame or .nil.
-- Operation:
--      If the optional read wait time is not present, this method acts
--      as a polling mechanism.  If an MESSAGE frame is present on the 
--      internal MESSAGE queue it is returned immediately.  Otherwise .nil
--      is returned.
--      If the read wait time is present, this method loops until an ERROR
--      frame becomes available.  The read wait time is used to determine
--      wait time before looping again.  Be careful, this is potentially
--      an infinite loop.
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
-- Public Method receive
--
-- Required Parameters:
--      None
-- Optional Parameters:
--      An optional read wait time
-- Returns:
--      An STOMP frame (ERROR, RECEIPT, MESSAGE) or .nil.
-- Operation:
--      If the optional read wait time is not present, this method acts
--      as a polling mechanism.  If a frame is present on any of the
--      internal frame queues it is returned immediately.  Otherwise .nil
--      is returned.
--      If the read wait time is present, this method loops until a
--      frame becomes available.  The read wait time is used to determine
--      wait time before looping again.  Be careful, this is potentially
--      an infinite loop.
--
::method receive
    expose errq rcptq msgq
    use arg slt
    --
    if slt == "SLT" then do
        tf = errq~pull
        if tf <> .nil then return tf
        tf = rcptq~pull
        if tf <> .nil then return tf
        tf = msgq~pull
        if tf <> .nil then return tf
        return .nil
    end
    --
    do forever
        tf = errq~pull
        if tf <> .nil then return tf
        tf = rcptq~pull
        if tf <> .nil then return tf
        tf = msgq~pull
        if tf <> .nil then return tf
        call SysSleep slt
    end

--
::method loadopts private
    expose discdbg rdrdbg wtrdbg,
        rdrslt wtrslt,
        wtrq rcptq errq msgq,
        NL DNL X00 subl atrl,
        chhb srhb hbd
    use arg sopt
    --
    ldbg = .false
    --
    wtrq = .queue~new
    errq = .queue~new
    rcptq = .queue~new
    msgq = .queue~new
    subl = .directory~new
    atrl = .directory~new
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
    if ldbg then say time("L") "discdbg:" discdbg
    --
    rdrdbg = .false
    if ho then do
        if sopt~entry("rdrdbg") <> .nil then
            rdrdbg = .true
    end
    t = value("STOMPRX_RDRDBG", "", .stc~env)
    if t <> "" then
        rdrdbg = .true
    if ldbg then say time("L") "rdrdbg:" rdrdbg
    --
    wtrdbg = .false
    if ho then do
        if sopt~entry("wtrdbg") <> .nil then
            wtrdbg = .true
    end
    t = value("STOMPRX_WTRDBG", "", .stc~env)
    if t <> "" then
        wtrdbg = .true
    if ldbg then say time("L") "wtrdbg:" wtrdbg
    --
    rdrslt = 0.2
    if ho then do
        if sopt~entry("rdrslt") <> .nil then
            rdrslt = sopt~entry("rdrslt")
    end
    t = value("STOMPRX_RDRSLT", "", .stc~env)
    if t <> "" then
        rdrslt = t
    if ldbg then say time("L") "rdrslt:" rdrslt
    --
    wtrslt = 0.2
    if ho then do
        if sopt~entry("wtrslt") <> .nil then
            wtrslt = sopt~entry("wtrslt")
    end
    t = value("STOMPRX_WTRSLT", "", .stc~env)
    if t <> "" then
        wtrslt = t
    if ldbg then say time("L") "wtrslt:" wtrslt
    --
    hbd = .hbdata~new(chhb, srhb)

--
-- Stomp SEND
-- Required Headers:
-- destination - for all STOMP protocol levels
-- Optional Headers:
-- Any user supplied header
-- Returns:
--      -1 if destination headers not present.
--      0 otherwise.
--
::method send public
    expose wtrq
    use strict arg h,b
    if h~value(.stc~HK_DESTINATION) == .nil then return -1
    sf = .frame~new(.stc~SEND, h, b)
    -- h~pp("In SEND. headers:")
    tix = wtrq~append(sf)
    -- say time("L") "send tix:" tix
    return 0

--
-- Stomp SUBSCRIBE
-- Required Parameters:
--      subscribe headers
-- Optional Parameters:
--      A user supplied queue.  Received MESSAGE frames will be placed on
--      this queue (if it is present)
-- Required Headers:
-- destination - for all STOMP protocol levels
-- id - for protocol levels 1.1 and 1.2
-- Optional Headers:
-- ack - for all protocol levels
-- Returns:
--      -1 if subscribe headers not present.
--      -2 if no destination header is present
--      -3 if no id header is present and the protocol level is not 1.0
-- Operation:
--      Parameters are checked.
--      A subscription instance is created and added to the active 
--      subscrption map.
--      The subscribe frame is sent to the broker.
--
::method subscribe public
    expose wtrq protocol subl
    use arg sh,ocbq
    --
    if sh == "SH" then return -1
    if sh~value(.stc~HK_DESTINATION) == .nil then return -2
    lid = sh~value(.stc~HK_ID)
    if protocol <> .stc~SPL_10 then do
        if lid == .nil then return -3
    end
    else do
        -- Proto 1.0
        if lid == .nil then do
            lid = .uuid~get
            ih = .header~new(.stc~HK_ID, lid)
            sh~add(ih)
        end
    end
    --
    -- say time("L") "lid" lid lid~class

    if ocbq == "OCBQ" then do
        nsub = .subscription~new(sh)
        subl~put(nsub, lid)
        -- say time("L") "No OCBQ, lid:" lid
    end
    else do
        nsub = .subscription~new(sh, ocbq)
        subl~put(nsub, lid)
        -- say time("L") "Have OCBQ, lid:" lid
    end
    sf = .frame~new(.stc~SUBSCRIBE, sh, "")
    tix = wtrq~append(sf)
    --
    return 0

--
-- Stomp UNSUBSCRIBE
-- Required Parameters:
--      unsubscribe headers
-- Required Headers:
-- destination - for all STOMP protocol levels
-- id - for all protocol levels (including 1.0)
-- Optional Headers:
-- none
-- Returns:
--      -1 if unsubscribe headers not present.
--      -2 if no destination header is present.
--      -3 if no id header is present.
--      -4 if the subscription does not currently exist
--      0 otherwise
--
::method unsubscribe public
    expose wtrq protocol subl
    use arg ush
    --
    if ush == "USH" then return -1
    if ush~value(.stc~HK_DESTINATION) == .nil then return -2
    lid = ush~value(.stc~HK_ID)
    if  lid == .nil then return -3
    tsub = subl~at(lid)
    if tsub == .nil then return -4
    t = subl~remove(lid)
    --
    sf = .frame~new(.stc~UNSUBSCRIBE, ush, "")
    tix = wtrq~append(sf)
    --
    return 0

-- Call this if you cannot use DISCONNECT
::method shutdown
    expose socket shutdown
    shutdown = .true
    retc = SockClose(socket)

--
-- Stomp BEGIN
-- Required Parameters:
--      begin headers
-- Required Headers:
-- transaction - all protocol levels
-- Returns:
--      -1 if begin headers not present.
--      -2 if the transaction already exists
--      0 otherwise
--
::method begin public
    expose wtrq atrl
    use strict arg h
    tid = h~value(.stc~HK_TRANSACTION)
    if  tid == .nil then return -1
    isact = atrl~at(tid)
    if isact == .true then return -2
    sf = .frame~new(.stc~BEGIN, h, "")
    tix = wtrq~append(sf)
    atrl~put(.true, tid)
    return 0

--
-- Stomp COMMIT
-- Required Parameters:
--      commit headers
-- Required Headers:
-- transaction - all protocol levels
-- Returns:
--      -1 if commit headers not present.
--      -2 if the transaction does not exist
--      0 otherwise
--
::method commit public
    expose wtrq atrl
    use strict arg h
    tid = h~value(.stc~HK_TRANSACTION)
    if  tid == .nil then return -1
    t = atrl~at(tid)
    if t == .nil then return -2
    --
    sf = .frame~new(.stc~COMMIT, h, "")
    t = wtrq~append(sf)
    t = atrl~remove(tid)
    return 0

--
-- Stomp ABORT
-- Required Parameters:
--      abort headers
-- Required Headers:
-- transaction - all protocol levels
-- Returns:
--      -1 if abort headers not present.
--      -2 if the transaction does not exist
--      0 otherwise
--
::method abort public
    expose wtrq atrl
    use strict arg h
    tid = h~value(.stc~HK_TRANSACTION)
    if  tid == .nil then return -1
    t = atrl~at(tid)
    if t == .nil then return -2
    sf = .frame~new(.stc~ABORT, h, "")
    t = wtrq~append(sf)
    t = atrl~remove(tid)
    return 0

--
-- Stomp ACK
-- Required Parameters:
--      ack headers
-- Required Headers:
-- Protocol Level 1.0 -
--  message-id - match the message being ACKd
-- Protocol Level 1.1 -
--  message-id - match the message being ACKd
--  subscription - the value of the subscriptions id header
-- Protocol Level 1.2 -
--  id - matching the ack header of the message being ACKd
-- Returns:
--      -1 if protocol is 1.0 and no message-id header is present
--      -2 if protocol is 1.1 and no message-id header is present
--      -3 if protocol is 1.1 and no subscription header is present
--      -4 if protocol is 1.2 and no id header is present
--
::method ack public
    expose wtrq protocol
    use strict arg h
    --
    select
        when protocol == .stc~SPL_10 then do
            if h~value(.stc~HK_MESSAGE_ID) == .nil then return -1
        end
        when protocol == .stc~SPL_11 then do
            if h~value(.stc~HK_MESSAGE_ID) == .nil then return -2
            if h~value(.stc~HK_SUBSCRIPTION) == .nil then return -3
        end
        when protocol == .stc~SPL_12 then do
            if h~value(.stc~HK_ID) == .nil then return -4
        end
    end
    sf = .frame~new(.stc~ACK, h, "")
    tix = wtrq~append(sf)
    return 0

--
-- Stomp NACK
-- Required Parameters:
--      nack headers
-- Required Headers:
-- Protocol Level 1.0 -
--  N/A
-- Protocol Level 1.1 -
--  message-id - match the message being NACKd
--  subscription - the value of the subscriptions id header
-- Protocol Level 1.2 -
--  id - matching the ack header of the message being NACKd
-- Returns:
--      -1 if protocol is 1.0
--      -2 if protocol is 1.1 and no message-id header is present
--      -3 if protocol is 1.1 and no subscription header is present
--      -4 if protocol is 1.2 and no id header is present
--
::method nack public
    expose wtrq protocol
    use strict arg h
    --
    select
        when protocol == .stc~SPL_10 then do
            return -1
        end
        when protocol == .stc~SPL_11 then do
            if h~value(.stc~HK_MESSAGE_ID) == .nil then return -2
            if h~value(.stc~HK_SUBSCRIPTION) == .nil then return -3
        end
        when protocol == .stc~SPL_12 then do
            if h~value(.stc~HK_ID) == .nil then return -4
        end
    end
    sf = .frame~new(.stc~NACK, h, "")
    tix = wtrq~append(sf)
    return 0

::requires 'rxsock' LIBRARY
/* Watch this.  Order is important. */
::requires "uuid.cls"
::requires "stc.cls"
::requires "header.cls"
::requires "headers.cls"
::requires "strutls.rex"
::requires "frame.cls"
::requires "subscription.cls"
::requires "hbdata.cls"
::requires "netconn.cls"
