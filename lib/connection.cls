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
::attribute protocol get
::attribute session get
::attribute server get
--
-- CTOR
--
::method init public
    expose edd socket connframe protocol session server
    use strict arg as, ch, od
    socket = as
    if \ch~isA(.headers) then do
        say "ch (parameter 2) must be a .headers instance"
        return .nil
    end
    if \od~isA(.directory) then do
        say "od (parameter 3) must be a .directory instance"
        return .nil
    end
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

::requires 'rxsock' LIBRARY
::requires "headers.cls"
::requires "frame.cls"
::requires "strutls.rex"
::requires "stc.cls"