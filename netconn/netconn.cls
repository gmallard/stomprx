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
--
-- Net Connection Helper
--
::class netConn public
--
-- Get and return a streaming network Connection
--
::method open public class
    use strict arg propfile

    -- Defaults
    ahost = "127.0.0.1"
    aport = '61613'

    -- Overrides from properties file
    if propfile \= .nil then do
        if .strutls~isFile(propfile) then do
            mp = .properties~load(propfile)
            th = mp~getProperty("host", "")
            if th \= "" then
                ahost = th
            tp = mp~getProperty("port", "")
            if tp \= "" then
                aport = tp
        end
    end

    -- Overrides from the environment
    x = value("STOMP_HOST",,"ENVIRONMENT")
    if x \= "" then
        ahost = x
    x = value("STOMP_PORT",,"ENVIRONMENT")
    if x \= "" then
        aport = x

    --
    /*  create a socket  */
    socket = SockSocket('AF_INET', 'SOCK_STREAM', 'IPPROTO_TCP')

    /*  specify the host we will connect to  */
    host.!family = 'AF_INET'
    host.!addr = ahost
    host.!port = aport

    -- say "host:" ahost
    -- say "port:" aport

    /*  connect to the server  */
    if SockConnect(socket, 'host.!') < 0 then do
        say 'SockConnect failed:' errno
        return .nil
    end
    --
    return socket
--

::requires "../lib/strutls.rex"
::requires 'rxsock' LIBRARY
