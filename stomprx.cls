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
        shutdown
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
    bw = SockSend(socket, cf~wirestring)
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
    wtrq = .queue~new
    errq = .queue~new
    rcptq = .queue~new
    msgq = .queue~new

    -- start the writer
    shutdown = .false
    self~start("writer", 0.2)

::method disconnect public
    expose socket wtrq shutdown
    use arg odh
    --
    if odh == "ODH" then
        useh = .headers~new
    else
        useh = odh
    --
    df = .frame~new(.stc~DISCONNECT, useh, "")
    in = wtrq~append(df) -- send frame to writer
    call SysSleep 0.4
    shutdown = .true
    --
    retc = SockClose(socket)
    -- say "close return code:" retc
    
::method writer unguarded
    expose socket wtrq shutdown
    use strict arg wst
    dbg = .false
    if dbg then say "writer starts"
    lc = 0
    wfc = 0
    do forever
        lc = lc + 1 
        -- say "writer start next loop" lc
        if shutdown then leave
        nxf = wtrq~pull
        if nxf == .nil then do
            -- say "writer sleeps"
            call SysSleep wst
            iterate
        end
        wfc = wfc + 1
        nfd = nxf~wirestring
        bw = SockSend(socket, nfd)
        if dbg then do
            say "frame number" wfc "sent" bw "bytes"
        end
    end
    --
    if dbg then say "writer ends"

::requires 'rxsock' LIBRARY
/* Watch this.  Order is important. */
::requires "stc.cls"
::requires "header.cls"
::requires "headers.cls"
::requires "strutls.rex"
::requires "frame.cls"
::requires "netconn.cls"
